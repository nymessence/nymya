# Dockerfile for NymyaLang Cross-Compilation Environment
# Supports ARM64, x86_64, and RISC-V64 targets

FROM ubuntu:22.04

LABEL maintainer="Erick"
LABEL description="Cross-compilation environment for NymyaLang targeting ARM64, x86_64, and RISC-V64"

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

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
    # Additional tools
    curl \
    wget \
    git \
    rust-all \
    cargo \
    # Libraries
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    # Utilities
    gdb-multiarch \
    binutils-dev \
    file \
    unzip \
    zip \
    tar \
    rsync \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up Rust for cross-compilation
RUN rustup target add aarch64-unknown-linux-gnu \
    x86_64-unknown-linux-gnu \
    riscv64gc-unknown-linux-gnu

# Install additional Rust tools
RUN rustup component add rust-src

# Create directory structure for the NymyaLang project
WORKDIR /opt/nymya

# Copy the nymyac source code (assuming we're building inside the container)
COPY ./nymyac /opt/nymya/nymyac

# Set up cross-compilation configurations
RUN mkdir -p /opt/nymya/configs

# Create configuration files for cross-compilation
RUN echo '[target.aarch64-unknown-linux-gnu]' > /opt/nymya/configs/config.toml && \
    echo 'linker = "aarch64-linux-gnu-gcc"' >> /opt/nymya/configs/config.toml && \
    echo '' >> /opt/nymya/configs/config.toml && \
    echo '[target.x86_64-unknown-linux-gnu]' >> /opt/nymya/configs/config.toml && \
    echo 'linker = "x86_64-linux-gnu-gcc"' >> /opt/nymya/configs/config.toml && \
    echo '' >> /opt/nymya/configs/config.toml && \
    echo '[target.riscv64gc-unknown-linux-gnu]' >> /opt/nymya/configs/config.toml && \
    echo 'linker = "riscv64-linux-gnu-gcc"' >> /opt/nymya/configs/config.toml

# Set up cargo configuration for cross-compilation
RUN mkdir -p ~/.cargo && \
    echo '[build]' > ~/.cargo/config.toml && \
    echo 'target-dir = "/opt/nymya/target"' >> ~/.cargo/config.toml

# Copy the configuration to cargo directory
RUN cp /opt/nymya/configs/config.toml ~/.cargo/

# Create build scripts
RUN echo '#!/bin/bash' > /opt/nymya/build_arm64.sh && \
    echo '# Build for ARM64' >> /opt/nymya/build_arm64.sh && \
    echo 'cd /opt/nymya/nymyac' >> /opt/nymya/build_arm64.sh && \
    echo 'cargo build --target aarch64-unknown-linux-gnu --release' >> /opt/nymya/build_arm64.sh && \
    chmod +x /opt/nymya/build_arm64.sh

RUN echo '#!/bin/bash' > /opt/nymya/build_x86_64.sh && \
    echo '# Build for x86_64' >> /opt/nymya/build_x86_64.sh && \
    echo 'cd /opt/nymya/nymyac' >> /opt/nymya/build_x86_64.sh && \
    echo 'cargo build --target x86_64-unknown-linux-gnu --release' >> /opt/nymya/build_x86_64.sh && \
    chmod +x /opt/nymya/build_x86_64.sh

RUN echo '#!/bin/bash' > /opt/nymya/build_riscv64.sh && \
    echo '# Build for RISC-V64' >> /opt/nymya/build_riscv64.sh && \
    echo 'cd /opt/nymya/nymyac' >> /opt/nymya/build_riscv64.sh && \
    echo 'cargo build --target riscv64gc-unknown-linux-gnu --release' >> /opt/nymya/build_riscv64.sh && \
    chmod +x /opt/nymya/build_riscv64.sh

RUN echo '#!/bin/bash' > /opt/nymya/build_all.sh && \
    echo '# Build for all targets' >> /opt/nymya/build_all.sh && \
    echo './build_arm64.sh' >> /opt/nymya/build_all.sh && \
    echo './build_x86_64.sh' >> /opt/nymya/build_all.sh && \
    echo './build_riscv64.sh' >> /opt/nymya/build_all.sh && \
    chmod +x /opt/nymya/build_all.sh

# Create a comprehensive build script
RUN echo '#!/bin/bash' > /opt/nymya/build_comprehensive.sh && \
    echo '' >> /opt/nymya/build_comprehensive.sh && \
    echo 'echo "Starting cross-compilation for NymyaLang compiler..."' >> /opt/nymya/build_comprehensive.sh && \
    echo '' >> /opt/nymya/build_comprehensive.sh && \
    echo '# Build for ARM64' >> /opt/nymya/build_comprehensive.sh && \
    echo 'echo "Building for ARM64..." && \' >> /opt/nymya/build_comprehensive.sh && \
    echo 'cd /opt/nymya/nymyac && \' >> /opt/nymya/build_comprehensive.sh && \
    echo 'cargo clean && \' >> /opt/nymya/build_comprehensive.sh && \
    echo 'cargo build --target aarch64-unknown-linux-gnu --release && \' >> /opt/nymya/build_comprehensive.sh && \
    echo 'echo "ARM64 build completed" && \' >> /opt/nymya/build_comprehensive.sh && \
    echo '' >> /opt/nymya/build_comprehensive.sh && \
    echo '# Build for x86_64' >> /opt/nymya/build_comprehensive.sh && \
    echo 'echo "Building for x86_64..." && \' >> /opt/nymya/build_comprehensive.sh && \
    echo 'cargo clean && \' >> /opt/nymya/build_comprehensive.sh && \
    echo 'cargo build --target x86_64-unknown-linux-gnu --release && \' >> /opt/nymya/build_comprehensive.sh && \
    echo 'echo "x86_64 build completed" && \' >> /opt/nymya/build_comprehensive.sh && \
    echo '' >> /opt/nymya/build_comprehensive.sh && \
    echo '# Build for RISC-V64' >> /opt/nymya/build_comprehensive.sh && \
    echo 'echo "Building for RISC-V64..." && \' >> /opt/nymya/build_comprehensive.sh && \
    echo 'cargo clean && \' >> /opt/nymya/build_comprehensive.sh && \
    echo 'cargo build --target riscv64gc-unknown-linux-gnu --release && \' >> /opt/nymya/build_comprehensive.sh && \
    echo 'echo "RISC-V64 build completed" && \' >> /opt/nymya/build_comprehensive.sh && \
    echo '' >> /opt/nymya/build_comprehensive.sh && \
    echo 'echo "All cross-compilation builds completed successfully!"' >> /opt/nymya/build_comprehensive.sh && \
    chmod +x /opt/nymya/build_comprehensive.sh

# Set up environment variables
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc
ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=x86_64-linux-gnu-gcc
ENV CARGO_TARGET_RISCV64GC_UNKNOWN_LINUX_GNU_LINKER=riscv64-linux-gnu-gcc

# Install test dependencies
RUN apt-get update && \
    apt-get install -y \
    qemu-user-static \
    qemu-system-aarch64 \
    qemu-system-riscv64 \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a test script for validating builds
RUN echo '#!/bin/bash' > /opt/nymya/test_builds.sh && \
    echo '# Test cross-compiled binaries' >> /opt/nymya/test_builds.sh && \
    echo 'echo "Testing ARM64 build..."' >> /opt/nymya/test_builds.sh && \
    echo 'if [ -f "/opt/nymya/nymyac/target/aarch64-unknown-linux-gnu/release/nymyac" ]; then' >> /opt/nymya/test_builds.sh && \
    echo '  echo "ARM64 binary exists: $(file /opt/nymya/nymyac/target/aarch64-unknown-linux-gnu/release/nymyac)"' >> /opt/nymya/test_builds.sh && \
    echo 'else' >> /opt/nymya/test_builds.sh && \
    echo '  echo "ERROR: ARM64 binary not found!"' >> /opt/nymya/test_builds.sh && \
    echo 'fi' >> /opt/nymya/test_builds.sh && \
    echo '' >> /opt/nymya/test_builds.sh && \
    echo 'echo "Testing x86_64 build..."' >> /opt/nymya/test_builds.sh && \
    echo 'if [ -f "/opt/nymya/nymyac/target/x86_64-unknown-linux-gnu/release/nymyac" ]; then' >> /opt/nymya/test_builds.sh && \
    echo '  echo "x86_64 binary exists: $(file /opt/nymya/nymyac/target/x86_64-unknown-linux-gnu/release/nymyac)"' >> /opt/nymya/test_builds.sh && \
    echo 'else' >> /opt/nymya/test_builds.sh && \
    echo '  echo "ERROR: x86_64 binary not found!"' >> /opt/nymya/test_builds.sh && \
    echo 'fi' >> /opt/nymya/test_builds.sh && \
    echo '' >> /opt/nymya/test_builds.sh && \
    echo 'echo "Testing RISC-V64 build..."' >> /opt/nymya/test_builds.sh && \
    echo 'if [ -f "/opt/nymya/nymyac/target/riscv64gc-unknown-linux-gnu/release/nymyac" ]; then' >> /opt/nymya/test_builds.sh && \
    echo '  echo "RISC-V64 binary exists: $(file /opt/nymya/nymyac/target/riscv64gc-unknown-linux-gnu/release/nymyac)"' >> /opt/nymya/test_builds.sh && \
    echo 'else' >> /opt/nymya/test_builds.sh && \
    echo '  echo "ERROR: RISC-V64 binary not found!"' >> /opt/nymya/test_builds.sh && \
    echo 'fi' >> /opt/nymya/test_builds.sh && \
    chmod +x /opt/nymya/test_builds.sh

# Create a README for the container
RUN echo "# NymyaLang Cross-Compilation Container" > /opt/nymya/README.md && \
    echo "" >> /opt/nymya/README.md && \
    echo "This container provides a complete cross-compilation environment for NymyaLang," >> /opt/nymya/README.md && \
    echo "supporting ARM64, x86_64, and RISC-V64 targets." >> /opt/nymya/README.md && \
    echo "" >> /opt/nymya/README.md && \
    echo "## Available Commands" >> /opt/nymya/README.md && \
    echo "" >> /opt/nymya/README.md && \
    echo "- \`/opt/nymya/build_arm64.sh\`: Build for ARM64" >> /opt/nymya/README.md && \
    echo "- \`/opt/nymya/build_x86_64.sh\`: Build for x86_64" >> /opt/nymya/README.md && \
    echo "- \`/opt/nymya/build_riscv64.sh\`: Build for RISC-V64" >> /opt/nymya/README.md && \
    echo "- \`/opt/nymya/build_all.sh\`: Build for all targets" >> /opt/nymya/README.md && \
    echo "- \`/opt/nymya/build_comprehensive.sh\`: Comprehensive build script" >> /opt/nymya/README.md && \
    echo "- \`/opt/nymya/test_builds.sh\`: Test the built binaries" >> /opt/nymya/README.md

RUN echo "export PATH=\$PATH:/opt/nymya" >> ~/.bashrc

WORKDIR /opt/nymya

CMD ["/bin/bash"]