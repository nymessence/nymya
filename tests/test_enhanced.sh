#!/bin/bash

# Enhanced testing script for NymyaLang
set -e  # Exit on error

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting enhanced NymyaLang tests in container...${NC}"

# Create workspace directories
mkdir -p /workspace/test_files
mkdir -p /workspace/tests/turing

# Copy source files to workspace
cp -r /workspace_src/* /workspace/ 2>/dev/null || echo "Continuing..."

# Test 1: Verify nymyac compiler functionality
echo -e "${BLUE}Test 1: Compiler functionality${NC}"
echo 'import crystal
crystal.manifest("Testing compiler...")' > /workspace/test_files/compiler_test.nym

cd /workspace/test_files
if /workspace/nymyac compiler_test.nym -o compiler_test_exe 2>/dev/null; then
    echo '{"test": "compiler_functionality", "status": "PASS", "message": "nymyac compiles basic files"}' >> /workspace/test_results.jsonl
    echo -e "${GREEN}✓ Compiler works${NC}"
else
    echo '{"test": "compiler_functionality", "status": "FAIL", "message": "nymyac failed to compile basic files"}' >> /workspace/test_results.jsonl
    echo -e "${RED}✗ Compiler failed${NC}"
fi

# Test 2: Verify nymya executable wrapper
echo -e "${BLUE}Test 2: Executable wrapper functionality${NC}"
if timeout 30s /workspace/nymya compiler_test.nym 2>/dev/null; then
    echo '{"test": "executable_wrapper", "status": "PASS", "message": "nymya executable wrapper runs programs"}' >> /workspace/test_results.jsonl
    echo -e "${GREEN}✓ Executable wrapper works${NC}"
else
    echo '{"test": "executable_wrapper", "status": "FAIL", "message": "nymya executable wrapper failed"}' >> /workspace/test_results.jsonl
    echo -e "${RED}✗ Executable wrapper failed${NC}"
fi

# Test 3: Verify math library functionality
echo -e "${BLUE}Test 3: Math library functionality${NC}"
echo 'import math
import crystal
crystal.manifest("Testing math library...")
var sqrt_val = math.sqrt(16.0)
crystal.manifest("Square root of 16: " + sqrt_val)
var gcd_val = math.gcd(48, 18)
crystal.manifest("GCD of 48 and 18: " + gcd_val)
var pow_val = math.pow_int(2, 10)
crystal.manifest("2^10: " + pow_val)' > /workspace/test_files/math_test.nym

if timeout 30s /workspace/nymya math_test.nym 2>/dev/null; then
    echo '{"test": "math_library", "status": "PASS", "message": "Math library functions work correctly"}' >> /workspace/test_results.jsonl
    echo -e "${GREEN}✓ Math library works${NC}"
else
    echo '{"test": "math_library", "status": "FAIL", "message": "Math library failed"}' >> /workspace/test_results.jsonl
    echo -e "${RED}✗ Math library failed${NC}"
fi

# Test 4: Verify quantum library functionality
echo -e "${BLUE}Test 4: Quantum library functionality${NC}"
echo 'import quantum
import quantum.sim
import crystal
import math
crystal.manifest("Testing quantum library...")
var circuit = quantum.sim.Circuit(2)
quantum.gate.h(circuit, 0)  // Hadamard on qubit 0
quantum.gate.cx(circuit, 0, 1)  // CNOT gate
var measurement = quantum.sim.measure_all(circuit)
crystal.manifest("Quantum circuit measurement: [" + measurement.join(", ") + "]")' > /workspace/test_files/quantum_test.nym

if timeout 30s /workspace/nymya quantum_test.nym 2>/dev/null; then
    echo '{"test": "quantum_library", "status": "PASS", "message": "Quantum library functions work correctly"}' >> /workspace/test_results.jsonl
    echo -e "${GREEN}✓ Quantum library works${NC}"
else
    echo '{"test": "quantum_library", "status": "FAIL", "message": "Quantum library failed"}' >> /workspace/test_results.jsonl
    echo -e "${RED}✗ Quantum library failed${NC}"
fi

# Test 5: Verify symbolic mathematics functionality
echo -e "${BLUE}Test 5: Symbolic mathematics functionality${NC}"
echo 'import symbolic
import crystal
crystal.manifest("Testing symbolic mathematics...")
var meaning_33 = symbolic.numerology.get_meaning(33)
crystal.manifest("Numerological meaning of 33: " + meaning_33.meaning)
var sacred_geom = symbolic.sacred_geometry.find_geometries_for_number(19)
crystal.manifest("Sacred geometry for 19: " + sacred_geom.length + " found")
var is_prime_23 = symbolic.primes.is_prime(23)
crystal.manifest("Is 23 prime (symbolic): " + is_prime_23)' > /workspace/test_files/symbolic_test.nym

if timeout 60s /workspace/nymya symbolic_test.nym 2>/dev/null; then
    echo '{"test": "symbolic_mathematics", "status": "PASS", "message": "Symbolic mathematics functions work correctly"}' >> /workspace/test_results.jsonl
    echo -e "${GREEN}✓ Symbolic mathematics works${NC}"
else
    echo '{"test": "symbolic_mathematics", "status": "FAIL", "message": "Symbolic mathematics failed"}' >> /workspace/test_results.jsonl
    echo -e "${RED}✗ Symbolic mathematics failed${NC}"
fi

# Test 6: Verify Turing completeness tests
echo -e "${BLUE}Test 6: Turing completeness verification${NC}"
if [ -f "/workspace/tests/turing/conditional.nym" ]; then
    if timeout 30s /workspace/nymya /workspace/tests/turing/conditional.nym 2>/dev/null; then
        echo '{"test": "turing_conditional", "status": "PASS", "message": "Conditional branching works"}' >> /workspace/test_results.jsonl
        echo -e "${GREEN}✓ Conditional tests passed${NC}"
    else
        echo '{"test": "turing_conditional", "status": "FAIL", "message": "Conditional branching failed"}' >> /workspace/test_results.jsonl
        echo -e "${RED}✗ Conditional tests failed${NC}"
    fi
else
    echo '{"test": "turing_conditional", "status": "SKIP", "message": "Conditional test file not found"}' >> /workspace/test_results.jsonl
fi

if [ -f "/workspace/tests/turing/loops.nym" ]; then
    if timeout 30s /workspace/nymya /workspace/tests/turing/loops.nym 2>/dev/null; then
        echo '{"test": "turing_loops", "status": "PASS", "message": "Unbounded loops work"}' >> /workspace/test_results.jsonl
        echo -e "${GREEN}✓ Loops tests passed${NC}"
    else
        echo '{"test": "turing_loops", "status": "FAIL", "message": "Unbounded loops failed"}' >> /workspace/test_results.jsonl
        echo -e "${RED}✗ Loops tests failed${NC}"
    fi
else
    echo '{"test": "turing_loops", "status": "SKIP", "message": "Loops test file not found"}' >> /workspace/test_results.jsonl
fi

# Test 7: Verify killer demo functionality
echo -e "${BLUE}Test 7: Killer demo functionality${NC}"
if [ -f "/workspace/tests/killer_demo.nym" ]; then
    if timeout 120s /workspace/nymya /workspace/tests/killer_demo.nym 2>/dev/null; then
        echo '{"test": "killer_demo", "status": "PASS", "message": "Killer demo executes successfully"}' >> /workspace/test_results.jsonl
        echo -e "${GREEN}✓ Killer demo works${NC}"
    else
        echo '{"test": "killer_demo", "status": "FAIL", "message": "Killer demo failed"}' >> /workspace/test_results.jsonl
        echo -e "${RED}✗ Killer demo failed${NC}"
    fi
else
    echo '{"test": "killer_demo", "status": "SKIP", "message": "Killer demo test file not found"}' >> /workspace/test_results.jsonl
fi

# Test 8: Architecture compatibility verification
echo -e "${BLUE}Test 8: Architecture compatibility${NC}"
echo "Host architecture: $(uname -m)"
echo "Compiler architecture detection: $HOSTTYPE"

# Test the binary format of the generated executable if it exists
if [ -f "/workspace/test_files/compiler_test_exe" ]; then
    FILE_INFO=$(file /workspace/test_files/compiler_test_exe 2>/dev/null || echo "Could not determine file type")
    echo "Generated executable: $FILE_INFO"
    echo '{"test": "binary_format", "status": "INFO", "message": "Executable format: '"$FILE_INFO"'"}' >> /workspace/test_results.jsonl
else
    echo '{"test": "binary_format", "status": "INFO", "message": "No executable file to check"}' >> /workspace/test_results.jsonl
fi

echo -e "${BLUE}Enhanced tests completed!${NC}"
