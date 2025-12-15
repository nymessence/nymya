"""
Comprehensive quantum vs classical benchmarks
"""
import time
import numpy as np
from typing import List, Tuple, Dict, Any
import json
import os
from quantum_complexity.quantum_algs.grovers_algorithm import GroversAlgorithm
from quantum_complexity.quantum_algs.quantum_sat_solver import QuantumSATSolver
from quantum_complexity.quantum_algs.qma_verification import QMAStyleVerifier


def benchmark_unstructured_search():
    """Benchmark quantum (Grover) vs classical unstructured search."""
    print("=== Benchmark: Unstructured Search ===")
    
    grover = GroversAlgorithm()
    results = []
    
    sizes = [4, 8, 16, 32]  # Different sizes to test
    
    for size in sizes:
        print(f"Testing size {size}...")
        
        # Create test data
        items = list(range(size))
        target = size // 2  # Target in the middle
        
        # Quantum approach (Grover's algorithm)
        start_time = time.time()
        _, quantum_result = grover.run_search(items, target, shots=500)
        quantum_time = time.time() - start_time
        
        # Classical approach (linear search)
        start_time = time.time()
        classical_result = items.index(target)  # Linear search
        classical_time = time.time() - start_time
        
        # Calculate theoretical complexities
        n = size
        classical_complexity = f"O({n})"
        quantum_complexity = f"O(√{n}) ≈ O({int(np.sqrt(n))})"
        
        result = {
            'problem_type': 'unstructured_search',
            'input_size': size,
            'classical_time': classical_time,
            'quantum_time': quantum_time,
            'classical_result': classical_result,
            'quantum_result': quantum_result.get('index'),
            'classical_complexity': classical_complexity,
            'quantum_complexity': quantum_complexity,
            'theoretical_quantum_speedup': np.sqrt(size),
            'actual_speedup': classical_time / quantum_time if quantum_time > 0 else float('inf'),
            'quantum_iterations': quantum_result.get('grover_iterations', 0),
            'circuit_depth': quantum_result.get('circuit_depth', 0),
            'complexity_classes': {
                'classical_class': 'O(N)',
                'quantum_class': 'O(√N) - Grover\'s algorithm'
            }
        }
        
        results.append(result)
        print(f"  Classical time: {classical_time:.6f}s, Quantum time: {quantum_time:.6f}s")
        print(f"  Actual speedup: {result['actual_speedup']:.2f}x")
    
    print()
    return results


def benchmark_sat_solving():
    """Benchmark quantum (Grover-based) vs classical SAT solving."""
    print("=== Benchmark: SAT Solving ===")
    
    solver = QuantumSATSolver()
    results = []
    
    # Test problems of different sizes
    test_problems = [
        # Small 2-SAT problem
        {
            'clauses': [[(0, True), (1, False)], [(0, False), (1, True)]],  # x0∨¬x1, ¬x0∨x1
            'n_vars': 2,
            'description': '2-SAT with 2 variables, 2 clauses'
        },
        # Small 3-SAT problem
        {
            'clauses': [
                [(0, True), (1, False), (2, True)],   # x0 ∨ ¬x1 ∨ x2
                [(0, False), (1, True), (2, False)]   # ¬x0 ∨ x1 ∨ ¬x2
            ],
            'n_vars': 3,
            'description': '3-SAT with 3 variables, 2 clauses'
        }
    ]
    
    for problem in test_problems:
        print(f"Testing: {problem['description']}")
        
        clauses = problem['clauses']
        n_vars = problem['n_vars']
        
        # Quantum approach (Grover-based SAT solver)
        start_time = time.time()
        _, quantum_result = solver.solve_sat_quantum(clauses, n_vars, shots=500)
        quantum_time = time.time() - start_time
        
        # Classical approach (brute force)
        start_time = time.time()
        classical_result = solver.solve_sat_classical(clauses, n_vars)
        classical_time = time.time() - start_time
        
        # Calculate theoretical complexities
        search_space = 2 ** n_vars
        classical_complexity = f"O(2^{n_vars}) = O({search_space})"
        quantum_complexity = f"O(√2^{n_vars}) ≈ O({int(np.sqrt(search_space))})"
        
        result = {
            'problem_type': 'sat_solving',
            'n_variables': n_vars,
            'n_clauses': len(clauses),
            'classical_time': classical_time,
            'quantum_time': quantum_time,
            'classical_result_found': classical_result is not None,
            'quantum_result_found': quantum_result['found_solution'],
            'classical_complexity': classical_complexity,
            'quantum_complexity': quantum_complexity,
            'theoretical_quantum_speedup': np.sqrt(search_space),
            'actual_speedup': classical_time / quantum_time if quantum_time > 0 else float('inf'),
            'search_space_size': search_space,
            'quantum_iterations': quantum_result.get('grover_iterations', 0),
            'circuit_depth': quantum_result.get('circuit_depth', 0),
            'complexity_classes': {
                'classical_class': 'NP-complete (exponential brute force)',
                'quantum_class': 'unknown (not known to be in BQP, Grover gives quadratic speedup)'
            }
        }
        
        results.append(result)
        print(f"  Classical time: {classical_time:.6f}s, Quantum time: {quantum_time:.6f}s")
        print(f"  Classical found solution: {result['classical_result_found']}")
        print(f"  Quantum found solution: {result['quantum_result_found']}")
        print(f"  Actual speedup: {result['actual_speedup']:.2f}x")
        print()
    
    return results


def benchmark_qma_verification():
    """Benchmark QMA-style verification vs classical verification."""
    print("=== Benchmark: QMA Verification ===")
    
    verifier = QMAStyleVerifier()
    results = []
    
    # Test with SAT problems
    test_problems = [
        {
            'clauses': [[(0, True), (1, False)], [(0, False), (1, True)]],  # Satisfiable
            'n_vars': 2,
            'satisfying_assignment': [True, True],
            'description': 'Satisfiable 2-SAT'
        },
        {
            'clauses': [[(0, True)], [(0, False)]],  # Unsatisfiable
            'n_vars': 1,
            'satisfying_assignment': [True],  # Invalid assignment
            'description': 'Unsatisfiable 1-SAT'
        }
    ]
    
    for problem in test_problems:
        print(f"Testing: {problem['description']}")
        
        clauses = problem['clauses']
        n_vars = problem['n_vars']
        assignment = problem['satisfying_assignment']
        
        # Classical verification
        start_time = time.time()
        classical_verdict = verifier.classical_verification(assignment, clauses)
        classical_time = time.time() - start_time
        
        # Quantum (QMA-style) verification
        start_time = time.time()
        quantum_result = verifier.verify_quantum_proof(n_vars, clauses, assignment)
        quantum_time = time.time() - start_time
        
        result = {
            'problem_type': 'qma_verification',
            'n_variables': n_vars,
            'n_clauses': len(clauses),
            'classical_verdict': classical_verdict,
            'quantum_verdict': quantum_result['verdict'],
            'classical_time': classical_time,
            'quantum_time': quantum_time,
            'acceptance_probability': quantum_result['acceptance_probability'],
            'circuit_depth': quantum_result['circuit_depth'],
            'problem_satisfiability': 'satisfiable' if classical_verdict else 'unsatisfiable',
            'complexity_classes': {
                'classical_verification': 'P (polynomial time)',
                'quantum_verification': 'QMA (quantum polynomial time with quantum proof)'
            }
        }
        
        results.append(result)
        print(f"  Classical verdict: {classical_verdict}, Time: {classical_time:.6f}s")
        print(f"  Quantum verdict: {quantum_result['verdict']}, Time: {quantum_time:.6f}s")
        print(f"  Acceptance probability: {quantum_result['acceptance_probability']:.3f}")
        print()
    
    return results


def run_comprehensive_benchmarks():
    """Run all quantum vs classical benchmarks."""
    print("Running Comprehensive Quantum vs Classical Benchmarks\n")
    
    all_results = {}
    
    # Run benchmarks
    search_results = benchmark_unstructured_search()
    all_results['unstructured_search'] = search_results
    
    sat_results = benchmark_sat_solving()
    all_results['sat_solving'] = sat_results
    
    qma_results = benchmark_qma_verification()
    all_results['qma_verification'] = qma_results
    
    # Save results
    os.makedirs('quantum_complexity/benchmarks', exist_ok=True)
    
    timestamp = int(time.time())
    filename = f'quantum_complexity/benchmarks/comprehensive_benchmark_{timestamp}.json'
    
    with open(filename, 'w') as f:
        json.dump(all_results, f, indent=2)
    
    print(f"All benchmark results saved to: {filename}")
    
    # Print summary
    print("=== Benchmark Summary ===")
    
    # Unstructured search summary
    if 'unstructured_search' in all_results:
        print("\nUnstructured Search:")
        for result in all_results['unstructured_search']:
            print(f"  Size {result['input_size']}: {result['actual_speedup']:.2f}x speedup")
    
    # SAT solving summary
    if 'sat_solving' in all_results:
        print("\nSAT Solving:")
        for result in all_results['sat_solving']:
            print(f"  {result['n_variables']} vars: {result['actual_speedup']:.2f}x speedup")
    
    # QMA verification summary
    if 'qma_verification' in all_results:
        print("\nQMA Verification:")
        for result in all_results['qma_verification']:
            print(f"  {result['n_variables']} vars: Classical={result['classical_verdict']}, Quantum={result['quantum_verdict']}")
    
    print(f"\nComplete benchmark results available in: {filename}")
    
    return all_results


if __name__ == "__main__":
    results = run_comprehensive_benchmarks()