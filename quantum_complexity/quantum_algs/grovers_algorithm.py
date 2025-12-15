"""
Implementation of Grover's Algorithm for quantum search
"""
import numpy as np
from qiskit import QuantumCircuit, ClassicalRegister
from qiskit_aer import Aer
from typing import List, Tuple, Optional, Dict
from quantum_complexity.utils.quantum_simulator import QuantumOracle


class GroversAlgorithm:
    """Implementation of Grover's search algorithm"""
    
    def __init__(self):
        self.backend = Aer.get_backend('aer_simulator')
    
    @staticmethod
    def create_diffusion_operator(num_qubits: int) -> QuantumCircuit:
        """
        Create the Grover diffusion operator (2|s><s| - I).
        
        Args:
            num_qubits: Number of qubits for the diffusion operator
            
        Returns:
            Quantum circuit implementing the diffusion operator
        """
        qc = QuantumCircuit(num_qubits)
        
        # Apply Hadamard to all qubits
        for i in range(num_qubits):
            qc.h(i)
        
        # Apply X to all qubits
        for i in range(num_qubits):
            qc.x(i)
        
        # Apply multi-controlled Z gate
        # For 1 qubit: just Z
        # For 2 qubits: CZ
        # For more: multi-controlled Z using H-X-H to make X
        if num_qubits == 1:
            qc.z(0)
        elif num_qubits == 2:
            qc.cz(0, 1)
        else:
            # For more than 2 qubits, implement multi-controlled Z
            qc.h(num_qubits - 1)  # Convert to multi-controlled X
            qc.mcx(list(range(num_qubits - 1)), num_qubits - 1)
            qc.h(num_qubits - 1)
        
        # Apply X to all qubits
        for i in range(num_qubits):
            qc.x(i)
        
        # Apply Hadamard to all qubits
        for i in range(num_qubits):
            qc.h(i)
        
        return qc
    
    @staticmethod
    def create_grover_search_circuit(oracle: QuantumCircuit, iterations: int = None) -> Tuple[QuantumCircuit, int]:
        """
        Create a complete Grover search circuit.
        
        Args:
            oracle: The oracle circuit that marks the solution state(s)
            iterations: Number of Grover iterations (default: calculate optimal)
            
        Returns:
            Tuple of (complete Grover circuit, number of iterations used)
        """
        num_qubits = oracle.num_qubits
        search_qubits = num_qubits  # All qubits are used for search in our implementation
        
        # Calculate optimal number of iterations if not provided
        if iterations is None:
            # For N items, optimal number of iterations is approximately pi/4 * sqrt(N)
            n = search_qubits  # number of qubits for search space
            N = 2 ** n  # size of search space
            if N > 1:
                iterations = int(np.pi / 4 * np.sqrt(N))
            else:
                iterations = 1
        
        # Create the quantum circuit with classical register for measurements
        qc = QuantumCircuit(num_qubits, search_qubits)
        
        # Initialize all qubits to uniform superposition
        for i in range(search_qubits):
            qc.h(i)
        
        # Apply Grover iterations
        diffusion_op = GroversAlgorithm.create_diffusion_operator(search_qubits)
        
        for _ in range(iterations):
            # Apply the oracle
            qc.compose(oracle, inplace=True)
            
            # Apply the diffusion operator
            qc.compose(diffusion_op, inplace=True)
        
        # Add measurements to the search qubits
        for i in range(search_qubits):
            qc.measure(i, i)
        
        return qc, iterations
    
    def run_search(self, items: List[int], target: int, shots: int = 1024) -> Tuple[Optional[int], Dict]:
        """
        Run Grover's algorithm to search for a target in the list of items.
        
        Args:
            items: The list of items to search through
            target: The target value to search for
            shots: Number of measurement shots
            
        Returns:
            Tuple of (found index or None, result dictionary with metrics)
        """
        from qiskit import transpile
        from collections import Counter
        import time
        
        start_time = time.time()
        
        # Create oracle for the search
        oracle = QuantumOracle.create_search_oracle(items, target)
        
        # Create the full Grover search circuit
        search_circuit, iterations_used = self.create_grover_search_circuit(oracle)
        
        # Transpile and run the circuit
        transpiled_circuit = transpile(search_circuit, self.backend)
        job = self.backend.run(transpiled_circuit, shots=shots)
        result = job.result()
        counts = result.get_counts(transpiled_circuit)
        
        execution_time = time.time() - start_time
        
        # Process results: find the most common measurement
        if counts:
            most_common_state = max(counts, key=counts.get)
            # Convert binary state to integer index
            found_index = int(most_common_state, 2)
            
            # Verify the result
            if 0 <= found_index < len(items) and items[found_index] == target:
                result_data = {
                    'found': True,
                    'index': found_index,
                    'measured_state': most_common_state,
                    'all_counts': counts,
                    'grover_iterations': iterations_used,
                    'execution_time': execution_time,
                    'circuit_depth': search_circuit.depth(),
                    'circuit_size': search_circuit.size()
                }
                return found_index, result_data
            else:
                result_data = {
                    'found': False,
                    'index': found_index,
                    'measured_state': most_common_state,
                    'all_counts': counts,
                    'grover_iterations': iterations_used,
                    'execution_time': execution_time,
                    'circuit_depth': search_circuit.depth(),
                    'circuit_size': search_circuit.size()
                }
                return None, result_data
        else:
            result_data = {
                'found': False,
                'index': None,
                'measured_state': None,
                'all_counts': counts,
                'grover_iterations': iterations_used,
                'execution_time': execution_time,
                'circuit_depth': search_circuit.depth(),
                'circuit_size': search_circuit.size()
            }
            return None, result_data

    def benchmark_scaling(self, sizes: List[int], target_position: float = 0.5, shots: int = 1024) -> List[Dict]:
        """
        Benchmark Grover's algorithm scaling with different input sizes.
        
        Args:
            sizes: List of input sizes (list lengths) to test
            target_position: Relative position of target in the list (0 to 1)
            shots: Number of measurement shots for each run
            
        Returns:
            List of benchmark results for each size
        """
        results = []
        
        for size in sizes:
            print(f"Running Grover's algorithm for size {size}...")
            
            # Create a list of unique numbers
            items = list(range(size))
            
            # Determine target index based on relative position
            target_idx = int(size * target_position) % size
            target = items[target_idx]
            
            # Run Grover's algorithm
            _, result_data = self.run_search(items, target, shots)
            
            # Add classical comparison for reference
            classical_steps = size  # Linear search worst case
            
            result_data.update({
                'input_size': size,
                'target_index': target_idx,
                'classical_scaling': f'O({size})',
                'quantum_scaling': f'O(√{size}) ≈ O({int(np.sqrt(size))})',
                'theoretical_quantum_steps': int(np.pi/4 * np.sqrt(size)),
                'classical_steps': classical_steps
            })
            
            results.append(result_data)
        
        return results


if __name__ == "__main__":
    # Test Grover's algorithm implementation
    grover = GroversAlgorithm()
    
    # Test on a small list
    print("Testing Grover's algorithm on a list of 8 items:")
    items = list(range(8))  # [0, 1, 2, 3, 4, 5, 6, 7]
    target = 5
    
    found_index, result_data = grover.run_search(items, target, shots=1000)
    print(f"Target {target} found at index: {found_index}")
    print(f"Execution time: {result_data['execution_time']:.6f}s")
    print(f"Circuit depth: {result_data['circuit_depth']}")
    print(f"Grover iterations: {result_data['grover_iterations']}")
    print(f"Measurement counts: {dict(list(result_data['all_counts'].items())[:3])}...")
    
    # Test scaling
    print("\nTesting scaling with different input sizes:")
    sizes = [4, 8, 16]
    scaling_results = grover.benchmark_scaling(sizes, shots=500)
    
    for result in scaling_results:
        print(f"Size {result['input_size']}: {result['execution_time']:.6f}s, "
              f"depth {result['circuit_depth']}, "
              f"quantum steps est. {result['theoretical_quantum_steps']}")