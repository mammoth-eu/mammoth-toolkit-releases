# Mammoth toolkit installation steps

## Info

This readme will guide you to the prerequisites and the installation steps of
the Mammoth toolkit.

All the required scripts can be found in the scripts folder.

## Step 1: Docker

**Important:** This step should be performed only once if docker is not already
installed

Just run

```bash
./docker_install.sh
```

In case the script is not executable please run the command

```bash
chmod +x docker_install.sh
```

and then run it.

## Step 2: K3D

**Important:** This step should be performed only once if K3D is not already
installed

The k3d_install.sh script installs K3d mini Kubernetes distribution on a linux
environment. Tested with UBUNTU based OS but it could work also for othe linux
distributions.

k3d is a lightweight wrapper to run k3s (Rancher Lab’s minimal Kubernetes
distribution) in docker.

k3d makes it very easy to create single- and multi-node k3s clusters in docker,
e.g. for local development on Kubernetes.

### Requirements

Before running this script the following requirements must be met:

- Docker engine installed and active

### Usage

Just run

```bash
./k3d_install.sh
```

In case the script is not executable please run the command

```bash
chmod +x k3d_install.sh
```

and then run it.

### What will be installed

This script will install the following tools:

- Kubectl (Kubernetes - Command line tool)
- K3D (mini kubernetes distribution)

## Step 3: KFP

**Important:** This step should be performed only once if KFP is not already
installed

The kfp_install.sh script installs Kubeflow Pipelines standalone on a linux
environment. Tested with K3D cluster but it should work with other Kubernetes
distributions also.

Kubeflow Pipelines (KFP) is a platform for building and deploying portable and
scalable machine learning (ML) workflows using Docker containers.

With KFP you can author components and pipelines using the KFP Python SDK,
compile pipelines to an intermediate representation YAML, and submit the
pipeline to run on a KFP-conformant backend such as the open source KFP backend
or Google Cloud Vertex AI Pipelines.

### Requirements

Before running this script the following requirements must be met:

- Docker engine installed and active
- K3D installed and active (if you are using k3d)
- At least one Kubernetes cluster active
- kubectl installed

If you just installed K3d you can create a Kubernetes cluster by running the
following command

```bash
k3d cluster create kfp
```

After the creation of the cluster you are ready to run this script.

### Usage

Just run

```bash
./kfp_install.sh
```

In case the script is not executable please run the command

```bash
chmod +x kfp_install.sh
```

and then run it.

When this script completes the Kubeflow pipelines deployment procedure started
but it takes some time to be ready as many things need to be downloaded and
configured during the deployment.

You can check the status of the deployment with the following command:

```bash
kubectl -n kubeflow get pods
```

Kubeflow pipelines will be ready when all pods, are in ready state.

When everything is ready, to access the Kubeflow Pipelines interface availabe at
localhost:8080 please run

```bash
kubectl port-forward -n kubeflow svc/ml-pipeline-ui 8080:80
```

### What will be installed

This script will install the following:

- Kubeflow Pipelines standalone version 2+


## Step: 4 Mammoth toolkit startup

Before proceeding please create a file named .env, if not already exists, with the following contents.

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



Make sure that K3D with KFP installed is up and running Make sure that the port
forward to KFP is active.

In this folder run the command

```bash
docker compose up -d
```

Wait until the system loads.

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


Visit the following URL in your browser

```url
http://localhost:5173
```

Login with the user and the credentials you created.


Instructions on how to run the pipeline can be found at [FairbenchRun.md](./FairbenchRun.md)


## Status

- Supporting the fairbench components
- User management through keycloack
- Secure API with krackend
- All users use the same KFP instance
- Toolkit dockerized and KFP in local K3D instance
- Protected characteristics fixed through the lists
- Scripts for installation
- Script for container registry with credentials
- Toolkit tested under linux (and WSL)
- Pipeline result may not be available always to toolkit
- Only model exploration flow is operational with fairbench modules
- Not all buttons work in the runs screen


## Links

- [Docker Engine](https://docs.docker.com/engine/)
- [K3D](https://k3d.io/)
- [K3S](https://github.com/k3s-io/k3s)
- [Kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [Kubeflow Pipelines](https://www.kubeflow.org/docs/components/pipelines/v2/)
- [KFP GitHub](https://github.com/kubeflow/pipelines)
