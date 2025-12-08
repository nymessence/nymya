#!/bin/bash

# Script to test the cross-compilation setup

echo "Building the cross-compilation Docker image..."

# Build the Docker image
docker build -f Dockerfile.cross -t nymya-cross-compiler .

if [ $? -ne 0 ]; then
    echo "Failed to build the Docker image"
    exit 1
fi

echo "Docker image built successfully!"

echo "Testing the cross-compilation environment..."

# Test the Linux builds
docker run --rm nymya-cross-compiler /opt/nymya/build_linux.sh

if [ $? -ne 0 ]; then
    echo "Linux build failed"
    exit 1
fi

echo "Linux builds completed successfully!"

# Test the Windows builds
docker run --rm nymya-cross-compiler /opt/nymya/build_windows.sh

if [ $? -ne 0 ]; then
    echo "Windows build failed"
    exit 1
fi

echo "Windows builds completed successfully!"

echo "Cross-compilation setup tests completed successfully!"