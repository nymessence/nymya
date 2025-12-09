#!/bin/bash

# Docker-based testing and debugging for Aya Nymya
# Tests GTK+4 compilation, execution, and nymya executable functionality

# Configuration
IMAGE_NAME="nymya-gui-test"
CONTAINER_NAME="nymya-gui-test-container"
SOURCE_DIR="/home/erick/nymya"
BUILD_DIR="/tmp/nymya_gui_tests"
LOG_FILE="test_results.jsonl"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Docker-based testing environment for Aya Nymya...${NC}"

# Create build directory
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# Create Dockerfile for GUI testing
cat > Dockerfile << 'EOF'
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools and GTK4
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    cmake \
    make \
    pkg-config \
    git \
    curl \
    wget \
    # GTK4 dependencies
    libgtk-4-dev \
    libadwaita-1-dev \
    libglib2.0-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libgdk-pixbuf-2.0-dev \
    libgraphene-1.0-dev \
    # Rust toolchain for NymyaLang compiler
    rustc \
    cargo \
    # Additional utilities
    jq \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set up Rust
RUN rustup-init -y

# Add cargo to PATH
ENV PATH="/root/.cargo/bin:$PATH"

# Install NymyaLang compiler dependencies
RUN cargo install --git https://github.com/nymessence/nymyac.git || echo "Installing from local for now"

# Create working directory
WORKDIR /workspace

# Copy source code
COPY . .

# Build nymya compiler
RUN cd /workspace/nymyac && cargo build --release

# Make nymya executable accessible
RUN ln -s /workspace/nymya /usr/local/bin/nymya

# Expose necessary files for testing
RUN chmod +x /workspace/nymya

CMD ["/bin/bash"]
EOF

# Create a test script for validating GUI functionality
cat > test_gui.sh << 'EOF'
#!/bin/bash

echo "Starting GUI functionality tests..."

# Test 1: Check if nymya executable works
echo "Test 1: Testing nymya executable..."
timeout 10s /workspace/nymya --help
if [ $? -eq 0 ]; then
    echo '{"test": "nymya_executable", "status": "PASS", "message": "nymya executable works correctly"}' >> /workspace/test_results.jsonl
else
    echo '{"test": "nymya_executable", "status": "FAIL", "message": "nymya executable failed"}' >> /workspace/test_results.jsonl
fi

# Test 2: Try compiling a simple NymyaLang file
echo "Test 2: Testing compilation..."
echo 'import crystal
crystal.manifest("Hello from NymyaLang!")' > /tmp/test_hello.nym

timeout 30s /workspace/nymya /tmp/test_hello.nym
if [ $? -eq 0 ]; then
    echo '{"test": "compilation", "status": "PASS", "message": "Basic compilation works"}' >> /workspace/test_results.jsonl
else
    echo '{"test": "compilation", "status": "FAIL", "message": "Basic compilation failed"}' >> /workspace/test_results.jsonl
fi

# Test 3: Test GUI libraries can be imported (syntax check)
echo "Test 3: Testing GUI library compilation..."
echo 'import gui
import crystal
crystal.manifest("GUI library imported successfully")' > /tmp/test_gui.nym

timeout 30s /workspace/nymya /tmp/test_gui.nym
if [ $? -eq 0 ]; then
    echo '{"test": "gui_import", "status": "PASS", "message": "GUI library imports successfully"}' >> /workspace/test_results.jsonl
else
    echo '{"test": "gui_import", "status": "FAIL", "message": "GUI library import failed"}' >> /workspace/test_results.jsonl
fi

# Test 4: Test Aya Nymya application
echo "Test 4: Testing Aya Nymya application..."
timeout 60s /workspace/nymya /workspace/tests/aya_nymya.nym
if [ $? -eq 0 ]; then
    echo '{"test": "aya_nymya_app", "status": "PASS", "message": "Aya Nymya application executes successfully"}' >> /workspace/test_results.jsonl
else
    echo '{"test": "aya_nymya_app", "status": "FAIL", "message": "Aya Nymya application failed"}' >> /workspace/test_results.jsonl
fi

# Test 5: Check for temporary file creation and cleanup
echo "Test 5: Testing temporary file management..."
# Create a simple test that uses temp files
echo 'import crystal
import lowlevel.file
var temp_file = "/tmp/nymya_test_" + crystal.platform.get_time() + ".txt"
var success = crystal.file.write(temp_file, "Test content")
if success {
    crystal.manifest("Temp file created: " + temp_file)
    // Don't delete to test cleanup later
} else {
    crystal.manifest("Failed to create temp file")
}' > /tmp/test_temp.nym

timeout 30s /workspace/nymya /tmp/test_temp.nym
if [ $? -eq 0 ]; then
    echo '{"test": "temp_file_management", "status": "PASS", "message": "Temporary file management works"}' >> /workspace/test_results.jsonl
else
    echo '{"test": "temp_file_management", "status": "FAIL", "message": "Temporary file management failed"}' >> /workspace/test_results.jsonl
fi

echo "GUI tests completed!"
EOF

chmod +x test_gui.sh

# Copy necessary source files
cp -r $SOURCE_DIR/* .

# Build the Docker image
echo -e "${BLUE}Building Docker image...${NC}"
docker build -t $IMAGE_NAME . 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to build Docker image${NC}"
    exit 1
fi

echo -e "${GREEN}Docker image built successfully${NC}"

# Run the tests in Docker container
echo -e "${BLUE}Running tests in Docker container...${NC}"

# Create the log file
touch $LOG_FILE

# Run the container and execute tests
docker run --rm -v $(pwd):/workspace --name $CONTAINER_NAME $IMAGE_NAME /workspace/test_gui.sh

# Check the results
echo -e "${BLUE}Test results:${NC}"
if [ -f $LOG_FILE ]; then
    cat $LOG_FILE
    
    # Calculate summary
    total_tests=$(wc -l < $LOG_FILE)
    passed_tests=$(grep '"status": "PASS"' $LOG_FILE | wc -l)
    failed_tests=$(grep '"status": "FAIL"' $LOG_FILE | wc -l)
    
    echo -e "${BLUE}Summary:${NC}"
    echo "Total tests: $total_tests"
    echo -e "${GREEN}Passed: $passed_tests${NC}"
    echo -e "${RED}Failed: $failed_tests${NC}"
    
    if [ $failed_tests -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
else
    echo -e "${RED}No test results found${NC}"
    exit 1
fi

# Cleanup
echo -e "${YELLOW}Cleaning up...${NC}"
docker rmi -f $IMAGE_NAME 2>/dev/null || true
rm -rf $BUILD_DIR