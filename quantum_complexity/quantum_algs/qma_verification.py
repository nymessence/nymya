"""
Quantum verification experiments (QMA-style verification)
"""
import numpy as np
import time
from qiskit import QuantumCircuit, ClassicalRegister
from qiskit_aer import Aer
from typing import List, Tuple, Dict, Any
from quantum_complexity.quantum_algs.grovers_algorithm import GroversAlgorithm


class QMAStyleVerifier:
    """
    QMA (Quantum Merlin Arthur) style verifier experiments.
    
    QMA is the quantum analog of NP where the prover (Merlin) sends quantum states
    and the verifier (Arthur) performs polynomial-time quantum computation.
    """
    
    def __init__(self):
        self.backend = Aer.get_backend('aer_simulator')
    
    def create_quantum_proof_for_3sat(self, variables: int, clauses: List[List[Tuple[int, bool]]], 
                                      satisfying_assignment: List[bool]) -> QuantumCircuit:
        """
        Create a simple quantum proof for 3SAT (simulating Merlin's proof).
        
        Args:
            variables: Number of variables in the problem
            clauses: 3SAT clauses
            satisfying_assignment: A satisfying assignment (classical proof)
            
        Returns:
            Quantum circuit representing the quantum proof
        """
        # Create a quantum circuit that encodes the satisfying assignment
        qc = QuantumCircuit(variables)
        
        # Initialize qubits based on the satisfying assignment
        for i, value in enumerate(satisfying_assignment[:variables]):
            if value:
                qc.x(i)  # Set to |1> if assignment is True
        
        # Add some quantum operations to make it more interesting
        # This could be Hadamards, entangling operations, etc.
        for i in range(variables - 1):
            qc.cx(i, i+1)  # Add some entanglement
        
        for i in range(variables):
            qc.h(i)  # Add some superposition
        
        return qc
    
    def create_qma_verifier(self, variables: int, clauses: List[List[Tuple[int, bool]]], 
                           proof_circuit: QuantumCircuit) -> QuantumCircuit:
        """
        Create a QMA verifier circuit that checks the quantum proof.
        
        Args:
            variables: Number of variables
            clauses: 3SAT clauses to verify
            proof_circuit: The quantum proof circuit from the prover
            
        Returns:
            Quantum circuit for the QMA verifier
        """
        # Total qubits: variable qubits + ancilla qubits for clause checks + result qubit
        n_clause_ancillas = len(clauses)
        total_qubits = variables + n_clause_ancillas + 1  # +1 for final result
        total_clbits = 1  # For final measurement
        
        # Create quantum circuit
        qc = QuantumCircuit(total_qubits, total_clbits)
        
        # Load the quantum proof into the variable qubits
        # (in a real QMA, this would be the prover's quantum state)
        # For this demo, we'll compose the proof circuit
        if proof_circuit.num_qubits == variables:
            qc.compose(proof_circuit, qubits=list(range(variables)), inplace=True)
        
        # Apply operations to verify the proof against the clauses
        # For each clause, we'll check if at least one literal is satisfied
        for clause_idx, clause in enumerate(clauses):
            clause_ancilla = variables + clause_idx
            
            # For each variable in the clause, check if it has the correct value
            literal_qubits = []
            for var_idx, is_positive in clause:
                literal_qubits.append(var_idx)
                
                # If literal should be positive but qubit is in wrong state, 
                # we need to handle this differently in quantum setting
                # For simplicity, we'll just apply X gate if negative literal
                if not is_positive:
                    qc.x(var_idx)
            
            # Mark if this clause is satisfied (at least one literal is true)
            # This is an OR of the literals in the clause
            if len(literal_qubits) == 1:
                qc.cx(literal_qubits[0], clause_ancilla)
            elif len(literal_qubits) == 2:
                # For 2 literals OR: we want to mark if at least one is 1
                qc.x(literal_qubits[0])
                qc.x(literal_qubits[1])
                qc.ccx(literal_qubits[0], literal_qubits[1], clause_ancilla)  # Mark when both are 0
                qc.x(literal_qubits[0])
                qc.x(literal_qubits[1])
                qc.x(clause_ancilla)  # Flip to mark OR result
            elif len(literal_qubits) == 3:
                # For 3 literals OR
                qc.x(literal_qubits[0])
                qc.x(literal_qubits[1])
                qc.x(literal_qubits[2])
                # Use ancilla to compute AND of negations (for 3 variables)
                temp_ancilla = variables + len(clauses)  # Use another available qubit temporarily
                if temp_ancilla < total_qubits:
                    # First, compute AND of first two negated variables
                    qc.ccx(literal_qubits[0], literal_qubits[1], temp_ancilla)
                    # Then AND with the third negated variable
                    qc.ccx(temp_ancilla, literal_qubits[2], clause_ancilla)
                    # Undo the temp ancilla computation
                    qc.ccx(temp_ancilla, literal_qubits[2], clause_ancilla)
                    qc.ccx(literal_qubits[0], literal_qubits[1], temp_ancilla)
                else:
                    # Simplified approach: just mark the first two as an OR
                    qc.ccx(literal_qubits[0], literal_qubits[1], clause_ancilla)
                # Reset the negated variables
                qc.x(literal_qubits[0])
                qc.x(literal_qubits[1])
                qc.x(literal_qubits[2])
                qc.x(clause_ancilla)  # Get the OR result
            
            # Flip back for negative literals
            for var_idx, is_positive in clause:
                if not is_positive:
                    qc.x(var_idx)
        
        # Now check if ALL clauses are satisfied (AND of all clause results)
        result_qubit = variables + len(clauses)
        clause_qubits = [variables + i for i in range(len(clauses))]
        
        if len(clause_qubits) == 1:
            # Just copy the single clause result
            qc.cx(clause_qubits[0], result_qubit)
        elif len(clause_qubits) == 2:
            # AND of two clause results
            qc.ccx(clause_qubits[0], clause_qubits[1], result_qubit)
        else:
            # For multiple clauses, compute AND of all
            for i in range(len(clause_qubits) - 1):
                # Use ancilla to compute running AND
                if i == 0:
                    # First AND operation: clause_qubits[0] AND clause_qubits[1] -> clause_qubits[0] (save result temporarily)
                    # We need an extra ancilla, or use a temporary location
                    temp_target = variables + len(clauses)  # Use next available qubit
                    if temp_target + i < result_qubit:
                        qc.ccx(clause_qubits[0], clause_qubits[1], temp_target)
                        # Now temp_target has the AND of first two clauses
                        # Continue with remaining clauses
                        current_result_pos = temp_target
                        for j in range(2, len(clause_qubits)):
                            next_pos = variables + len(clauses) + 1 if j % 2 == 0 else variables + len(clauses)  # Toggle positions
                            if next_pos != current_result_pos and next_pos < result_qubit:
                                qc.ccx(current_result_pos, clause_qubits[j], next_pos)
                                # Reset the old result position
                                qc.ccx(current_result_pos, clause_qubits[j], next_pos)
                                qc.ccx(current_result_pos, clause_qubits[j], next_pos)
                                current_result_pos = next_pos
                    # For now, simplify and just use first two clauses
                    qc.ccx(clause_qubits[0], clause_qubits[1], clause_qubits[2] if len(clause_qubits) > 2 else result_qubit)
            # More complex for many clauses - simplified for demo
        
        # Measure the final result
        qc.measure(result_qubit, 0)
        
        return qc

    def verify_quantum_proof(self, variables: int, clauses: List[List[Tuple[int, bool]]], 
                            satisfying_assignment: List[bool], shots: int = 1000) -> Dict[str, Any]:
        """
        Verify a quantum proof for SAT using QMA-style verification.
        
        Args:
            variables: Number of variables in the SAT problem
            clauses: SAT clauses to verify
            satisfying_assignment: A satisfying assignment (classical proof used to create quantum proof)
            shots: Number of measurement shots
            
        Returns:
            Dictionary with verification results
        """
        start_time = time.time()
        
        # Create quantum proof based on the satisfying assignment
        quantum_proof = self.create_quantum_proof_for_3sat(variables, clauses, satisfying_assignment)
        
        # Create the QMA verifier circuit
        verifier_circuit = self.create_qma_verifier(variables, clauses, quantum_proof)
        
        # Run the verification circuit
        from qiskit import transpile
        transpiled_circuit = transpile(verifier_circuit, self.backend)
        job = self.backend.run(transpiled_circuit, shots=shots)
        result = job.result()
        counts = result.get_counts(transpiled_circuit)
        
        execution_time = time.time() - start_time
        
        # Analyze results
        # In QMA, we accept if the measurement result has a high probability of being 1
        accept_count = counts.get('1', 0) if len(counts) > 0 else 0
        reject_count = counts.get('0', 0) if len(counts) > 0 else 0
        total_samples = accept_count + reject_count
        
        acceptance_probability = accept_count / total_samples if total_samples > 0 else 0
        
        verdict = acceptance_probability > 0.5  # Accept if probability of 1 is > 0.5
        
        return {
            'verdict': verdict,
            'accept_count': accept_count,
            'reject_count': reject_count,
            'total_samples': total_samples,
            'acceptance_probability': acceptance_probability,
            'execution_time': execution_time,
            'circuit_depth': verifier_circuit.depth(),
            'circuit_size': verifier_circuit.size(),
            'quantum_proof_size': quantum_proof.size(),
            'satisfying_assignment': satisfying_assignment
        }
    
    def classical_verification(self, assignment: List[bool], clauses: List[List[Tuple[int, bool]]]) -> bool:
        """
        Classical verification of a SAT assignment.
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


def run_qma_verification_experiments():
    """Run QMA-style verification experiments."""
    verifier = QMAStyleVerifier()
    
    print("=== QMA-Style Verification Experiments ===\n")
    
    # Test 1: Valid proof (satisfying assignment)
    print("Test 1: Valid proof (should be accepted)")
    # Use the same example: (x1 ∨ ¬x2 ∨ x3) ∧ (¬x1 ∨ x2 ∨ ¬x3)
    clauses1 = [
        [(0, True), (1, False), (2, True)],   # x0 ∨ ¬x1 ∨ x2
        [(0, False), (1, True), (2, False)]   # ¬x0 ∨ x1 ∨ ¬x2
    ]
    n_vars1 = 3
    
    # Find a satisfying assignment (we know [False, False, False] works)
    satisfying_assignment1 = [False, False, False]
    
    print(f"  Clauses: {len(clauses1)} clauses with {n_vars1} variables")
    print(f"  Valid assignment (classically verified): {verifier.classical_verification(satisfying_assignment1, clauses1)}")
    
    # Verify with QMA-style quantum verification
    qma_result1 = verifier.verify_quantum_proof(n_vars1, clauses1, satisfying_assignment1)
    print(f"  QMA verification result: {'ACCEPT' if qma_result1['verdict'] else 'REJECT'}")
    print(f"  Acceptance probability: {qma_result1['acceptance_probability']:.3f}")
    print(f"  Execution time: {qma_result1['execution_time']:.6f}s")
    print(f"  Circuit depth: {qma_result1['circuit_depth']}")
    
    # Test 2: Invalid proof (non-satisfying assignment)
    print(f"\nTest 2: Invalid proof (should be rejected)")
    # Use an assignment that doesn't satisfy clauses
    non_satisfying_assignment = [True, True, True]
    
    print(f"  Non-satisfying assignment (classically verified): {verifier.classical_verification(non_satisfying_assignment, clauses1)}")
    
    qma_result2 = verifier.verify_quantum_proof(n_vars1, clauses1, non_satisfying_assignment)
    print(f"  QMA verification result: {'ACCEPT' if qma_result2['verdict'] else 'REJECT'}")
    print(f"  Acceptance probability: {qma_result2['acceptance_probability']:.3f}")
    print(f"  Execution time: {qma_result2['execution_time']:.6f}s")
    print(f"  Circuit depth: {qma_result2['circuit_depth']}")
    
    # Additional analysis
    print(f"\nQMA vs NP Verification Comparison:")
    print(f"  NP: Classical verifier takes polynomial time to check classical proof")
    print(f"  QMA: Quantum verifier takes polynomial time to check quantum proof")
    print(f"  For SAT problem, quantum verification provides quantum state as proof")
    print(f"  The power of QMA comes from quantum superposition in the proof")
    print(f"  However, QMA != BQP (quantum analog of P), so NP ⊆ QMA ⊆ PSPACE")
    
    return [qma_result1, qma_result2]


if __name__ == "__main__":
    results = run_qma_verification_experiments()