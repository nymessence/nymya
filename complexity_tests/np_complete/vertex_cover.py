"""
Vertex Cover Problem - NP-complete problem
Find a subset of vertices that covers all edges in an undirected graph.
"""
import random
from typing import List, Set, Tuple, Optional


class Graph:
    """Simple graph representation"""
    def __init__(self, vertices: int):
        self.vertices = vertices
        self.edges = set()  # Set of (u, v) tuples where u < v
    
    def add_edge(self, u: int, v: int):
        """Add an undirected edge between vertices u and v"""
        if u != v:  # No self-loops
            edge = (min(u, v), max(u, v))  # Normalize edge representation
            self.edges.add(edge)
    
    def get_edges(self) -> Set[Tuple[int, int]]:
        """Get all edges in the graph"""
        return self.edges
    
    def get_neighbors(self, vertex: int) -> List[int]:
        """Get neighbors of a vertex"""
        neighbors = []
        for u, v in self.edges:
            if u == vertex:
                neighbors.append(v)
            elif v == vertex:
                neighbors.append(u)
        return neighbors


def find_vertex_cover_bruteforce(graph: Graph, k: int) -> Optional[List[int]]:
    """
    Find a vertex cover of size k using brute force approach.
    Time complexity: O(2^V * E) where V is number of vertices and E is number of edges
    
    Args:
        graph: Input graph  
        k: Maximum size of vertex cover to find
        
    Returns:
        A vertex cover of size at most k as a list of vertices, or None if not found
    """
    n = graph.vertices
    
    if k > n:
        k = n  # Adjust k to be at most n
    
    # Generate all subsets of vertices of size up to k
    def generate_subsets(start: int, current_subset: List[int], remaining_size: int):
        if remaining_size == 0:
            yield current_subset[:]
            return
        if start >= n:
            return
        
        # Try adding vertex start to the subset
        current_subset.append(start)
        yield from generate_subsets(start + 1, current_subset, remaining_size - 1)
        current_subset.pop()
        
        # Try not adding vertex start to the subset
        yield from generate_subsets(start + 1, current_subset, remaining_size)
    
    # Check if each subset is a valid vertex cover
    for subset in generate_subsets(0, [], k):
        # Check if this subset covers all edges
        covered_edges = set()
        for vertex in subset:
            for neighbor in graph.get_neighbors(vertex):
                edge = (min(vertex, neighbor), max(vertex, neighbor))
                covered_edges.add(edge)
        
        if covered_edges == graph.edges:
            return subset  # Found a valid vertex cover
    
    return None  # No vertex cover of size k or less found


def generate_vertex_cover_input(vertices: int, edge_probability: float = 0.3) -> Tuple[Graph, int]:
    """
    Generates input for vertex cover problem.
    
    Args:
        vertices: Number of vertices in the graph
        edge_probability: Probability of edge existence between any two vertices
        
    Returns:
        Tuple of (graph, k_size_for_vertex_cover_search)
    """
    graph = Graph(vertices)
    
    # Randomly add edges based on probability
    for i in range(vertices):
        for j in range(i + 1, vertices):
            if random.random() < edge_probability:
                graph.add_edge(i, j)
    
    # Choose k as approximately half the number of vertices
    # This gives a challenging but potentially solvable problem
    k = min(vertices // 2, 6)  # Cap k to make problem solvable in reasonable time
    
    return graph, k


def verify_vertex_cover(graph: Graph, cover: List[int]) -> bool:
    """
    Verifies if a given set of vertices forms a vertex cover.
    
    Args:
        graph: Input graph
        cover: List of vertices to verify
        
    Returns:
        True if vertices form a vertex cover, False otherwise
    """
    cover_set = set(cover)
    
    # Check if all vertices in the cover actually exist in the graph
    for v in cover_set:
        if v >= graph.vertices:
            return False
    
    # Check if every edge has at least one endpoint in the cover
    for u, v in graph.edges:
        if u not in cover_set and v not in cover_set:
            return False
    
    return True


if __name__ == "__main__":
    # Test with a simple graph
    g = Graph(5)
    # Create a star-like structure centered at vertex 0
    g.add_edge(0, 1)
    g.add_edge(0, 2)
    g.add_edge(0, 3)
    g.add_edge(3, 4)
    
    print(f"Graph has {g.vertices} vertices and {len(g.edges)} edges")
    print("Edges:", list(g.edges))
    
    # Look for a vertex cover of size 2
    k = 2
    cover = find_vertex_cover_bruteforce(g, k)
    print(f"Vertex cover of size at most {k}: {cover}")
    
    if cover:
        print(f"Verification: {verify_vertex_cover(g, cover)}")
    
    # Test with random graph
    print("\nTesting with random graph:")
    random_graph, random_k = generate_vertex_cover_input(6, 0.4)
    print(f"Random graph has {random_graph.vertices} vertices and {len(random_graph.edges)} edges")
    print(f"Looking for vertex cover of size at most {random_k}")
    
    random_cover = find_vertex_cover_bruteforce(random_graph, random_k)
    print(f"Random vertex cover: {random_cover}")
    
    if random_cover:
        print(f"Random verification: {verify_vertex_cover(random_graph, random_cover)}")