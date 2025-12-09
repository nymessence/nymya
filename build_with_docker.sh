#!/bin/bash

set -e  # Exit on error

# Source version info from version.conf
if [ -f "version.conf" ]; then
    source version.conf
else
    echo "version.conf not found, using default values"
    VERSION="0.2.0"
    DEV_STAGE="alpha"
    REVISION="6"  # Start with existing revision
    BUILD_DIR="nymya-build-${VERSION}"
    VERSION_STRING="${VERSION}-${DEV_STAGE}~${REVISION}"
fi

echo "Building NymyaLang packages for all architectures using Docker..."
echo "Version: ${VERSION_STRING}"

# Create build directory
BUILD_DIR="nymya-build-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Build Docker image
echo "Building cross-compilation Docker image..."
docker build -f Dockerfile.cross_full -t nymya-cross-compile .

# Create temporary directory for Docker builds to ensure all source files are available
mkdir -p docker_build_context
cp -r .[^.]* ..?* .??* docker_build_context/ 2>/dev/null || cp -r * docker_build_context/  # Copy all files including hidden ones

# Run cross-compilation for each architecture inside the container
echo "Building for x86_64..."
docker run --rm -v $(pwd)/docker_build_context:/workspace -w /workspace nymya-cross-compile \
    bash -c "cd nymyac && cargo build --target x86_64-unknown-linux-gnu --release && cd .. && mkdir -p ${BUILD_DIR}/nymya-amd64 && cp nymyac/target/x86_64-unknown-linux-gnu/release/nymyac ${BUILD_DIR}/nymya-amd64/usr_bin_nymyac"

echo "Building for aarch64..."
docker run --rm -v $(pwd)/docker_build_context:/workspace -w /workspace nymya-cross-compile \
    bash -c "cd nymyac && cargo build --target aarch64-unknown-linux-gnu --release && cd .. && mkdir -p ${BUILD_DIR}/nymya-arm64 && cp nymyac/target/aarch64-unknown-linux-gnu/release/nymyac ${BUILD_DIR}/nymya-arm64/usr_bin_nymyac"

echo "Building for armv7 (armhf)..."
docker run --rm -v $(pwd)/docker_build_context:/workspace -w /workspace nymya-cross-compile \
    bash -c "cd nymyac && cargo build --target armv7-unknown-linux-gnueabihf --release && cd .. && mkdir -p ${BUILD_DIR}/nymya-armhf && cp nymyac/target/armv7-unknown-linux-gnueabihf/release/nymyac ${BUILD_DIR}/nymya-armhf/usr_bin_nymyac"

# Now create proper package structures and .deb files for each architecture
for arch_suffix in amd64 arm64 armhf; do
    echo "Creating package structure for $arch_suffix..."
    
    # Determine proper target architecture name and package architecture
    case $arch_suffix in
        "amd64")
            target_arch="x86_64"
            pkg_arch="amd64"
            bin_dir="${BUILD_DIR}/nymya-amd64"
            ;;
        "arm64")
            target_arch="aarch64"
            pkg_arch="arm64"
            bin_dir="${BUILD_DIR}/nymya-arm64"
            ;;
        "armhf")
            target_arch="armv7"
            pkg_arch="armhf"
            bin_dir="${BUILD_DIR}/nymya-armhf"
            ;;
        *)
            echo "Unknown architecture: $arch_suffix"
            continue
            ;;
    esac
    
    # Create package directory structure
    pkg_dir="${BUILD_DIR}/nymya-${pkg_arch}"
    rm -rf "$pkg_dir"  # Clean up any previous attempts
    mkdir -p "$pkg_dir/DEBIAN"
    mkdir -p "$pkg_dir/usr/bin"
    mkdir -p "$pkg_dir/usr/lib/nymya"
    mkdir -p "$pkg_dir/usr/share/doc/nymya"
    mkdir -p "$pkg_dir/usr/share/nymya/examples"
    
    # Copy the appropriate binary to the package
    if [ -f "${bin_dir}/usr_bin_nymyac" ]; then
        mkdir -p "${pkg_dir}/usr/bin"
        cp "${bin_dir}/usr_bin_nymyac" "${pkg_dir}/usr/bin/nymyac"
        chmod +x "${pkg_dir}/usr/bin/nymyac"
    elif [ -f "${bin_dir}/nymyac" ]; then
        mkdir -p "${pkg_dir}/usr/bin"
        cp "${bin_dir}/nymyac" "${pkg_dir}/usr/bin/nymyac"
        chmod +x "${pkg_dir}/usr/bin/nymyac"
    else
        echo "ERROR: Binary not found for $arch_suffix"
        continue
    fi
    
    # Copy the nymya wrapper script if it exists
    if [ -f "./nymya" ]; then
        cp "./nymya" "${pkg_dir}/usr/bin/nymya"
        chmod +x "${pkg_dir}/usr/bin/nymya"
    fi
    
    # Create control file for this architecture
    cat > "${pkg_dir}/DEBIAN/control" << CTRL_EOF
Package: nymya
Version: ${VERSION}-${DEV_STAGE}~${REVISION}
Section: devel
Priority: optional
Architecture: ${pkg_arch}
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
CTRL_EOF
    
    # Copy library files for this architecture
    for subdir in math math/gmp math/hypercalc math/functions ml ml/classical ml/quantum_ml networking networking/classical networking/quantum quantum quantum/gate quantum/sim quantum/alg datetime crystal crystal/io lowlevel physics system data_structures symbolic symbolic/numerology symbolic/sacred_geometry symbolic/primes symbolic/repeating symbolic/special symbolic/integration; do
        if [ -d "nymyac/library/$subdir" ]; then
            mkdir -p "${pkg_dir}/usr/lib/nymya/$subdir"
            find "nymyac/library/$subdir" -name "*.nym" -type f -exec cp {} "${pkg_dir}/usr/lib/nymya/$subdir/" \; 2>/dev/null || true
        fi
    done
    
    # Create an example file for testing
    cat > "${pkg_dir}/usr/share/nymya/examples/simple_test.nym" << 'EXAMPLE_EOF'
// Simple test program
import crystal
import math

crystal.manifest("NymyaLang v0.2.0 test successful!")
var result = math.sqrt(16.0)
crystal.manifest("Square root of 16 = " + result)
EXAMPLE_EOF
    
    # Calculate installed size for real
    INSTALLED_SIZE=$(du -sk "$pkg_dir" | cut -f1)
    sed -i "s/Installed-Size: .*/Installed-Size: $INSTALLED_SIZE/" "${pkg_dir}/DEBIAN/control"
    
    # Build the .deb package
    package_name="${BUILD_DIR}/nymya_${VERSION}_${pkg_arch}.deb"
    dpkg-deb --build --root-owner-group "$pkg_dir" "$package_name"
    echo "  ✓ Built package: $package_name"
done

echo ""
echo "All packages built successfully in ${BUILD_DIR}/:"
ls -la ${BUILD_DIR}/*.deb

# Cleanup
rm -rf docker_build_context