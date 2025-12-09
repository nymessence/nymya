#!/bin/bash
# NymyaLang Package Build Script
# Creates .deb package for the current host architecture only

set -e  # Exit on error

echo "=== NymyaLang Package Build System ==="
echo "Building .deb package for host architecture only"
echo ""

VERSION=${1:-"0.2.0"}
DEV_STAGE="alpha"
REVISION="5"
BUILD_DIR="nymya-build-${VERSION}"

# Create root build directory
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Build for host architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
    TARGET="x86_64-unknown-linux-gnu"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    ARCH="arm64"
    TARGET="aarch64-unknown-linux-gnu"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

echo "Building package for architecture: $ARCH (Host: $(uname -m))"
echo "Target triple: $TARGET"

# Create package structure for this architecture
PKG_DIR="${BUILD_DIR}/nymya-${ARCH}"
rm -rf "${PKG_DIR}"
mkdir -p "${PKG_DIR}/DEBIAN"
mkdir -p "${PKG_DIR}/usr/bin"
mkdir -p "${PKG_DIR}/usr/lib/nymya"
mkdir -p "${PKG_DIR}/usr/include/nymya"
mkdir -p "${PKG_DIR}/usr/share/doc/nymya"
mkdir -p "${PKG_DIR}/usr/share/nymya/examples"
mkdir -p "${PKG_DIR}/usr/share/nymya/syntax_highlighter"

# Create control file
cat > "${PKG_DIR}/DEBIAN/control" << EOF
Package: nymya
Version: ${VERSION}-${DEV_STAGE}~${REVISION}
Section: devel
Priority: optional
Architecture: ${ARCH}
Depends: libc6 (>= 2.14), libgcc1 (>= 1:4.1.1), libstdc++6 (>= 4.1.1)
Maintainer: Nymessence Development Team <nymessence@gmail.com>
X-Thanks-To: Erick (Founder & Architect), Nya (Comms Coordinator), Qwen-cli Agent
Support-us: https://www.buymeacoffee.com/nymessence/
Installed-Size: 4096
Repo: https://www.github.com/nymessence/nymya.git
Description: NymyaLang - A consciousness-integrated programming language
 The NymyaLang compiler (nymyac) is a next-generation programming language
 with quantum computing integration and consciousness awareness. Features include:
 .
 * Advanced AI/ML with both classical and quantum machine learning
 * Quantum networking and consciousness-aware communication
 * Hypercalc mathematical functions with special case handling
 * Low-level bit manipulation and system operations
 * Quantum-resistant encryption and secure communications
 * Integration with quantum photonic hardware
 .
 The language follows the foundational principle of Rita-Nora balance:
 structural precision combined with ethical flow in all operations.
 .
 This package includes the NymyaLang compiler and standard libraries.
EOF

# Build the compiler for the specific target architecture
echo "  Building compiler for target: $TARGET"

if [ -d nymyac ]; then
    cd nymyac && cargo build --target $TARGET --release && cd ..
    
    if [ -f "nymyac/target/$TARGET/release/nymyac" ]; then
        cp "nymyac/target/$TARGET/release/nymyac" "${PKG_DIR}/usr/bin/nymyac"
        chmod +x "${PKG_DIR}/usr/bin/nymyac"
        echo "  ✓ Copied compiler binary for $TARGET"
    else
        echo "Error: Compiler binary not found at nymyac/target/$TARGET/release/nymyac"
        exit 1
    fi
else
    echo "Error: nymyac directory not found"
    exit 1
fi

# Copy the nymya wrapper script
if [ -f "./nymya" ]; then
    cp "./nymya" "${PKG_DIR}/usr/bin/nymya"
    chmod +x "${PKG_DIR}/usr/bin/nymya"
    echo "  ✓ Copied wrapper script"
else
    echo "Error: nymya wrapper script not found"
    exit 1
fi

# Create library directory structure
echo "  Setting up library files..."
for subdir in math math/gmp math/hypercalc math/functions ml ml/classical ml/quantum_ml networking networking/classical networking/quantum quantum quantum/gate quantum/sim quantum/alg gui datetime crystal lowlevel physics system symbolic symbolic/numerology symbolic/sacred_geometry symbolic/primes symbolic/repeating symbolic/special symbolic/integration; do
    if [ -d "nymyac/library/$subdir" ]; then
        mkdir -p "${PKG_DIR}/usr/lib/nymya/$subdir"
        find "nymyac/library/$subdir" -name "*.nym" -type f -exec cp {} "${PKG_DIR}/usr/lib/nymya/$subdir/" \; -exec echo "    Copied: {}" \;
    fi
done

# Copy syntax highlighting files if they exist
if [ -d "syntax_highlighter" ]; then
    cp -r syntax_highlighter/* "${PKG_DIR}/usr/share/nymya/syntax_highlighter/"
    echo "  ✓ Copied syntax highlighting files"
fi

# Example files
cat > "${PKG_DIR}/usr/share/nymya/examples/hello_quantum_symbolic.nym" << 'EOF'
// Hello Quantum Symbolic Mathematics Example
import crystal
import math
import quantum
import symbolic

func main() -> Void {
    crystal.manifest("Hello, Quantum Symbolic Mathematics!")
    crystal.manifest("Shira yo sela lora en nymya")

    // Test symbolic mathematics
    var meaning_33 = symbolic.numerology.get_meaning(33)
    crystal.manifest("Meaning of 33: " + meaning_33.meaning)
    
    // Test geometry correspondences
    var geometries_for_19 = symbolic.sacred_geometry.find_geometries_for_number(19)
    crystal.manifest("Geometries for 19: " + geometries_for_19.length)
    
    // Test prime symbolism
    var prime_info_23 = symbolic.primes.get_prime_symbol(23)
    crystal.manifest("Prime 23 classification: " + prime_info_23.classification)
    
    // Test quantum operations
    var circuit = quantum.sim.Circuit(2)
    quantum.gate.h(circuit, 0)
    quantum.gate.cx(circuit, 0, 1)
    
    var statevector = circuit.get_statevector()
    crystal.manifest("Quantum entanglement created with |00>+|11> state")
    
    // Test GUI integration (when available)
    crystal.manifest("NymyaLang with symbolic mathematics integration demonstrated!")
}
EOF

# Documentation
cat > "${PKG_DIR}/usr/share/doc/nymya/README.txt" << EOF
NymyaLang Programming Environment v${VERSION} ($ARCH)

Includes:
- nymyac compiler
- nymya wrapper script
- Nymya standard library
- Symbolic mathematics subsystem (numerology, sacred geometry, primes)
- Syntax highlighting for editors
- Quantum computing integration
- Examples and documentation

New in v${VERSION}: 
- Symbolic mathematics with numerology and sacred geometry
- GUI abstractions with SwiftUI-like syntax  
- Enhanced quantum simulator with proper tensor calculations
- Turing completeness verification programs
- Aya Nymya killer demo application

Rita-Nora balance in computing.
EOF

# Update installed size
INSTALLED_SIZE=$(du -sk "${PKG_DIR}" | cut -f1)
sed -i "s/Installed-Size: .*/Installed-Size: $INSTALLED_SIZE/" "${PKG_DIR}/DEBIAN/control"

# Build package
PKG_NAME="nymya_${VERSION}_${ARCH}.deb"
dpkg-deb --build --root-owner-group "${PKG_DIR}" "${BUILD_DIR}/${PKG_NAME}"

echo "  ✓ Package built: ${BUILD_DIR}/${PKG_NAME}"
echo ""

echo "=== PACKAGE BUILD COMPLETED SUCCESSFULLY ==="
echo "Package created in: ${BUILD_DIR}/"
echo "  ${PKG_NAME}"
echo ""
echo "To install: sudo dpkg -i ${BUILD_DIR}/${PKG_NAME}"
echo ""
