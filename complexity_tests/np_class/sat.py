"""
Boolean Satisfiability Problem (SAT) - NP-complete problem
Given a Boolean formula, determine if there exists an assignment of variables that makes the formula true.
"""
import random
from typing import List, Dict, Tuple, Optional


class Clause:
    """Represents a clause in CNF (disjunction of literals)"""
    def __init__(self, literals: List[Tuple[str, bool]]):
        """
        Args:
            literals: List of (variable_name, is_positive) tuples
                     e.g., [('x1', True), ('x2', False)] represents x1 ∨ ¬x2
        """
        self.literals = literals
    
    def evaluate(self, assignment: Dict[str, bool]) -> bool:
        """Evaluate the clause with given variable assignment"""
        for var, is_positive in self.literals:
            if var not in assignment:
                raise ValueError(f"Variable {var} not assigned")
            
            if is_positive and assignment[var]:
                return True
            if not is_positive and not assignment[var]:
                return True
        return False
    
    def __repr__(self):
        return ' ∨ '.join([f"{'¬' if not pos else ''}{var}" for var, pos in self.literals])


class CNFFormula:
    """Represents a formula in Conjunctive Normal Form"""
    def __init__(self, clauses: List[Clause]):
        self.clauses = clauses
        # Extract all variables from clauses
        self.variables = set()
        for clause in clauses:
            for var, _ in clause.literals:
                self.variables.add(var)
    
    def evaluate(self, assignment: Dict[str, bool]) -> bool:
        """Evaluate the entire formula with given variable assignment"""
        for clause in self.clauses:
            if not clause.evaluate(assignment):
                return False  # All clauses must be true
        return True
    
    def get_variables(self) -> List[str]:
        """Return list of variables in the formula"""
        return list(self.variables)


def sat_solver_bruteforce(formula: CNFFormula) -> Optional[Dict[str, bool]]:
    """
    Solves SAT using brute force approach.
    Time complexity: O(2^n * m) where n is number of variables and m is number of clauses
    
    Args:
        formula: CNF formula to solve
        
    Returns:
        Satisfying assignment if found, None otherwise
    """
    variables = formula.get_variables()
    n = len(variables)
    
    if n == 0:
        return {} if formula.evaluate({}) else None
    
    # Try all possible assignments (2^n possibilities)
    for mask in range(1 << n):
        assignment = {}
        for i, var in enumerate(variables):
            assignment[var] = bool(mask & (1 << i))
        
        if formula.evaluate(assignment):
            return assignment
    
    return None  # No satisfying assignment found


def generate_sat_input(num_vars: int, num_clauses: int, clause_size: int = 3) -> CNFFormula:
    """
    Generates a random CNF formula for SAT problem.
    
    Args:
        num_vars: Number of variables in the formula
        num_clauses: Number of clauses in the formula
        clause_size: Number of literals per clause (default 3 for 3-SAT-like)
        
    Returns:
        Random CNF formula
    """
    clauses = []
    
    for _ in range(num_clauses):
        literals = []
        # Select random variables for the clause
        selected_vars = random.sample(range(1, num_vars + 1), min(clause_size, num_vars))
        
        for var_idx in selected_vars:
            var_name = f"x{var_idx}"
            is_positive = random.choice([True, False])
            literals.append((var_name, is_positive))
        
        clauses.append(Clause(literals))
    
    return CNFFormula(clauses)


def verify_sat_solution(formula: CNFFormula, assignment: Dict[str, bool]) -> bool:
    """
    Verifies if an assignment satisfies the given formula.
    
    Args:
        formula: CNF formula
        assignment: Variable assignment
        
    Returns:
        True if assignment satisfies formula, False otherwise
    """
    return formula.evaluate(assignment)


if __name__ == "__main__":
    # Basic test with a simple formula
    # (x1 ∨ ¬x2 ∨ x3) ∧ (¬x1 ∨ x2 ∨ ¬x3)
    clauses = [
        Clause([('x1', True), ('x2', False), ('x3', True)]),
        Clause([('x1', False), ('x2', True), ('x3', False)])
    ]
    formula = CNFFormula(clauses)
    
    print("Formula:", " ∧ ".join(str(clause) for clause in clauses))
    
    solution = sat_solver_bruteforce(formula)
    print(f"Solution: {solution}")
    
    if solution:
        print(f"Verification: {verify_sat_solution(formula, solution)}")
    else:
        print("No solution found")
    
    # Test with random formula
    print("\nTesting with random formula:")
    random_formula = generate_sat_input(5, 3, 3)
    print(f"Random formula: {' ∧ '.join(str(clause) for clause in random_formula.clauses)}")
    
    random_solution = sat_solver_bruteforce(random_formula)
    print(f"Random solution: {random_solution}")
    
    if random_solution:
        print(f"Random verification: {verify_sat_solution(random_formula, random_solution)}")
        print(f"Random assignment evaluates to: {random_formula.evaluate(random_solution)}")