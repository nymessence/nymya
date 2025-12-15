"""
Test runner for NP-class problems
"""
from utils.measurement import run_complexity_test, save_results, estimate_complexity_growths
from np_class.subset_sum import subset_sum_bruteforce, generate_subset_sum_input, verify_subset_sum_solution
from np_class.sat import sat_solver_bruteforce, generate_sat_input
from np_class.ksat import generate_3sat_input, solve_3sat_bruteforce


def test_subset_sum():
    """Test subset sum complexity"""
    print("Testing Subset Sum...")
    input_sizes = [10, 12, 14, 16, 18]  # Smaller sizes due to exponential complexity
    
    def run_subset_sum(data_tuple):
        nums, target = data_tuple
        return subset_sum_bruteforce(nums, target)
    
    def input_gen(size):
        return generate_subset_sum_input(size)
    
    results = run_complexity_test(run_subset_sum, input_sizes, input_gen, "NP", "subset_sum")
    growth_rates = estimate_complexity_growths(results)
    print(f"Growth rates for subset sum: {growth_rates}")
    save_results(results, "complexity_tests/benchmarks/subset_sum_results.json")
    return results


def test_sat():
    """Test SAT complexity"""
    print("\nTesting SAT...")
    # Use smaller input sizes due to exponential complexity
    clause_counts = [5, 7, 9, 11]  # Using number of clauses as proxy for size
    input_sizes = clause_counts
    
    def run_sat(formula):
        return sat_solver_bruteforce(formula)
    
    def input_gen(size):
        # Generate SAT problem with 'size' variables and 'size' clauses
        return generate_sat_input(size, size, clause_size=3)
    
    results = run_complexity_test(run_sat, input_sizes, input_gen, "NP", "sat_general")
    growth_rates = estimate_complexity_growths(results)
    print(f"Growth rates for general SAT: {growth_rates}")
    save_results(results, "complexity_tests/benchmarks/sat_results.json")
    return results


def test_3sat():
    """Test 3-SAT complexity"""
    print("\nTesting 3-SAT...")
    # Use smaller input sizes due to exponential complexity
    clause_counts = [5, 7, 9, 11]  # Using number of clauses as proxy for size
    input_sizes = clause_counts
    
    def run_3sat(formula):
        return solve_3sat_bruteforce(formula)
    
    def input_gen(size):
        # Generate 3-SAT problem with 'size' variables and 'size' clauses
        return generate_3sat_input(size, size)
    
    results = run_complexity_test(run_3sat, input_sizes, input_gen, "NP", "3sat")
    growth_rates = estimate_complexity_growths(results)
    print(f"Growth rates for 3-SAT: {growth_rates}")
    save_results(results, "complexity_tests/benchmarks/3sat_results.json")
    return results


if __name__ == "__main__":
    print("Running NP-class complexity tests...\n")
    
    # Note: These tests might take a while due to exponential complexity
    subset_results = test_subset_sum()
    sat_results = test_sat()  
    sat3_results = test_3sat()
    
    print("\nNP-class tests completed!")
    print("Results saved to complexity_tests/benchmarks/")