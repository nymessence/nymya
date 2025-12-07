# NymyaLang Compiler Packaging System

This directory contains the packaging system for creating .deb packages for the NymyaLang Compiler across multiple architectures.

## Package Contents

The NymyaLang Compiler (nymyac) packages include:

- **Compiler Binary**: The main `nymyac` executable
- **Standard Libraries**: 
  - `math.nym` - Mathematical and numerical utilities
  - `quantum.nym` - Quantum computing operations
  - `functions.nym` - Advanced mathematical functions
  - `lowlevel.nym` - Low-level bit shift and memory operations
  - `networking.nym` - Classical and quantum networking
  - `ai_ml.nym` - Classical and quantum machine learning
- **Example Programs**: Sample .nym files demonstrating language features
- **Documentation**: Basic usage documentation

## Supported Architectures

The build system creates packages for these architectures:
- `amd64`: Standard 64-bit Intel/AMD systems
- `arm64`: 64-bit ARM systems (including Raspberry Pi 4, newer phones)
- `armhf`: Hard-float 32-bit ARM systems (older Raspberry Pi models)

## Build Instructions

To build the packages, run:

```bash
./build_deb_packages.sh
```

This will create packages in the `debian_packages/[arch]/` directories.

## Package Dependencies

The packages have the following dependencies:
- `libc6` (>= 2.14)
- `libgcc1` (>= 1:4.1.1)

These are standard system libraries found on most Linux distributions.

## Installation

Install the appropriate package for your architecture using:

```bash
sudo dpkg -i nymyac_[version]_[architecture].deb
```

## Verification

After installation, verify the compiler works:

```bash
nymyac --help
```

## Architecture-Specific Notes

### AMD64
- Standard x86-64 architecture
- Full performance and feature support

### ARM64 
- Includes support for quantum computing features
- Optimized for newer ARM-based systems

### ARMHF
- Hard-float ABI for 32-bit ARM systems
- Reduced precision for some quantum simulations

## Distribution Targets

The packages are designed to work with:
- Ubuntu 18.04 LTS and later
- Debian 10 (Buster) and later
- Raspberry Pi OS (both 32-bit and 64-bit versions)

## Release Versioning

Current development version: 0.1.0

This represents early access functionality with:
- Basic .nym file compilation
- Quantum computing library integration
- Mathematical operations and hypercalc
- Networking and AI/ML capabilities
- Low-level operations support