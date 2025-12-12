#!/bin/bash

# Test script to install and test the .deb package in a container

# Create a temporary container
echo "Testing the updated .deb package in Docker..."

# Create a test container to install the package - explicitly use amd64
docker run --rm --platform linux/amd64 -v $(pwd)/nymya-build-0.1.3:/packages ubuntu:22.04 bash -c "
    apt-get update --allow-insecure-repositories &&
    dpkg -i ./packages/nymya_0.1.3_amd64.deb &&
    apt-get install -fy &&
    echo '=== Testing Nymya compiler ===' &&
    nymyac --help &&
    echo 'func main() -> Void { crystal.manifest(\"Hello from container!\"); }' > /tmp/test.nym &&
    echo '=== Compiling test file ===' &&
    nymyac /tmp/test.nym -o /tmp/output &&
    echo '=== Compilation successful ===' &&
    cat /tmp/output
"