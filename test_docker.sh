#!/bin/bash
# Test script for NymyaLang compiler in Docker

# Test 1: Basic functionality
echo "=== Test 1: Basic functionality ==="
cat > /workspace/test_basic.nym << 'EOF'
import crystal
crystal.manifest("Basic test successful!")
EOF

cd /workspace
./nymyac/target/release/nymyac test_basic.nym -o test_basic_exe
if [ $? -eq 0 ]; then
  echo "Basic test compilation successful"
  ./test_basic_exe
  if [ $? -eq 0 ]; then
    echo "Basic test execution successful"
  else
    echo "Basic test execution failed"
    exit 1
  fi
else
  echo "Basic test compilation failed"
  exit 1
fi

# Test 2: Array functionality
echo -e "\n=== Test 2: Array functionality ==="
cat > /workspace/test_array.nym << 'EOF'
import crystal

crystal.manifest("Array test starting...")
// Test array creation and initialization
var test_arr = []

// Test appending values
test_arr.append(1)
test_arr.append(2)
test_arr.append(3)

// Test length
var len = test_arr.length
crystal.manifest("Array length: " + len.to_string())

// Test array access
var first = test_arr[0]
crystal.manifest("First element: " + first.to_string())

crystal.manifest("Array test completed successfully!")
EOF

cd /workspace
./nymyac/target/release/nymyac test_array.nym -o test_array_exe
if [ $? -eq 0 ]; then
  echo "Array test compilation successful"
  ./test_array_exe
  if [ $? -eq 0 ]; then
    echo "Array test execution successful"
  else
    echo "Array test execution failed"
    exit 1
  fi
else
  echo "Array test compilation failed"
  exit 1
fi

# Test 3: Module function calls
echo -e "\n=== Test 3: Module function calls ==="
cat > /workspace/test_modules.nym << 'EOF'
import crystal
import math

crystal.manifest("Module function test starting...")

// Test math functions
var sqrt_val = math.sqrt(16.0)
crystal.manifest("Square root of 16: " + sqrt_val.to_string())

// Test crystal functions
crystal.manifest("Module function test completed!")
EOF

cd /workspace
./nymyac/target/release/nymyac test_modules.nym -o test_modules_exe
if [ $? -eq 0 ]; then
  echo "Module test compilation successful"
  ./test_modules_exe
  if [ $? -eq 0 ]; then
    echo "Module test execution successful"
  else
    echo "Module test execution failed"
    exit 1
  fi
else
  echo "Module test compilation failed"
  exit 1
fi

# Test 4: Complex expressions
echo -e "\n=== Test 4: Complex expressions ==="
cat > /workspace/test_complex.nym << 'EOF'
import crystal

var counter = 0
crystal.manifest("Complex expression test: " + counter.to_string())

var val = 4
var doubled = val * 2
crystal.manifest("Doubled value: " + doubled.to_string())

crystal.manifest("Complex expression test completed!")
EOF

./nymyac/target/release/nymyac test_complex.nym -o test_complex_exe
if [ $? -eq 0 ]; then
  echo "Complex test compilation successful"
  ./test_complex_exe
  if [ $? -eq 0 ]; then
    echo "Complex test execution successful"
  else
    echo "Complex test execution failed"
    exit 1
  fi
else
  echo "Complex test compilation failed"
  exit 1
fi

echo -e "\n=== All tests passed! ==="