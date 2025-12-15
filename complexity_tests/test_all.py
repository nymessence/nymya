"""
Master test runner for all complexity class experiments
"""
from utils.measurement import run_complexity_test, save_results, plot_complexity, estimate_complexity_growths, generate_realistic_test_sizes
from utils.input_generators import generate_scalable_input
import os


def run_all_p_class_tests():
    """Run all P-class complexity tests"""
    print("=== Running P-Class Tests ===")
    
    # Import P-class functions
    from p_class.linear_search import linear_search
    from p_class.binary_search import binary_search 
    from p_class.merge_sort import merge_sort
    
    results = []
    
    # Test Linear Search
    print("\n1. Testing Linear Search...")
    input_sizes = generate_realistic_test_sizes('P', 'linear_search', [100, 500, 1000, 2000, 5000])
    def run_linear_search(data_tuple):
        arr, target = data_tuple
        return linear_search(arr, target)
    ls_results = run_complexity_test(run_linear_search, input_sizes, 'P', 'linear_search', 'linear_search')
    results.extend(ls_results)
    
    # Test Binary Search
    print("\n2. Testing Binary Search...")
    input_sizes = generate_realistic_test_sizes('P', 'binary_search', [100, 500, 1000, 2000, 5000])
    def run_binary_search(data_tuple):
        arr, target = data_tuple
        return binary_search(arr, target)
    bs_results = run_complexity_test(run_binary_search, input_sizes, 'P', 'binary_search', 'binary_search')
    results.extend(bs_results)
    
    # Test Merge Sort
    print("\n3. Testing Merge Sort...")
    input_sizes = generate_realistic_test_sizes('P', 'merge_sort', [100, 500, 1000, 2000])
    def run_merge_sort(arr):
        return merge_sort(arr)
    ms_results = run_complexity_test(run_merge_sort, input_sizes, 'P', 'merge_sort', 'merge_sort')
    results.extend(ms_results)
    
    # Save P-class results
    save_results(ls_results, "complexity_tests/benchmarks/p_class/linear_search_results.json")
    save_results(bs_results, "complexity_tests/benchmarks/p_class/binary_search_results.json")
    save_results(ms_results, "complexity_tests/benchmarks/p_class/merge_sort_results.json")
    
    return results


def run_all_np_class_tests():
    """Run all NP-class complexity tests"""
    print("\n=== Running NP-Class Tests ===")
    
    # Import NP-class functions
    from np_class.subset_sum import subset_sum_bruteforce
    from np_class.sat import sat_solver_bruteforce
    from np_class.ksat import solve_3sat_bruteforce
    
    results = []
    
    # Test Subset Sum
    print("\n1. Testing Subset Sum...")
    input_sizes = generate_realistic_test_sizes('NP', 'subset_sum', [8, 10, 12, 14])
    def run_subset_sum(data_tuple):
        nums, target = data_tuple
        return subset_sum_bruteforce(nums, target)
    ss_results = run_complexity_test(run_subset_sum, input_sizes, 'NP', 'subset_sum', 'subset_sum')
    results.extend(ss_results)
    
    # Test General SAT
    print("\n2. Testing General SAT...")
    input_sizes = generate_realistic_test_sizes('NP', 'sat', [5, 6, 7, 8])
    def run_sat(formula):
        return sat_solver_bruteforce(formula)
    sat_results = run_complexity_test(run_sat, input_sizes, 'NP', 'sat', 'sat_general')
    results.extend(sat_results)
    
    # Test 3-SAT
    print("\n3. Testing 3-SAT...")
    input_sizes = generate_realistic_test_sizes('NP', '3sat', [5, 6, 7, 8])
    def run_3sat(formula):
        return solve_3sat_bruteforce(formula)
    sat3_results = run_complexity_test(run_3sat, input_sizes, 'NP', '3sat', '3sat')
    results.extend(sat3_results)
    
    # Save NP-class results
    save_results(ss_results, "complexity_tests/benchmarks/np_class/subset_sum_results.json")
    save_results(sat_results, "complexity_tests/benchmarks/np_class/sat_results.json")
    save_results(sat3_results, "complexity_tests/benchmarks/np_class/3sat_results.json")
    
    return results


def run_all_np_complete_tests():
    """Run all NP-complete complexity tests"""
    print("\n=== Running NP-Complete Tests ===")
    
    # Import NP-complete functions
    from np_complete.clique import find_clique_bruteforce
    from np_complete.vertex_cover import find_vertex_cover_bruteforce
    from np_complete.tsp_decision import tsp_decision_bruteforce
    
    results = []
    
    # Test Clique
    print("\n1. Testing Clique Problem...")
    input_sizes = generate_realistic_test_sizes('NP-complete', 'clique', [6, 8, 10, 12])
    def run_clique(data_tuple):
        graph, k = data_tuple
        return find_clique_bruteforce(graph, k)
    clique_results = run_complexity_test(run_clique, input_sizes, 'NP-complete', 'clique', 'clique')
    results.extend(clique_results)
    
    # Test Vertex Cover
    print("\n2. Testing Vertex Cover...")
    input_sizes = generate_realistic_test_sizes('NP-complete', 'vertex_cover', [6, 8, 10, 12])
    def run_vc(data_tuple):
        graph, k = data_tuple
        return find_vertex_cover_bruteforce(graph, k)
    vc_results = run_complexity_test(run_vc, input_sizes, 'NP-complete', 'vertex_cover', 'vertex_cover')
    results.extend(vc_results)
    
    # Test TSP Decision
    print("\n3. Testing TSP Decision...")
    input_sizes = generate_realistic_test_sizes('NP-complete', 'tsp_decision', [4, 5, 6, 7])
    def run_tsp(data_tuple):
        distances, threshold = data_tuple
        return tsp_decision_bruteforce(distances, threshold)
    tsp_results = run_complexity_test(run_tsp, input_sizes, 'NP-complete', 'tsp_decision', 'tsp_decision')
    results.extend(tsp_results)
    
    # Save NP-complete results
    save_results(clique_results, "complexity_tests/benchmarks/np_complete/clique_results.json")
    save_results(vc_results, "complexity_tests/benchmarks/np_complete/vertex_cover_results.json")
    save_results(tsp_results, "complexity_tests/benchmarks/np_complete/tsp_decision_results.json")
    
    return results


def run_all_np_hard_tests():
    """Run all NP-hard complexity tests"""
    print("\n=== Running NP-Hard Tests ===")
    
    # Import NP-hard functions
    from np_hard.tsp_optimization import tsp_optimal_bruteforce
    
    results = []
    
    # Test TSP Optimization
    print("\n1. Testing TSP Optimization...")
    input_sizes = generate_realistic_test_sizes('NP-hard', 'tsp_optimization', [4, 5, 6, 7])
    def run_tsp_opt(distances):
        return tsp_optimal_bruteforce(distances)
    tsp_opt_results = run_complexity_test(run_tsp_opt, input_sizes, 'NP-hard', 'tsp_optimization', 'tsp_optimization')
    results.extend(tsp_opt_results)
    
    # Save NP-hard results
    save_results(tsp_opt_results, "complexity_tests/benchmarks/np_hard/tsp_optimization_results.json")
    
    return results


def run_all_reduction_tests():
    """Run polynomial reduction tests"""
    print("\n=== Running Polynomial Reduction Tests ===")
    
    from reductions.test_reductions import (
        test_sat_to_3sat_reduction,
        test_3sat_to_clique_reduction,
        test_clique_to_vertex_cover_reduction
    )
    
    print("Running reduction tests...")
    test_sat_to_3sat_reduction()
    test_3sat_to_clique_reduction()
    test_clique_to_vertex_cover_reduction()
    
    print("Reduction tests completed!")


def analyze_all_results():
    """Analyze results from all tests"""
    print("\n=== Analyzing All Results ===")
    
    # This would normally analyze collected results
    # For now, we'll just list the result files that were created
    import glob
    
    result_files = glob.glob("complexity_tests/benchmarks/**/*.json", recursive=True)
    print(f"Generated {len(result_files)} result files:")
    for f in result_files:
        print(f"  - {f}")


def main():
    """Run all complexity tests"""
    print("Starting comprehensive P vs NP complexity experiments...\n")
    
    # Create necessary directories
    os.makedirs("complexity_tests/benchmarks/p_class", exist_ok=True)
    os.makedirs("complexity_tests/benchmarks/np_class", exist_ok=True) 
    os.makedirs("complexity_tests/benchmarks/np_complete", exist_ok=True)
    os.makedirs("complexity_tests/benchmarks/np_hard", exist_ok=True)
    os.makedirs("complexity_tests/benchmarks/reductions", exist_ok=True)
    
    all_results = []
    
    try:
        p_results = run_all_p_class_tests()
        all_results.extend(p_results)
        
        np_results = run_all_np_class_tests()
        all_results.extend(np_results)
        
        npc_results = run_all_np_complete_tests()
        all_results.extend(npc_results)
        
        nph_results = run_all_np_hard_tests()
        all_results.extend(nph_results)
        
        run_all_reduction_tests()
        
        analyze_all_results()
        
        print(f"\nCompleted all tests! Generated {len(all_results)} total results.")
        print("Results saved in complexity_tests/benchmarks/")
        
    except KeyboardInterrupt:
        print("\nTests interrupted by user.")
    except Exception as e:
        print(f"\nError during testing: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()