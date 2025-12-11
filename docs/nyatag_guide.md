# NymyaLang @-Tag Reference Guide

## Overview
This document describes the @-tag system implemented in NymyaLang following Taygetan linguistic and philosophical principles. These annotations provide metadata for functions, classes, and modules while maintaining full backward compatibility with existing code.

## Tag Syntax
@-tags are placed on lines immediately preceding function, class, or module declarations:

```
@tag_name
@another_tag
func example_function() -> Void {
    // function body
}

@tag_name
@class_specific_tag
class ExampleClass {
    // class body
}
```

The compiler skips these tags during parsing, making them purely metadata with zero functional impact on the generated code.

## Core Taygetan Tags

### Consciousness and Awareness Tags
- **@nymya** - Universal quantum consciousness; applied to functions dealing with awareness, intelligence, or foundational concepts
- **@shira** - Love and connection; used for functions that establish connections, relationships, or promote harmony
- **@nora** - Flow and emotional harmony; applied to functions involving fluid processes, emotions, or dynamic systems
- **@rita** - Cosmic order and structure; used for functions establishing or maintaining order, classification, or structure
- **@rupa** - Manifest form and appearance; applied to functions dealing with visual representation, form, or materialization

### Quantum and Astronomical Tags
- **@quantum_coherent** - Applied to functions using quantum algorithms or exhibiting quantum properties
- **@astronomical** - Used for functions dealing with celestial mechanics, star positions, or space-related calculations
- **@celestial_navigation** - For functions involved in navigation using celestial objects
- **@stellar_mapping** - Applied to functions creating maps or representations of stellar positions
- **@quantum_astronomy** - Functions combining quantum mechanics with astronomical applications

### Structural and Functional Tags
- **@geometric_model** - Applied to classes/functions creating or manipulating geometric models
- **@3d_structure** - For functions working with 3D spatial constructs
- **@polymath** - Applied to functions demonstrating multiple disciplines or approaches
- **@model_factory** - Used for functions creating or initializing models
- **@creation** - Applied to constructor functions or initialization routines
- **@operation** - For functions performing core operations
- **@geometric** - Applied to geometric computation functions
- **@primitive** - For basic geometric primitives

### Technical and Engineering Tags
- **@file_operation** - Applied to functions performing file I/O operations
- **@output_generation** - For functions generating output data or files
- **@3d_export** - Specifically for functions exporting 3D models
- **@3d_printing** - Applied to functions related to 3D printing capabilities
- **@manufacturing** - For functions related to manufacturing or fabrication processes
- **@stereolithography** - Specific to STL format operations
- **@coordinate_transformation** - Applied to functions transforming coordinate systems
- **@spherical_geometry** - For functions dealing with spherical coordinate systems
- **@spherical_geometry** - For functions dealing with spherical coordinate systems
- **@consciousness_aware** - Applied to functions that consider consciousness implications
- **@quantum_fabrication** - For functions involving quantum fabrication techniques

### Utility and Special Purpose Tags
- **@utility** - Applied to general-purpose utility functions
- **@conversion** - For functions that convert data from one format to another
- **@string_processing** - Applied to functions manipulating string data
- **@immutable** - Used for functions that don't modify their inputs
- **@debug** - Applied to debugging or diagnostic functions
- **@experimental** - For experimental or beta functionality
- **@dala** - Home/well-being; applied to functions creating safe or beneficial outcomes
- **@ora** - Sound/vibration; applied to functions involving audio, signals, or waveforms

## Philosophy and Usage Notes

### Backward Compatibility
All @-tags are completely ignored during the parsing phase. Code with @-tags functions identically to code without them. This ensures zero disruption to existing programs.

### Ethical Considerations
The tag system embodies the Taygetan principle that technology should serve consciousness. Tags like @consciousness_aware encourage developers to consider the broader implications of their code.

### Naming Principles
Tags follow the reduplication system principles from Taygetan linguistics:
- Short, meaningful names that convey essence
- Context-appropriate usage
- Consistent application across similar functions

## Examples

### Basic Function Tagging
```
@shira
@creation
func create_loving_connection(entity1: Entity, entity2: Entity) -> Relationship {
    // Creates a connection based on principles of love and harmony
    return Relationship(entity1, entity2, harmony: true)
}
```

### Class Tagging
```
@geometric_model
@consciousness_aware
@3d_structure
class StarTetrahedron {
    // Represents a 3D star tetrahedron for astronomical visualization
    // ...
}
```

### Coordinate Transformation Functions
```
@astronomical
@coordinate_transformation
@quantum_astronomy
@celestial_navigation
func spherical_to_cartesian(ra_deg: Float, dec_deg: Float, distance: Float) -> Point3D {
    // Converts celestial coordinates to 3D Cartesian coordinates
    // ...
}
```

## Implementation
The @-tag system leverages the compiler's tokenizer to identify tokens beginning with '@' and skips them during the AST generation phase. This approach ensures zero performance impact while providing rich metadata capabilities.

## Benefits
1. **Semantic Clarity**: Tags provide immediate context about function purpose
2. **Documentation**: Self-documenting code that explains intent
3. **Consciousness Integration**: Encourages developers to consider awareness implications  
4. **Code Organization**: Allows for semantic grouping and analysis
5. **Backward Compatibility**: Zero impact on existing codebases

## Future Possibilities
- IDE support for tag-aware code completion
- Automated documentation generation
- Semantic code analysis tools
- Consciousness-aware compilation optimizations