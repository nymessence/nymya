#!/bin/bash
# Script to run comprehensive stress tests and generate images
# run_stress_tests.sh

echo "🔬 Starting NymyaLang Stress Tests..."
echo "========================================="

# Create directory for generated images if it doesn't exist
mkdir -p generated_images

echo "🧪 Testing Cellular Automata Generation..."

# Run cellular automata test
echo "  Running cellular automata test..."
./nymyac/tests/cellular_automata_test.nym || echo "⚠️  Cellular automata test failed"

echo "🌀 Testing Fractal Generation..."

# Run fractal generation test
echo "  Running fractal generation test..."
./nymyac/tests/fractal_generation_test.nym || echo "⚠️  Fractal generation test failed"

echo "🚀 Running Comprehensive Stress Test..."

# Run comprehensive stress test
echo "  Running comprehensive stress test..."
./nymyac/tests/comprehensive_stress_test.nym || echo "⚠️  Comprehensive stress test failed"

echo ""
echo "🎉 All tests completed!"
echo "📸 Generated images should be in the current directory:"
ls -la *.png 2>/dev/null || echo "No PNG files found in current directory"

echo ""
echo "Moving images to generated_images directory..."
mv *.png generated_images/ 2>/dev/null || echo "No PNG files to move"

echo "✅ Images moved to generated_images directory:"
ls -la generated_images/

echo ""
echo "🔍 To view results, check the generated_images directory."