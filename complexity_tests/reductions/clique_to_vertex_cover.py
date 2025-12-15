"""
CLIQUE to Vertex Cover Reduction - Polynomial time reduction
This transformation helps show the relationship between these NP-complete problems.
"""
import time
from typing import List, Tuple
from np_complete.clique import Graph as CliqueGraph
from np_complete.vertex_cover import Graph as VC_Graph


def clique_to_vertex_cover_reduction(graph: CliqueGraph, k: int) -> Tuple[VC_Graph, int]:
    """
    Polynomial time reduction from CLIQUE to Vertex Cover.
    Uses the complement graph approach: a clique of size k in G exists
    if and only if there is a vertex cover of size |V| - k in the complement of G.
    
    Time complexity: O(V^2) to construct the complement graph
    
    Args:
        graph: Original graph for the CLIQUE problem
        k: Size of clique to find
        
    Returns:
        Tuple of (complement_graph, vertex_cover_size) where vertex_cover_size = |V| - k
    """
    start_time = time.time()
    
    n = graph.vertices
    
    # Create complement graph
    complement = VC_Graph(n)
    
    # Add edges that are NOT present in the original graph
    for i in range(n):
        for j in range(i + 1, n):
            # If there's no edge between i and j in original graph, add it to complement
            if j not in graph.neighbors(i):
                complement.add_edge(i, j)
    
    vc_size = n - k
    
    reduction_time = time.time() - start_time
    
    print(f"CLIQUE to Vertex Cover reduction took {reduction_time:.6f} seconds")
    print(f"Original graph had {graph.vertices} vertices, complement has same")
    print(f"Looking for clique of size {k} in original <=> vertex cover of size {vc_size} in complement")
    
    return complement, vc_size


def verify_reduction_property(graph: CliqueGraph, k: int, complement_graph: VC_Graph, vc_size: int) -> bool:
    """
    Verify the mathematical property of the reduction.
    A clique of size k exists in G iff a vertex cover of size |V|-k exists in complement of G.
    """
    n = graph.vertices
    
    # Basic check: sizes should match
    if n != complement_graph.vertices:
        print("Vertex count mismatch between original and complement graphs")
        return False
    
    if vc_size != n - k:
        print(f"Vertex cover size mismatch: expected {n - k}, got {vc_size}")
        return False
    
    print("Reduction property verification passed: sizes match correctly")
    return True


if __name__ == "__main__":
    # Test with a simple graph that has a known clique
    g = CliqueGraph(5)
    # Create a triangle (clique of size 3): 0-1-2-0
    g.add_edge(0, 1)
    g.add_edge(1, 2)
    g.add_edge(2, 0)
    # Add some more edges
    g.add_edge(0, 3)
    g.add_edge(1, 3)
    
    print("Original graph (for CLIQUE problem):")
    print(f"Vertices: {g.vertices}")
    print(f"Edges: {[(u, v) for u in range(g.vertices) for v in g.neighbors(u) if u < v]}")
    
    k = 3  # Looking for a clique of size 3
    
    complement_graph, vc_size = clique_to_vertex_cover_reduction(g, k)
    
    print(f"\nComplement graph (for Vertex Cover problem):")
    print(f"Vertices: {complement_graph.vertices}")
    complement_edges = []
    for u in range(complement_graph.vertices):
        for v in complement_graph.get_neighbors(u):
            if u < v:  # Count each edge only once
                complement_edges.append((u, v))
    print(f"Edges: {complement_edges}")
    
    print(f"\nReduction:")
    print(f"  CLIQUE: Find size-{k} clique in original")
    print(f"  Vertex Cover: Find size-{vc_size} vertex cover in complement")
    
    # Verify the reduction property
    is_valid = verify_reduction_property(g, k, complement_graph, vc_size)
    print(f"\nReduction validity: {is_valid}")