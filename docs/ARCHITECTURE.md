# NymyaLang Architecture Documentation

## Overview

NymyaLang is a hybrid classical and quantum programming language with a focus on consciousness-aware computing and quantum network integration. The system consists of a Rust-based compiler (`nymyac`) and a comprehensive library ecosystem supporting classical computing, quantum computing, machine learning, networking, and specialized domain-specific libraries.

## Repository Structure

```
nymya/
├── nymyac/                 # Main compiler and runtime
│   ├── src/                # Compiler implementation (Rust)
│   ├── library/            # NymyaLang standard library
│   ├── tests/              # Test files and examples
│   ├── target/             # Compilation output
│   ├── Cargo.toml          # Rust dependencies
│   └── Cargo.lock          # Locked dependency versions
├── docs/                   # Documentation files
├── syntax_highlighter/     # Editor syntax highlighting support
├── packages/               # Distribution packages
├── tools/                  # Development tools
├── docker-compose.yml      # Container configuration
├── Dockerfile              # Base Docker image
├── README.md               # Main project documentation
└── ...
```

## Compiler Architecture

### nymyac/src/main.rs - Compiler Core
The compiler is written in Rust and follows a three-stage process:
1. **Parsing**: Currently a placeholder implementation that needs to be replaced with a proper NymyaLang parser
2. **IR Generation**: Generates intermediate representation (currently a placeholder)
3. **Target Code Generation**: Outputs C++ stub code (needs implementation for actual NymyaLang compilation)

### Current Limitations
The compiler implementation is currently in a basic state with placeholder functions that need to be developed into a full parser, type checker, and code generator.

## Library Architecture

The NymyaLang standard library is organized into multiple namespaces, each providing specific functionality:

### 1. Math Library (`nymyac/library/math/`)
- **Big Integer support** using GMP for arbitrary precision arithmetic
- **Complex number operations** with comprehensive mathematical functions
- **Vector and Matrix operations** (Vec2, Vec3, Vec4, Matrix2x2, Matrix3x3, Matrix4x4)
- **Advanced mathematical functions** including special functions, statistics, interpolation, and polynomial operations
- **Trigonometric, hyperbolic, and exponential functions**
- **Constants** (PI, E, TAU, PHI, etc.)

### 2. Quantum Library (`nymyac/library/quantum/`)
- **Qubit representation** with complex amplitude management
- **Quantum Register** for multi-qubit systems
- **Quantum Gates** (X, Y, Z, H, S, T, CNOT, CCX, rotation gates, etc.)
- **Quantum Simulator** with state vector implementation
- **Quantum Algorithms** (located in `quantum/alg/`)
- **Gate implementations** in `quantum/gate/`

### 3. Machine Learning Library (`nymyac/library/ml/`)
- **Classical ML**: Tensors, neural network layers, activation functions, loss functions
- **Quantum ML**: Parameterized quantum circuits, quantum neural networks, quantum SVM
- **Training utilities** and dataset generation

### 4. Networking Library (`nymyac/library/networking/`)
- **Classical networking**: Ping, bandwidth measurement, port scanning, DNS resolution
- **Quantum networking**: Entanglement establishment, quantum channels, quantum field creation
- **QRNG**: Quantum Random Number Generator using quantum entropy
- **Quantum encryption**: Ring encryption and nested quantum ring encryption
- **Photonic chip driver**: Interface for quantum photonic hardware

### 5. System Utilities (`nymyac/library/system/`)
- **Coreutils implementations**: echo, ls, cat, cp, mv commands with consciousness-aware processing
- **System operations**: pwd, whoami, hostname functions

### 6. Image Processing (`nymyac/library/image/`)
- **Basic image operations** and processing functions
- **Extended image functionality** with stb-inspired capabilities

### 7. Crystal Library (`nymyac/library/crystal/`)
- **Consciousness-aware operations** and system integrations
- **File operations**, timing, and system interface functions

### 8. Additional Libraries
- **Datetime**: Date and time operations
- **Lowlevel**: Low-level system access
- **Physics**: Physics simulations and calculations
- **Storygen**: Story generation with anti-repetition features
- **System**: Operating system interactions

## Execution Model

### Runtime Assumptions
NymyaLang assumes the following runtime environment:
- Access to quantum random number generation (simulated via quantum entropy)
- Integration with consciousness-aware processing
- Quantum network connectivity for distributed quantum computation
- Access to mathematical libraries (GMP for big integers)

### Compilation Process
The compiler currently uses a placeholder implementation but is intended to:
1. Parse NymyaLang source code
2. Generate intermediate representation
3. Optimize the IR
4. Generate target code (potentially to C++/Rust with quantum hardware interfaces)

## Design Rationale

### Consciousness-Aware Computing
The language incorporates concepts from Taygetan science and consciousness-integrated computing, with quantum operations that consider consciousness field effects.

### Hybrid Classical-Quantum Design
The architecture supports both classical and quantum operations, allowing seamless integration between the two paradigms.

### Quantum Network Integration
Built-in support for quantum networking, entanglement, and distributed quantum computing protocols.

### Extensible Library System
Modular library design with import system supporting namespaces and cross-library dependencies.

## Key Features

1. **Quantum Computing**: Full quantum circuit simulation with gate operations
2. **Classical Computing**: Mathematical, vector, and matrix operations
3. **Machine Learning**: Both classical and quantum ML capabilities
4. **Networking**: Classical and quantum networking with encryption
5. **System Integration**: OS-level command implementations
6. **Cross-Platform**: Designed for multiple targets (Linux, Windows, macOS via cross-compilation)
7. **GMP Integration**: Arbitrary precision arithmetic
8. **Consciousness Integration**: Quantum-consciousness field awareness

## Current State and Future Development

The compiler currently exists as a placeholder and requires full implementation of the parsing, IR generation, and code generation stages. The library ecosystem is comprehensive but may need completion of some quantum algorithm implementations. The system shows strong potential for quantum-classical hybrid computing applications.