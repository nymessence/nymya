# Changelog

## [0.2.0-alpha~3] - 2025-12-08

### Added
- **GTK+4 Abstractions with SwiftUI-like syntax**:
  - Declarative window, button, layout, and input field components
  - Vstack, HStack, ZStack, and Grid layout containers
  - Quantum-aware components (QuantumVisualization, etc.)
  - Mystical computing features (numerology displays, sacred geometry viewers)
  - ChakraLayout and TachyonFieldView for mystical interfaces
  - Documentation in docs/GUI_ABSTRACTIONS.md

- **'nymya' executable with compilation system**:
  - Compiles NymyaLang code via nymyac behind the scenes
  - Saves compiled executables in hidden temp folder
  - Provides seamless execution interface
  - Temporary file management system

- **Aya Nymya Test App**:
  - Jupyter-like interface with Markdown, HTML, and NymyaLang blocks
  - Syntax highlighting for NymyaLang
  - Interactive execution via 'nymya' executable
  - Sample content demonstrating numerology, sacred geometry, quantum modules

- **Docker-based Testing and Debugging**:
  - Automated GTK+4 compilation and execution testing
  - Aya Nymya block execution with runtime error capture
  - Temp folder execution verification
  - JSONL logging system for test results

### Changed
- Introduced GUI library subsystem under nymyac/library/gui/
- Enhanced symbolic mathematics integration with GUI components
- Improved compiler toolchain with temporary execution support
- Added comprehensive GUI documentation

## [0.2.0] - 2025-12-08

### Added
- Complete library API documentation in docs/LIBRARY_API.md
- Architecture documentation in docs/ARCHITECTURE.md
- Quantum simulator with full tensor product implementation
- Turing completeness verification programs in tests/turing/:
  - Conditional branching example
  - Unbounded looping/recursion example
  - Tape/memory simulation
  - Register machine implementation
  - Lambda calculus evaluator
  - Prime number computation
- Killer demo: Quantum-enhanced hybrid classifier in tests/killer_demo.nym
- Enhanced math library with integer power and GCD functions
- Functional parser and lexer for the NymyaLang compiler

### Changed
- Improved quantum simulator with complete tensor product calculations
- Fixed quantum gate matrix computations for single, two, and three-qubit operations
- Moved math.pow_int and math.gcd from quantum algorithms to main math library
- Enhanced container environment with cross-compilation toolchains
- Improved error handling in library functions

### Fixed
- Quantum circuit simulation with proper tensor product implementation
- Placeholder implementations in quantum simulator replaced with proper algorithms
- Library consistency issues identified during refactoring

### Removed
- Placeholder implementations in quantum simulator
- Duplicate function definitions

## [0.1.5] - 2025-12-05

### Added
- Image processing library with stb-inspired functionality
- Comprehensive story generation library with anti-repetition features
- Syntax highlighting support for multiple editors

### Changed
- Enhanced library ecosystem with image and storygen capabilities
- Improved cross-compilation environment for multiple architectures
- Integrated GMP dependency for mathematical operations

## [0.1.0] - 2025-11-25

### Added
- Initial release of NymyaLang compiler (nymyac)
- Basic library ecosystem including math, quantum, ML, and system libraries
- Cross-compilation support for Linux (amd64, arm64, riscv64), Windows, and macOS