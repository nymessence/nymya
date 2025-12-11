# Graphics Library for NymyaLang

This library provides 3D graphics functionality for NymyaLang, including PLY file format support and 3D model creation capabilities.

## Contents

- `ply_basic.nym` - Basic PLY (Polygon File Format) handling functions
- `3d_basic.nym` - Basic 3D geometry functions (to be implemented)

## Features

- Create and manipulate 3D models
- Generate PLY files for 3D visualization
- Support for vertices, faces, and common 3D shapes
- Specialized functions for astronomical visualization

## Usage

```nym
import graphics.ply_basic

var model = graphics.ply_basic.create_model()
model.add_tetrahedron(0.0, 0.0, 0.0, 1.0)  // Add a tetrahedron at origin with scale 1.0
model.write_ply("output.ply")
```

## Example Applications

- Astronomical visualization of star clusters
- 3D modeling of sacred geometry
- Scientific visualization