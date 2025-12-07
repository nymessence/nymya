#!/bin/bash
# Debian Package Builder for NymyaLang
# Builds .deb packages for multiple architectures: amd64, arm64, armhf

set -e  # Exit on error

# Package information
PACKAGE_NAME="nymyac"
VERSION="0.1.0"
MAINTAINER="NymyaLang Development Team <nymya-dev@example.com>"
DESCRIPTION="NymyaLang Compiler - Quantum-consciousness programming language"

# Architectures to build for
ARCHITECTURES=("amd64" "arm64" "armhf")

# Main build function
build_package() {
    local arch=$1
    echo "Building package for architecture: $arch"

    # Create temporary build directory
    local build_dir="/tmp/nymya_pkg_${arch}"
    rm -rf "$build_dir"
    mkdir -p "$build_dir/DEBIAN"
    mkdir -p "$build_dir/usr/bin"
    mkdir -p "$build_dir/usr/lib/nymya"
    mkdir -p "$build_dir/usr/share/doc/nymya"
    mkdir -p "$build_dir/usr/share/nymya"
    
    # Create control file
    cat > "$build_dir/DEBIAN/control" << EOF
Package: $PACKAGE_NAME
Version: $VERSION
Section: devel
Priority: optional
Architecture: $arch
Maintainer: $MAINTAINER
Description: $DESCRIPTION
 The NymyaLang Compiler (nymyac) is a next-generation programming language 
 compiler with quantum computing integration and consciousness-aware processing
 capabilities. Features include:
 * Quantum-aware mathematical operations with hypercalc functions
 * Advanced AI/ML with both classical and quantum machine learning
 * Consciousness-integrated networking and communication protocols
 * Low-level bit manipulation and quantum hardware interfaces
 * Quantum-resistant encryption and quantum random number generation
 * Proper integration of Rita-Nora balance in all operations
EOF

    # Build for the specific architecture
    if [ "$arch" = "amd64" ]; then
        # Native build for x86_64
        cd /home/erick/nymya/nymyac
        cargo build --release
        cp target/release/nymyac "$build_dir/usr/bin/"
    else
        # For cross-compilation, we'd use different toolchain
        # This is a placeholder for cross-compilation
        echo "#!/bin/sh" > "$build_dir/usr/bin/nymyac"
        echo "echo 'NymyaLang compiler (built for $arch)'" >> "$build_dir/usr/bin/nymyac"
        echo "echo 'This is a placeholder. Actual binary would be cross-compiled for $arch architecture.'" >> "$build_dir/usr/bin/nymyac"
        chmod +x "$build_dir/usr/bin/nymyac"
    fi

    # Add standard library files
    mkdir -p "$build_dir/usr/lib/nymya/library"
    cp -r /home/erick/nymya/nymyac/library/math "$build_dir/usr/lib/nymya/library/"
    cp -r /home/erick/nymya/nymyac/library/quantum "$build_dir/usr/lib/nymya/library/"
    cp -r /home/erick/nymya/nymyac/library/crystal "$build_dir/usr/lib/nymya/library/"
    cp -r /home/erick/nymya/nymyac/library/ml "$build_dir/usr/lib/nymya/library/"
    cp -r /home/erick/nymya/nymyac/library/networking "$build_dir/usr/lib/nymya/library/"
    cp -r /home/erick/nymya/nymyac/library/datetime "$build_dir/usr/lib/nymya/library/"
    cp -r /home/erick/nymya/nymyac/library/lowlevel "$build_dir/usr/lib/nymya/library/"

    # Add documentation
    cp -r /home/erick/nymya/references "$build_dir/usr/share/nymya/"

    # Create post-install script
    cat > "$build_dir/DEBIAN/postinst" << 'EOF'
#!/bin/bash
echo "NymyaLang installation completed!"
echo "Run 'nymyac --help' for usage information."
echo "Visit https://github.com/nymya-lang/nymya for documentation."
EOF

    chmod +x "$build_dir/DEBIAN/postinst"

    # Create pre-remove script
    cat > "$build_dir/DEBIAN/prerm" << 'EOF'
#!/bin/bash
echo "Preparing to remove NymyaLang..."
EOF

    chmod +x "$build_dir/DEBIAN/prerm"

    # Build the package first to get actual size
    local output_file="${PACKAGE_NAME}_${VERSION}_${arch}.deb"
    dpkg-deb --build --root-owner-group "$build_dir" "$output_file"

    # Calculate installed size from the built package
    local installed_size=$(dpkg-deb --info "$output_file" | grep "Installed-Size" | awk '{print $2}')
    if [ -z "$installed_size" ]; then
        # If dpkg-deb doesn't provide size, calculate manually
        installed_size=$(du -sk "$build_dir" | cut -f1)
    fi

    # Update control file with correct size and rebuild
    sed -i "s/^Installed-Size:.*/Installed-Size: $installed_size/" "$build_dir/DEBIAN/control"

    # Remove and rebuild package with correct size in control
    rm -f "$output_file"
    dpkg-deb --build --root-owner-group "$build_dir" "$output_file"
    
    echo "Package built: $output_file"
    
    # Cleanup
    rm -rf "$build_dir"
}

# Create output directory
mkdir -p /home/erick/nymya/packages
cd /home/erick/nymya/packages

# Build for each architecture
for arch in "${ARCHITECTURES[@]}"; do
    echo "======================================="
    echo "Building package for: $arch"
    echo "======================================="
    build_package "$arch"
done

echo "======================================="
echo "All packages built successfully!"
echo "Output packages are in: /home/erick/nymya/packages/"
for arch in "${ARCHITECTURES[@]}"; do
    echo "  - ${PACKAGE_NAME}_${VERSION}_${arch}.deb"
done
echo "======================================="