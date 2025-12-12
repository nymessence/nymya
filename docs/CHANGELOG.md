# Changelog

## [0.2.0-alpha.7] - 2025-12-09

### Fixed
- **Compiler Code Generation Issue**: Fixed critical bug where the nymyac compiler was generating template C++ code with only placeholder comments instead of actual executable code from NymyaLang source
  - Implemented proper tokenization and parsing of NymyaLang source code
  - Added AST generation and code translation from NymyaLang to C++
  - Fixed `crystal.manifest()` calls to properly output to console instead of just showing metadata messages
  - Verified fix with multiple test programs showing correct output

### Changed
- Updated version numbers to 0.2.0-alpha.7 across all configuration files
- Improved compiler with actual code generation instead of stub generation

## [0.2.0-alpha.6] - 2025-12-08

### Added
- **Data Structures Library (`data_structures`)**:
  - Binary Search Trees (BST) with insertion, search, and traversal operations
  - Queues with enqueue, dequeue, and peek operations
  - Min-Heaps with insert, extract_min, and peek operations
  - Doubly Linked Lists with append, prepend, find, and remove operations
  - Tuple implementations (Tuple2, Tuple3, Tuple4) with getter/setter methods
  - Stack implementation with push, pop, and peek operations

- **Testing Utilities (`data_structures.testing`)**:
  - Assertion functions: `assert()`, `assert_equal()`, `assert_not_equal()`, `assert_true()`, `assert_false()`
  - Comprehensive testing framework for data structures

- **Centralized Version Management**:
  - `version.conf` file with VERSION, DEV_STAGE, and REVISION variables
  - Build scripts now read version from central configuration
  - Consistent version tracking across all components

- **Enhanced Math Library**:
  - Added `math.pow_int()` for safe integer exponentiation
  - Added `math.gcd()` for integer greatest common divisor
  - Optimized implementations for mathematical operations

- **Cross-Platform Executable (`nymya`)**:
  - Improved architecture detection with proper ARM64/AMD64/RISCV64 support
  - Enhanced QEMU fallback mechanism for mixed-architecture execution
  - Better error handling and temporary file management

- **Comprehensive GUI Abstractions**:
  - Complete GTK+4 integration with SwiftUI-like declarative syntax
  - Quantum-aware UI components with consciousness integration
  - Sacred geometry viewers and numerology displays
  - Mystical computing interfaces with chakra layouts
  - Proper event handling through reactive system

- **Symbolic Mathematics Engine**:
  - Complete numerology subsystem with meanings for 1-9 and master numbers
  - Sacred geometry mapping engine with Metatron's Cube, Flower of Life, etc.
  - Prime number symbolism with twin prime and Mersenne prime classification
  - Integration engine with overlays and multi-layer meanings

- **Quantum Algorithms Implementation**:
  - Deutsch-Jozsa, Bernstein-Vazirani, Simon's algorithms
  - Quantum phase estimation and Shor's factoring algorithm
  - Grover's search algorithm and quantum Fourier transform
  - QAOA and VQE for quantum optimization

- **Turing Completeness Verification**:
  - Conditional branching programs
  - Unbounded looping and recursion implementations
  - Tape/memory simulation with dynamic allocation
  - Universal computation patterns and nontrivial computation tests

### Changed
- Improved quantum simulator with complete tensor product calculations
- Enhanced symbolic mathematics integration with quantum computing
- Optimized compiler with proper AST generation and code translation
- Better error handling and architecture detection in execution pipeline
- Organized scripts into dedicated `scripts/` directory
- Fixed compilation pipeline to properly generate C++ executables
- Enhanced documentation with complete API references

### Fixed
- Fixed C++ target code generation in `nymyac` compiler
- Corrected quantum gate matrix computations and tensor products
- Resolved architecture compatibility issues in binary execution
- Fixed import statement handling in the symbolic mathematics system
- Corrected build script to properly handle cross-compilation targets

## [0.2.0-alpha.5] - 2025-12-08

### Added
- **GTK+4 Abstractions with SwiftUI-like Syntax**:
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
  - Architecture detection with QEMU fallback for cross-platform compatibility
  - Temporary file management system

- **Aya Nymya Test App**:
  - Jupyter-like interface with blocks for Markdown, HTML, and NymyaLang
  - Syntax highlighting for NymyaLang
  - Interactive execution via 'nymya' executable
  - Sample content demonstrating numerology, sacred geometry, quantum modules

- **Turing Completeness Verification Programs**:
  - Conditional branching examples
  - Unbounded looping and recursion implementations
  - Tape/memory simulation with unbounded storage
  - Universal computation patterns (register machine, lambda calculus)
  - Nontrivial computational tests (prime number computation)
  - Complete verification in tests/turing/

### Changed
- Updated compiler to support proper cross-architecture builds
- Enhanced symbolic mathematics integration with GUI components
- Improved error handling and architecture detection in nymya executable
- Added comprehensive GUI and Turing completeness documentation

## [0.2.0-alpha.4] - 2025-12-08

### Added
- Symbolic Mathematics Subsystem:
  - Numerology engine with canonical mappings (1-9, master numbers)
  - Repeating number classifier (111, 222, 369 patterns, etc.)
  - Special numbers library with cultural and mathematical constants
  - Prime number symbolism with classification and properties
  - Sacred geometry engine with complete mapping system
  - Integration engine with overlays and multi-layer meanings

### Changed
- Enhanced math library with pow_int and gcd functions
- Integrated symbolic mathematics with existing quantum and AI/ML modules
- Improved documentation covering symbolic mathematics subsystem

## [0.2.0-alpha.3] - 2025-12-08

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