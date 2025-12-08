# Changelog

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