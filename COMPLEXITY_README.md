# Complexity Theory in NymyaLang

This directory contains implementations of complexity theory concepts.

## NymyaLang Implementation

The following files provide complexity theory demonstrations that compile and run successfully with the NymyaLang compiler:

- `simple_complexity.nym` - Basic complexity concepts demonstration
- `complexity_concepts.nym` - Detailed complexity classes and algorithm examples

Due to current NymyaLang compiler limitations with method calls and type conversion, more complex algorithmic demonstrations are kept in Python implementations.

## Comprehensive Research Implementation

The full complexity theory research suite, including:

- P, NP, NP-Complete, NP-Hard algorithm implementations
- Quantum vs Classical complexity comparisons
- Grover's algorithm and quantum SAT solving
- Polynomial reductions (SAT→3-SAT, 3-SAT→CLIQUE, etc.)
- Detailed benchmarks and analysis

Is implemented in the `complexity_tests/` and `quantum_complexity/` directories using Python, as these require sophisticated libraries (Qiskit, NumPy, etc.) and complex algorithms that cannot be meaningfully expressed in the current NymyaLang syntax with its compilation limitations.