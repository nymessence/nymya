"""
Test runner for NP-Complete problems
"""
from utils.measurement import run_complexity_test, save_results, estimate_complexity_growths
from np_complete.clique import find_clique_bruteforce, generate_clique_input, verify_clique
from np_complete.vertex_cover import find_vertex_cover_bruteforce, generate_vertex_cover_input, verify_vertex_cover
from np_complete.tsp_decision import tsp_decision_bruteforce, generate_tsp_input, verify_tsp_solution


def test_clique():
    """Test clique problem complexity"""
    print("Testing Clique Problem...")
    # Use smaller input sizes due to exponential complexity
    vertex_counts = [6, 8, 10, 12]  # Small graphs due to exponential complexity
    
    def run_clique(data_tuple):
        graph, k = data_tuple
        return find_clique_bruteforce(graph, k)
    
    def input_gen(size):
        return generate_clique_input(size)
    
    results = run_complexity_test(run_clique, vertex_counts, input_gen, "NP-complete", "clique")
    growth_rates = estimate_complexity_growths(results)
    print(f"Growth rates for clique: {growth_rates}")
    save_results(results, "complexity_tests/benchmarks/clique_results.json")
    return results


def test_vertex_cover():
    """Test vertex cover problem complexity"""
    print("\nTesting Vertex Cover Problem...")
    # Use smaller input sizes due to exponential complexity
    vertex_counts = [6, 8, 10, 12]
    
    def run_vc(data_tuple):
        graph, k = data_tuple
        return find_vertex_cover_bruteforce(graph, k)
    
    def input_gen(size):
        return generate_vertex_cover_input(size)
    
    results = run_complexity_test(run_vc, vertex_counts, input_gen, "NP-complete", "vertex_cover")
    growth_rates = estimate_complexity_growths(results)
    print(f"Growth rates for vertex cover: {growth_rates}")
    save_results(results, "complexity_tests/benchmarks/vertex_cover_results.json")
    return results


def test_tsp_decision():
    """Test TSP decision problem complexity"""
    print("\nTesting TSP Decision Problem...")
    # Use very small input sizes due to factorial complexity
    city_counts = [4, 5, 6, 7]  # Very small due to factorial complexity
    
    def run_tsp(data_tuple):
        distances, threshold = data_tuple
        return tsp_decision_bruteforce(distances, threshold)
    
    def input_gen(size):
        return generate_tsp_input(size)
    
    results = run_complexity_test(run_tsp, city_counts, input_gen, "NP-complete", "tsp_decision")
    growth_rates = estimate_complexity_growths(results)
    print(f"Growth rates for TSP decision: {growth_rates}")
    save_results(results, "complexity_tests/benchmarks/tsp_decision_results.json")
    return results


if __name__ == "__main__":
    print("Running NP-Complete complexity tests...\n")
    
    # Note: These tests will be quite slow due to exponential/factorial complexity
    clique_results = test_clique()
    vc_results = test_vertex_cover()
    tsp_results = test_tsp_decision()
    
    print("\nNP-Complete tests completed!")
    print("Results saved to complexity_tests/benchmarks/")