"""
Test runner for NP-Hard problems
"""
from utils.measurement import run_complexity_test, save_results, estimate_complexity_growths
from np_hard.tsp_optimization import tsp_optimal_bruteforce, generate_tsp_opt_input, verify_tsp_opt_solution


def test_tsp_optimization():
    """Test TSP optimization problem complexity"""
    print("Testing TSP Optimization Problem...")
    # Use very small input sizes due to factorial complexity
    city_counts = [4, 5, 6]  # Very small due to factorial complexity
    
    def run_tsp_opt(distances):
        return tsp_optimal_bruteforce(distances)
    
    def input_gen(size):
        return generate_tsp_opt_input(size)
    
    results = run_complexity_test(run_tsp_opt, city_counts, input_gen, "NP-hard", "tsp_optimization")
    growth_rates = estimate_complexity_growths(results)
    print(f"Growth rates for TSP optimization: {growth_rates}")
    save_results(results, "complexity_tests/benchmarks/tsp_optimization_results.json")
    
    # Extract just the cost from results for analysis
    for result in results:
        tour, cost = result['result']
        result['optimal_cost'] = cost
        del result['result']  # Remove the complex tour data
        result['result'] = f"Cost: {cost}, Tour length: {len(tour) if tour else 0}"
    
    return results


if __name__ == "__main__":
    print("Running NP-Hard complexity tests...\n")
    
    # Note: These tests will be extremely slow due to factorial complexity
    tsp_opt_results = test_tsp_optimization()
    
    print("\nNP-Hard tests completed!")
    print("Results saved to complexity_tests/benchmarks/")