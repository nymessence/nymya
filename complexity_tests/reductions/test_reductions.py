"""
Test runner for polynomial reductions
"""
from utils.measurement import measure_time_and_space
from reductions.sat_to_3sat import sat_to_3sat_reduction
from reductions.ksat_to_clique import three_sat_to_clique_reduction
from reductions.clique_to_vertex_cover import clique_to_vertex_cover_reduction
from np_class.sat import generate_sat_input
from np_class.ksat import generate_3sat_input
from np_complete.clique import generate_clique_input


def test_sat_to_3sat_reduction():
    """Test SAT to 3-SAT reduction"""
    print("Testing SAT to 3-SAT Reduction...")
    
    # Create a small SAT problem
    sat_formula = generate_sat_input(4, 3, clause_size=2)  # Small problem to keep test fast
    
    print(f"Original SAT formula: {len(sat_formula.clauses)} clauses, {len(sat_formula.get_variables())} variables")
    
    exec_time, memory_used, result = measure_time_and_space(sat_to_3sat_reduction, sat_formula)
    
    if result:
        reduced_formula = result
        print(f"Reduced to 3-SAT: {len(reduced_formula.clauses)} clauses, {len(reduced_formula.get_variables())} variables")
        print(f"Reduction time: {exec_time:.6f}s, memory: {memory_used} bytes")
        
        # Log the transformation
        print(f"[reduction] SAT to 3-SAT transformation:")
        print(f"  - input clauses: {len(sat_formula.clauses)} -> {len(reduced_formula.clauses)}")
        print(f"  - input vars: {len(sat_formula.get_variables())} -> {len(reduced_formula.get_variables())}")
        print(f"  - time: {exec_time:.6f}s")
    
    return exec_time, memory_used


def test_3sat_to_clique_reduction():
    """Test 3-SAT to CLIQUE reduction"""
    print("\nTesting 3-SAT to CLIQUE Reduction...")
    
    # Create a small 3-SAT problem
    sat_formula = generate_3sat_input(4, 3)  # 4 variables, 3 clauses
    
    print(f"Original 3-SAT formula: {len(sat_formula.clauses)} clauses, {len(sat_formula.get_variables())} variables")
    
    exec_time, memory_used, result = measure_time_and_space(three_sat_to_clique_reduction, sat_formula)
    
    if result:
        graph, k = result
        print(f"Reduced to CLIQUE: graph with {graph.vertices} vertices, looking for {k}-clique")
        print(f"Reduction time: {exec_time:.6f}s, memory: {memory_used} bytes")
        
        # Log the transformation
        print(f"[reduction] 3-SAT to CLIQUE transformation:")
        print(f"  - 3-SAT clauses: {len(sat_formula.clauses)}")
        print(f"  - graph vertices: {graph.vertices}")
        print(f"  - clique size k: {k}")
        print(f"  - time: {exec_time:.6f}s")
    
    return exec_time, memory_used


def test_clique_to_vertex_cover_reduction():
    """Test CLIQUE to Vertex Cover reduction"""
    print("\nTesting CLIQUE to Vertex Cover Reduction...")
    
    # Create a small graph for CLIQUE problem
    graph, k = generate_clique_input(6, edge_probability=0.4)
    
    print(f"Original CLIQUE problem: graph with {graph.vertices} vertices, looking for {k}-clique")
    
    exec_time, memory_used, result = measure_time_and_space(clique_to_vertex_cover_reduction, graph, k)
    
    if result:
        complement_graph, vc_size = result
        print(f"Reduced to Vertex Cover: complement graph with {complement_graph.vertices} vertices, looking for {vc_size}-vertex cover")
        print(f"Reduction time: {exec_time:.6f}s, memory: {memory_used} bytes")
        
        # Log the transformation
        print(f"[reduction] CLIQUE to Vertex Cover transformation:")
        print(f"  - original vertices: {graph.vertices}")
        print(f"  - original k: {k}")
        print(f"  - complement vertices: {complement_graph.vertices}")
        print(f"  - VC size: {vc_size}")
        print(f"  - time: {exec_time:.6f}s")
    
    return exec_time, memory_used


if __name__ == "__main__":
    print("Running polynomial reduction tests...\n")
    
    sat_3sat_time, sat_3sat_mem = test_sat_to_3sat_reduction()
    ksat_clique_time, ksat_clique_mem = test_3sat_to_clique_reduction()
    clique_vc_time, clique_vc_mem = test_clique_to_vertex_cover_reduction()
    
    print(f"\nReduction tests completed!")
    print(f"Total time for reductions: {sat_3sat_time + ksat_clique_time + clique_vc_time:.6f}s")