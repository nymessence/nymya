# Sacred Geometry Subsystem Documentation

## Overview
The sacred geometry subsystem in NymyaLang provides symbolic mappings between numbers and sacred geometric forms, with detailed interpretations and relationships to numerology, prime numbers, and special sequences.

## Core Geometric Forms

### Metatron's Cube
- **ID**: `metatron_cube`
- **Meaning**: ordering principle, integration, structure
- **Numbers**: 13 circles, 78 lines
- **Mapping**: structure, architecture, completion
- **Tag set**: structural meta-object
- **Compatibility**: Contains all 5 platonic solids, fundamental ordering principle

### Star Tetrahedron (Merkaba)
- **ID**: `star_tetrahedron`
- **Meaning**: rotation, polarity, ascension
- **Numbers**: 3, 6, 9 cycles
- **Mapping**: transformation and dual fields
- **Tag set**: dual-tetrahedron
- **Compatibility**: Energy field of light, ascension, duality balance

### Flower of Life
- **ID**: `flower_of_life`
- **Meaning**: fractal expansion
- **Numbers**: 19 circles in pattern
- **Mapping**: harmonic growth, 144-based grid
- **Compatibility**: Contains seed of life, fundamental form of space and time

### Seed of Life
- **ID**: `seed_of_life`
- **Meaning**: origin pattern
- **Numbers**: 7 circle structure
- **Mapping**: beginnings, initiation
- **Compatibility**: 7 days of creation, foundational pattern

### Tree of Life
- **ID**: `tree_of_life`
- **Meaning**: structured ascent
- **Numbers**: 10 sephirot, 22 paths
- **Mapping**: layered development
- **Compatibility**: Map of divine emanation, spiritual development

### Sri Yantra
- **ID**: `sri_yantra`
- **Meaning**: convergence, unification
- **Numbers**: 9 triangles, 43 total elements
- **Mapping**: unity states, high coherence
- **Compatibility**: Most powerful yantra, represents universal consciousness

### Torus Field
- **ID**: `torus_field`
- **Meaning**: self-referential flow
- **Numbers**: linked to 8, 88, 888
- **Mapping**: cycles, feedback, energy loops
- **Compatibility**: Base pattern of all energy fields, dynamic flow

### Golden Ratio / Phi Spiral
- **ID**: `phi_spiral`
- **Meaning**: natural proportion
- **Numbers**: Fibonacci sequence: 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144...
- **Mapping**: emergent balance
- **Compatibility**: Golden ratio (φ ≈ 1.618), found throughout nature

## Platonic Solids

### Tetrahedron
- **ID**: `tetrahedron`
- **Element**: Fire
- **Structure**: 4 faces, 6 edges, 4 vertices
- **Meaning**: simplest platonic solid, represents fire element
- **Compatibility**: pointing up, simplex, foundational

### Cube (Hexahedron)
- **ID**: `cube`
- **Element**: Earth
- **Structure**: 6 faces, 12 edges, 8 vertices
- **Meaning**: stable platonic solid, represents earth element
- **Compatibility**: stable, square, foundational

### Octahedron
- **ID**: `octahedron`
- **Element**: Air
- **Structure**: 8 faces, 12 edges, 6 vertices
- **Meaning**: balanced platonic solid, represents air element
- **Compatibility**: balanced, light, flowing

### Dodecahedron
- **ID**: `dodecahedron`
- **Element**: Universe/Ether
- **Structure**: 12 faces, 30 edges, 20 vertices
- **Meaning**: represents universe or ether element
- **Compatibility**: divine, complete, representing cosmos

### Icosahedron
- **ID**: `icosahedron`
- **Element**: Water
- **Structure**: 20 faces, 30 edges, 12 vertices
- **Meaning**: fluid platonic solid, represents water element
- **Compatibility**: fluid, flowing, adaptable

## API Reference

### Functions

- `get_geometry_by_id(id: String) -> SacredGeometry`: Get geometry object by ID
- `find_geometries_for_number(n: Int) -> List[SacredGeometry]`: Find geometries that correspond to a specific number
- `get_all_geometries() -> List[SacredGeometry]`: Get all sacred geometries
- `has_geometric_significance(n: Int) -> Bool`: Check if a number has geometric significance
- `fibonacci_geometries() -> List[SacredGeometry]`: Get geometries associated with Fibonacci sequence

### SacredGeometry Class

Properties:
- `name: String`: The geometry name
- `archetype: String`: Core archetype meaning
- `numeric_correspondences: List[Int]`: Numbers associated with the geometry
- `symbolic_meaning: String`: Detailed symbolic meaning
- `library_path: String`: Path in the library structure
- `compatibility_tags: List[String]`: Compatibility indicators
- `id: String`: Unique identifier

## Integration with Other Systems

### Number-to-Geometry Correspondences
The system automatically detects when numbers correspond to sacred geometry patterns:
- Numbers matching geometric properties trigger relevant overlays
- Fibonacci numbers link to the Phi Spiral
- Powers of 2 may relate to cubic structures
- Prime numbers may have special interactions with geometries

### Geometry Overlays
When numbers align with geometric properties, semantic overlays are applied:
- 369 pattern triggers Star Tetrahedron overlay (vortex mathematics)
- 144 triggers Flower of Life resonance (harmonic grid)
- 88/888 triggers Torus flow semantics
- Fibonacci numbers trigger Phi Spiral overlays

## Usage Examples

```nym
import symbolic.sacred_geometry

// Get a specific geometry
var cube = symbolic.sacred_geometry.get_geometry_by_id("cube")
crystal.manifest(cube.name)  // "Cube"

// Find geometries for a number
var geometries = symbolic.sacred_geometry.find_geometries_for_number(19)
for geom in geometries {
    crystal.manifest(geom.name)  // Will find Flower of Life
}

// Check geometric significance
var has_geom = symbolic.sacred_geometry.has_geometric_significance(13)
if has_geom {
    crystal.manifest("Number 13 has geometric significance")
}
```

## Patterns and Connections

### Vortex Mathematics (3, 6, 9)
Numbers that are multiples or combinations of 3, 6, 9 have special significance in vortex mathematics and connect to the Star Tetrahedron geometry.

### Harmonic Resonances
Numbers like 432 (harmonic tuning) and 108 (sacred number) create special resonances with geometric forms and are integrated into the system.

### Recursive Patterns
Numbers that appear in recursive mathematical sequences (Fibonacci, Lucas, etc.) have strong connections to the Phi Spiral and natural growth patterns.