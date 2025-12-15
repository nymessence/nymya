"""
Binary Search - O(log n) time complexity
A P-class problem
"""
import random
from typing import List


def binary_search(arr: List[int], target: int) -> int:
    """
    Performs binary search on a sorted array to find the index of target.
    
    Args:
        arr: Sorted list of integers to search in
        target: Integer value to search for
        
    Returns:
        Index of target in array, or -1 if not found
    """
    left, right = 0, len(arr) - 1
    
    while left <= right:
        mid = (left + right) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return -1


def generate_binary_search_input(size: int) -> tuple:
    """
    Generates input for binary search test.
    Creates a sorted array and a target value.
    
    Args:
        size: Size of the array to generate
        
    Returns:
        Tuple of (sorted_array, target_value)
    """
    # Generate random array
    arr = [random.randint(1, size * 2) for _ in range(size)]
    # Sort the array
    arr.sort()
    # Pick a random element as target (so we know it exists)
    target = random.choice(arr) if arr else 0
    return arr, target


if __name__ == "__main__":
    # Basic test
    test_arr, test_target = generate_binary_search_input(10)
    print(f"Sorted Array: {test_arr}")
    print(f"Target: {test_target}")
    result = binary_search(test_arr, test_target)
    print(f"Result: {result}")
    if result != -1:
        print(f"Verified: {test_arr[result] == test_target}")