# P vs NP Complexity Theory Experiments - Documentation

## Overview

This project contains a comprehensive suite of experiments exploring computational complexity theory, focusing on the fundamental question of whether P equals NP. The experiments implement various algorithmic problems across different complexity classes to empirically study their time and space complexity characteristics.

## Problem Classes Studied

### P (Polynomial Time)
Problems solvable in polynomial time by a deterministic Turing machine. These are considered "tractable" or "efficiently solvable" problems.

**Implemented Problems:**
- **Linear Search** (O(n)): Find an element in an unsorted array
- **Binary Search** (O(log n)): Find an element in a sorted array  
- **Merge Sort** (O(n log n)): Sort an array of elements

### NP (Nondeterministic Polynomial Time)
Problems where solutions can be verified in polynomial time. All P problems are also in NP.

**Implemented Problems:**
- **Subset Sum**: Given a set of integers, find if there exists a subset that sums to a target value
- **Boolean Satisfiability (SAT)**: Determine if there's a variable assignment that makes a Boolean formula true
- **3-SAT**: A special case of SAT where each clause has exactly 3 literals

### NP-Complete
Problems that are both in NP and NP-hard. They are the "hardest" problems in NP.

**Implemented Problems:**
- **Clique**: Find a complete subgraph of a given size k
- **Vertex Cover**: Find a set of vertices that covers all edges
- **TSP Decision**: Decide if there exists a Hamiltonian cycle with cost ≤ threshold

### NP-Hard
Problems that are at least as hard as the hardest problems in NP, but don't need to be in NP themselves.

**Implemented Problems:**
- **TSP Optimization**: Find the shortest possible Hamiltonian cycle

## Polynomial Reductions

The project implements several key polynomial reductions to demonstrate the relationships between complexity classes:

1. **SAT → 3-SAT**: Show that 3-SAT is at least as hard as SAT
2. **3-SAT → CLIQUE**: Prove CLIQUE is NP-complete
3. **CLIQUE → Vertex Cover**: Demonstrate the relationship between these NP-complete problems

Each reduction comes with timing and validation to verify polynomial time transformation.

## Methodology

### Input Generation
- Scalable input generators that account for the computational feasibility of different problem classes
- P-class problems use larger inputs (hundreds to thousands of elements)
- NP and NP-complete problems use moderate inputs (tens of elements) due to exponential complexity
- NP-hard problems use very small inputs (under 10 elements) due to factorial complexity

### Measurement
- Execution time measured using high-precision timers
- Memory usage tracked via process monitoring
- Multiple runs to ensure consistent measurements
- Automated complexity classification based on growth rates

### Analysis
- Polynomial curve fitting to estimate complexity class
- Comparison against theoretical complexity bounds
- Identification of phase transitions where problems become intractable

## How to Run Tests

### Individual Problem Class Tests
```bash
# Run P-class tests
python -m p_class.test_p_class

# Run NP-class tests  
python -m np_class.test_np_class

# Run NP-complete tests
python -m np_complete.test_np_complete

# Run NP-hard tests
python -m np_hard.test_np_hard

# Run reduction tests
python -m reductions.test_reductions
```

### Comprehensive Test Suite
```bash
python test_all.py
```

This will run all tests and save results to `complexity_tests/benchmarks/` in JSON format.

## Expected Theoretical vs Empirical Results

### P-Class Problems
- **Linear Search**: O(n) - Linear growth in execution time with input size
- **Binary Search**: O(log n) - Logarithmic growth, much slower than linear
- **Merge Sort**: O(n log n) - Quasi-linear growth

### NP-Class Problems
- **Subset Sum**: O(2^n) - Exponential growth, becomes intractable for n > 20
- **SAT**: O(2^n) where n is the number of variables
- **3-SAT**: Also O(2^n) but with different constant factors

### NP-Complete Problems
- **Clique**: O(2^n) or worse in the worst case
- **Vertex Cover**: O(2^n) or worse in the worst case  
- **TSP Decision**: O(n! * n) for brute force approach

### NP-Hard Problems
- **TSP Optimization**: O(n! * n) for brute force - factorial complexity

## Key Insights

### Why P vs NP Matters
- If P = NP, then many computational problems currently considered intractable would become efficiently solvable
- This would have profound implications for cryptography, optimization, artificial intelligence, and many other fields
- Most researchers believe P ≠ NP, but a proof remains elusive

### Verification vs Solving
- NP problems are characterized by the fact that solutions can be verified quickly (in polynomial time)
- Finding solutions may be exponentially harder than verifying them
- This is the core distinction that makes the P vs NP question so important

### The Role of Reductions
- Polynomial reductions show that one problem is at least as hard as another
- They preserve the polynomial-time solvability property
- They are used to prove NP-completeness by showing that an NP-complete problem can be reduced to the target problem

## Implementation Notes

### Algorithm Choices
- All problems are implemented with straightforward, easy-to-understand algorithms
- For NP-hard problems, brute force approaches are used to clearly demonstrate the complexity
- More efficient algorithms exist for many problems but would obscure the complexity characteristics

### Scalability Considerations
- Input sizes are carefully chosen to demonstrate complexity without requiring excessive computation time
- The measurement infrastructure automatically adjusts for the computational feasibility of different problem types
- All tests include proper timing and memory usage tracking

### Empirical vs Theoretical Analysis
- Theoretical analysis provides worst-case bounds
- Empirical results may vary based on input characteristics
- Some inputs may be easier or harder than the worst case
- The experiments aim to demonstrate the growth rates that align with theoretical expectations

## Files and Structure

```
complexity_tests/
├── p_class/           # P problems and tests
├── np_class/          # NP problems and tests  
├── np_complete/       # NP-complete problems and tests
├── np_hard/           # NP-hard problems and tests
├── reductions/        # Polynomial reductions
├── utils/             # Measurement and utility functions
│   ├── measurement.py # Time and space measurement tools
│   └── input_generators.py # Scalable input generation
├── benchmarks/        # Results output directory
└── test_all.py        # Main comprehensive test runner
```

## Further Research Directions

- Implement approximation algorithms for NP-hard problems
- Study phase transitions in problem difficulty
- Explore parameterized complexity approaches
- Investigate quantum algorithms for these problems
- Implement more sophisticated solvers and compare with brute force approaches

This experimental suite serves as a practical exploration of the P vs NP question and related complexity theory concepts, bridging theoretical understanding with empirical evidence.