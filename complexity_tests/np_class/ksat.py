"""
3-SAT Problem - NP-complete problem
Special case of SAT where each clause has exactly 3 literals.
"""
import random
from typing import List, Dict, Tuple, Optional
from np_class.sat import Clause, CNFFormula, sat_solver_bruteforce


def generate_3sat_input(num_vars: int, num_clauses: int) -> CNFFormula:
    """
    Generates a random 3-CNF formula for 3-SAT problem.
    
    Args:
        num_vars: Number of variables in the formula
        num_clauses: Number of clauses in the formula (each with exactly 3 literals)
        
    Returns:
        Random 3-CNF formula
    """
    clauses = []
    
    for _ in range(num_clauses):
        literals = []
        
        # For 3-SAT, we always select exactly 3 different variables for each clause
        selected_vars = random.sample(range(1, num_vars + 1), min(3, num_vars))
        
        for var_idx in selected_vars:
            var_name = f"x{var_idx}"
            is_positive = random.choice([True, False])
            literals.append((var_name, is_positive))
        
        # If we have fewer than 3 variables, add duplicates with different polarities
        while len(literals) < 3 and num_vars > 0:
            var_idx = random.randint(1, num_vars)
            var_name = f"x{var_idx}"
            is_positive = random.choice([True, False])
            literals.append((var_name, is_positive))
        
        clauses.append(Clause(literals))
    
    return CNFFormula(clauses)


def solve_3sat_bruteforce(formula: CNFFormula) -> Optional[Dict[str, bool]]:
    """
    Specialized solver for 3-SAT using brute force.
    This is essentially the same as the general SAT solver since both are NP-complete.
    
    Args:
        formula: 3-CNF formula to solve
        
    Returns:
        Satisfying assignment if found, None otherwise
    """
    # Since 3-SAT is a special case of SAT, we can reuse the same solver
    return sat_solver_bruteforce(formula)


if __name__ == "__main__":
    # Test with a known satisfiable 3-SAT formula
    # (x1 ∨ ¬x2 ∨ x3) ∧ (¬x1 ∨ x2 ∨ ¬x3) ∧ (x1 ∨ x2 ∨ x3)
    clauses = [
        Clause([('x1', True), ('x2', False), ('x3', True)]),
        Clause([('x1', False), ('x2', True), ('x3', False)]),
        Clause([('x1', True), ('x2', True), ('x3', True)])
    ]
    formula = CNFFormula(clauses)
    
    print("3-SAT Formula:", " ∧ ".join(str(clause) for clause in clauses))
    
    solution = solve_3sat_bruteforce(formula)
    print(f"Solution: {solution}")
    
    if solution:
        print(f"Evaluation: {formula.evaluate(solution)}")
    
    # Test with random 3-SAT
    print("\nTesting with random 3-SAT:")
    random_formula = generate_3sat_input(4, 3)
    print(f"Random 3-SAT formula: {' ∧ '.join(str(clause) for clause in random_formula.clauses)}")
    
    random_solution = solve_3sat_bruteforce(random_formula)
    print(f"Random solution: {random_solution}")
    
    if random_solution:
        print(f"Random evaluation: {random_formula.evaluate(random_solution)}")