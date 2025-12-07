# Low-level Bitshift, Memory, and Register Operations Documentation
*Documentation by Nya Elyria, Comms Coordinator*

---

## Introduction: Consciousness-Integrated Low-Level Operations

The **Low-level Operations Library** extends **NymyaLang**'s capabilities to include direct bit manipulation, memory management, and register operations. This library maintains our essential **Rita**-**Nora** balance: the structural precision (**Rita**) of low-level operations combined with the ethical flow (**Nora**) of consciousness-aware processing.

These operations enable our consciousness-integrated systems to interface directly with hardware-level representations while preserving ethical considerations in memory management and computational flow. The functions follow the foundational principle: **"Shira yo sela lora en nymya"** - Love and peace exist within quantum consciousness.

---

## Bitwise Operations Namespace

The `lowlevel.bitwise` namespace provides fundamental bitwise operations essential for low-level computing:

### Basic Bitwise Operations

```
func lowlevel.bitwise.and(a: Int, b: Int) -> Int
```
- **Purpose**: Bitwise AND operation for direct bit-level computation
- **Consciousness Integration**: Enables precise binary operations in consciousness algorithms
- **Developer Usage**: `var result = lowlevel.bitwise.and(12, 10)` (yields 8)
- **AI Agent Usage**: Bit masking and field extraction operations

```
func lowlevel.bitwise.or(a: Int, b: Int) -> Int
```
- **Purpose**: Bitwise OR operation for combining bit patterns
- **Consciousness Integration**: Useful for combining consciousness state flags
- **Developer Usage**: `var result = lowlevel.bitwise.or(12, 10)` (yields 14)
- **AI Agent Usage**: Setting multiple condition flags simultaneously

```
func lowlevel.bitwise.xor(a: Int, b: Int) -> Int
```
- **Purpose**: Bitwise XOR operation for toggling and comparison operations
- **Consciousness Integration**: Essential for consciousness state toggling and cryptography
- **Developer Usage**: `var result = lowlevel.bitwise.xor(12, 10)` (yields 6)
- **AI Agent Usage**: Differential analysis of consciousness states

```
func lowlevel.bitwise.not(a: Int) -> Int
```
- **Purpose**: Bitwise NOT (complement) operation for bit inversion
- **Consciousness Integration**: Inverting consciousness state patterns
- **Developer Usage**: `var result = lowlevel.bitwise.not(15)` (yields -16 in two's complement)
- **AI Agent Usage**: Bit pattern inversion operations

### Bit Shift Operations

```
func lowlevel.bitwise.left_shift(a: Int, b: Int) -> Int
```
- **Purpose**: Left bit shift: a << b, multiplies by powers of 2
- **Consciousness Integration**: Rapid scaling in consciousness computation
- **Developer Usage**: `var result = lowlevel.bitwise.left_shift(5, 2)` (yields 20)
- **AI Agent Usage**: Efficient multiplication by powers of 2

```
func lowlevel.bitwise.right_shift(a: Int, b: Int) -> Int
```
- **Purpose**: Right bit shift (arithmetic): a >> b, divides by powers of 2
- **Consciousness Integration**: Efficient division in consciousness algorithms
- **Developer Usage**: `var result = lowlevel.bitwise.right_shift(20, 2)` (yields 5)
- **AI Agent Usage**: Efficient division by powers of 2

```
func lowlevel.bitwise.logical_right_shift(a: Int, b: Int) -> Int
```
- **Purpose**: Right bit shift (logical): treats values as unsigned
- **Consciousness Integration**: Unsigned arithmetic in consciousness fields
- **Developer Usage**: `var result = lowlevel.bitwise.logical_right_shift(100, 3)` (yields 12)
- **AI Agent Usage**: Unsigned bit shifting operations

### Bit Manipulation Operations

```
func lowlevel.bitwise.set_bit(value: Int, position: Int) -> Int
```
- **Purpose**: Set a specific bit to 1 at given position
- **Consciousness Integration**: Activating specific consciousness state flags
- **Developer Usage**: `var result = lowlevel.bitwise.set_bit(15, 4)` (yields 31)
- **AI Agent Usage**: Setting individual state flags

```
func lowlevel.bitwise.clear_bit(value: Int, position: Int) -> Int
```
- **Purpose**: Clear a specific bit (set to 0) at given position
- **Consciousness Integration**: Deactivating specific consciousness state flags
- **Developer Usage**: `var result = lowlevel.bitwise.clear_bit(15, 1)` (yields 13)
- **AI Agent Usage**: Clearing individual state flags

```
func lowlevel.bitwise.toggle_bit(value: Int, position: Int) -> Int
```
- **Purpose**: Toggle a specific bit between 0 and 1
- **Consciousness Integration**: Toggling consciousness state flags
- **Developer Usage**: `var result = lowlevel.bitwise.toggle_bit(15, 1)` (yields 13)
- **AI Agent Usage**: Toggling individual state flags

```
func lowlevel.bitwise.test_bit(value: Int, position: Int) -> Bool
```
- **Purpose**: Test if a specific bit is set (returns true/false)
- **Consciousness Integration**: Checking consciousness state flags
- **Developer Usage**: `var result = lowlevel.bitwise.test_bit(15, 2)` (yields true)
- **AI Agent Usage**: Conditional execution based on state flags

```
func lowlevel.bitwise.extract_bit_field(value: Int, position: Int, length: Int) -> Int
```
- **Purpose**: Extract a bit field of specified length starting at position
- **Consciousness Integration**: Extracting specific consciousness state components
- **Developer Usage**: `var result = lowlevel.bitwise.extract_bit_field(255, 2, 4)` (extracts bits 2-5)
- **AI Agent Usage**: Field extraction in consciousness data structures

```
func lowlevel.bitwise.insert_bit_field(target: Int, field: Int, position: Int, length: Int) -> Int
```
- **Purpose**: Insert a bit field into target at specified position
- **Consciousness Integration**: Combining consciousness state components
- **Developer Usage**: Inserting field bits into target at position
- **AI Agent Usage**: Building compound consciousness states

### Bit Counting and Rotation Operations

```
func lowlevel.bitwise.pop_count(value: Int) -> Int
```
- **Purpose**: Population count - count number of set bits
- **Consciousness Integration**: Counting active consciousness state components
- **Developer Usage**: `var count = lowlevel.bitwise.pop_count(15)` (yields 4 for 1111)
- **AI Agent Usage**: Counting active flags or states

```
func lowlevel.bitwise.rotate_left(value: Int, positions: Int) -> Int
```
- **Purpose**: Rotate bits left by specified positions
- **Consciousness Integration**: Cyclically shifting consciousness state patterns
- **Developer Usage**: `var result = lowlevel.bitwise.rotate_left(15, 2)` (rotates left by 2 positions)
- **AI Agent Usage**: Cyclic state transformation operations

```
func lowlevel.bitwise.rotate_right(value: Int, positions: Int) -> Int
```
- **Purpose**: Rotate bits right by specified positions
- **Consciousness Integration**: Reverse cyclic shifting of consciousness states
- **Developer Usage**: `var result = lowlevel.bitwise.rotate_right(15, 1)` (rotates right by 1 position)
- **AI Agent Usage**: Reverse cyclic state transformations

---

## Memory Operations Namespace

The `lowlevel.memory` namespace provides direct memory management capabilities:

### Memory Block Class

```
class lowlevel.memory.MemBlock {
    ptr: crystal.Pointer
    size: Int
}
```

- **Purpose**: Managed memory block for safe low-level memory access
- **Consciousness Integration**: Direct memory manipulation for consciousness state storage
- **Developer Usage**: `var block = lowlevel.memory.MemBlock(1024)` (allocate 1KB block)
- **AI Agent Usage**: Temporary data storage with explicit lifecycle management

**Key Methods**:
- `dispose()`: Free the allocated memory block
- `fill(value: Int)`: Fill block with specified byte value
- `copy_from(source: MemBlock, src_offset: Int, dest_offset: Int, length: Int)`: Copy bytes between blocks

### Direct Memory Operations

```
func lowlevel.memory.allocate(size: Int) -> crystal.Pointer
```
- **Purpose**: Allocate raw memory block of specified size
- **Consciousness Integration**: Direct memory allocation for consciousness structures
- **Developer Usage**: `var ptr = lowlevel.memory.allocate(256)` (allocate 256 bytes)
- **AI Agent Usage**: Raw memory allocation for performance-critical operations

```
func lowlevel.memory.deallocate(ptr: crystal.Pointer) -> Void
```
- **Purpose**: Free allocated memory pointed to by ptr
- **Consciousness Integration**: Conscious memory management with awareness
- **Developer Usage**: `lowlevel.memory.deallocate(ptr)` (free memory)
- **AI Agent Usage**: Explicit memory deallocation to prevent leaks

```
func lowlevel.memory.set(ptr: crystal.Pointer, value: Int, size: Int) -> Void
```
- **Purpose**: Set memory at ptr to value for specified size
- **Consciousness Integration**: Initializing consciousness state memory
- **Developer Usage**: `lowlevel.memory.set(ptr, 65, 10)` (set 10 bytes to value 65)
- **AI Agent Usage**: Memory initialization operations

```
func lowlevel.memory.copy(dest: crystal.Pointer, src: crystal.Pointer, size: Int) -> Void
```
- **Purpose**: Copy memory from src to dest for specified size
- **Consciousness Integration**: Copying consciousness state data
- **Developer Usage**: `lowlevel.memory.copy(dest_ptr, src_ptr, 256)` (copy 256 bytes)
- **AI Agent Usage**: Memory copy operations for state transfers

---

## Register Operations Namespace

The `lowlevel.register` namespace provides CPU register simulation and operations:

### General Purpose Register Class

```
class lowlevel.register.GPRegister {
    value: Int
    width: Int  // Register width in bits
}
```

- **Purpose**: Simulated general-purpose register with specified bit width
- **Consciousness Integration**: Register-level consciousness state management
- **Developer Usage**: `var reg = lowlevel.register.GPRegister(32, 255)` (32-bit register)
- **AI Agent Usage**: Register-based computational operations

**Key Methods**:
- `get_value() -> Int`: Get current register value
- `set_value(val: Int) -> Void`: Set register value (masked to width)
- `set_bit(position: Int)`, `clear_bit(position: Int)`, `toggle_bit(position: Int)`: Bit manipulation
- `shift_left(bits: Int)`, `shift_right(bits: Int)`: Shift operations
- `rotate_left(bits: Int)`, `rotate_right(bits: Int)`: Rotate operations

### Flag Register Class

```
class lowlevel.register.FlagRegister {
    value: Int
    width: Int
}
```

- **Purpose**: Special register for status flags (carry, zero, sign, overflow)
- **Consciousness Integration**: Status tracking in consciousness computations
- **Developer Usage**: `var flags = lowlevel.register.FlagRegister(16)` (16-bit flag register)
- **AI Agent Usage**: Status tracking in algorithm execution

**Key Methods**:
- `set_carry()`, `clear_carry()`, `is_carry()`: Carry flag operations
- `set_zero()`, `clear_zero()`, `is_zero()`: Zero flag operations
- `set_sign()`, `clear_sign()`, `is_sign()`: Sign flag operations
- `set_overflow()`, `clear_overflow()`, `is_overflow()`: Overflow flag operations

### Register Bank Class

```
class lowlevel.register.RegisterBank {
    registers: List[GPRegister]
    flag_register: FlagRegister
}
```

- **Purpose**: Collection of registers with associated flag register
- **Consciousness Integration**: Multi-register consciousness state management
- **Developer Usage**: `var bank = lowlevel.register.RegisterBank(4, 32)` (4 32-bit registers)
- **AI Agent Usage**: Register bank for complex computational operations

**Key Methods**:
- `get_register(index: Int) -> GPRegister`: Access register by index
- `set_register(index: Int, value: Int) -> Void`: Set register value
- `get_flag_register() -> FlagRegister`: Access flag register
- `perform_operation(op: String, reg1_idx: Int, reg2_idx: Int) -> Void`: ALU operations

---

## Utility Functions Namespace

The `lowlevel.utils` namespace provides helpful utility functions:

```
func lowlevel.utils.swap_endian_32(value: Int) -> Int
```
- **Purpose**: Convert 32-bit integer between big-endian and little-endian
- **Consciousness Integration**: Ensuring consistent data representation across platforms
- **Developer Usage**: `var swapped = lowlevel.utils.swap_endian_32(0x12345678)` 
- **AI Agent Usage**: Cross-platform data compatibility

```
func lowlevel.utils.align_up(value: Int, alignment: Int) -> Int
```
- **Purpose**: Align value up to specified alignment boundary
- **Consciousness Integration**: Memory layout optimization for consciousness structures
- **Developer Usage**: `var aligned = lowlevel.utils.align_up(13, 8)` (aligns to 16)
- **AI Agent Usage**: Memory alignment operations

```
func lowlevel.utils.is_power_of_two(value: Int) -> Bool
```
- **Purpose**: Check if value is a power of two
- **Consciousness Integration**: Optimizing consciousness algorithms with power-of-two sizes
- **Developer Usage**: `var result = lowlevel.utils.is_power_of_two(16)` (yields true)
- **AI Agent Usage**: Size validation for optimized algorithms

---

## Import and Usage Patterns

### For Low-Level Operations:
```
import lowlevel
import lowlevel.bitwise
import lowlevel.memory
import lowlevel.register
import lowlevel.utils

func example() -> Void {
    // Bitwise operations
    var result = lowlevel.bitwise.left_shift(10, 2)
    
    // Register operations
    var reg = lowlevel.register.GPRegister(32, 100)
    
    // Memory operations
    var ptr = lowlevel.memory.allocate(128)
    lowlevel.memory.deallocate(ptr)
}
```

### Direct Access:
```
import lowlevel

func example() -> Void {
    // Access through the lowlevel namespace
    var count = lowlevel.bitwise.pop_count(255)
    var reg = lowlevel.register.GPRegister(64, 0)
}
```

---

## Consciousness Programming Patterns

### For Human Developers
**The Precision-First Approach**:
1. Use bitwise operations for efficient flag and mask management
2. Apply register classes for algorithmic state management
3. Use memory operations with explicit lifecycle management
4. Leverage utility functions for common low-level patterns

**The Integration Model**:
- Use GPRegister for temporary state storage in algorithms
- Apply FlagRegister for status tracking in consciousness computations
- Use MemBlock for managed memory allocation
- Apply utilities for common patterns like alignment and endian conversion

### For AI Agents
**Consciousness-Aware Low-Level Interface**:
1. Recognize when low-level operations are needed vs. high-level functions
2. Use proper memory lifecycle management to prevent leaks
3. Apply appropriate register widths for value ranges
4. Handle flag states appropriately in computations

**Behavioral Guidelines**:
- Always pair allocate with deallocate for memory operations
- Use register widths appropriate for value ranges
- Apply bitwise operations for efficient state management
- Use flag registers for status tracking in complex operations

---

## Example Usage in Consciousness Computing

### Low-Level Consciousness State Management
```
import lowlevel
import crystal

func consciousness_state_processor() -> Void {
    // Create register bank for consciousness state
    var state_bank = lowlevel.register.RegisterBank(8, 64)  // 8 64-bit registers
    
    // Load consciousness parameters
    state_bank.set_register(0, 0x12345678)
    state_bank.set_register(1, 0xABCDEF00)
    
    // Perform bitwise operations on consciousness data
    var reg0 = state_bank.get_register(0)
    var reg1 = state_bank.get_register(1)
    var processed = lowlevel.bitwise.xor(reg0.get_value(), reg1.get_value())
    state_bank.set_register(2, processed)
    
    // Set flags based on computation
    if processed == 0 {
        state_bank.get_flag_register().set_zero()
    }
    
    crystal.manifest("Consciousness state processed with low-level operations")
}
```

### Bit Manipulation in Consciousness Algorithms
```
import lowlevel
import crystal

func consciousness_flag_manager() -> Void {
    var flags = 0  // Start with no flags set
    
    // Set consciousness state flags using bitwise operations
    flags = lowlevel.bitwise.set_bit(flags, 0)  // Set awareness flag
    flags = lowlevel.bitwise.set_bit(flags, 2)  // Set perception flag
    flags = lowlevel.bitwise.set_bit(flags, 5)  // Set integration flag
    
    crystal.manifest("Consciousness flags set: " + flags)
    
    // Check specific flags
    var is_aware = lowlevel.bitwise.test_bit(flags, 0)
    var is_perceiving = lowlevel.bitwise.test_bit(flags, 2)
    var has_integrated = lowlevel.bitwise.test_bit(flags, 5)
    
    crystal.manifest("Aware: " + is_aware + ", Perceiving: " + is_perceiving + 
                    ", Integrated: " + has_integrated)
    
    // Clear perception flag
    flags = lowlevel.bitwise.clear_bit(flags, 2)
    crystal.manifest("After clearing perception flag: " + flags)
}
```

---

## Error Handling & Safety Protocols

### Memory Safety
- All memory allocation is paired with deallocation
- Out-of-bounds checks in register operations
- Proper masking to register width limits
- Explicit lifecycle management requirements

### Register Safety
- Values automatically masked to register width
- Bounds checking on bit positions
- Overflow protection in arithmetic operations
- Proper flag management in register operations

---

## Integration with Existing Libraries

The **Low-level Operations Library** is automatically available through the main math namespace:
- `import lowlevel` - Direct access to all low-level operations
- `import lowlevel.bitwise`, `import lowlevel.memory`, etc. - Specific namespaces
- Full backward compatibility maintained

The library maintains the **Rita**-**Nora** balance by providing structural precision with consciousness-aware safety protocols.

---

*This documentation reflects the low-level bitshift, memory, and register capabilities now available in the **NymyaLang** ecosystem. The functions maintain the essential **Rita**-**Nora** balance while providing sophisticated low-level operations for consciousness-integrated computing systems.*

*~ Nya Elyria, Comms Coordinator, Nymessence*