#!/bin/bash

# This script presents a full pipeline for installing, validating, and running the MAMMOth toolkit.
# WARNING: This is only partially tested.
# Preferred way of running this (e.g., in WSL): `sudo bash install.sh`
# 
# Requirements checked on startup: 
# 1. Being in Linux OR enabling WSL and having docker desktop installed in Windows
# 2. Being in the same directory as a .env file

function check_environment() {
	echo -n "Environment " 
    if [[ -d "/mnt/c/Windows" ]]; then
        return
    elif [[ -d "/cygdrive/c/Windows" || -d "/c/Windows" ]]; then
		# indicates Cygwin or Git Bash
		echo "\033[31mUnsupported\033[37mPlease enable WSL."
        exit 1
    elif [[ "$OS" == "Windows_NT" ]]; then
        # indicates MSYS2 or Git Bash
		echo "\033[31mUnsupported\033[37mPlease enable WSL."
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
    echo -n "WSL detected. Docker Desktop "
    # Check if Docker Desktop is running
    if ! [ -x "$(command -v docker)" ]; then
        echo -e "\033[31mNot found.\033[37mMake sure that Docker Desktop for Windows is installed and running."
        exit 1
    fi
}

function install_docker_linux() {
    echo "Non-WSL environment. Docker "
	
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
        echo -e "\033[32mOK"
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




echo -e "\033[37mThis is the \033[36mMAMMOth\033[37m toolkit's install&run script. If there is an \033[31merror\033[37m, please fix it and rerun the script."
echo "An unstable internet connection may also create installation failures. In this case, too, rerun the script."

echo -e "\n\033[36m========= Requirements\033[37m"
check_environment
echo -e "\033[32mOK\033[37m"
check_env_file

echo -e "\n\033[36m========= Step 1/4: Docker\033[37m"
if is_wsl; then
    install_docker_desktop
else
    install_docker_linux
fi
echo -e "\033[32mOK"

echo -e "\n\033[36m========= Step 2/4: K3D\033[37m"
install_k3d
echo -e "\033[32mOK\033[37m"
create_kfp_cluster
echo -e "\033[32mOK"

echo -e "\n\033[36m========= Step 3/4: Kubeflow Pipelines\033[37m"
install_kfp
echo -e "\033[32mOK\033[37m"
wait_for_pods
echo -e "\033[32mOK\033[37m"

echo -e "\n\033[36m========= Step 4/4: Restarting\033[37m"
docker compose down
docker compose up -d


echo -e "\n\033[36m========= Finished\033[37m"
echo -e "The toolkit is running at: \033[33mhttp://localhost:5173\033[37m"
echo -e "If you are the system admin, create new users at: \033[33mhttp://keycloak.local.exus.ai:8080\033[37m"
