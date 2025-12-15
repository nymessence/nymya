"""
Complexity measurement utilities for algorithm benchmarking.
"""
import time
import psutil
import os
import json
from typing import Callable, Any, Dict, List, Tuple
import matplotlib.pyplot as plt
import numpy as np
from .input_generators import generate_scalable_input, get_realistic_input_size


def measure_time_and_space(func: Callable, *args, **kwargs) -> Tuple[float, int, Any]:
    """
    Measures execution time and memory usage of a function.

    Args:
        func: Function to measure
        *args: Arguments to pass to function
        **kwargs: Keyword arguments to pass to function

    Returns:
        Tuple of (execution_time_seconds, memory_used_bytes, function_return_value)
    """
    # Get initial memory
    process = psutil.Process(os.getpid())
    initial_memory = process.memory_info().rss

    # Measure execution time
    start_time = time.perf_counter()
    result = func(*args, **kwargs)
    end_time = time.perf_counter()

    # Calculate memory usage
    final_memory = process.memory_info().rss
    memory_used = final_memory - initial_memory

    execution_time = end_time - start_time

    return execution_time, memory_used, result


def run_complexity_test(func: Callable, input_sizes: List[int], problem_class: str,
                       problem_type: str, test_name: str) -> List[Dict[str, Any]]:
    """
    Runs a complexity test across multiple input sizes using scalable generators.

    Args:
        func: Algorithm function to test
        input_sizes: List of input sizes to test
        problem_class: P, NP, NP-complete, or NP-hard
        problem_type: Specific problem type (e.g., 'linear_search', 'subset_sum', etc.)
        test_name: Name of the test

    Returns:
        List of results for each input size
    """
    results = []

    for size in input_sizes:
        # Generate input using the scalable generator
        input_data = generate_scalable_input(size, problem_class, problem_type)

        exec_time, memory_used, result = measure_time_and_space(func, input_data)

        result_dict = {
            'input_size': size,
            'execution_time': exec_time,
            'memory_used': memory_used,
            'result': str(result) if result is not None else "None",  # Convert complex results to string
            'problem_class': problem_class,
            'problem_type': problem_type,
            'test_name': test_name
        }

        results.append(result_dict)

        print(f"{test_name}: Size {size}, Time: {exec_time:.6f}s, Memory: {memory_used} bytes")

    return results


def run_complexity_test_with_custom_generator(func: Callable, input_sizes: List[int], input_generator: Callable,
                       problem_class: str, test_name: str) -> List[Dict[str, Any]]:
    """
    Runs a complexity test across multiple input sizes with a custom input generator.

    Args:
        func: Algorithm function to test
        input_sizes: List of input sizes to test
        input_generator: Function that generates input for given size
        problem_class: P, NP, NP-complete, or NP-hard
        test_name: Name of the test

    Returns:
        List of results for each input size
    """
    results = []

    for size in input_sizes:
        input_data = input_generator(size)

        exec_time, memory_used, result = measure_time_and_space(func, input_data)

        result_dict = {
            'input_size': size,
            'execution_time': exec_time,
            'memory_used': memory_used,
            'result': str(result) if result is not None else "None",  # Convert complex results to string
            'problem_class': problem_class,
            'test_name': test_name
        }

        results.append(result_dict)

        print(f"{test_name}: Size {size}, Time: {exec_time:.6f}s, Memory: {memory_used} bytes")

    return results


def plot_complexity(results: List[Dict[str, Any]], title: str, save_path: str = None):
    """
    Plots the complexity results.

    Args:
        results: List of result dictionaries
        title: Title for the plot
        save_path: Optional path to save the plot
    """
    if not results:
        print("No results to plot")
        return

    sizes = [r['input_size'] for r in results]
    times = [r['execution_time'] for r in results]

    plt.figure(figsize=(10, 6))
    plt.plot(sizes, times, marker='o', label='Actual')

    # Add theoretical complexity curves for comparison
    if sizes and times:
        n = np.array(sizes)
        t = np.array(times)
        if len(n) > 0 and n[0] > 0 and t[0] > 0:
            # Scale the theoretical curves to match the first data point
            scale_factor = t[0]

            # For different complexity classes
            if max(n) > 0:
                x = np.linspace(min(n), max(n), 100)

                # Linear: O(n)
                try:
                    linear_y = scale_factor * (x / n[0])
                    plt.plot(x, linear_y, '--', label='O(n) - Linear', alpha=0.7)
                except:
                    pass

                # Quadratic: O(n^2)
                try:
                    quad_y = scale_factor * (x**2 / n[0]**2)
                    plt.plot(x, quad_y, '--', label='O(n²) - Quadratic', alpha=0.7)
                except:
                    pass

                # Cubic: O(n^3)
                try:
                    cubic_y = scale_factor * (x**3 / n[0]**3)
                    plt.plot(x, cubic_y, '--', label='O(n³) - Cubic', alpha=0.7)
                except:
                    pass

                # Exponential: O(2^n) - only if range is reasonable
                if max(n) <= 20:  # Don't plot exponential for large n
                    try:
                        exp_y = scale_factor * (2.0**(x - n[0]))
                        plt.plot(x, exp_y, '--', label='O(2ⁿ) - Exponential', alpha=0.7)
                    except:
                        pass

    plt.title(title)
    plt.xlabel('Input Size')
    plt.ylabel('Execution Time (seconds)')
    plt.legend()
    plt.grid(True, alpha=0.3)

    if save_path:
        plt.savefig(save_path)
        print(f"Plot saved to {save_path}")

    plt.show()


def save_results(results: List[Dict[str, Any]], filename: str):
    """
    Saves results to JSON file.
    """
    # Make sure the directory exists
    import os
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    with open(filename, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"Results saved to {filename}")


def estimate_complexity_growths(results: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Estimates complexity growth rates from results and provides more detailed analysis.

    Args:
        results: List of result dictionaries

    Returns:
        Dictionary with growth rate estimates and complexity classification
    """
    if len(results) < 2:
        return {}

    # Calculate ratios for different complexity classes
    sizes = [r['input_size'] for r in results]
    times = [r['execution_time'] for r in results]

    if len(sizes) < 2 or sizes[-1] <= sizes[0]:
        return {}

    growth_rates = {}

    # Compute polynomial fits to estimate complexity class
    try:
        # Fit to different complexity classes
        log_n = np.log(np.array(sizes)[sizes[0] > 0]) if sizes[0] > 0 else []
        log_times = np.log(np.array(times)[np.array(times) > 0]) if times[0] > 0 else []

        # Only do polynomial fits when we have valid data
        if len(log_n) > 1 and len(log_times) > 1 and len(log_n) == len(log_times):
            # Linear fit for log(t) vs log(n) to get power: t ~ n^k => log(t) = log(c) + k*log(n)
            log_times_valid = log_times
            log_n_valid = log_n
            slope, intercept = np.polyfit(log_n_valid, log_times_valid, 1)
            growth_rates['polynomial_fit_exponent'] = float(slope)

            # Classify based on the exponent
            if 0.5 <= slope <= 1.5:
                growth_rates['estimated_class'] = 'linear or log-linear'
            elif 1.5 < slope <= 2.5:
                growth_rates['estimated_class'] = 'quadratic'
            elif 2.5 < slope <= 3.5:
                growth_rates['estimated_class'] = 'cubic'
            elif slope > 3.5:
                growth_rates['estimated_class'] = 'polynomial (high degree) or exponential'
            else:
                growth_rates['estimated_class'] = 'sublinear'
    except:
        print("Could not compute polynomial fit for growth rate")

    # Check for specific growth patterns
    if sizes[-1] > sizes[0] and times[-1] > 0 and times[0] > 0:
        # Linear growth: O(n)
        linear_ratio = (times[-1] / times[0]) / (sizes[-1] / sizes[0])
        growth_rates['linear_growth_ratio'] = linear_ratio

        # Quadratic growth: O(n^2)
        if sizes[0] > 0:
            quad_ratio = (times[-1] / times[0]) / ((sizes[-1]**2) / (sizes[0]**2))
            growth_rates['quadratic_growth_ratio'] = quad_ratio

        # Cubic growth: O(n^3)
        if sizes[0] > 0:
            cubic_ratio = (times[-1] / times[0]) / ((sizes[-1]**3) / (sizes[0]**3))
            growth_rates['cubic_growth_ratio'] = cubic_ratio

    # Check for exponential growth: O(c^n)
    if len(results) >= 2:
        ratios = []
        for i in range(1, len(results)):
            if sizes[i] > sizes[i-1] and times[i-1] > 0 and times[i] > 0:
                # For exponential: f(n) = c^n, so f(n2)/f(n1) = c^(n2-n1)
                # So c = (f(n2)/f(n1))^(1/(n2-n1))
                ratio = times[i] / times[i-1]
                size_diff = sizes[i] - sizes[i-1]
                if size_diff > 0:
                    base = ratio ** (1.0 / size_diff)
                    ratios.append(base)

        if ratios:
            avg_base = sum(ratios) / len(ratios)
            growth_rates['exponential_base_avg'] = avg_base
            if avg_base > 1.5:
                growth_rates['growth_pattern'] = 'exponential-like'

    # Check for factorial growth: O(n!)
    if len(results) >= 2:
        factorial_ratios = []
        for i in range(1, len(results)):
            if sizes[i] > sizes[i-1] and sizes[i-1] > 0 and times[i-1] > 0 and times[i] > 0:
                # For factorial: f(n) = n!, so f(n2)/f(n1) = (n! for n2) / (n! for n1)
                # This gets very large very quickly
                ratio = times[i] / times[i-1]
                expected_factorial_growth = 1
                for n in range(sizes[i-1] + 1, sizes[i] + 1):
                    expected_factorial_growth *= n
                if sizes[i-1] > 0:
                    expected_factorial_growth /= sizes[i-1]  # Normalize
                if expected_factorial_growth > 0:
                    factorial_ratio = ratio / expected_factorial_growth
                    factorial_ratios.append(factorial_ratio)

        if factorial_ratios:
            growth_rates['factorial_growth_pattern'] = sum(factorial_ratios) / len(factorial_ratios)

    return growth_rates


def generate_realistic_test_sizes(problem_class: str, problem_type: str, base_sizes: List[int] = None) -> List[int]:
    """
    Generate realistic input sizes based on problem class and type.

    Args:
        problem_class: P, NP, NP-complete, or NP-hard
        problem_type: Specific problem type
        base_sizes: Base sizes to scale from (if None, defaults will be used)

    Returns:
        Scaled list of realistic input sizes
    """
    if base_sizes is None:
        base_sizes = [5, 10, 15, 20]

    realistic_sizes = []
    for base_size in base_sizes:
        realistic_size = get_realistic_input_size(problem_class, problem_type, base_size)
        realistic_sizes.append(realistic_size)

    # Remove duplicates and sort
    realistic_sizes = sorted(list(set(realistic_sizes)))
    return realistic_sizes