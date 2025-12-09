#!/bin/bash
# NymyaLang Package Build Script
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

echo "=== NymyaLang Package Build System v${VERSION_STRING} ==="
echo "Building .deb packages for multiple architectures: amd64, arm64, armhf"
echo ""

BUILD_DIR="nymya-build-${VERSION}"

# Create root build directory
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Function to build package for specific architecture
build_for_arch() {
    local arch=$1
    echo "Building package for architecture: $arch"
    
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
Architecture: ${arch}
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
            TARGET="x86_64-unknown-linux-gnu"
            echo "  Building for target: $TARGET"
            if [ -d nymyac ]; then
                cd nymyac && cargo build --target $TARGET --release && cd ..
                if [ -f "nymyac/target/$TARGET/release/nymyac" ]; then
                    cp "nymyac/target/$TARGET/release/nymyac" "${pkg_dir}/usr/bin/nymyac"
                else
                    echo "Error: Binary not found at nymyac/target/$TARGET/release/nymyac"
                    exit 1
                fi
            else
                echo "Error: nymyac directory not found"
                exit 1
            fi
            ;;
        "arm64")
            # Cross-compile for ARM64
            TARGET="aarch64-unknown-linux-gnu"
            echo "  Cross-compiling for target: $TARGET"
            if [ -d nymyac ]; then
                cd nymyac && cargo build --target $TARGET --release && cd ..
                if [ -f "nymyac/target/$TARGET/release/nymyac" ]; then
                    cp "nymyac/target/$TARGET/release/nymyac" "${pkg_dir}/usr/bin/nymyac"
                else
                    echo "Error: Binary not found at nymyac/target/$TARGET/release/nymyac"
                    exit 1
                fi
            else
                echo "Error: nymyac directory not found"
                exit 1
            fi
            ;;
        "armhf")
            # Cross-compile for ARMHF
            TARGET="armv7-unknown-linux-gnueabihf"
            echo "  Cross-compiling for target: $TARGET"
            if [ -d nymyac ]; then
                cd nymyac && cargo build --target $TARGET --release && cd ..
                if [ -f "nymyac/target/$TARGET/release/nymyac" ]; then
                    cp "nymyac/target/$TARGET/release/nymyac" "${pkg_dir}/usr/bin/nymyac"
                else
                    echo "Error: Binary not found at nymyac/target/$TARGET/release/nymyac"
                    exit 1
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
    mkdir -p "${pkg_dir}/usr/lib/nymya/math"
    mkdir -p "${pkg_dir}/usr/lib/nymya/ml"  
    mkdir -p "${pkg_dir}/usr/lib/nymya/networking"
    mkdir -p "${pkg_dir}/usr/lib/nymya/quantum"
    mkdir -p "${pkg_dir}/usr/lib/nymya/lowlevel"
    mkdir -p "${pkg_dir}/usr/lib/nymya/datetime"
    mkdir -p "${pkg_dir}/usr/lib/nymya/crystal"
    mkdir -p "${pkg_dir}/usr/lib/nymya/physics"
    
    # Create main category directories
    mkdir -p "${pkg_dir}/usr/lib/nymya/math"
    mkdir -p "${pkg_dir}/usr/lib/nymya/ml"
    mkdir -p "${pkg_dir}/usr/lib/nymya/networking"
    mkdir -p "${pkg_dir}/usr/lib/nymya/quantum"
    mkdir -p "${pkg_dir}/usr/lib/nymya/lowlevel"
    mkdir -p "${pkg_dir}/usr/lib/nymya/datetime"
    mkdir -p "${pkg_dir}/usr/lib/nymya/crystal"
    mkdir -p "${pkg_dir}/usr/lib/nymya/physics"
    mkdir -p "${pkg_dir}/usr/lib/nymya/system"

    # Copy all subdirectories with their contents
    for subdir in math math/gmp math/hypercalc math/functions ml ml/classical ml/quantum_ml networking networking/classical networking/quantum quantum quantum/gate quantum/sim quantum/alg datetime crystal crystal/io lowlevel physics physics/quantum system; do
        if [ -d "nymyac/library/$subdir" ]; then
            mkdir -p "${pkg_dir}/usr/lib/nymya/$subdir"
            find "nymyac/library/$subdir" -name "*.nym" -type f -exec cp {} "${pkg_dir}/usr/lib/nymya/$subdir/" \; -exec echo "  Copied: {}" \;
        fi
    done

    # Special handling for individual files in top-level directories (if any exist)

    
    # Example files
    cat > "${pkg_dir}/usr/share/nymya/examples/hello_quantum.nym" << 'EOF'
// Hello Quantum World Example
import crystal
import quantum
import math

func main() -> Void {
    crystal.manifest("Hello, Quantum Consciousness!")
    crystal.manifest("Shira yo sela lora en nymya")
    
    var circuit = quantum.sim.create_circuit(2)
    quantum.gate.h(circuit, 0)
    quantum.gate.cx(circuit, 0, 1)
    
    var measurement = quantum.sim.measure_all(circuit)
    crystal.manifest("Quantum entanglement result: " + measurement.join(", "))
}
EOF

    cat > "${pkg_dir}/usr/share/nymya/examples/ai_example.nym" << 'EOF'
// AI Example with consciousness awareness
import ml
import ml.classical
import crystal

func main() -> Void {
    crystal.manifest("Consciousness-Integrated AI Example")
    
    var nn = ml.classical.NeuralNetwork()
    var layer = ml.classical.Layer(2, 4, "relu")
    nn.add_layer(layer)
    
    crystal.manifest("AI system initialized with consciousness-aware architecture")
}
EOF
    
    # Copy syntax highlighting files
    if [ -d "syntax_highlighter" ]; then
        mkdir -p "${pkg_dir}/usr/share/nymya/syntax_highlighter"
        cp -r syntax_highlighter/* "${pkg_dir}/usr/share/nymya/syntax_highlighter/"

        # Also install syntax highlighting in appropriate system locations
        mkdir -p "${pkg_dir}/usr/share/vim/vimfiles/syntax"
        mkdir -p "${pkg_dir}/usr/share/nano"
        mkdir -p "${pkg_dir}/usr/share/gtksourceview-4/language-specs"
        mkdir -p "${pkg_dir}/usr/share/highlight/langDefs"

        # Copy to Vim syntax directory if available
        if [ -f "syntax_highlighter/nym.vim" ]; then
            cp "syntax_highlighter/nym.vim" "${pkg_dir}/usr/share/vim/vimfiles/syntax/"
        fi

        # Copy to Nano syntax directory if available
        if [ -f "syntax_highlighter/nym.nanorc" ]; then
            cp "syntax_highlighter/nym.nanorc" "${pkg_dir}/usr/share/nano/"
        fi

        # Copy to GTKSourceView language specs if available
        if [ -f "syntax_highlighter/nymya.lang" ]; then
            cp "syntax_highlighter/nymya.lang" "${pkg_dir}/usr/share/gtksourceview-4/language-specs/"
        fi

        # Copy to highlight language definitions if available
        if [ -f "syntax_highlighter/nymya.xml" ]; then
            cp "syntax_highlighter/nymya.xml" "${pkg_dir}/usr/share/highlight/langDefs/"
        fi

        echo "  Copied: syntax highlighting files"
    fi

    # Documentation
    cat > "${pkg_dir}/usr/share/doc/nymya/README.txt" << EOF
NymyaLang Programming Environment v${VERSION} (${arch})

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
    local pkg_name="nymya_${VERSION}_${arch}.deb"
    dpkg-deb --build --root-owner-group "${pkg_dir}"
    mv "${pkg_dir}.deb" "${BUILD_DIR}/${pkg_name}"
    
    echo "  ✓ Package built: ${BUILD_DIR}/${pkg_name}"
    echo ""
}

# Build for all targets
for arch in amd64 arm64 armhf; do
    build_for_arch "$arch"
done

echo "=== PACKAGE BUILD COMPLETED SUCCESSFULLY ==="
echo "Packages created in: ${BUILD_DIR}/"
for arch in amd64 arm64 armhf; do
    echo "  nymya_${VERSION}_${arch}.deb"
done

echo ""

