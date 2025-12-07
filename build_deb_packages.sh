#!/bin/bash
# Build script for creating NymyaLang Compiler .deb packages

set -e  # Exit on error

# Define architectures
ARCHITECTURES=("amd64" "arm64" "armhf")
COMPILER_NAME="nymyac"
VERSION="0.1.0"

# Function to build for a specific architecture
build_for_arch() {
    local arch=$1
    echo "Building $COMPILER_NAME for architecture: $arch"
    
    # Create package directory structure
    PKG_DIR="pkg_${COMPILER_NAME}_${VERSION}_${arch}"
    rm -rf "${PKG_DIR}"  # Clean previous build
    mkdir -p "${PKG_DIR}/DEBIAN"
    mkdir -p "${PKG_DIR}/usr/bin"
    mkdir -p "${PKG_DIR}/usr/lib/nymyac"
    mkdir -p "${PKG_DIR}/usr/share/doc/nymyac"
    mkdir -p "${PKG_DIR}/usr/share/nymyac/examples"
    
    # Determine binary source based on architecture
    # In a real scenario, we would cross-compile or use binaries built for each arch
    # For now, we'll show the structure
    case $arch in
        "amd64")
            # This would typically have an amd64 binary
            echo "Creating mock amd64 binary for $COMPILER_NAME"
            echo "#!/bin/sh" > "${PKG_DIR}/usr/bin/${COMPILER_NAME}"
            echo "echo 'This is the ${COMPILER_NAME} compiler for $arch'" >> "${PKG_DIR}/usr/bin/${COMPILER_NAME}"
            chmod +x "${PKG_DIR}/usr/bin/${COMPILER_NAME}"
            ;;
        "arm64")
            # This would typically have an arm64 binary
            echo "Creating mock arm64 binary for $COMPILER_NAME"
            echo "#!/bin/sh" > "${PKG_DIR}/usr/bin/${COMPILER_NAME}"
            echo "echo 'This is the ${COMPILER_NAME} compiler for $arch'" >> "${PKG_DIR}/usr/bin/${COMPILER_NAME}"
            chmod +x "${PKG_DIR}/usr/bin/${COMPILER_NAME}"
            ;;
        "armhf")
            # This would typically have an armhf binary
            echo "Creating mock armhf binary for $COMPILER_NAME"
            echo "#!/bin/sh" > "${PKG_DIR}/usr/bin/${COMPILER_NAME}"
            echo "echo 'This is the ${COMPILER_NAME} compiler for $arch'" >> "${PKG_DIR}/usr/bin/${COMPILER_NAME}"
            chmod +x "${PKG_DIR}/usr/bin/${COMPILER_NAME}"
            ;;
        *)
            echo "Unsupported architecture: $arch"
            return 1
            ;;
    esac
    
    # Add mock library files (would be real compiled libraries in real deployment)
    echo "Mock NymyaLang standard library" > "${PKG_DIR}/usr/lib/nymyac/std.nym"
    echo "Mock math library" > "${PKG_DIR}/usr/lib/nymyac/math.nym"
    echo "Mock quantum library" > "${PKG_DIR}/usr/lib/nymyac/quantum.nym"
    echo "Mock math functions library" > "${PKG_DIR}/usr/lib/nymyac/functions.nym"
    echo "Mock lowlevel library" > "${PKG_DIR}/usr/lib/nymyac/lowlevel.nym"
    echo "Mock networking library" > "${PKG_DIR}/usr/lib/nymyac/networking.nym"
    echo "Mock machine learning library" > "${PKG_DIR}/usr/lib/nymyac/ai_ml.nym"
    
    # Add example files
    echo "import math" > "${PKG_DIR}/usr/share/nymyac/examples/hello.nym"
    echo "import crystal" >> "${PKG_DIR}/usr/share/nymyac/examples/hello.nym"
    echo "" >> "${PKG_DIR}/usr/share/nymyac/examples/hello.nym"
    echo "func main() -> Void {" >> "${PKG_DIR}/usr/share/nymyac/examples/hello.nym"
    echo "    crystal.manifest(\"Hello from NymyaLang!\")" >> "${PKG_DIR}/usr/share/nymyac/examples/hello.nym"
    echo "    crystal.manifest(\"Compiled for ${arch}\")" >> "${PKG_DIR}/usr/share/nymyac/examples/hello.nym"
    echo "}" >> "${PKG_DIR}/usr/share/nymyac/examples/hello.nym"
    
    echo "import quantum" > "${PKG_DIR}/usr/share/nymyac/examples/quantum_hello.nym"
    echo "import crystal" >> "${PKG_DIR}/usr/share/nymyac/examples/quantum_hello.nym"
    echo "" >> "${PKG_DIR}/usr/share/nymyac/examples/quantum_hello.nym"
    echo "func main() -> Void {" >> "${PKG_DIR}/usr/share/nymyac/examples/quantum_hello.nym"
    echo "    var qubit = quantum.Qubit.zero()" >> "${PKG_DIR}/usr/share/nymyac/examples/quantum_hello.nym"
    echo "    crystal.manifest(\"Quantum hello from NymyaLang on ${arch}!\")" >> "${PKG_DIR}/usr/share/nymyac/examples/quantum_hello.nym"
    echo "}" >> "${PKG_DIR}/usr/share/nymyac/examples/quantum_hello.nym"
    
    # Add documentation
    echo "NymyaLang Compiler - Version ${VERSION}" > "${PKG_DIR}/usr/share/doc/nymyac/README.md"
    echo "===============================" >> "${PKG_DIR}/usr/share/doc/nymyac/README.md"
    echo "" >> "${PKG_DIR}/usr/share/doc/nymyac/README.md"
    echo "This is the NymyaLang Compiler package for ${arch} architecture." >> "${PKG_DIR}/usr/share/doc/nymyac/README.md"
    echo "" >> "${PKG_DIR}/usr/share/doc/nymyac/README.md"
    echo "Usage:" >> "${PKG_DIR}/usr/share/doc/nymyac/README.md"
    echo "  ${COMPILER_NAME} <input.nym> -o <output>" >> "${PKG_DIR}/usr/share/doc/nymyac/README.md"
    echo "" >> "${PKG_DIR}/usr/share/doc/nymyac/README.md"
    echo "Examples can be found in /usr/share/nymyac/examples/" >> "${PKG_DIR}/usr/share/doc/nymyac/README.md"
    
    # Create control file with architecture-specific info
    cat > "${PKG_DIR}/DEBIAN/control" << EOF
Package: ${COMPILER_NAME}
Version: ${VERSION}
Section: devel
Priority: optional
Architecture: ${arch}
Depends: libc6 (>= 2.14), libgcc1 (>= 1:4.1.1)
Maintainer: Nymessence Team <nymessence@example.com>
Installed-Size: 2048
Homepage: https://github.com/nymya/nymyac
Description: NymyaLang Compiler - Compiles .nym files to executable code
 The NymyaLang Compiler (nymyac) is a cutting-edge compiler for the
 NymyaLang programming language, which features consciousness-aware
 programming constructs, quantum computing integration, and advanced
 mathematical operations.
 .
 Key features include:
 * Quantum computing integration with quantum gates and algorithms
 * Advanced mathematical functions with hypercalc capabilities
 * Consciousness-aware programming paradigm with Rita-Nora balance
 * Networking capabilities with classical and quantum networking
 * AI/ML and Quantum ML libraries for machine learning
 * Low-level bit shift and system operations support
 * Photonic chip driver interface for quantum hardware
 .
 This compiler transforms .nym source files into executable code,
 enabling developers to write consciousness-integrated applications.
EOF
    
    # Set proper permissions
    chmod 644 "${PKG_DIR}/usr/lib/nymyac/"*
    chmod 644 "${PKG_DIR}/usr/share/nymyac/examples/"*
    chmod 644 "${PKG_DIR}/usr/share/doc/nymyac/"*
    chmod 755 "${PKG_DIR}/usr/bin/${COMPILER_NAME}"
    
    # Calculate installed-size
    INSTALLED_SIZE=$(du -sb "${PKG_DIR}" | cut -f1)
    sed -i "s/Installed-Size: .*/Installed-Size: ${INSTALLED_SIZE}/" "${PKG_DIR}/DEBIAN/control"
    
    echo "Packaging $COMPILER_NAME for $arch..."
    dpkg-deb --build --root-owner-group "${PKG_DIR}"
    
    echo "Built package: ${PKG_DIR}.deb"
    
    # Move to appropriate architecture folder
    mkdir -p "debian_packages/${arch}"
    mv "${PKG_DIR}.deb" "debian_packages/${arch}/"
    
    echo "Package for ${arch} created successfully!"
}

# Build for all architectures
for arch in "${ARCHITECTURES[@]}"; do
    build_for_arch "$arch"
done

echo ""
echo "All packages built successfully! Find them in:"
for arch in "${ARCHITECTURES[@]}"; do
    echo "  - debian_packages/${arch}/${COMPILER_NAME}_${VERSION}_${arch}.deb"
done