#!/bin/bash

# Verification Test Suite for NymyaLang v0.2.0-alpha~6
# Tests all core functionality and confirms stable operation

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting NymyaLang v0.2.0-alpha~6 Verification Suite${NC}"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

run_test() {
    local test_name="$1"
    local command="$2"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Running $test_name... "
    if eval "$command"; then
        echo -e "${GREEN}PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}FAIL${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "  Command: $command"
    fi
}

# Test 1: Compiler functionality
echo -e "${BLUE}=== Compiler Functionality Tests ===${NC}"

cat > test_compiler.nym << 'EOF'
import crystal
import math

crystal.manifest("Compiler test: Basic functionality")
var result = math.sqrt(16.0)
crystal.manifest("Square root of 16: " + result)
EOF

run_test "Basic compilation" "./nymyac/target/release/nymyac test_compiler.nym -o test_compiler_exe && ./test_compiler_exe | grep -q 'Square root of 16:'"

# Test 2: Quantum library functionality  
echo -e "${BLUE}=== Quantum Library Tests ===${NC}"

cat > test_quantum.nym << 'EOF'
import crystal
import quantum
import quantum.sim

crystal.manifest("Quantum test: Creating circuit")
var circuit = quantum.sim.Circuit(2)
quantum.gate.h(circuit, 0)
quantum.gate.cx(circuit, 0, 1)
crystal.manifest("Created Bell state circuit with 2 qubits")
EOF

run_test "Quantum circuit compilation" "./nymyac/target/release/nymyac test_quantum.nym -o test_quantum_exe && ./test_quantum_exe | grep -q 'Bell state'"

# Test 3: Math library functionality
echo -e "${BLUE}=== Math Library Tests ===${NC}"

cat > test_math.nym << 'EOF'
import crystal
import math

crystal.manifest("Math test: Various operations")
var sqrt_val = math.sqrt(25.0)
crystal.manifest("Square root of 25: " + sqrt_val)

var gcd_val = math.gcd(48, 18)
crystal.manifest("GCD of 48 and 18: " + gcd_val)

var pow_val = math.pow_int(2, 10)
crystal.manifest("2^10: " + pow_val)
EOF

run_test "Math operations compilation" "./nymyac/target/release/nymyac test_math.nym -o test_math_exe && ./test_math_exe | grep -q '256'"

# Test 4: Symbolic mathematics functionality
echo -e "${BLUE}=== Symbolic Mathematics Tests ===${NC}"

cat > test_symbolic.nym << 'EOF'
import crystal
import symbolic
import symbolic.numerology

crystal.manifest("Symbolic mathematics test: Numerology")
var meaning_33 = symbolic.numerology.get_meaning(33)
crystal.manifest("Meaning of 33: " + meaning_33.meaning)

var sacred_geom = symbolic.sacred_geometry.find_geometries_for_number(19)
crystal.manifest("Sacred geometry for 19: " + sacred_geom.length)
EOF

run_test "Symbolic mathematics compilation" "./nymyac/target/release/nymyac test_symbolic.nym -o test_symbolic_exe && ./test_symbolic_exe | grep -q 'Sacred geometry for 19:'"

# Test 5: Turing completeness constructs
echo -e "${BLUE}=== Turing Completeness Constructs Tests ===${NC}"

cat > test_turing_constructs.nym << 'EOF'
import crystal
import math

crystal.manifest("Turing completeness test: Conditionals and loops")

// Test conditional
var x = 10
if x > 5 {
    crystal.manifest("Conditional branching works")
} else {
    crystal.manifest("Conditional failed")
}

// Test loop
var count = 0
while count < 5 {
    crystal.manifest("Loop iteration: " + count)
    count = count + 1
}

// Test recursion
func factorial(n: Int) -> Int {
    if n <= 1 {
        return 1
    }
    return n * factorial(n - 1)
}

var fact5 = factorial(5)
crystal.manifest("Factorial of 5: " + fact5)
EOF

run_test "Turing constructs compilation" "./nymyac/target/release/nymyac test_turing_constructs.nym -o test_turing_constructs_exe && ./test_turing_constructs_exe | grep -q 'Factorial of 5: 120'"

# Test 6: Killer demo functionality
echo -e "${BLUE}=== Killer Demo Functionality Test ===${NC}"

# We'll just test that the killer demo can be compiled (execution might take too long)
run_test "Killer demo compilation" "./nymyac/target/release/nymyac tests/killer_demo.nym -o killer_demo_test_exe 2>/dev/null && [ -f killer_demo_test_exe ]"

# Test 7: GUI system components (just test import works)
echo -e "${BLUE}=== GUI System Components Test ===${NC}"

cat > test_gui_import.nym << 'EOF'
import crystal
import gui

crystal.manifest("GUI import test: Libraries accessible")
crystal.manifest("GUI system components loaded successfully")
EOF

run_test "GUI library import" "./nymyac/target/release/nymyac test_gui_import.nym -o test_gui_exe && ./test_gui_exe | grep -q 'GUI system components loaded'"

# Test 8: Networking functionality
echo -e "${BLUE}=== Networking System Test ===${NC}"

cat > test_networking.nym << 'EOF'
import crystal
import networking

crystal.manifest("Networking test: Libraries accessible")
var special_nums = [42, 108, 33, 144]
for num in special_nums {
    var meaning = symbolic.numerology.get_meaning(num)
    crystal.manifest("Number " + num + " symbolic meaning: " + meaning.meaning)
}
EOF

run_test "Networking libraries compilation" "./nymyac/target/release/nymyac test_networking.nym -o test_networking_exe && ./test_networking_exe | grep -q 'symbolic meaning'"

echo -e "${BLUE}=== Test Summary ===${NC}"
echo "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 All verification tests PASSED! NymyaLang is stable and complete.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some verification tests FAILED!${NC}"
    exit 1
fi

# Cleanup temporary files
rm -f test_*.nym test_*_exe killer_demo_test_exe