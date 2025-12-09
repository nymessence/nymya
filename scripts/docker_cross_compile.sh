#!/bin/bash

# Docker-based Cross-Compilation System for NymyaLang
# Builds NymyaLang compiler for multiple architectures using Docker containers

set -e  # Exit on error

echo "=== NymyaLang Docker-Based Cross-Compilation System ==="
echo ""

# Define output directory
OUTPUT_DIR="cross_build_output"
mkdir -p $OUTPUT_DIR

# Create Dockerfile for cross-compilation environment
cat > Dockerfile.cross_compile << 'DOCKERFILE'
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
    gcc-riscv64-linux-gnu \
    g++-riscv64-linux-gnu \
    # Additional tools for cross-compilation
    qemu-user-static \
    qemu-system-aarch64 \
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
    && \
    rm -rf /var/lib/apt/lists/*

# Install Rust using rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install target architectures for cross-compilation
RUN rustup target add \
    x86_64-unknown-linux-gnu \
    aarch64-unknown-linux-gnu \
    riscv64gc-unknown-linux-gnu

# Configure cargo for cross-compilation
RUN mkdir -p ~/.cargo && \
    echo '[target.x86_64-unknown-linux-gnu]' > ~/.cargo/config && \
    echo 'linker = "x86_64-linux-gnu-gcc"' >> ~/.cargo/config && \
    echo '' >> ~/.cargo/config && \
    echo '[target.aarch64-unknown-linux-gnu]' >> ~/.cargo/config && \
    echo 'linker = "aarch64-linux-gnu-gcc"' >> ~/.cargo/config && \
    echo '' >> ~/.cargo/config && \
    echo '[target.riscv64gc-unknown-linux-gnu]' >> ~/.cargo/config && \
    echo 'linker = "riscv64-linux-gnu-gcc"' >> ~/.cargo/config

WORKDIR /workspace

# Copy source code
COPY . /workspace/

CMD ["/bin/bash"]
DOCKERFILE

# Create build script for individual targets
cat > build_target.sh << 'BUILD_SCRIPT'
#!/bin/bash

# Build script for target architecture inside Docker
TARGET=$1
OUTPUT_DIR=$2

if [ -z "$TARGET" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 <target> <output_dir>"
    echo "Example: $0 x86_64-unknown-linux-gnu output_x86_64"
    exit 1
fi

echo "Building for target: $TARGET"

# Create output directory
mkdir -p "/workspace/$OUTPUT_DIR"

# Check if nymyac directory exists
if [ ! -d "/workspace/nymyac" ]; then
    echo "Error: nymyac directory not found"
    exit 1
fi

# Build the compiler for the specific target
cd /workspace/nymyac
cargo build --target "$TARGET" --release

if [ -f "target/$TARGET/release/nymyac" ]; then
    cp "target/$TARGET/release/nymyac" "/workspace/$OUTPUT_DIR/nymyac"
    echo "Successfully built nymyac for $TARGET"
else
    echo "Error: Binary not found for $TARGET at target/$TARGET/release/nymyac"
    exit 1
fi

# Copy the main nymya executable script
cp "/workspace/nymya" "/workspace/$OUTPUT_DIR/nymya"
chmod +x "/workspace/$OUTPUT_DIR/nymya"

echo "Build completed for $TARGET in /workspace/$OUTPUT_DIR"
BUILD_SCRIPT

chmod +x build_target.sh

# Build Docker image
echo "Building Docker image for cross-compilation..."
docker build -f Dockerfile.cross_compile -t nymya-cross-compiler .

# Define target architectures to build
TARGETS=(
    "x86_64-unknown-linux-gnu:amd64"
    "aarch64-unknown-linux-gnu:arm64" 
    "riscv64gc-unknown-linux-gnu:riscv64"
)

echo "Cross-compiling for target architectures:"

# Build for each target architecture
for target_mapping in "${TARGETS[@]}"; do
    TARGET=$(echo "$target_mapping" | cut -d: -f1)
    ARCH=$(echo "$target_mapping" | cut -d: -f2)
    
    echo "  Building for $TARGET ($ARCH)..."
    
    # Create output directory for this target
    CONTAINER_OUTPUT_DIR="build_$ARCH"
    mkdir -p "$OUTPUT_DIR/$CONTAINER_OUTPUT_DIR"
    
    # Run build in Docker container for this target
    docker run --rm \
        -v "$PWD/$OUTPUT_DIR/$CONTAINER_OUTPUT_DIR":/workspace/output_dir \
        -v "$PWD":/workspace/src \
        -e TARGET="$TARGET" \
        -e OUTPUT_DIR="output_dir" \
        nymya-cross-compiler \
        bash -c "cd /workspace/src && ./build_target.sh '$TARGET' '/workspace/output_dir'"
    
    # Create .deb package for this architecture
    echo "    Creating .deb package for $ARCH..."
    
    # Create package directory structure
    PKG_DIR="pkg_temp_$ARCH"
    rm -rf "$PKG_DIR"
    mkdir -p "$PKG_DIR/DEBIAN"
    mkdir -p "$PKG_DIR/usr/bin"
    mkdir -p "$PKG_DIR/usr/lib/nymya"
    mkdir -p "$PKG_DIR/usr/share/doc/nymya"
    mkdir -p "$PKG_DIR/usr/share/nymya/examples"
    mkdir -p "$PKG_DIR/usr/share/nymya/library"
    
    # Copy built binaries
    if [ -f "$OUTPUT_DIR/$CONTAINER_OUTPUT_DIR/nymyac" ]; then
        cp "$OUTPUT_DIR/$CONTAINER_OUTPUT_DIR/nymyac" "$PKG_DIR/usr/bin/nymyac"
        cp "$OUTPUT_DIR/$CONTAINER_OUTPUT_DIR/nymya" "$PKG_DIR/usr/bin/nymya"
        chmod +x "$PKG_DIR/usr/bin/nymyac"
        chmod +x "$PKG_DIR/usr/bin/nymya"
        
        # Copy library files
        if [ -d "/workspace/src/nymyac/library" ]; then
            cp -r /workspace/src/nymyac/library/* "$PKG_DIR/usr/lib/nymya/"
        fi
        
        # Create control file for the package
        cat > "$PKG_DIR/DEBIAN/control" << CONTROL_EOF
Package: nymya
Version: 0.2.0-alpha~4
Section: devel
Priority: optional
Architecture: $ARCH
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
CONTROL_EOF
        
        # Calculate actual installed size
        ACTUAL_SIZE=$(du -sk "$PKG_DIR" | cut -f1)
        sed -i "s/Installed-Size: .*/Installed-Size: $ACTUAL_SIZE/" "$PKG_DIR/DEBIAN/control"
        
        # Build the package
        PKG_NAME="nymya_0.2.0-alpha~4_${ARCH}.deb"
        dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT_DIR/$PKG_NAME"
        
        echo "    Created package: $OUTPUT_DIR/$PKG_NAME"
        
        # Cleanup
        rm -rf "$PKG_DIR"
    else
        echo "    Warning: No binary found for $ARCH, skipping package creation"
    fi
done

echo ""
echo "=== Docker-Based Cross-Compilation Completed ==="
echo "Packages created in $OUTPUT_DIR/:"
ls -la "$OUTPUT_DIR"/*.deb

# Cleanup Docker image
docker rmi -f nymya-cross-compiler >/dev/null 2>&1 || true

echo ""
echo "Cross-compilation successful! All packages ready in $OUTPUT_DIR/"