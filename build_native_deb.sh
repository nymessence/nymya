#!/bin/bash
# Simplified NymyaLang Package Build Script for native architecture only
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
echo "Building .deb package for native architecture only"
echo ""

BUILD_DIR="nymya-build-${VERSION}"

# Create root build directory
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Determine native architecture
ARCH=$(dpkg --print-architecture 2>/dev/null || echo "amd64")
echo "Building package for native architecture: $ARCH"

# Create package structure for this architecture
pkg_dir="${BUILD_DIR}/nymya-${ARCH}"
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
Architecture: ${ARCH}
Depends: libc6 (>= 2.14), libgcc1 (>= 1:4.1.1), libstdc++6 (>= 4.1.1), g++ (>= 9.0)
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

# Copy the compiled binary
if [ -f "nymyac/target/release/nymyac" ]; then
    cp "nymyac/target/release/nymyac" "${pkg_dir}/usr/bin/nymyac"
    echo "  Copied compiler binary"
else
    echo "Error: Binary not found at nymyac/target/release/nymyac"
    exit 1
fi

# Ensure binary is executable
chmod +x "${pkg_dir}/usr/bin/nymyac"

# Copy all library files
for subdir in crystal data_structures datetime graphics gui image lowlevel math ml networking physics quantum storygen symbolic system; do
    if [ -d "../nymyac/library/$subdir" ]; then
        mkdir -p "${pkg_dir}/usr/lib/nymya/$subdir"
        find "../nymyac/library/$subdir" -name "*.nym" -type f -exec cp {} "${pkg_dir}/usr/lib/nymya/$subdir/" \; -exec echo "  Copied: {}" \;
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
EOF

# Copy syntax highlighting files if they exist
if [ -d "/home/erick/nymya/syntax_highlighter" ]; then
    mkdir -p "${pkg_dir}/usr/share/nymya/syntax_highlighter"
    cp -r /home/erick/nymya/syntax_highlighter/* "${pkg_dir}/usr/share/nymya/syntax_highlighter/" 2>/dev/null || true

    # Also install syntax highlighting in appropriate system locations
    mkdir -p "${pkg_dir}/usr/share/vim/vimfiles/syntax"
    mkdir -p "${pkg_dir}/usr/share/nano"
    mkdir -p "${pkg_dir}/usr/share/gtksourceview-4/language-specs"
    mkdir -p "${pkg_dir}/usr/share/highlight/langDefs"

    # Copy to system locations if available
    if [ -f "/home/erick/nymya/syntax_highlighter/nym.vim" ]; then
        cp "/home/erick/nymya/syntax_highlighter/nym.vim" "${pkg_dir}/usr/share/vim/vimfiles/syntax/"
    fi
    if [ -f "/home/erick/nymya/syntax_highlighter/nym.nanorc" ]; then
        cp "/home/erick/nymya/syntax_highlighter/nym.nanorc" "${pkg_dir}/usr/share/nano/"
    fi
    if [ -f "/home/erick/nymya/syntax_highlighter/nymya.lang" ]; then
        cp "/home/erick/nymya/syntax_highlighter/nymya.lang" "${pkg_dir}/usr/share/gtksourceview-4/language-specs/"
    fi
    if [ -f "/home/erick/nymya/syntax_highlighter/nymya.xml" ]; then
        cp "/home/erick/nymya/syntax_highlighter/nymya.xml" "${pkg_dir}/usr/share/highlight/langDefs/"
    fi

    echo "  Copied: syntax highlighting files"
fi

# Documentation
cat > "${pkg_dir}/usr/share/doc/nymya/README.txt" << EOF
NymyaLang Programming Environment v${VERSION} (${ARCH})

Includes:
- nymyac compiler
- Nymya standard library
- Syntax highlighting for editors
- Examples and documentation

Rita-Nora balance in computing.
EOF

# Update installed size
installed_size=$(du -sk "${pkg_dir}" | cut -f1)
sed -i "s/Installed-Size: .*/Installed-Size: $installed_size/" "${pkg_dir}/DEBIAN/control"

# Build package
pkg_name="nymya_${VERSION}-${DEV_STAGE}~${REVISION}_${ARCH}.deb"
dpkg-deb --build --root-owner-group "${pkg_dir}" "${BUILD_DIR}/${pkg_name}"

echo "  ✓ Package built: ${BUILD_DIR}/${pkg_name}"

echo "=== PACKAGE BUILD COMPLETED SUCCESSFULLY ==="
echo "Package created in: ${BUILD_DIR}/${pkg_name}"