#!/bin/bash

set -e

echo "Starting MAI-BIAS Toolkit..."
k3d cluster start kfp
docker compose up -d
echo -e "\033[33mMAI-BIAS Toolkit activated\033[37m"

echo -e "The toolkit is running at: \033[33mhttp://localhost:5173\033[37m"
echo -e "If this is the first time you use it, you can use the demo user: \033[33mUser: demo Pass: demo\033[37m"