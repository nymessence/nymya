"""
Linear Search - O(n) time complexity
A P-class problem
"""
import random
from typing import List


def linear_search(arr: List[int], target: int) -> int:
    """
    Performs linear search on an array to find the index of target.
    
    Args:
        arr: List of integers to search in
        target: Integer value to search for
        
    Returns:
        Index of target in array, or -1 if not found
    """
    for i in range(len(arr)):
        if arr[i] == target:
            return i
    return -1


def generate_linear_search_input(size: int) -> tuple:
    """
    Generates input for linear search test.
    Creates a sorted array and a target value.
    
    Args:
        size: Size of the array to generate
        
    Returns:
        Tuple of (array, target_value)
    """
    # Generate random array
    arr = [random.randint(1, size * 2) for _ in range(size)]
    # Pick a random element as target (so we know it exists)
    target = random.choice(arr) if arr else 0
    return arr, target


if __name__ == "__main__":
    # Basic test
    test_arr, test_target = generate_linear_search_input(10)
    print(f"Array: {test_arr}")
    print(f"Target: {test_target}")
    result = linear_search(test_arr, test_target)
    print(f"Result: {result}")
    if result != -1:
        print(f"Verified: {test_arr[result] == test_target}")