#!/bin/bash

set -e

echo "Stopping MAI-BIAS Toolkit..."
k3d cluster stop kfp
docker compose down
echo -e "\033[33mMAI-BIAS Toolkit terminated\033[37m"