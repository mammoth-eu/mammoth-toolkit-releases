# MAMMOth Bias Toolkit

*Alpha version.*

This is a toolkit for the exploration of bias in AI systems and create recommendations for fairer system creation. You can set it up either locally or in your organization's server for developers to access it remotely.
The toolkit can load a broad range of datatypes (e.g., tabular, graph, vision) and models, and can analyze them with a variety of tools.
Loader and analysis modules are dockerized components to ensure independent execution. This repository holds the main toolkit's implementation only; an overview of components implemented by the MAMMOth consortium can be found in the [mammoth-commons catalogue](https://github.com/mammoth-eu/mammoth-commons/tree/dev/catalogue). There, you will also find the component build process and instructions on how to generate custom ones, for example to handle your own proprietary data.

## Status

- [ ] Integration of MAMMOth's technical components: 1/6
- [X] User management: keycloack, shared KFP instance
- [X] Secure API: krackend
- [X] Toolkit dockerized and KFP in local K3D instance
- [ ] Protected characteristics: fixed through the lists
- [X] Installation: scripts
- [X] Tested: Linux, WSL
- [ ] Debugging: pipeline result may not be available always to toolkit
- [ ] Bias analysis pipelines: 1/2 (missing dataset bias analysis)

## Installation

You will be guided to install the prerequisite software for the Mammoth toolkit to run. All scripts can be found in the *scripts/* folder.

[Step 1: Docker](#step-1-docker)<br>
[Step 2: K3D](#step-2-k3d)<br>
[Step 3: KFP](#step-3-kfp)<br>
[Step 4: Toolkit Startup](#step-4-toolkit-startup)<br>
[Links](#links)

### Step 1: Docker

Install Docker only if it is **not** already installed. On Windows enable WSL and install Docker Desktop instead.

```bash
chmod +x docker_install.sh  # make the script executable
./docker_install.sh
```

</details>


### Step 2: K3D

Install Kubectl (Kubernetes - Command line tool) and the K3D mini Kubernetes distribution if the latter **not** already installed. 
K3D is a lightweight wrapper to run K3S (Rancher Lab’s minimal Kubernetes
distribution) in docker. Tested with UBUNTU based OS but it could work also for other linux
distributions. The docker engine must be installed *and active*.

```bash
chmod +x k3d_install.sh
./k3d_install.sh
k3d cluster create kfp  # create a K3D cluster
```

### Step 3: KFP

Install KFP (Kubeflow Pipelines) standalone version 2+ if **not** already installed. 
The K3D cluster needs to be running already.
Tested with K3D cluster but it should work with other Kubernetes
distributions also. The toolkit maked use of the KFP Python SDK to
compile pipelines to an intermediate representation YAML. These pipelines are submitted
to run on a KFP-conformant backend such as the open source KFP backend
or Google Cloud Vertex AI Pipelines.

```bash
chmod +x kfp_install.sh
./kfp_install.sh
```

<details>
<summary>Track progress</summary>
<br>

When the above script completes, the Kubeflow pipelines deployment procedure starts by itself.
It takes some time to be ready as many things need to be downloaded and
configured during the deployment. Check deployment status with:

```bash
kubectl -n kubeflow get pods
```

Kubeflow pipelines will be ready when all pods are in ready state.
Afterwards,  access the Kubeflow Pipelines interface availabe at
localhost:8080 by running:

```bash
kubectl port-forward --address 0.0.0.0 svc/ml-pipeline-ui 8010:80 -n kubeflow
kubectl port-forward --address 0.0.0.0 svc/ml-pipeline-ui 8010:80 -n kubeflow
```
</details>



### Step 4: Toolkit startup

Before proceeding please create an *.env* on the top level folder, if it does not already exists.
Make sure that K3D with KFP installed is up and running and that the port
forward to KFP is active. In this same top-level folder run the command

```bash
docker compose up -d
```

Wait until the system loads. The toolkit is available at the following URL in your browser: http://localhost:5173

<details>
<summary>Create a new user at: http://keycloak.local.exus.ai:8080 </summary>
<br>

Visit the following URL in your browser to create a user

```url
http://keycloak.local.exus.ai:8080
```

Login with the credentials provided in the .env file
for KEYCLOAK_ADMIN_USER and KEYCLOAK_ADMIN_PASSWORD

- Select from the dropdown at the left the option **toolkit**
- Select **Users** from the menu
- Click on **Add user**
- Fill in the details (username, email, firstname, lastname) and click on **Create**
- Click on the **Credentials** tab and set a password
- Turn off the **Temporary** switch
- Save the password

</details>



<details>
<summary>Default .env contents</summary>
<br>

```env
COMPOSE_PROJECT_NAME=mammoth_kk

KEYCLOAK_POSTGRES_USER=mammoth_kc_db_user
KEYCLOAK_POSTGRES_PASSWORD=mammoth_kc_db_pass
KEYCLOAK_POSTGRES_DATABASE=mammoth_kc_db
KEYCLOAK_HOSTNAME=keycloak.local.exus.ai
KEYCLOAK_ADMIN_USER=kc_admin
KEYCLOAK_ADMIN_PASSWORD=kc_admin_pass
KEYCLOAK_LOGLEVEL=INFO
KC_HEALTH_ENABLED=true
KC_METRICS_ENABLED=true
API_POSTGRES_USER=mammoth_api_db_user
API_POSTGRES_PASSWORD=mammoth_api_db_pass
API_POSTGRES_DATABASE=mammoth_api_db
API_POSTGRES_HOST=api-db
API_POSTGRES_PORT=5432

VITE_KEYCLOAK_URL=http://keycloak.local.exus.ai:8080
VITE_KEYCLOAK_CLIENT_ID=kraken
VITE_KEYCLOAK_REALM=toolkit
VITE_LOGOUT_REDIRECT_URI=http://localhost:5173
VITE_BACKEND_URL=http://krakend.local.exus.ai:8081
```
</details>


### Links


[Docker Engine](https://docs.docker.com/engine/)<br>
[K3D](https://k3d.io/)<br>
[K3S](https://github.com/k3s-io/k3s)<br>
[Kubectl](https://kubernetes.io/docs/reference/kubectl/)<br>
[Kubeflow Pipelines](https://www.kubeflow.org/docs/components/pipelines/v2/)<br>
[KFP GitHub](https://github.com/kubeflow/pipelines)

