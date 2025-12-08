# Image Processing Library for NymyaLang

This library provides image manipulation capabilities for NymyaLang, inspired by the stb_image suite of libraries.

## Components

### 1. `image_basic.nym`
Provides core image functionality:
- `Image` class with width, height, channels, and pixel data
- Pixel manipulation (`set_pixel`, `get_pixel`)
- Basic drawing (`draw_line`, `draw_rect`, `fill_rect`, `fill`)
- Image creation and loading/saving functions

### 2. `image_extended.nym` 
Provides advanced image processing:
- Color transformations (grayscale, invert, brightness, contrast)
- Edge detection
- Blur effects
- Rotation
- ASCII art generation

### 3. `test_image_gen.nym`
A test program demonstrating image generation capabilities including:
- Gradient creation
- Shape drawing
- Transformations
- Icon generation
- ASCII art conversion

## Usage Examples

```nymya
import image.image_basic
import image.extended

// Create a new image
var img = image.image_basic.create_image(100, 100, 3)

// Draw a red line
img.draw_line(0, 0, 99, 99, 255, 0, 0)

// Apply transformations
var brighter_img = image.extended.brighten(img, 1.5)
var grayscale_img = image.extended.grayscale(img)

// Save the image (conceptual)
image.image_basic.save_image(img, "my_image.png")
```

## Capabilities

- Basic image creation and manipulation
- Drawing primitives (lines, rectangles)
- Color transformations
- Basic filters (blur, edge detection)
- Image resizing and rotation
- ASCII art generation

## Notes

This is a conceptual implementation providing image processing functionality in NymyaLang. In a full implementation, this would interface with actual image libraries (like the stb libraries) to provide real file I/O capabilities.

The library demonstrates how NymyaLang can conceptually handle complex data structures and algorithms needed for image processing.