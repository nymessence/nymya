"""
Quantum vs Classical comparison framework
"""
import time
import numpy as np
from typing import Callable, Any, Dict, List, Tuple
from quantum_complexity.utils.quantum_simulator import QuantumSimulator, QuantumOracle, create_grover_circuit


class QuantumVsClassicalComparator:
    """Framework for comparing quantum and classical algorithms"""
    
    def __init__(self):
        self.quantum_sim = QuantumSimulator()
        
    def benchmark_unstructured_search(self, items: List[int], target: int) -> Dict[str, Any]:
        """
        Compare quantum (Grover) vs classical search algorithms.
        
        Args:
            items: List of items to search through
            target: Target value to search for
            
        Returns:
            Dictionary with comparison results
        """
        print(f"Comparing search algorithms for list of {len(items)} items...")
        
        # Classical linear search
        start_time = time.time()
        classical_result = self._linear_search(items, target)
        classical_time = time.time() - start_time
        
        # Quantum Grover search (simulated)
        start_time = time.time()
        quantum_result, quantum_metrics = self._grover_search(items, target)
        quantum_time = time.time() - start_time
        
        # Create oracle for the search
        oracle = QuantumOracle.create_search_oracle(items, target)
        
        # Get circuit complexity metrics
        grover_circuit = create_grover_circuit(oracle)
        circuit_metrics = self.quantum_sim.simulate_circuit(grover_circuit, shots=100)
        
        # Complexity analysis
        n = len(items)
        classical_scaling = f"O({n})"  # Linear search
        quantum_scaling = f"O(√{n}) ≈ O({int(np.sqrt(n))})"  # Grover's algorithm
        
        results = {
            'problem_type': 'unstructured_search',
            'input_size': n,
            'classical_result': classical_result,
            'quantum_result': quantum_result,
            'classical_time': classical_time,
            'quantum_time': quantum_time,
            'classical_scaling': classical_scaling,
            'quantum_scaling': quantum_scaling,
            'circuit_metrics': circuit_metrics,
            'complexity_classes': {
                'classical_class': 'O(N)',
                'quantum_class': 'O(√N) - Grover\'s algorithm'
            }
        }
        
        return results
    
    def _linear_search(self, items: List[int], target: int) -> int:
        """Classical linear search implementation."""
        for i, item in enumerate(items):
            if item == target:
                return i
        return -1
    
    def _grover_search(self, items: List[int], target: int) -> Tuple[int, Dict]:
        """Simulated quantum Grover search."""
        # In a real implementation, we would run the Grover circuit
        # For simulation, we return the same result but with metrics
        # indicating the quantum approach would have been used
        
        # Find target classically to return correct result
        result = self._linear_search(items, target)
        
        # Create mock quantum metrics (in real scenario, would run quantum circuit)
        oracle = QuantumOracle.create_search_oracle(items, target)
        grover_circuit = create_grover_circuit(oracle)
        metrics = self.quantum_sim.simulate_circuit(grover_circuit, shots=100)
        
        return result, metrics
    
    def benchmark_sat_problem(self, clauses: List[List[Tuple[int, bool]]], num_vars: int) -> Dict[str, Any]:
        """
        Compare quantum (Grover-based) vs classical SAT solving.
        
        Args:
            clauses: SAT problem clauses
            num_vars: Number of variables
            
        Returns:
            Dictionary with comparison results
        """
        print(f"Comparing SAT algorithms for {num_vars} variables and {len(clauses)} clauses...")
        
        # Classical brute force SAT
        start_time = time.time()
        classical_result = self._brute_force_sat(clauses, num_vars)
        classical_time = time.time() - start_time
        
        # Quantum Grover-based SAT (simulated)
        start_time = time.time()
        quantum_result, quantum_metrics = self._grover_sat(clauses, num_vars)
        quantum_time = time.time() - start_time
        
        # Create oracle for SAT
        oracle = QuantumOracle.create_sat_oracle(clauses, num_vars)
        
        # Get circuit complexity metrics
        grover_circuit = create_grover_circuit(oracle)
        circuit_metrics = self.quantum_sim.simulate_circuit(grover_circuit, shots=100)
        
        # Complexity analysis
        n = num_vars
        classical_scaling = f"O(2^{n})"  # Brute force
        quantum_scaling = f"O(2^({n}/2)) ≈ O({int(2**(n/2))})"  # Grover's algorithm
        
        results = {
            'problem_type': 'sat',
            'num_variables': num_vars,
            'num_clauses': len(clauses),
            'classical_result': classical_result,
            'quantum_result': quantum_result,
            'classical_time': classical_time,
            'quantum_time': quantum_time,
            'classical_scaling': classical_scaling,
            'quantum_scaling': quantum_scaling,
            'circuit_metrics': circuit_metrics,
            'complexity_classes': {
                'classical_class': 'NP-complete',
                'quantum_class': 'unknown (not known to be in BQP, Grover gives quadratic speedup)'
            }
        }
        
        return results
    
    def _brute_force_sat(self, clauses: List[List[Tuple[int, bool]]], num_vars: int) -> List[bool]:
        """Classical brute force SAT solver."""
        import itertools
        
        for assignment in itertools.product([False, True], repeat=num_vars):
            is_satisfied = True
            for clause in clauses:
                clause_satisfied = False
                for var_idx, is_positive in clause:
                    if var_idx < len(assignment):
                        if (is_positive and assignment[var_idx]) or (not is_positive and not assignment[var_idx]):
                            clause_satisfied = True
                            break
                if not clause_satisfied:
                    is_satisfied = False
                    break
            
            if is_satisfied:
                return list(assignment)
        
        return None  # No satisfying assignment found
    
    def _grover_sat(self, clauses: List[List[Tuple[int, bool]]], num_vars: int) -> Tuple[List[bool], Dict]:
        """Simulated quantum SAT solver using Grover's algorithm."""
        # In a real implementation, we would run the Grover circuit for SAT
        # For simulation, we return the same result but with metrics
        # indicating the quantum approach would have been used
        
        # Find solution classically to return correct result
        result = self._brute_force_sat(clauses, num_vars)
        
        # Create oracle and get metrics
        oracle = QuantumOracle.create_sat_oracle(clauses, num_vars)
        grover_circuit = create_grover_circuit(oracle)
        metrics = self.quantum_sim.simulate_circuit(grover_circuit, shots=100)
        
        return result, metrics


def run_quantum_vs_classical_baselines():
    """Run baseline comparisons to establish quantum vs classical performance."""
    comparator = QuantumVsClassicalComparator()
    
    print("=== Quantum vs Classical Baseline Comparisons ===\n")
    
    # Test 1: Unstructured Search
    print("1. Unstructured Search Comparison:")
    search_items = list(range(16))  # 16 items
    search_target = 10
    
    search_results = comparator.benchmark_unstructured_search(search_items, search_target)
    print(f"  Classical time: {search_results['classical_time']:.6f}s")
    print(f"  Quantum time: {search_results['quantum_time']:.6f}s")
    print(f"  Classical scaling: {search_results['classical_scaling']}")
    print(f"  Quantum scaling: {search_results['quantum_scaling']}")
    print(f"  Circuit depth: {search_results['circuit_metrics']['circuit_depth']}")
    print(f"  Circuit size: {search_results['circuit_metrics']['circuit_size']}")
    print(f"  Num qubits: {search_results['circuit_metrics']['num_qubits']}")
    print()
    
    # Test 2: SAT Problem
    print("2. SAT Problem Comparison:")
    # (x1 ∨ ¬x2 ∨ x3) ∧ (¬x1 ∨ x2 ∨ ¬x3) - 3-SAT with 3 variables
    sat_clauses = [
        [(0, True), (1, False), (2, True)],  # x1 ∨ ¬x2 ∨ x3
        [(0, False), (1, True), (2, False)]  # ¬x1 ∨ x2 ∨ ¬x3
    ]
    num_vars = 3
    
    sat_results = comparator.benchmark_sat_problem(sat_clauses, num_vars)
    print(f"  Classical time: {sat_results['classical_time']:.6f}s")
    print(f"  Quantum time: {sat_results['quantum_time']:.6f}s")
    print(f"  Classical scaling: {sat_results['classical_scaling']}")
    print(f"  Quantum scaling: {sat_results['quantum_scaling']}")
    print(f"  Circuit depth: {sat_results['circuit_metrics']['circuit_depth']}")
    print(f"  Circuit size: {sat_results['circuit_metrics']['circuit_size']}")
    print(f"  Num qubits: {sat_results['circuit_metrics']['num_qubits']}")
    print()
    
    print("Baseline comparisons completed!")
    
    return [search_results, sat_results]


if __name__ == "__main__":
    results = run_quantum_vs_classical_baselines()