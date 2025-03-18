#!/bin/bash

set -e

# Step 1: Get the current NodeHosts value
echo "Retrieving current NodeHosts..."
NODEHOSTS=$(kubectl get configmap coredns -n kube-system -o jsonpath='{.data.NodeHosts}')
echo "Current NodeHosts:"
echo "$NODEHOSTS"

# Step 2: Check if host.k3d.internal exists and update or add a new entry
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

# Step 3: Create a temporary YAML file for the updated ConfigMap
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

# Step 4: Apply the updated ConfigMap
echo "Applying updated ConfigMap..."
kubectl apply -f "$TEMP_FILE"

# Cleanup temporary file
rm -f "$TEMP_FILE"

echo "Done!"
