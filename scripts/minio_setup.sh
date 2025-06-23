#!/bin/bash

# Variables - set these to your MinIO deployment details
MINIO_ALIAS="minio"
MINIO_ENDPOINT="http://kfp-minio.local.exus.ai:8082"
MINIO_ACCESS_KEY="minio"
MINIO_SECRET_KEY="minio123"
BUCKET_NAME="data"


# Add needed Minio ingress for toolkit communication
kubectl apply -f ./minio/internal-minio-ingress.yaml

# 1. Download mc only if not already present
if [ ! -x "./mc" ]; then
  echo "Downloading mc client..."
  curl -sSL https://dl.min.io/client/mc/release/linux-amd64/mc -o ./mc
  chmod +x ./mc
else
  echo "mc client already present. Skipping download."
fi

# 2. Set up the MinIO alias
./mc alias set $MINIO_ALIAS $MINIO_ENDPOINT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY

# 3. Create the bucket
./mc mb $MINIO_ALIAS/$BUCKET_NAME

# 4. Set the bucket policy to readonly for all users
./mc anonymous set download $MINIO_ALIAS/$BUCKET_NAME

echo "Bucket '$BUCKET_NAME' created and readonly policy applied to all users."
