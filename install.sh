#!/bin/bash

# This script presents a full pipeline for installing, validating, and running the MAMMOth toolkit.
# WARNING: This is only partially tested.
# Preferred way of running this (e.g., in WSL): `sudo bash install.sh`
# 
# Requirements checked on startup: 
# 1. Being in Linux OR enabling WSL and having docker desktop installed in Windows
# 2. Being in the same directory as a .env file

function clone_repo() {
    # Pre-step: Ensure we are in the right directory
    if [ -d "scripts" ]; then
        echo -n "Assuming already valid directory ('scripts/' is here)"
        echo -e "\033[32mOK\033[37m"
    elif [ -d "mai_bias" ]; then
        echo -n "Using cached 'mai_bias/' "
        cd mai_bias || { echo "\033[31mFailed to cd\033[37m"; exit 1; }
        echo -e "\033[32mOK\033[37m"
    else
        git clone https://github.com/mammoth-eu/mammoth-toolkit-releases mai_bias || { echo "Failed to clone repo"; exit 1; }
        cd mai_bias || { echo "\033[31mFailed to cd after git clone\033[37m"; exit 1; }
        echo -n "Using cloned 'mai_bias/' "
        echo -e "\033[32mOK\033[37m"
    fi
}

function check_environment() {
	echo -n "Environment " 
    if [[ -d "/mnt/c/Windows" ]]; then
        return
    elif [[ -d "/cygdrive/c/Windows" || -d "/c/Windows" ]]; then
		# indicates Cygwin or Git Bash
		echo "\033[31mUnsupported\033[37mPlease enable WSL if you are on Windows."
        exit 1
    elif [[ "$OS" == "Windows_NT" ]]; then
        # indicates MSYS2 or Git Bash
		echo "\033[31mUnsupported\033[37mPlease enable WSL if you are on Windows."
        return 1
    else
        return
    fi
}

function is_wsl() {
    grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null
    return $?
}

function install_docker_desktop() {
    echo "WSL detected."
    echo -n "Docker Desktop "
    # Check if Docker Desktop is running
    if ! [ -x "$(command -v docker)" ]; then
        echo -e "\033[31mNot found.\033[37mMake sure that Docker Desktop for Windows is installed and running."
        exit 1
    fi
}

function install_docker_linux() {
    echo "Non-WSL environment."
    echo -n "Docker "
	
	# Check if Docker is already installed
    if [ -x "$(command -v docker)" ]; then
        return
    fi
	
	echo -e "\033[33mInstalling\033[37m"

    # Update the apt package index
    sudo apt-get update -y

    # Install packages to allow apt to use a repository over HTTPS
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker’s official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Set up the stable repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y # Update the apt package index again
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io # Install the latest version of Docker Engine and containerd
    sudo docker run hello-world # Verify that Docker Engine is installed correctly by running the hello-world image
    sudo usermod -aG docker $USER # Add the current user to the docker group so you can run docker without sudo
}

function install_k3d() {
    echo -n "k3d "
	
    # Check if k3d is already installed
    if [ -x "$(command -v k3d)" ]; then
        return
    fi
	echo -e "\033[33mInstalling\033[37m"

    # Get kubectl for Kubernetes management
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

    # Validate binary
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    read -p "Make sure that the validation check was OK, and press enter to continue, otherwise stop the script CTRL+C and restart it" input

    # Install kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    # Check successful installation
    kubectl version --client

    # Install k3d
    echo "Starting k3d installation"
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
}

function create_kfp_cluster() {
    echo -n "kfp cluster "

    # Check if the k3d cluster already exists
    if k3d cluster list | grep -q 'kfp'; then
        return
    fi
	echo -e "\033[33mCreating\033[37m"

    # Create the k3d cluster
    k3d cluster create kfp --api-port 6550 -p "8082:80@loadbalancer" --agents 1
}

function check_env_file() {
    ENV_FILE=".env"
    echo -n ".env file "
    # Check if the .env file exists
    if [ -f "$ENV_FILE" ]; then
        echo -e "\033[32mOK\033[37m"
    else
        echo -e "\033[31mNot found. Please create it before proceeding.\033[37m"
        exit 1
    fi
}

function install_kfp() {
    echo -n "kfp "
    # Check if Kubeflow Pipelines is installed by looking for a specific resource
    if true; then
        return 0
    fi
    echo -e "\033[33mInstalling\033[37m"
	
    export PIPELINE_VERSION=2.2.0

    kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=$PIPELINE_VERSION"
    kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io
    kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=$PIPELINE_VERSION"
    # Add needed KFP ingress for toolkit communication
    kubectl apply -f ./scripts/kfp_ingress.yaml
    # Add needed Minio ingress for toolkit communication
    kubectl apply -f ./scripts/minio/internal-minio-ingress.yaml
}
	
# Function to check if all pods are running and ready
function all_pods_running_and_ready() {
  local pod_info
  kubectl -n "$NAMESPACE" get pods --no-headers
  pod_info=$(kubectl -n "$NAMESPACE" get pods --no-headers)

  # Check if all pods are in the Running state and all containers are ready
  echo "$pod_info" | while read -r line; do
    status=$(echo "$line" | awk '{print $3}')
    ready=$(echo "$line" | awk '{print $2}')

    # Check if pod is not in Running state or not all containers are ready
    if [ "$status" == "Creating" ]; then
      return 0
    fi
  done

  return 1
}

function wait_for_pods() {
	while true; do
	  echo -n "KubeFlow pods "
	  if true; then
        return
	  fi
	  echo -e "\033[33mCreating\033[37m (sleep for 20 secs - for details ctrl+C and monitor with: kubectl -n kubeflow get pods)"
	  sleep 20
	done
}


function config_core_dns() {
    echo "Retrieving current NodeHosts..."
    NODEHOSTS=$(kubectl get configmap coredns -n kube-system -o jsonpath='{.data.NodeHosts}')
    echo "Current NodeHosts:"
    echo "$NODEHOSTS"
    HOST_EXISTS=false
    UPDATED_NODEHOSTS=""
    while IFS= read -r line; do
      if [[ $line =~ "host.k3d.internal" ]]; then
        # Update the IP address if host.k3d.internal exists
        IP=$(echo "$line" | awk '{print $1}')
        NEW_IP=$(echo "$IP" | awk -F '.' '{print $1"."$2"."$3".1"}')
        UPDATED_NODEHOSTS+="$NEW_IP host.k3d.internal"$'\n'
        HOST_EXISTS=true
      else
        UPDATED_NODEHOSTS+="$line"$'\n'
      fi
    done <<< "$NODEHOSTS"
    if [ "$HOST_EXISTS" = false ]; then
      # If host.k3d.internal does not exist, add a new entry
      IPS=()
      while IFS= read -r line; do
        IP=$(echo "$line" | awk '{print $1}')
        if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          IPS+=("$IP")
        fi
      done <<< "$NODEHOSTS"

      if [ ${#IPS[@]} -gt 0 ]; then
        NEW_IP=$(echo "${IPS[0]}" | awk -F '.' '{print $1"."$2"."$3".1"}')
      else
        NEW_IP='172.21.0.1'  # Default IP if no existing IPs
      fi
      UPDATED_NODEHOSTS+="$NEW_IP host.k3d.internal"$'\n'
    fi
    echo "\nUpdated NodeHosts:"
    echo "$UPDATED_NODEHOSTS"
    TEMP_FILE="updated_coredns.yaml"
cat <<EOF > "$TEMP_FILE"
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  NodeHosts: |
$(echo "$UPDATED_NODEHOSTS" | sed 's/^/    /')
EOF
    echo "Applying updated ConfigMap..."
    kubectl apply -f "$TEMP_FILE"
    rm -f "$TEMP_FILE"
    echo "Done!"
}


function update_modules() {
    echo "Stopping running instance..."
    docker compose down
    URL="https://github.com/mammoth-eu/mammoth-commons/releases/latest/download/module_yamls.tar.gz"
    OUTPUT_FILE="module_yamls.tar.gz"
    EXTRACT_DIR="modules"
    echo "Downloading module configurations from mammoth-commons..."
    if ! curl -L -o "$OUTPUT_FILE" "$URL"; then
        echo "\033[31mFailed to download '$URL'\033[37m"; return
    fi
    mkdir -p "$EXTRACT_DIR"
    echo -n "Extracting "
    if ! tar -xzf "$OUTPUT_FILE" -C "$EXTRACT_DIR"; then
        echo "\033[31mFailed to extract ''$OUTPUT_FILE'\033[37m"; exit 1
    fi

    if [ ! -d "$EXTRACT_DIR/yamls" ]; then
        echo "\033[31m''$EXTRACT_DIR/yamls/' not found\033[37m"; exit 1
    fi
    mkdir -p components_yaml components_metadata
    rm -rf components_yaml/* components_metadata/*
    [ -d "$EXTRACT_DIR/yamls/data" ] && cp -r "$EXTRACT_DIR/yamls/data/"* components_yaml/ || echo "\033[31mData directory not found\033[37m "
    [ -d "$EXTRACT_DIR/yamls/meta" ] && cp -r "$EXTRACT_DIR/yamls/meta/"* components_metadata/ || echo "\033[31mMeta directory not found\033[37m "
    rm -rf "$EXTRACT_DIR" "$OUTPUT_FILE"
    echo -e "\033[32mOK\033[37m"
}


install_minio() {
    MINIO_ALIAS="minio"
    MINIO_ENDPOINT="http://kfp-minio.local.exus.ai:8082"
    MINIO_ACCESS_KEY="minio"
    MINIO_SECRET_KEY="minio123"
    BUCKET_NAME="data"
    kubectl apply -f ./scripts/minio/internal-minio-ingress.yaml
    if [ ! -x "./mc" ]; then
        echo "Downloading mc client..."
        curl -sSL https://dl.min.io/client/mc/release/linux-amd64/mc -o ./mc
        chmod +x ./mc
    fi
    if ! ./mc alias list | grep -q "^$MINIO_ALIAS"; then
        echo "Setting alias '$MINIO_ALIAS' "
        ./mc alias set $MINIO_ALIAS $MINIO_ENDPOINT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
    else
        echo -n "Existing alias '$MINIO_ALIAS' "
    fi
    echo -e "\033[32mOK\033[37m"
    if ./mc ls $MINIO_ALIAS/$BUCKET_NAME >/dev/null 2>&1; then
        echo -n "MinIO bucket '$MINIO_ALIAS/$BUCKET_NAME' "
    else
        echo "Setting up bucket..."
        ./mc mb $MINIO_ALIAS/$BUCKET_NAME
        ./mc anonymous set download $MINIO_ALIAS/$BUCKET_NAME
        echo "MinIO bucket '$MINIO_ALIAS/$BUCKET_NAME' "
    fi
    echo -e "\033[32mOK\033[37m"
}

function draw_mammoth() {
echo -e "\033[90m"
cat << "EOF"
          _.-- ,.--.
        .'   .'      /
        | @       |'..--------._
       /      \._/              '.
      /  .-.-                     \
     (  /    \                     \
     \\      '.                  | #
      \\       \   -.           /
       :\       |    )._____.'   \
        "       |   /  \  |  \    )
                |   |./'  :__ \.-'
                '--'
EOF
echo -e "\033[37m"
}

function draw_mammoth_front() {
echo -e "\033[90m"
cat << "EOF"                                                                             
                                                                                
              @@@@@@@@@@@   @@@@@   @@@@@@@@@@@
         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@
     @@@@@@@@@@@@@@  @@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@@@@@
      @@@@@@@@@@@@   %@@@@@@@@ @@@@@@@@@   @@@@@@@@@@@@
       @@@@@@@@@@@    @@@@@@@@ @@@@@@@@     @@@@@@@@@@
        @@@@@@@@@      @@@@@@@ @@@@@@@      @@@@@@@@@
          @@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@
            @@@@        @@@@@@ @@@@@@@       @@@@@
              @@@      @@@@@@@ @@@@@@@@     @@@
                 @@@@@@@@@@@@@ @@@@@@@@@@@@@
                        @@@@@@ @@@@@@
                      @@@@ @@@ @@@@@@@
                     @@@@  @@@ @@@  @@@@
                  @@@@      @@ @@@     @@@@
                            @@ @@
                            @@ @@
                            @@ @@
                             @ @

EOF
echo -e "\033[37m"
}



echo -e "\n\033[36m================ MAI-BIAS INSTALL ================ \033[37m"
echo -e "\033[37mThis is the \033[36mMAI-BIAS\033[37m toolkit's install&run script. If"
echo -e "there is an \033[31merror\033[37m, please address it and rerun the script."
echo "An unstable internet connection may also create installation"
echo "failures. In this case, too, rerun this. Report bugs at: "
echo -e "\033[33mhttps://github.com/mammoth-eu/mammoth-toolkit-releases\033[0m"
draw_mammoth

echo -e "\n\033[36m========= Step 1/4: Requirements\033[37m"
clone_repo
check_environment
echo -e "\033[32mOK\033[37m"
check_env_file
if is_wsl; then
    install_docker_desktop
else
    install_docker_linux
fi
echo -e "\033[32mOK\033[37m"

echo -e "\n\033[36m========= Step 2/4: Kubernetes (K3D, KFP, MinIO)\033[37m"
install_k3d
echo -e "\033[32mOK\033[37m"
create_kfp_cluster
echo -e "\033[32mOK\033[37m"
install_kfp
echo -e "\033[32mOK\033[37m"
wait_for_pods
echo -e "\033[32mOK\033[37m"
install_minio


echo -e "\n\033[36m========= Step 3/4: Update modules\033[37m"
update_modules

# echo -e "\n\033[36m========= Step 4/5: Kubeflow Pipelines CoreDNS config\033[37m"
# config_core_dns
# echo -e "\033[32mOK\033[37m"

echo -e "\n\033[36m========= Step 4/4: Start\033[37m"
# docker compose down  # stopped in update
k3d cluster start kfp
docker compose up -d


echo -e "\n\033[36m================ MAI-BIAS RUNNING ================ \033[37m"
echo -e "The MAMMOth project's modules and local runner:\n\033[33mhttps://github.com/mammoth-eu/mammoth-commons\033[37m\n"
echo -e "Stop command: \033[33msource stop_toolkit.sh\033[37m"
echo -e "MAI-BIAS frontent: \033[33mhttp://localhost:5173\033[37m"
echo -e "Default credentials: User \033[33mdemo\033[37m, Pass \033[33mdemo\033[37m"
draw_mammoth_front
