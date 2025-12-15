# Complexity Theory in NymyaLang

This directory contains implementations of complexity theory concepts.

## NymyaLang Implementation

The following files provide complexity theory demonstrations that compile and run successfully with the NymyaLang compiler:

- `simple_complexity.nym` - Basic complexity concepts demonstration
- `complexity_concepts.nym` - Detailed complexity classes and algorithm examples

Due to current NymyaLang compiler limitations, more complex algorithmic demonstrations are kept in Python implementations.

## Known NymyaLang Compiler Bugs

During testing, several compiler bugs were identified:

1. **Comment Processing Bug**: The lexer does not properly handle `//` style comments, potentially treating comment text as code.

2. **Method Call Bug**: Method calls like `variable.to_string()` generate incorrect C++ code using pointer syntax (`->`) instead of proper method calls, causing runtime failures.

3. **String Concatenation Bug**: String concatenation with variables like `"text" + variable` generates invalid C++ code that compiles but fails at runtime.

4. **Type Conversion Bug**: The compiler struggles with automatic type conversion between strings and numeric types.

## Working Patterns for NymyaLang

To work within current compiler limitations:

- Use only string literals in `crystal.manifest()` calls
- Avoid string concatenation with variables
- Avoid method calls like `.to_string()`
- Keep variable assignments simple and separate from output calls
- Do not use `//` style comments in code (use meaningful function names instead)

## Comprehensive Research Implementation

The full complexity theory research suite, including:

- P, NP, NP-Complete, NP-Hard algorithm implementations
- Quantum vs Classical complexity comparisons
- Grover's algorithm and quantum SAT solving
- Polynomial reductions (SAT→3-SAT, 3-SAT→CLIQUE, etc.)
- Detailed benchmarks and analysis

Is implemented in the `complexity_tests/` and `quantum_complexity/` directories using Python, as these require sophisticated libraries (Qiskit, NumPy, etc.) and complex algorithms that cannot be meaningfully expressed in the current NymyaLang syntax with its compilation limitations.