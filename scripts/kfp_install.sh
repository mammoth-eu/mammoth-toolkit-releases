#!/bin/sh
set -e

echo "This will deploy Kubeflow Pipelines Standalone instance v2.2.0"

read -p "Please monitor the installation and provide input as required. Press enter to continue..." input
echo ""
echo  "---- Please make sure that you have installed and active: ----"
echo "- Docker"
echo "- Kubernetes cluster, could be K3d, Minikube, or any other distribution"
echo "- kubectl"
echo ""
read -p " Press enter to continue, or CTRL+C to stop the script..." input


# Do the installation
export PIPELINE_VERSION=2.3.0

kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=$PIPELINE_VERSION"
kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io
kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=$PIPELINE_VERSION"

echo 'Applying ingress for kfp.local.exus.ai access'
kubectl apply -f ./kfp_ingress.yaml

echo 'If no errors occurred installation of Kubeflow pipelines is complete'
echo ""
echo "Kubeflow pipelines will be ready when all pods, running next command, are in ready state"
echo "kubectl -n kubeflow get pods"
echo ""
echo "To access KFP interface run the following command and then connect to localhost:8080"
echo "kubectl port-forward -n kubeflow svc/ml-pipeline-ui 8080:80"


# For uninstall
# export PIPELINE_VERSION=2.0.3
# kubectl delete -k "github.com/kubeflow/pipelines/manifests/kustomize/env/platform-agnostic-pns?ref=$PIPELINE_VERSION"
# kubectl delete -k "github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=$PIPELINE_VERSION"

# https://www.kubeflow.org/docs/components/pipelines/v1/installation/localcluster-deployment/
