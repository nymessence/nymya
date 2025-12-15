"""
Quantum SAT solver based on Grover's algorithm
"""
import numpy as np
import time
from qiskit import QuantumCircuit
from qiskit_aer import Aer
from typing import List, Tuple, Optional, Dict, Any
from quantum_complexity.utils.quantum_simulator import QuantumOracle
from quantum_complexity.quantum_algs.grovers_algorithm import GroversAlgorithm


class QuantumSATSolver:
    """Quantum solver for SAT problems using Grover's algorithm"""
    
    def __init__(self):
        self.backend = Aer.get_backend('aer_simulator')
        self.grover = GroversAlgorithm()
    
    @staticmethod
    def create_sat_oracle_detailed(variables: int, clauses: List[List[Tuple[int, bool]]]) -> QuantumCircuit:
        """
        Create a quantum oracle for SAT problems.
        
        Args:
            variables: Number of variables in the SAT problem
            clauses: List of clauses, each clause is a list of (var_index, is_positive) tuples
            
        Returns:
            Quantum circuit implementing the SAT oracle
        """
        # Total qubits needed: variables + clause ancillas + output qubit
        n_clause_ancillas = len(clauses)
        total_qubits = variables + n_clause_ancillas + 1  # +1 for final output
        
        # Create quantum circuit
        qc = QuantumCircuit(total_qubits)
        
        # Process each clause
        for clause_idx, clause in enumerate(clauses):
            clause_ancilla = variables + clause_idx
            
            # For each clause, we need to check if at least one literal is true
            # This is an OR of literals in the clause
            literal_qubits = []
            for var_idx, is_positive in clause:
                literal_qubits.append(var_idx)
                
                # If literal is negative, we temporarily flip it
                if not is_positive:
                    qc.x(var_idx)
            
            # Mark the clause as satisfied if at least one literal is true
            # For this, we'll use multi-controlled X to mark when OR of literals is true
            if len(literal_qubits) == 1:
                # Single literal: just CNOT
                qc.cx(literal_qubits[0], clause_ancilla)
            elif len(literal_qubits) == 2:
                # Two literals: implement OR using ancilla logic
                # To implement OR(x, y), we use: OR(x, y) = NOT(AND(NOT(x), NOT(y)))
                # But for marking purposes, we can implement it directly 
                qc.x(literal_qubits[0])
                qc.x(literal_qubits[1])
                qc.ccx(literal_qubits[0], literal_qubits[1], clause_ancilla)
                qc.x(literal_qubits[0])
                qc.x(literal_qubits[1])
                qc.x(clause_ancilla)  # Flip to get OR result
            else:
                # For 3+ literals, we use multi-controlled X with additional logic
                # Initialize ancilla to |1>, then CCX to make it |0> only if all inputs are |0>
                qc.x(clause_ancilla)  # Start with ancilla as 1
                if len(literal_qubits) == 3:
                    # For 3 literals, use two CCX gates
                    temp_ancilla = variables + n_clause_ancillas  # Use next available qubit temporarily
                    if temp_ancilla < total_qubits:
                        qc.ccx(literal_qubits[0], literal_qubits[1], temp_ancilla)
                        qc.ccx(temp_ancilla, literal_qubits[2], clause_ancilla)
                        # Undo the temp ancilla
                        qc.ccx(temp_ancilla, literal_qubits[2], clause_ancilla)
                        qc.ccx(literal_qubits[0], literal_qubits[1], temp_ancilla)
                    else:
                        # Simplified approach for now
                        qc.x(clause_ancilla)  # Just reset
                elif len(literal_qubits) == 2:
                    # Use CCX for 2 inputs
                    qc.ccx(literal_qubits[0], literal_qubits[1], clause_ancilla)
                    # Then we need to get the OR: apply X gates to get AND of negations, then negate
                    # Actually, let's use the correct approach for OR
                    qc.x(literal_qubits[0])
                    qc.x(literal_qubits[1])
                    qc.ccx(literal_qubits[0], literal_qubits[1], clause_ancilla)
                    qc.x(literal_qubits[0])
                    qc.x(literal_qubits[1])
                    qc.x(clause_ancilla)  # Get the OR result instead of AND
            
            # Flip back negative literals
            for var_idx, is_positive in clause:
                if not is_positive:
                    qc.x(var_idx)
        
        # Finally, compute AND of all clause results
        output_qubit = variables + n_clause_ancillas
        
        if n_clause_ancillas == 1:
            # Just copy the single clause result
            qc.cx(variables, output_qubit)
        elif n_clause_ancillas == 2:
            # AND of two clause results
            qc.ccx(variables, variables + 1, output_qubit)
        else:
            # For more clauses, use multi-controlled X
            clause_qubits = [variables + i for i in range(n_clause_ancillas)]
            # Simplified for now
            if n_clause_ancillas <= 2:
                qc.ccx(clause_qubits[0], clause_qubits[1], output_qubit)
        
        return qc

    def encode_assignment(self, assignment: List[bool], n_vars: int) -> int:
        """
        Encode a boolean assignment as an integer index.
        
        Args:
            assignment: List of boolean values for each variable
            n_vars: Total number of variables
            
        Returns:
            Integer representation of the assignment
        """
        # Pad assignment if needed
        padded = assignment + [False] * (n_vars - len(assignment))
        
        # Convert to integer
        result = 0
        for i, val in enumerate(padded):
            if val:
                result += (1 << i)  # Add 2^i if true
        return result

    def decode_assignment(self, encoded: int, n_vars: int) -> List[bool]:
        """
        Decode an integer index to a boolean assignment.
        
        Args:
            encoded: Integer representation of the assignment
            n_vars: Total number of variables
            
        Returns:
            List of boolean values for each variable
        """
        assignment = []
        for i in range(n_vars):
            assignment.append(bool(encoded & (1 << i)))
        return assignment

    def verify_assignment(self, assignment: List[bool], clauses: List[List[Tuple[int, bool]]]) -> bool:
        """
        Classically verify if an assignment satisfies all clauses.
        
        Args:
            assignment: Boolean assignment to verify
            clauses: SAT clauses to check
            
        Returns:
            True if assignment satisfies all clauses
        """
        for clause in clauses:
            clause_satisfied = False
            for var_idx, is_positive in clause:
                if var_idx < len(assignment):
                    var_value = assignment[var_idx]
                    if (is_positive and var_value) or (not is_positive and not var_value):
                        clause_satisfied = True
                        break
            if not clause_satisfied:
                return False
        return True

    def solve_sat_quantum(self, clauses: List[List[Tuple[int, bool]]], n_vars: int, 
                         shots: int = 1024) -> Tuple[Optional[List[bool]], Dict[str, Any]]:
        """
        Solve SAT problem using quantum search (Grover's algorithm).
        
        Args:
            clauses: SAT clauses to solve
            n_vars: Number of variables in the SAT problem
            shots: Number of measurement shots
            
        Returns:
            Tuple of (satisfying assignment or None, result metrics)
        """
        import time
        from collections import Counter
        
        start_time = time.time()
        
        try:
            # Create oracle for SAT problem
            # This is a simplified version - creating a complete SAT oracle is complex
            # We'll simulate the approach conceptually
            
            # In a real implementation, we would create a specific SAT oracle
            # For now, we'll create the oracle circuit using the detailed method
            oracle = self.create_sat_oracle_detailed(n_vars, clauses)
            
            # Create the Grover search circuit for SAT
            # We need to search through all possible 2^n variable assignments
            search_space_size = 2 ** n_vars
            
            # Calculate optimal number of iterations
            optimal_iterations = int(np.pi/4 * np.sqrt(search_space_size)) if search_space_size > 1 else 1
            
            # Create the full quantum circuit for SAT
            qc = QuantumCircuit(oracle.num_qubits, n_vars)  # Measurements only for variable qubits
            
            # Initialize variable qubits to superposition
            for i in range(n_vars):
                qc.h(i)
            
            # Apply Grover iterations
            diffusion_op = self.grover.create_diffusion_operator(n_vars)
            
            for _ in range(optimal_iterations):
                # Apply the SAT oracle
                qc.compose(oracle, inplace=True)
                
                # Apply the diffusion operator (only to variable qubits)
                qc.compose(diffusion_op, inplace=True)
            
            # Add measurements to the variable qubits
            for i in range(n_vars):
                qc.measure(i, i)
            
            # Run the circuit
            from qiskit import transpile
            transpiled_circuit = transpile(qc, self.backend)
            job = self.backend.run(transpiled_circuit, shots=shots)
            result = job.result()
            counts = result.get_counts(transpiled_circuit)
            
            execution_time = time.time() - start_time
            
            # Process results: find the most common measurement
            if counts:
                most_common_state = max(counts, key=counts.get)
                # Convert binary measurement to assignment
                assignment = [bool(int(bit)) for bit in reversed(most_common_state.zfill(n_vars))]
                
                # Verify the assignment classically
                is_valid = self.verify_assignment(assignment, clauses)
                
                result_data = {
                    'found_solution': is_valid,
                    'assignment': assignment if is_valid else None,
                    'raw_measurement': most_common_state,
                    'all_counts': counts,
                    'grover_iterations': optimal_iterations,
                    'execution_time': execution_time,
                    'circuit_depth': qc.depth(),
                    'circuit_size': qc.size(),
                    'search_space_size': search_space_size,
                    'quantum_speedup_factor': np.sqrt(search_space_size)  # Theoretical speedup
                }
                
                return assignment if is_valid else None, result_data
            else:
                result_data = {
                    'found_solution': False,
                    'assignment': None,
                    'raw_measurement': None,
                    'all_counts': counts,
                    'grover_iterations': optimal_iterations,
                    'execution_time': execution_time,
                    'circuit_depth': qc.depth(),
                    'circuit_size': qc.size(),
                    'search_space_size': search_space_size,
                    'quantum_speedup_factor': np.sqrt(search_space_size)
                }
                return None, result_data
                
        except Exception as e:
            execution_time = time.time() - start_time
            result_data = {
                'found_solution': False,
                'assignment': None,
                'error': str(e),
                'execution_time': execution_time,
                'circuit_depth': 0,
                'circuit_size': 0,
                'search_space_size': 2 ** n_vars,
                'quantum_speedup_factor': np.sqrt(2 ** n_vars)
            }
            return None, result_data

    def solve_sat_classical(self, clauses: List[List[Tuple[int, bool]]], n_vars: int) -> List[bool]:
        """
        Solve SAT problem using classical brute force.
        
        Args:
            clauses: SAT clauses to solve
            n_vars: Number of variables in the SAT problem
            
        Returns:
            Satisfying assignment or None if no solution exists
        """
        import itertools
        import time
        
        start_time = time.time()
        
        # Try all possible assignments
        for assignment in itertools.product([False, True], repeat=n_vars):
            if self.verify_assignment(assignment, clauses):
                execution_time = time.time() - start_time
                return list(assignment)
        
        execution_time = time.time() - start_time
        return None


def run_quantum_vs_classical_sat_comparison():
    """Run a comparison between quantum and classical SAT solving."""
    solver = QuantumSATSolver()
    
    print("=== Quantum vs Classical SAT Solving Comparison ===\n")
    
    # Test SAT instance: (x1 ∨ ¬x2 ∨ x3) ∧ (¬x1 ∨ x2 ∨ ¬x3) - should be satisfiable
    clauses = [
        [(0, True), (1, False), (2, True)],   # x1 ∨ ¬x2 ∨ x3
        [(0, False), (1, True), (2, False)]   # ¬x1 ∨ x2 ∨ ¬x3
    ]
    n_vars = 3
    
    print(f"Testing with {n_vars} variables and {len(clauses)} clauses:")
    for i, clause in enumerate(clauses):
        clause_str = " ∨ ".join([f"{'¬' if not pos else ''}x{var}" for var, pos in clause])
        print(f"  Clause {i+1}: ({clause_str})")
    
    # Solve with quantum approach
    print(f"\nQuantum SAT solving (Grover's algorithm):")
    quantum_solution, quantum_metrics = solver.solve_sat_quantum(clauses, n_vars, shots=1000)
    print(f"  Found solution: {quantum_solution is not None}")
    if quantum_solution:
        print(f"  Assignment: {quantum_solution}")
        print(f"  Verification: {solver.verify_assignment(quantum_solution, clauses)}")
    print(f"  Execution time: {quantum_metrics['execution_time']:.6f}s")
    print(f"  Circuit depth: {quantum_metrics['circuit_depth']}")
    print(f"  Grover iterations: {quantum_metrics['grover_iterations']}")
    
    # Solve with classical approach
    print(f"\nClassical SAT solving (brute force):")
    classical_solution = solver.solve_sat_classical(clauses, n_vars)
    classical_start = time.time()
    # Re-run with timing
    classical_solution = solver.solve_sat_classical(clauses, n_vars)
    classical_time = time.time() - classical_start
    print(f"  Found solution: {classical_solution is not None}")
    if classical_solution:
        print(f"  Assignment: {classical_solution}")
        print(f"  Verification: {solver.verify_assignment(classical_solution, clauses)}")
    print(f"  Execution time: {classical_time:.6f}s")
    
    # Complexity analysis
    search_space = 2 ** n_vars
    print(f"\nComplexity Analysis:")
    print(f"  Search space: {search_space} assignments")
    print(f"  Classical scaling: O({search_space}) - brute force")
    print(f"  Quantum scaling: O(√{search_space}) ≈ O({int(np.sqrt(search_space))}) - Grover's algorithm")
    print(f"  Theoretical speedup: ~{np.sqrt(search_space):.1f}x")
    
    return quantum_metrics


if __name__ == "__main__":
    import time  # Import needed for the function
    metrics = run_quantum_vs_classical_sat_comparison()