"""
Traveling Salesman Problem (Decision Version) - NP-complete problem
Given a graph and a distance threshold, determine if there exists a Hamiltonian cycle with total cost ≤ threshold.
"""
import random
from typing import List, Tuple, Optional
import itertools


def tsp_decision_bruteforce(distances: List[List[int]], threshold: int) -> Optional[List[int]]:
    """
    Solve TSP decision problem using brute force approach.
    Time complexity: O(n! * n) where n is number of cities
    
    Args:
        distances: 2D matrix where distances[i][j] is the distance from city i to city j
        threshold: Maximum allowed total distance
        
    Returns:
        A tour (list of city indices) with cost ≤ threshold, or None if not found
    """
    n = len(distances)
    
    if n <= 1:
        return [] if n == 0 else [0]
    
    # Generate all possible permutations of cities (excluding the first city which is fixed)
    # This represents all possible tours starting and ending at city 0
    cities = list(range(1, n))
    
    for perm in itertools.permutations(cities):
        # Create tour starting from city 0
        tour = [0] + list(perm)
        # Calculate total cost including return to start
        total_cost = 0
        for i in range(n):
            total_cost += distances[tour[i]][tour[(i + 1) % n]]
        
        if total_cost <= threshold:
            return tour
    
    return None  # No tour found within threshold


def generate_tsp_input(num_cities: int, max_distance: int = 100) -> Tuple[List[List[int]], int]:
    """
    Generates input for TSP decision problem.
    
    Args:
        num_cities: Number of cities in the problem
        max_distance: Maximum distance between any two cities
        
    Returns:
        Tuple of (distance_matrix, threshold_for_decision_problem)
    """
    # Generate random symmetric distance matrix
    distances = [[0] * num_cities for _ in range(num_cities)]
    
    for i in range(num_cities):
        for j in range(i + 1, num_cities):
            dist = random.randint(1, max_distance)
            distances[i][j] = dist
            distances[j][i] = dist  # Symmetric distances
    
    # Set diagonal to 0 (distance from city to itself)
    for i in range(num_cities):
        distances[i][i] = 0
    
    # Calculate an appropriate threshold based on the size of the problem
    # Using a threshold that's roughly halfway between optimistic and pessimistic estimates
    avg_dist = sum(sum(row) for row in distances) / (num_cities * num_cities) if num_cities > 0 else 0
    threshold = int(avg_dist * num_cities * 0.6)  # Adjust threshold to make problem neither too easy nor too hard
    
    return distances, threshold


def verify_tsp_solution(distances: List[List[int]], tour: List[int], threshold: int) -> bool:
    """
    Verifies if a TSP tour is valid and meets the threshold constraint.
    
    Args:
        distances: Distance matrix
        tour: Proposed tour as a list of city indices
        threshold: Maximum allowed total distance
        
    Returns:
        True if tour is valid and cost ≤ threshold, False otherwise
    """
    n = len(distances)
    
    if len(tour) != n:
        return False
    
    # Check if tour visits all cities exactly once
    if set(tour) != set(range(n)):
        return False
    
    # Calculate total cost
    total_cost = 0
    for i in range(n):
        from_city = tour[i]
        to_city = tour[(i + 1) % n]  # Return to start city
        total_cost += distances[from_city][to_city]
    
    # Check if total cost is within threshold
    return total_cost <= threshold


if __name__ == "__main__":
    # Test with a simple 4-city example
    distances_4 = [
        [0, 10, 15, 20],
        [10, 0, 35, 25], 
        [15, 35, 0, 30],
        [20, 25, 30, 0]
    ]
    
    print("4-city distance matrix:")
    for row in distances_4:
        print(row)
    
    threshold = 100  # Set a reasonable threshold
    print(f"\nLooking for tour with cost ≤ {threshold}")
    
    tour = tsp_decision_bruteforce(distances_4, threshold)
    print(f"Found tour: {tour}")
    
    if tour:
        print(f"Verification: {verify_tsp_solution(distances_4, tour, threshold)}")
        
        # Calculate actual cost
        cost = 0
        n = len(tour)
        for i in range(n):
            from_city = tour[i]
            to_city = tour[(i + 1) % n]
            cost += distances_4[from_city][to_city]
        print(f"Actual tour cost: {cost}")
    
    # Test with random TSP
    print("\nTesting with random TSP:")
    random_distances, random_threshold = generate_tsp_input(5, 50)
    print(f"Random distance matrix for 5 cities")
    print(f"Threshold: {random_threshold}")
    
    random_tour = tsp_decision_bruteforce(random_distances, random_threshold)
    print(f"Random tour: {random_tour}")
    
    if random_tour:
        print(f"Random verification: {verify_tsp_solution(random_distances, random_tour, random_threshold)}")