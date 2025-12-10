# NymyaLang Cross-Compilation Environment

This document describes the cross-compilation environment for building NymyaLang compiler for multiple platforms (Linux, Windows, macOS) using Docker.

## Overview

The cross-compilation environment allows building NymyaLang compiler for:
- Linux (x86_64, aarch64, riscv64)
- Windows (x86_64, i686) using mingw-w64
- macOS (x86_64, aarch64) using osxcross

## Docker Setup

The environment is built using Docker with the Dockerfile.cross file that configures:

### Linux Cross-Compilation
- `aarch64-unknown-linux-gnu`
- `x86_64-unknown-linux-gnu` 
- `riscv64gc-unknown-linux-gnu`
- `i686-unknown-linux-gnu`

### Windows Cross-Compilation
- `x86_64-pc-windows-gnu`
- `i686-pc-windows-gnu`

Using mingw-w64 toolchain:
- `gcc-mingw-w64`
- `g++-mingw-w64`

### macOS Cross-Compilation
- `x86_64-apple-darwin`
- `aarch64-apple-darwin`

Using osxcross framework, which requires a macOS SDK (not included in this build due to licensing restrictions).

## GMP Library Support

The environment includes GMP (GNU Multiple Precision Arithmetic Library) support for all platforms:
- Linux: `libgmp-dev`, `libgmp10`
- Windows: Requires manual GMP build for mingw-w64 (see below)
- macOS: Available when osxcross is properly configured

## Building the Environment

```bash
# Build the cross-compilation Docker image
docker build -f Dockerfile.cross -t nymya-cross-compiler .

# Run the cross-compilation environment
docker run -it --rm -v $(pwd):/workspace nymya-cross-compiler
```

## Using the Environment

### Inside the Container

The container includes several scripts for building:

```bash
# Build for all Linux targets
/opt/nymya/build_linux.sh

# Build for all Windows targets
/opt/nymya/build_windows.sh

# Build for all targets (Linux and Windows)
/opt/nymya/build_all.sh

# Test the builds
/opt/nymya/test_builds.sh
```

### Manual Cross-Compilation

```bash
# Build for Linux x86_64
cd /opt/nymya/nymyac
cargo build --target x86_64-unknown-linux-gnu --release

# Build for Windows x86_64
cargo build --target x86_64-pc-windows-gnu --release

# Build for macOS x86_64 (requires osxcross setup)
cargo build --target x86_64-apple-darwin --release
```

## macOS Setup (Manual)

The Docker image includes osxcross but requires a macOS SDK to function:

1. Obtain a macOS SDK (from a macOS system or Xcode)
2. Extract the SDK and place it in the container
3. Run the osxcross setup:

```bash
# Within the container
/opt/nymya/setup_osxcross.sh
```

## GMP for Windows

GMP needs to be cross-compiled for Windows targets. To do this manually:

```bash
# Download GMP source
# Cross-compile using mingw-w64 toolchain
./configure --host=x86_64-w64-mingw32 --prefix=/opt/mingw-gmp
make && make install
```

## Architecture-Specific Notes

### ARM64 Host System
This setup was developed on an ARM64 host system, so:
- Linux cross-compilation targets include x86_64 and riscv64
- Windows cross-compilation uses mingw-w64
- The container environment allows cross-compilation from ARM64 to other architectures

### QEMU Support
The environment includes QEMU for emulation if needed for testing:
- `qemu-user-static` for user-mode emulation
- `qemu-system-*` for full system emulation

## Cargo Configuration

The environment sets up Cargo cross-compilation configuration in `~/.cargo/config.toml` with appropriate linkers for each target architecture.

## Known Limitations

1. **macOS Builds**: Full macOS cross-compilation requires a macOS SDK, which is not included due to licensing restrictions.
2. **GMP on Windows**: GMP library requires manual compilation for Windows targets.
3. **Architecture Mismatch**: Some linking issues may occur when cross-compiling between architectures with different calling conventions.

## Troubleshooting

### Common Issues

1. **Linker errors**: May occur if target-specific dependencies are missing
2. **GMP not found**: Ensure GMP development packages are installed
3. **Cross-compilation failures**: Check target-specific configuration in Cargo

### Verification

To verify your cross-compilation setup:

```bash
# Check available targets
rustc --print target-list | grep -E "(linux|windows|darwin)"

# Test a simple build
cd test_project
cargo build --target x86_64-pc-windows-gnu --release
```

## Building NymyaLang

To build NymyaLang for different platforms:

```bash
# Clone the repository in the container
cd /opt/nymya/nymyac

# Build for your target platform
cargo build --target <target-triple> --release

# Find the resulting binary in:
# target/<target-triple>/release/nymyac(.exe for Windows)
```

The resulting binaries will be placed in the appropriate target subdirectory and can be distributed to the target platforms.