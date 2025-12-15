"""
Test runner for P-class problems
"""
from utils.measurement import run_complexity_test, save_results, plot_complexity, estimate_complexity_growths
from p_class.linear_search import linear_search, generate_linear_search_input
from p_class.binary_search import binary_search, generate_binary_search_input
from p_class.merge_sort import merge_sort, generate_merge_sort_input


def test_linear_search():
    """Test linear search complexity"""
    print("Testing Linear Search...")
    input_sizes = [100, 500, 1000, 2000, 5000]
    
    def run_search(data_tuple):
        arr, target = data_tuple
        return linear_search(arr, target)
    
    def input_gen(size):
        return generate_linear_search_input(size)
    
    results = run_complexity_test(run_search, input_sizes, input_gen, "P", "linear_search")
    growth_rates = estimate_complexity_growths(results)
    print(f"Growth rates for linear search: {growth_rates}")
    save_results(results, "complexity_tests/benchmarks/linear_search_results.json")
    return results


def test_binary_search():
    """Test binary search complexity"""
    print("\nTesting Binary Search...")
    input_sizes = [100, 500, 1000, 2000, 5000, 10000]
    
    def run_search(data_tuple):
        arr, target = data_tuple
        return binary_search(arr, target)
    
    def input_gen(size):
        return generate_binary_search_input(size)
    
    results = run_complexity_test(run_search, input_sizes, input_gen, "P", "binary_search")
    growth_rates = estimate_complexity_growths(results)
    print(f"Growth rates for binary search: {growth_rates}")
    save_results(results, "complexity_tests/benchmarks/binary_search_results.json")
    return results


def test_merge_sort():
    """Test merge sort complexity"""
    print("\nTesting Merge Sort...")
    input_sizes = [100, 500, 1000, 2000]
    
    def run_sort(arr):
        return merge_sort(arr)
    
    def input_gen(size):
        return generate_merge_sort_input(size)
    
    results = run_complexity_test(run_sort, input_sizes, input_gen, "P", "merge_sort")
    growth_rates = estimate_complexity_growths(results)
    print(f"Growth rates for merge sort: {growth_rates}")
    save_results(results, "complexity_tests/benchmarks/merge_sort_results.json")
    return results


if __name__ == "__main__":
    print("Running P-class complexity tests...\n")
    
    linear_results = test_linear_search()
    binary_results = test_binary_search()
    merge_results = test_merge_sort()
    
    print("\nP-class tests completed!")
    print("Results saved to complexity_tests/benchmarks/")