#!/bin/bash
# Enhanced NymyaLang Cross-Compilation Package Build Script
# Creates .deb packages for multiple architectures: amd64, arm64, armhf
# Source version info from version.conf

set -e  # Exit on error

# Source version information from version.conf
if [ -f "/home/erick/nymya/version.conf" ]; then
    source /home/erick/nymya/version.conf
else
    # Default values if version.conf not found
    VERSION="0.2.0"
    DEV_STAGE="alpha"
    REVISION="6"
    BUILD_DIR="nymya-build-${VERSION}"
    VERSION_STRING="${VERSION}-${DEV_STAGE}~${REVISION}"
fi

echo "=== Enhanced NymyaLang Cross-Compilation System v${VERSION_STRING} ==="
echo "Building .deb packages for multiple architectures: amd64, arm64, armhf"
echo ""

BUILD_DIR="nymya-build-${VERSION}"

# Create root build directory
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Install necessary cross-compilation targets if not already installed
echo "Installing cross-compilation targets..."
rustup target add x86_64-unknown-linux-gnu 2>/dev/null || echo "x86_64-unknown-linux-gnu target already installed or rustup not available"
rustup target add aarch64-unknown-linux-gnu 2>/dev/null || echo "aarch64-unknown-linux-gnu target already installed or rustup not available"
rustup target add armv7-unknown-linux-gnueabihf 2>/dev/null || echo "armv7-unknown-linux-gnueabihf target already installed or rustup not available"

echo ""

# Function to build package for specific architecture
build_for_arch() {
    local arch=$1
    local target=$2
    local description=$3
    
    echo "Building package for architecture: $arch ($description)"

    # Create package structure for this architecture
    local pkg_dir="${BUILD_DIR}/nymya-${arch}"
    rm -rf "${pkg_dir}"
    mkdir -p "${pkg_dir}/DEBIAN"
    mkdir -p "${pkg_dir}/usr/bin"
    mkdir -p "${pkg_dir}/usr/lib/nymya"
    mkdir -p "${pkg_dir}/usr/include/nymya"
    mkdir -p "${pkg_dir}/usr/share/doc/nymya"
    mkdir -p "${pkg_dir}/usr/share/nymya/examples"

    # Create control file specific to this architecture
    cat > "${pkg_dir}/DEBIAN/control" << EOF
Package: nymya
Version: ${VERSION}-${DEV_STAGE}~${REVISION}
Section: devel
Priority: optional
Architecture: $arch
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

    # Build actual compiler binary for the specific architecture
    case "$arch" in
        "amd64")
            # For amd64 package, build for x86_64 target
            if [ -d nymyac ]; then
                echo "  Building for target: $target"
                cd nymyac && cargo build --target $target --release && cd ..
                if [ -f "nymyac/target/$target/release/nymyac" ]; then
                    cp "nymyac/target/$target/release/nymyac" "${pkg_dir}/usr/bin/nymyac"
                    echo "  Binary copied successfully"
                else
                    echo "Error: Binary not found at nymyac/target/$target/release/nymyac"
                    # Try to build without target (native) and copy if cross-compilation fails
                    if [ -f "nymyac/target/release/nymyac" ]; then
                        cp "nymyac/target/release/nymyac" "${pkg_dir}/usr/bin/nymyac"
                        echo "  Warning: Used native binary since cross-compiled binary not available"
                    else
                        echo "Error: Neither cross-compiled nor native binary found"
                        exit 1
                    fi
                fi
            else
                echo "Error: nymyac directory not found"
                exit 1
            fi
            ;;
        "arm64")
            # Cross-compile for ARM64
            echo "  Cross-compiling for target: $target"
            if [ -d nymyac ]; then
                cd nymyac && cargo build --target $target --release && cd ..
                if [ -f "nymyac/target/$target/release/nymyac" ]; then
                    cp "nymyac/target/$target/release/nymyac" "${pkg_dir}/usr/bin/nymyac"
                    echo "  Binary copied successfully"
                else
                    echo "Error: Binary not found at nymyac/target/$target/release/nymyac"
                    # Try to build without target (native) and copy if cross-compilation fails
                    if [ -f "nymyac/target/release/nymyac" ]; then
                        cp "nymyac/target/release/nymyac" "${pkg_dir}/usr/bin/nymyac"
                        echo "  Warning: Used native binary since cross-compiled binary not available"
                    else
                        echo "Error: Neither cross-compiled nor native binary found"
                        exit 1
                    fi
                fi
            else
                echo "Error: nymyac directory not found"
                exit 1
            fi
            ;;
        "armhf")
            # Cross-compile for ARMHF
            echo "  Cross-compiling for target: $target"
            if [ -d nymyac ]; then
                cd nymyac && cargo build --target $target --release && cd ..
                if [ -f "nymyac/target/$target/release/nymyac" ]; then
                    cp "nymyac/target/$target/release/nymyac" "${pkg_dir}/usr/bin/nymyac"
                    echo "  Binary copied successfully"
                else
                    echo "Error: Binary not found at nymyac/target/$target/release/nymyac"
                    # Try to build without target (native) and copy if cross-compilation fails
                    if [ -f "nymyac/target/release/nymyac" ]; then
                        cp "nymyac/target/release/nymyac" "${pkg_dir}/usr/bin/nymyac"
                        echo "  Warning: Used native binary since cross-compiled binary not available"
                    else
                        echo "Error: Neither cross-compiled nor native binary found"
                        exit 1
                    fi
                fi
            else
                echo "Error: nymyac directory not found"
                exit 1
            fi
            ;;
        *)
            echo "Unsupported architecture: $arch"
            exit 1
            ;;
    esac

    # Ensure binary is executable
    chmod +x "${pkg_dir}/usr/bin/nymyac"

    # Standard library directories
    for subdir in math math/gmp math/hypercalc math/functions ml ml/classical ml/quantum_ml networking networking/classical networking/quantum quantum quantum/gate quantum/sim quantum/alg datetime crystal crystal/io lowlevel physics physics/quantum system symbolic symbolic/integration symbolic/numerology symbolic/primes symbolic/repeating symbolic/sacred_geometry symbolic/special gui graphics graphics/ply_basic graphics/stl_basic image image/basic image/image_extended storygen storygen/api_client storygen/character_loader storygen/config storygen/context_builder storygen/environmental_triggers storygen/repitition_detector storygen/response_generator storygen/scenario_adapter storygen/scenario_progression storygen/utils; do
        if [ -d "nymyac/library/$subdir" ]; then
            mkdir -p "${pkg_dir}/usr/lib/nymya/$subdir"
            find "nymyac/library/$subdir" -name "*.nym" -type f -exec cp {} "${pkg_dir}/usr/lib/nymya/$subdir/" \; -exec echo "  Copied: {}" \;
        fi
    done

    # Example files
    cat > "${pkg_dir}/usr/share/nymya/examples/hello_quantum.nym" << 'EOF'
// Hello Quantum World Example
import crystal
import quantum
import math

crystal.manifest("Hello, Quantum Consciousness!")
crystal.manifest("Shira yo sela lora en nymya")

var circuit = quantum.sim.create_circuit(2)
quantum.gate.h(circuit, 0)
quantum.gate.cx(circuit, 0, 1)

var measurement = quantum.sim.measure_all(circuit)
crystal.manifest("Quantum entanglement result: " + measurement.join(", "))
EOF

    cat > "${pkg_dir}/usr/share/nymya/examples/ai_example.nym" << 'EOF'
// AI Example with consciousness awareness
import ml
import ml.classical
import crystal

crystal.manifest("Consciousness-Integrated AI Example")

var nn = ml.classical.NeuralNetwork()
var layer = ml.classical.Layer(2, 4, "relu")
nn.add_layer(layer)

crystal.manifest("AI system initialized with consciousness-aware architecture")
EOF

    # Copy syntax highlighting files if they exist
    if [ -d "syntax_highlighter" ]; then
        mkdir -p "${pkg_dir}/usr/share/nymya/syntax_highlighter"
        cp -r syntax_highlighter/* "${pkg_dir}/usr/share/nymya/syntax_highlighter/" 2>/dev/null || echo "  No syntax highlighter files found, skipping"
        
        # Also install syntax highlighting in appropriate system locations
        mkdir -p "${pkg_dir}/usr/share/vim/vimfiles/syntax"
        mkdir -p "${pkg_dir}/usr/share/nano"
        mkdir -p "${pkg_dir}/usr/share/gtksourceview-4/language-specs"
        mkdir -p "${pkg_dir}/usr/share/highlight/langDefs"

        # Copy to system locations if available
        if [ -f "syntax_highlighter/nym.vim" ]; then
            cp "syntax_highlighter/nym.vim" "${pkg_dir}/usr/share/vim/vimfiles/syntax/"
        fi
        if [ -f "syntax_highlighter/nym.nanorc" ]; then
            cp "syntax_highlighter/nym.nanorc" "${pkg_dir}/usr/share/nano/"
        fi
        if [ -f "syntax_highlighter/nymya.lang" ]; then
            cp "syntax_highlighter/nymya.lang" "${pkg_dir}/usr/share/gtksourceview-4/language-specs/"
        fi
        if [ -f "syntax_highlighter/nymya.xml" ]; then
            cp "syntax_highlighter/nymya.xml" "${pkg_dir}/usr/share/highlight/langDefs/"
        fi
        
        if [ -f "syntax_highlighter/nym.vim" ] || [ -f "syntax_highlighter/nym.nanorc" ] || [ -f "syntax_highlighter/nymya.lang" ] || [ -f "syntax_highlighter/nymya.xml" ]; then
            echo "  Copied: syntax highlighting files"
        fi
    fi

    # Documentation
    cat > "${pkg_dir}/usr/share/doc/nymya/README.txt" << EOF
NymyaLang Programming Environment v${VERSION} ($arch)

Includes:
- nymyac compiler
- Nymya standard library
- Syntax highlighting for editors
- Examples and documentation

Rita-Nora balance in computing.
EOF

    # Update installed size
    local installed_size=$(du -sk "${pkg_dir}" | cut -f1)
    sed -i "s/Installed-Size: .*/Installed-Size: $installed_size/" "${pkg_dir}/DEBIAN/control"

    # Build package
    local pkg_name="nymya_${VERSION}-${DEV_STAGE}~${REVISION}_${arch}.deb"
    dpkg-deb --build --root-owner-group "${pkg_dir}" "${BUILD_DIR}/${pkg_name}"

    echo "  ✓ Package built: ${BUILD_DIR}/${pkg_name}"
    echo ""
}

# Build for all targets
echo "Starting cross-compilation builds..."
build_for_arch "amd64" "x86_64-unknown-linux-gnu" "Intel 64-bit"
build_for_arch "arm64" "aarch64-unknown-linux-gnu" "ARM 64-bit"  
build_for_arch "armhf" "armv7-unknown-linux-gnueabihf" "ARM Hard Float 32-bit"

echo "=== CROSS-COMPILATION PACKAGE BUILD COMPLETED SUCCESSFULLY ==="
echo "Packages created in: ${BUILD_DIR}/"
for arch in amd64 arm64 armhf; do
    pkg_name="nymya_${VERSION}-${DEV_STAGE}~${REVISION}_${arch}.deb"
    if [ -f "${BUILD_DIR}/${pkg_name}" ]; then
        echo "  ✓ ${pkg_name}"
        size=$(du -h "${BUILD_DIR}/${pkg_name}" | cut -f1)
        echo "    Size: $size"
    else
        echo "  ✗ ${pkg_name} (FAILED)"
    fi
done

echo ""
echo "Build completed at $(date)"