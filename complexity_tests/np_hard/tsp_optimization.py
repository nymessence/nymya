"""
Traveling Salesman Problem (Optimization Version) - NP-hard problem
Find the shortest possible route that visits each city exactly once and returns to the origin city.
"""
import random
from typing import List, Tuple
import itertools


def tsp_optimal_bruteforce(distances: List[List[int]]) -> Tuple[List[int], int]:
    """
    Solve TSP optimization problem using brute force approach.
    Time complexity: O(n! * n) where n is number of cities
    
    Args:
        distances: 2D matrix where distances[i][j] is the distance from city i to city j
        
    Returns:
        Tuple of (best_tour, min_cost) where best_tour is the optimal tour
        and min_cost is the minimum possible cost
    """
    n = len(distances)
    
    if n <= 1:
        return ([0] if n == 1 else [], 0)
    
    # Generate all possible permutations of cities (excluding the first city which is fixed)
    # This represents all possible tours starting and ending at city 0
    cities = list(range(1, n))
    
    min_cost = float('inf')
    best_tour = None
    
    for perm in itertools.permutations(cities):
        # Create tour starting from city 0
        tour = [0] + list(perm)
        # Calculate total cost including return to start
        total_cost = 0
        for i in range(n):
            total_cost += distances[tour[i]][tour[(i + 1) % n]]
        
        if total_cost < min_cost:
            min_cost = total_cost
            best_tour = tour
    
    return best_tour, int(min_cost)


def generate_tsp_opt_input(num_cities: int, max_distance: int = 100) -> List[List[int]]:
    """
    Generates input for TSP optimization problem.
    
    Args:
        num_cities: Number of cities in the problem
        max_distance: Maximum distance between any two cities
        
    Returns:
        Distance matrix for TSP optimization
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
    
    return distances


def verify_tsp_opt_solution(distances: List[List[int]], tour: List[int], expected_cost: int) -> bool:
    """
    Verifies if a TSP optimization solution is valid and has the claimed cost.
    
    Args:
        distances: Distance matrix
        tour: Proposed tour as a list of city indices
        expected_cost: Claimed minimum cost
        
    Returns:
        True if tour is valid and has the claimed cost, False otherwise
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
    
    # Check if calculated cost matches expected cost
    return total_cost == expected_cost


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
    
    best_tour, min_cost = tsp_optimal_bruteforce(distances_4)
    print(f"\nBest tour: {best_tour}")
    print(f"Minimum cost: {min_cost}")
    
    print(f"Verification: {verify_tsp_opt_solution(distances_4, best_tour, min_cost)}")
    
    # Test with random TSP optimization
    print("\nTesting with random TSP optimization:")
    random_distances = generate_tsp_opt_input(5, 50)
    print("Random distance matrix for 5 cities generated")
    
    random_best_tour, random_min_cost = tsp_optimal_bruteforce(random_distances)
    print(f"Random best tour: {random_best_tour}")
    print(f"Random minimum cost: {random_min_cost}")
    
    print(f"Random verification: {verify_tsp_opt_solution(random_distances, random_best_tour, random_min_cost)}")