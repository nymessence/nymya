# P vs NP Complexity Theory Experiments

This directory contains a comprehensive experimental framework for studying computational complexity theory, with focus on the P vs NP problem, NP-completeness, NP-hardness, and polynomial reductions.

## Project Structure

- `p_class/` - Polynomial time solvable problems (P)
- `np_class/` - Problems verifiable in polynomial time (NP)  
- `np_complete/` - NP-complete problems
- `np_hard/` - NP-hard problems
- `reductions/` - Polynomial time reductions between problems
- `utils/` - Measurement and utility functions
- `benchmarks/` - Test results and performance data
- `data/` - Input generators and test cases

## Implemented Problems

### P Problems (Polynomial Time)
- Linear Search - O(n)
- Binary Search - O(log n)  
- Merge Sort - O(n log n)

### NP Problems
- Subset Sum - Determine if a subset sums to target
- SAT (Boolean Satisfiability) - General case
- 3-SAT - SAT with exactly 3 literals per clause

### NP-Complete Problems
- Clique - Find complete subgraph of size k
- Vertex Cover - Find set of vertices covering all edges
- TSP Decision - Decide if tour ≤ threshold exists

### NP-Hard Problems
- TSP Optimization - Find shortest tour

## Polynomial Reductions

- SAT → 3-SAT
- 3-SAT → CLIQUE  
- CLIQUE → Vertex Cover

## Running Experiments

Run the full test suite:
```bash
python test_all.py
```

Or run individual problem class tests:
```bash
python -m p_class.test_p_class
python -m np_class.test_np_class
python -m np_complete.test_np_complete
python -m np_hard.test_np_hard
python -m reductions.test_reductions
```

## Key Features

- Scalable input generation respecting computational feasibility
- Automated time and memory measurement
- Complexity analysis and classification
- Polynomial time reduction verification
- Comprehensive documentation

## Documentation

See [COMPLEXITY_THEORY_DOCUMENTATION.md](COMPLEXITY_THEORY_DOCUMENTATION.md) for complete technical details and analysis.

## Research Goals

This experimental system aims to:
- Empirically verify theoretical complexity bounds
- Demonstrate the practical implications of P vs NP
- Show how reductions prove relative hardness
- Provide educational examples of complexity concepts
- Bridge theoretical understanding with practical implementation