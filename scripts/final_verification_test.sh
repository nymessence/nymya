#!/bin/bash

# Final verification test for the fixed NymyaLang system
# Ensures architecture compatibility and proper executable generation

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting final verification test for NymyaLang v0.2.0-alpha.3${NC}"

# Create a temporary directory for testing
TEST_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'nymyatest.XXXXXX')
echo -e "${BLUE}Using test directory: $TEST_DIR${NC}"

# Copy the current working nymya system to the test directory
cp -r /home/erick/nymya/* "$TEST_DIR/"
cd "$TEST_DIR"

# Build the compiler first
echo -e "${BLUE}Building the nymyac compiler...${NC}"
cd nymyac && cargo build --release && cd ..

# Create a simple test file
cat > hello_test.nym << 'EOF'
import crystal
import math

crystal.manifest("Hello from NymyaLang!")
crystal.manifest("Testing basic functionality...")

// Test math operations
var result = math.sqrt(16.0)
crystal.manifest("Square root of 16: " + result)

// Test symbolic mathematics
import symbolic
var meaning = symbolic.get_meaning(33)
crystal.manifest("Meaning of 33: " + meaning.meaning)

// Test GUI components (declaration only, not execution)
crystal.manifest("GUI components available for use")
crystal.manifest("Test completed successfully!")
EOF

# Test the nymya executable directly
echo -e "${BLUE}Testing nymya executable...${NC}"
echo -e "${YELLOW}Running: ./nymya hello_test.nym${NC}"
timeout 120s ./nymya hello_test.nym

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ nymya executable test PASSED${NC}"
else
    echo -e "${RED}✗ nymya executable test FAILED${NC}"
    exit 1
fi

# Test more complex functionality
cat > advanced_test.nym << 'EOF'
import crystal
import math
import symbolic
import quantum.sim

crystal.manifest("Advanced NymyaLang Test")
crystal.manifest("========================")

// Test complex math operations
var pow_result = math.pow_int(2, 10)
crystal.manifest("2^10 = " + pow_result)

var gcd_result = math.gcd(48, 18)
crystal.manifest("GCD(48, 18) = " + gcd_result)

// Test numerology
var num_meaning = symbolic.numerology.get_meaning(22)
crystal.manifest("Master number 22: " + num_meaning.meaning)

// Test sacred geometry associations
var geometries = symbolic.sacred_geometry.find_geometries_for_number(19)
crystal.manifest("Sacred geometries for 19: " + geometries.length)

// Test prime identification
var prime_test = symbolic.primes.is_prime(17)
crystal.manifest("Is 17 prime? " + prime_test)

crystal.manifest("Advanced test completed!")
EOF

echo -e "${BLUE}Testing advanced functionality...${NC}"
timeout 120s ./nymya advanced_test.nym

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Advanced functionality test PASSED${NC}"
else
    echo -e "${RED}✗ Advanced functionality test FAILED${NC}"
    exit 1
fi

# Test Aya Nymya application
echo -e "${BLUE}Testing Aya Nymya application...${NC}"
timeout 180s ./nymya tests/aya_nymya.nym

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Aya Nymya application test PASSED${NC}"
else
    echo -e "${RED}✗ Aya Nymya application test FAILED${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 All tests passed! NymyaLang v0.2.0-alpha.3 is verified!${NC}"

# Show architecture information
echo -e "${BLUE}System Information:${NC}"
echo "Architecture: $(uname -m)"
echo "OS: $(uname -s)"

# Cleanup
cd /
rm -rf "$TEST_DIR"

# Exit successfully
exit 0