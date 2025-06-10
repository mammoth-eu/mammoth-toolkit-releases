#!/bin/bash

# Stop the toolkit
echo "Stopping toolkit..."
docker compose down

# Set the URL for the latest release of module_yamls.tar.gz
URL="https://github.com/mammoth-eu/mammoth-commons/releases/latest/download/module_yamls.tar.gz"

# Set output file and directory
OUTPUT_FILE="module_yamls.tar.gz"
EXTRACT_DIR="modules"

echo "Downloading latest module yamls from $URL..."

# Download the file using curl
if ! curl -L -o "$OUTPUT_FILE" "$URL"; then
    echo "Error: Failed to download file from $URL"
    exit 1
fi

echo "Successfully downloaded $OUTPUT_FILE"

# Check if extract directory exists, create if not
if [ ! -d "$EXTRACT_DIR" ]; then
    mkdir -p "$EXTRACT_DIR"
    echo "Created directory: $EXTRACT_DIR"
fi

# Extract the tar.gz file
echo "Extracting files to $EXTRACT_DIR..."
if ! tar -xzf "$OUTPUT_FILE" -C "$EXTRACT_DIR"; then
    echo "Error: Failed to extract $OUTPUT_FILE"
    exit 1
fi

echo "Successfully extracted module yamls to $EXTRACT_DIR"

# Check if the yamls directory exists in the extracted content
if [ ! -d "$EXTRACT_DIR/yamls" ]; then
    echo "Error: Expected yamls directory not found in the extracted content"
    exit 1
fi

# Create components_yaml and components_metadata directories if they don't exist
echo "Creating target directories if they don't exist..."
mkdir -p components_yaml
mkdir -p components_metadata

# Delete existing content in the target directories
echo "Cleaning existing content in target directories..."
rm -rf components_yaml/*
rm -rf components_metadata/*

# Copy files from extracted structure to the target directories
echo "Copying files to target directories..."
if [ -d "$EXTRACT_DIR/yamls/data" ]; then
    cp -r "$EXTRACT_DIR/yamls/data/"* components_yaml/
    echo "Copied data files to components_yaml"
else
    echo "Warning: data directory not found in extracted content"
fi

if [ -d "$EXTRACT_DIR/yamls/meta" ]; then
    cp -r "$EXTRACT_DIR/yamls/meta/"* components_metadata/
    echo "Copied meta files to components_metadata"
else
    echo "Warning: meta directory not found in extracted content"
fi

# Clean up
echo "Cleaning up..."
rm -rf "$EXTRACT_DIR/yamls"
rm -rf "$EXTRACT_DIR"
rm "$OUTPUT_FILE"

echo "Update completed successfully!"
echo "You can start the toolkit using the start_toolkit.sh script"