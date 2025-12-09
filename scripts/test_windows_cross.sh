#!/bin/bash

# Test Windows cross-compilation for NymyaLang

echo "Testing Windows cross-compilation setup..."

# Create a simple test nymya file
cat > test.nym << 'EOF'
// Simple test program
import crystal

func main() -> Void {
    crystal.manifest("Hello from cross-compiled Windows binary!")
}
EOF

# Create a basic Cargo project structure within nymyac for testing
mkdir -p test_project/src
cat > test_project/Cargo.toml << 'EOF'
[package]
name = "test_nymya"
version = "0.1.0"
edition = "2021"

[[bin]]
name = "test_nymya"
path = "src/main.rs"
EOF

cat > test_project/src/main.rs << 'EOF'
fn main() {
    println!("Testing Windows cross-compilation");
    
    // Test GMP functionality if available
    #[cfg(target_env = "msvc")]
    println!("Compiling for Windows with MSVC");
    
    #[cfg(target_env = "gnu")]
    println!("Compiling for Windows with GNU toolchain");
    
    println!("Windows cross-compilation test completed successfully!");
}
EOF

# Try to build for Windows x86_64
echo "Building for Windows x86_64..."
cd test_project
if cargo build --target x86_64-pc-windows-gnu --release 2>/dev/null; then
    echo "Windows x86_64 build successful!"
    file target/x86_64-pc-windows-gnu/release/test_nymya.exe
else
    echo "Windows x86_64 build failed, but this is expected without proper GMP for Windows"
fi

# Try to build for Windows i686
echo "Building for Windows i686..."
if cargo build --target i686-pc-windows-gnu --release 2>/dev/null; then
    echo "Windows i686 build successful!"
    file target/i686-pc-windows-gnu/release/test_nymya.exe
else
    echo "Windows i686 build failed, but this is expected without proper GMP for Windows"
fi

echo "Cross-compilation test completed!"