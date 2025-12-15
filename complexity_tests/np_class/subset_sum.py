"""
Subset Sum Problem - NP-complete problem
Given a set of integers, determine if there exists a non-empty subset that sums to zero (or a target value).
"""
import random
from typing import List, Optional


def subset_sum_bruteforce(nums: List[int], target: int) -> Optional[List[int]]:
    """
    Solves subset sum using brute force approach.
    Time complexity: O(2^n) - exponential
    
    Args:
        nums: List of integers
        target: Target sum
        
    Returns:
        A subset that sums to target, or None if no such subset exists
    """
    n = len(nums)
    # Iterate through all possible subsets (2^n possibilities)
    for mask in range(1, 1 << n):  # Skip empty subset by starting from 1
        subset = []
        current_sum = 0
        
        for i in range(n):
            if mask & (1 << i):  # Check if i-th bit is set
                subset.append(nums[i])
                current_sum += nums[i]
                
        if current_sum == target:
            return subset
            
    return None  # No subset found


def generate_subset_sum_input(size: int, target: int = 0) -> tuple:
    """
    Generates input for subset sum problem.
    
    Args:
        size: Number of integers in the set
        target: Target sum (default 0)
        
    Returns:
        Tuple of (list_of_integers, target_sum)
    """
    # Generate random numbers in a range that allows possibility of reaching target
    nums = [random.randint(-size, size) for _ in range(size)]
    return nums, target


def verify_subset_sum_solution(nums: List[int], target: int, subset: List[int]) -> bool:
    """
    Verifies if a subset sums to the target.
    
    Args:
        nums: Original list of numbers
        target: Target sum
        subset: Proposed solution subset
        
    Returns:
        True if subset is valid, False otherwise
    """
    # Check if subset elements are from original set
    for num in subset:
        if num not in nums:
            return False
    
    # Check if sum equals target
    return sum(subset) == target


if __name__ == "__main__":
    # Basic test
    test_nums, test_target = generate_subset_sum_input(10)
    print(f"Numbers: {test_nums}")
    print(f"Target: {test_target}")
    
    solution = subset_sum_bruteforce(test_nums, test_target)
    print(f"Solution: {solution}")
    
    if solution:
        print(f"Verification: {verify_subset_sum_solution(test_nums, test_target, solution)}")
        print(f"Sum: {sum(solution)}")
    else:
        print("No solution found")