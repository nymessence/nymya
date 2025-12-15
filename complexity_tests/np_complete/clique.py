"""
Clique Problem - NP-complete problem
Find a complete subgraph of a given size k in an undirected graph.
"""
import random
from typing import List, Set, Tuple, Optional


class Graph:
    """Simple graph representation using adjacency list"""
    def __init__(self, vertices: int):
        self.vertices = vertices
        self.adj_list = {i: set() for i in range(vertices)}
    
    def add_edge(self, u: int, v: int):
        """Add an undirected edge between vertices u and v"""
        if u != v:  # No self-loops
            self.adj_list[u].add(v)
            self.adj_list[v].add(u)
    
    def has_edge(self, u: int, v: int) -> bool:
        """Check if there's an edge between u and v"""
        return v in self.adj_list[u]
    
    def neighbors(self, vertex: int) -> Set[int]:
        """Get neighbors of a vertex"""
        return self.adj_list[vertex]
    
    def get_vertices(self) -> List[int]:
        """Get all vertices"""
        return list(self.adj_list.keys())


def find_clique_bruteforce(graph: Graph, k: int) -> Optional[List[int]]:
    """
    Find a clique of size k using brute force approach.
    Time complexity: O(V^k * k^2) where V is number of vertices
    
    Args:
        graph: Input graph
        k: Size of clique to find
        
    Returns:
        A clique of size k as a list of vertices, or None if not found
    """
    n = graph.vertices
    
    if k > n:
        return None
    
    # Generate all combinations of k vertices
    def generate_combinations(start: int, current_combo: List[int], k_remaining: int):
        if k_remaining == 0:
            yield current_combo[:]
            return
        if start >= n:
            return
        
        for i in range(start, n):
            current_combo.append(i)
            yield from generate_combinations(i + 1, current_combo, k_remaining - 1)
            current_combo.pop()
    
    # Check if each combination forms a complete subgraph (clique)
    for combo in generate_combinations(0, [], k):
        is_clique = True
        for i in range(k):
            for j in range(i + 1, k):
                if not graph.has_edge(combo[i], combo[j]):
                    is_clique = False
                    break
            if not is_clique:
                break
        
        if is_clique:
            return combo
    
    return None  # No clique of size k found


def generate_clique_input(vertices: int, edge_probability: float = 0.3) -> Tuple[Graph, int]:
    """
    Generates input for clique problem.
    
    Args:
        vertices: Number of vertices in the graph
        edge_probability: Probability of edge existence between any two vertices
        
    Returns:
        Tuple of (graph, k_size_for_clique_search)
    """
    graph = Graph(vertices)
    
    # Randomly add edges based on probability
    for i in range(vertices):
        for j in range(i + 1, vertices):
            if random.random() < edge_probability:
                graph.add_edge(i, j)
    
    # Choose k as a reasonable size that might have a solution
    # Making k slightly challenging but not impossible
    k = min(vertices // 3, 5)  # Cap k to make problem solvable in reasonable time
    
    return graph, k


def verify_clique(graph: Graph, clique: List[int]) -> bool:
    """
    Verifies if a given set of vertices forms a clique.
    
    Args:
        graph: Input graph
        clique: List of vertices to verify
        
    Returns:
        True if vertices form a clique, False otherwise
    """
    k = len(clique)
    
    # Check if all vertices in the clique actually exist in the graph
    for v in clique:
        if v >= graph.vertices:
            return False
    
    # Check if every pair of vertices in the clique has an edge between them
    for i in range(k):
        for j in range(i + 1, k):
            if not graph.has_edge(clique[i], clique[j]):
                return False
    
    return True


if __name__ == "__main__":
    # Test with a simple graph
    g = Graph(5)
    # Create a triangle (clique of size 3): 0-1-2-0
    g.add_edge(0, 1)
    g.add_edge(1, 2)
    g.add_edge(2, 0)
    # Add some more edges
    g.add_edge(0, 3)
    g.add_edge(1, 3)
    g.add_edge(2, 4)
    
    print(f"Graph has {g.vertices} vertices")
    print("Adjacency list:", dict(g.adj_list))
    
    # Look for a clique of size 3
    k = 3
    clique = find_clique_bruteforce(g, k)
    print(f"Clique of size {k}: {clique}")
    
    if clique:
        print(f"Verification: {verify_clique(g, clique)}")
    
    # Test with random graph
    print("\nTesting with random graph:")
    random_graph, random_k = generate_clique_input(8, 0.4)
    print(f"Random graph has {random_graph.vertices} vertices and looking for clique of size {random_k}")
    
    random_clique = find_clique_bruteforce(random_graph, random_k)
    print(f"Random clique: {random_clique}")
    
    if random_clique:
        print(f"Random verification: {verify_clique(random_graph, random_clique)}")