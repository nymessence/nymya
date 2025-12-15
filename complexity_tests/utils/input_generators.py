"""
Scalable input generators for all problem classes
"""
import random
from typing import List, Tuple, Dict, Any
import numpy as np


def generate_p_class_inputs(input_size: int, problem_type: str) -> Any:
    """
    Generate scalable inputs for P-class problems.
    
    Args:
        input_size: Size parameter for the input
        problem_type: Type of P-class problem ('linear_search', 'binary_search', 'merge_sort')
        
    Returns:
        Appropriately structured input for the specified problem
    """
    if problem_type == 'linear_search':
        # Generate array and target
        arr = [random.randint(1, input_size * 2) for _ in range(input_size)]
        target = random.choice(arr) if arr else 0
        return arr, target
        
    elif problem_type == 'binary_search':
        # Generate sorted array and target
        arr = [random.randint(1, input_size * 2) for _ in range(input_size)]
        arr.sort()
        target = random.choice(arr) if arr else 0
        return arr, target
        
    elif problem_type == 'merge_sort':
        # Generate unsorted array
        return [random.randint(1, input_size * 2) for _ in range(input_size)]
        
    else:
        raise ValueError(f"Unknown P-class problem type: {problem_type}")


def generate_np_class_inputs(input_size: int, problem_type: str) -> Any:
    """
    Generate scalable inputs for NP-class problems.
    
    Args:
        input_size: Size parameter for the input
        problem_type: Type of NP-class problem ('subset_sum', 'sat', '3sat')
        
    Returns:
        Appropriately structured input for the specified problem
    """
    if problem_type == 'subset_sum':
        # Generate set of numbers and target
        nums = [random.randint(-input_size, input_size) for _ in range(input_size)]
        target = 0  # Common target
        return nums, target
        
    elif problem_type == 'sat':
        # For SAT, input_size represents number of variables
        # Generate formula with input_size variables and input_size clauses
        from np_class.sat import generate_sat_input
        return generate_sat_input(input_size, input_size, clause_size=3)
        
    elif problem_type == '3sat':
        # Similar to SAT but specifically for 3-SAT
        from np_class.ksat import generate_3sat_input
        return generate_3sat_input(input_size, input_size)
        
    else:
        raise ValueError(f"Unknown NP-class problem type: {problem_type}")


def generate_np_complete_inputs(input_size: int, problem_type: str) -> Any:
    """
    Generate scalable inputs for NP-complete problems.
    
    Args:
        input_size: Size parameter for the input
        problem_type: Type of NP-complete problem ('clique', 'vertex_cover', 'tsp_decision')
        
    Returns:
        Appropriately structured input for the specified problem
    """
    if problem_type == 'clique':
        # input_size represents number of vertices
        from np_complete.clique import generate_clique_input
        return generate_clique_input(input_size, edge_probability=min(0.4, 2.0/input_size if input_size > 0 else 0.4))
        
    elif problem_type == 'vertex_cover':
        # input_size represents number of vertices
        from np_complete.vertex_cover import generate_vertex_cover_input
        return generate_vertex_cover_input(input_size, edge_probability=min(0.4, 2.0/input_size if input_size > 0 else 0.4))
        
    elif problem_type == 'tsp_decision':
        # input_size represents number of cities
        from np_complete.tsp_decision import generate_tsp_input
        return generate_tsp_input(input_size, max_distance=100)
        
    else:
        raise ValueError(f"Unknown NP-complete problem type: {problem_type}")


def generate_np_hard_inputs(input_size: int, problem_type: str) -> Any:
    """
    Generate scalable inputs for NP-hard problems.
    
    Args:
        input_size: Size parameter for the input
        problem_type: Type of NP-hard problem ('tsp_optimization')
        
    Returns:
        Appropriately structured input for the specified problem
    """
    if problem_type == 'tsp_optimization':
        # input_size represents number of cities
        from np_hard.tsp_optimization import generate_tsp_opt_input
        return generate_tsp_opt_input(input_size, max_distance=100)
        
    else:
        raise ValueError(f"Unknown NP-hard problem type: {problem_type}")


def generate_scalable_input(input_size: int, problem_class: str, problem_type: str) -> Any:
    """
    Main function to generate scalable inputs for any problem class.
    
    Args:
        input_size: Size parameter for the input
        problem_class: Class of problem ('P', 'NP', 'NP-complete', 'NP-hard')
        problem_type: Specific problem type
        
    Returns:
        Appropriately structured input for the specified problem
    """
    if problem_class == 'P':
        return generate_p_class_inputs(input_size, problem_type)
    elif problem_class == 'NP':
        return generate_np_class_inputs(input_size, problem_type)
    elif problem_class == 'NP-complete':
        return generate_np_complete_inputs(input_size, problem_type)
    elif problem_class == 'NP-hard':
        return generate_np_hard_inputs(input_size, problem_type)
    else:
        raise ValueError(f"Unknown problem class: {problem_class}")


def get_realistic_input_size(problem_class: str, problem_type: str, base_size: int = 10) -> int:
    """
    Get a realistic input size for a problem considering its complexity.
    
    Args:
        problem_class: Class of problem
        problem_type: Specific problem type
        base_size: Base size to scale from
        
    Returns:
        Scaled input size appropriate for the problem's complexity
    """
    # Adjust sizes based on complexity and computational feasibility
    if problem_class in ['P']:
        # P problems can handle larger inputs efficiently
        multipliers = {
            'linear_search': 100,
            'binary_search': 100,
            'merge_sort': 10
        }
        return max(base_size, base_size * multipliers.get(problem_type, 10))
    
    elif problem_class == 'NP':
        # NP problems - moderate sizes due to exponential algorithms
        multipliers = {
            'subset_sum': 1,
            'sat': 1, 
            '3sat': 1
        }
        return min(base_size * multipliers.get(problem_type, 1), 20)  # Cap sizes
    
    elif problem_class == 'NP-complete':
        # NP-complete problems - smaller sizes due to exponential algorithms
        multipliers = {
            'clique': 1,
            'vertex_cover': 1,
            'tsp_decision': 1
        }
        return min(base_size * multipliers.get(problem_type, 1), 10)  # Even smaller sizes
    
    elif problem_class == 'NP-hard':
        # NP-hard problems - very small sizes due to factorial/exponential algorithms
        multipliers = {
            'tsp_optimization': 1
        }
        return min(base_size * multipliers.get(problem_type, 1), 8)  # Very small
    
    return base_size


# Test the scalable generators
if __name__ == "__main__":
    print("Testing scalable input generators...\n")
    
    # Test P-class
    print("P-class inputs:")
    ls_input = generate_scalable_input(100, 'P', 'linear_search')
    print(f"  Linear search: array of size {len(ls_input[0])}")
    
    bs_input = generate_scalable_input(100, 'P', 'binary_search')
    print(f"  Binary search: sorted array of size {len(bs_input[0])}")
    
    ms_input = generate_scalable_input(100, 'P', 'merge_sort')
    print(f"  Merge sort: unsorted array of size {len(ms_input)}")
    
    # Test NP-class
    print("\nNP-class inputs:")
    ss_input = generate_scalable_input(15, 'NP', 'subset_sum')
    print(f"  Subset sum: set of size {len(ss_input[0])}")
    
    sat_input = generate_scalable_input(8, 'NP', 'sat')  # Smaller for NP problems
    print(f"  SAT: {len(sat_input.clauses)} clauses, {len(sat_input.get_variables())} variables")
    
    # Test NP-complete  
    print("\nNP-complete inputs:")
    clique_input = generate_scalable_input(8, 'NP-complete', 'clique')
    graph, k = clique_input
    print(f"  Clique: graph with {graph.vertices} vertices, looking for size-{k} clique")
    
    # Test NP-hard
    print("\nNP-hard inputs:")
    tsp_input = generate_scalable_input(6, 'NP-hard', 'tsp_optimization')
    print(f"  TSP optimization: {len(tsp_input)}x{len(tsp_input)} distance matrix")
    
    # Test realistic sizing
    print("\nRealistic input sizes:")
    for cls, typ in [('P', 'linear_search'), ('NP', 'subset_sum'), 
                     ('NP-complete', 'clique'), ('NP-hard', 'tsp_optimization')]:
        realistic_size = get_realistic_input_size(cls, typ, base_size=10)
        print(f"  {cls} {typ}: size {realistic_size}")