# Create a Dockerfile for cross-compilation
cat > Dockerfile.cross_full << 'EOF'
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_BACKTRACE=1

# Install essential build tools and cross-compilation toolchains
RUN apt-get update && \
    apt-get install -y \
    # Essential build tools  
    build-essential \
    gcc \
    g++ \
    clang \
    cmake \
    make \
    pkg-config \
    # Cross-compilation toolchains
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    gcc-x86-64-linux-gnu \
    g++-x86-64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    gcc-riscv64-linux-gnu \
    g++-riscv64-linux-gnu \
    # Additional tools
    qemu-user-static \
    qemu-system-aarch64 \
    qemu-system-x86 \
    qemu-system-x86-64 \
    qemu-system-riscv64 \
    binfmt-support \
    # Rust toolchain
    curl \
    wget \
    git \
    # Libraries
    libssl-dev \
    zlib1g-dev \
    # Utilities
    file \
    jq \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install targets for cross-compilation
RUN rustup target add \
    x86_64-unknown-linux-gnu \
    aarch64-unknown-linux-gnu \
    armv7-unknown-linux-gnueabihf \
    riscv64gc-unknown-linux-gnu

# Create workspace
WORKDIR /workspace

CMD ["/bin/bash"]
EOF

# Create a build script that uses Docker for cross-compilation
cat > build_with_docker.sh << 'SCRIPT'
#!/bin/bash

set -e  # Exit on error

# Source version info from version.conf
if [ -f "version.conf" ]; then
    source version.conf
else
    echo "version.conf not found, using default values"
    VERSION="0.2.0"
    DEV_STAGE="alpha"
    REVISION="6"
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

# Run cross-compilation for each architecture inside the container
echo "Building for x86_64..."
docker run --rm -v $(pwd):/workspace -w /workspace nymya-cross-compile \
    bash -c "cd nymyac && cargo build --target x86_64-unknown-linux-gnu --release && cd .. && mkdir -p ${BUILD_DIR}/nymya-amd64 && cp nymyac/target/x86_64-unknown-linux-gnu/release/nymyac ${BUILD_DIR}/nymya-amd64/nymyac"

echo "Building for aarch64..."
docker run --rm -v $(pwd):/workspace -w /workspace nymya-cross-compile \
    bash -c "cd nymyac && cargo build --target aarch64-unknown-linux-gnu --release && cd .. && mkdir -p ${BUILD_DIR}/nymya-arm64 && cp nymyac/target/aarch64-unknown-linux-gnu/release/nymyac ${BUILD_DIR}/nymya-arm64/nymyac"

echo "Building for armv7 (armhf)..."
docker run --rm -v $(pwd):/workspace -w /workspace nymya-cross-compile \
    bash -c "cd nymyac && cargo build --target armv7-unknown-linux-gnueabihf --release && cd .. && mkdir -p ${BUILD_DIR}/nymya-armhf && cp nymyac/target/armv7-unknown-linux-gnueabihf/release/nymyac ${BUILD_DIR}/nymya-armhf/nymyac"

# Create package structure in each directory, populate with the rest of the files and create .deb packages
for arch in amd64 arm64 armhf; do
    echo "Creating package structure for $arch..."
    PKG_DIR="${BUILD_DIR}/nymya-$arch"
    mkdir -p "$PKG_DIR/DEBIAN"
    mkdir -p "$PKG_DIR/usr/bin"
    mkdir -p "$PKG_DIR/usr/lib/nymya"
    mkdir -p "$PKG_DIR/usr/share/doc/nymya"
    mkdir -p "$PKG_DIR/usr/share/nymya/examples"
    
    # Copy the specific architecture binary to /usr/bin
    cp "$PKG_DIR/nymyac" "$PKG_DIR/usr/bin/nymyac"
    chmod +x "$PKG_DIR/usr/bin/nymyac"
    
    # Create control file for this architecture
    cat > "$PKG_DIR/DEBIAN/control" << EOF_CTRL
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
EOF_CTRL
    
    # Copy library files
    for subdir in math math/gmp math/hypercalc math/functions ml ml/classical ml/quantum_ml networking networking/classical networking/quantum quantum quantum/gate quantum/sim quantum/alg datetime crystal lowlevel physics system data_structures; do
        if [ -d "nymyac/library/$subdir" ]; then
            mkdir -p "${PKG_DIR}/usr/lib/nymya/$subdir"
            find "nymyac/library/$subdir" -name "*.nym" -type f -exec cp {} "${PKG_DIR}/usr/lib/nymya/$subdir/" \;
        fi
    done
    
    # Copy nymya executable wrapper script if it exists
    if [ -f "./nymya" ]; then
        cp "./nymya" "${PKG_DIR}/usr/bin/nymya"
        chmod +x "${PKG_DIR}/usr/bin/nymya"
    fi
    
    # Create example file
    cat > "${PKG_DIR}/usr/share/nymya/examples/hello_quantum.nym" << 'EXAMPLE_EOF'
import crystal
import math

func main() -> Void {
    crystal.manifest("Hello, Quantum Consciousness!")
    crystal.manifest("Shira yo sela lora en nymya")
    
    var result = math.sqrt(16.0)
    crystal.manifest("Square root of 16: " + result)
}
EXAMPLE_EOF
    
    # Calculate installed size
    INSTALLED_SIZE=$(du -sk "$PKG_DIR" | cut -f1)
    sed -i "s/Installed-Size: .*/Installed-Size: $INSTALLED_SIZE/" "$PKG_DIR/DEBIAN/control"
    
    # Build the package
    case $arch in
        "arm64")  pkg_arch="arm64" ;;
        "armhf")  pkg_arch="armhf" ;;  
        *)        pkg_arch="amd64" ;;
    esac
    
    dpkg-deb --build --root-owner-group "$PKG_DIR" "${BUILD_DIR}/nymya_${VERSION}_${pkg_arch}.deb"
    echo "Built package: ${BUILD_DIR}/nymya_${VERSION}_${pkg_arch}.deb"
done

echo "All packages built successfully in ${BUILD_DIR}/"
ls -la ${BUILD_DIR}/*.deb
SCRIPT

chmod +x build_with_docker.sh

# Build the packages using Docker
./build_with_docker.sh

# Update the revision number in version.conf
echo "Updating revision from 6 to 7..."
sed -i 's/REVISION="6"/REVISION="7"/' version.conf
echo "Updated version.conf to revision 7"

# Rebuild with the new revision
./build_with_docker.sh

# Create a git commit for all changes
git add . && git commit -m "Fix ARMHF compilation by using Docker-based cross-compilation environment, update revision to 7"

# Push the changes
./scripts/git_push.sh