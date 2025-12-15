"""
Merge Sort - O(n log n) time complexity
A P-class problem
"""
import random
from typing import List


def merge_sort(arr: List[int]) -> List[int]:
    """
    Performs merge sort on an array.
    
    Args:
        arr: List of integers to sort
        
    Returns:
        Sorted list of integers
    """
    if len(arr) <= 1:
        return arr
    
    mid = len(arr) // 2
    left = merge_sort(arr[:mid])
    right = merge_sort(arr[mid:])
    
    # Merge the sorted halves
    result = []
    i = j = 0
    
    while i < len(left) and j < len(right):
        if left[i] <= right[j]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1
    
    # Add remaining elements
    result.extend(left[i:])
    result.extend(right[j:])
    
    return result


def generate_merge_sort_input(size: int) -> List[int]:
    """
    Generates input for merge sort test.
    
    Args:
        size: Size of the array to generate
        
    Returns:
        Unsorted list of integers
    """
    return [random.randint(1, size * 2) for _ in range(size)]


if __name__ == "__main__":
    # Basic test
    test_arr = generate_merge_sort_input(10)
    print(f"Original Array: {test_arr}")
    sorted_arr = merge_sort(test_arr)
    print(f"Sorted Array: {sorted_arr}")
    print(f"Correctly sorted: {sorted_arr == sorted(test_arr)}")