# NymyaLang Library API Documentation

## Table of Contents
1. [Math Library](#math-library)
2. [Quantum Library](#quantum-library)
3. [Crystal Library](#crystal-library)
4. [DateTime Library](#datetime-library)
5. [Low-level Library](#low-level-library)
6. [Machine Learning Library](#machine-learning-library)
7. [Quantum Algorithms](#quantum-algorithms)
8. [Networking Library](#networking-library)
9. [System Library](#system-library)
10. [Image Library](#image-library)

## Math Library

### Namespace: `math`

#### Classes
- **BigInt**: Arbitrary precision integer implementation using GMP
  - `init(value: Int)` / `init(value: String)`: Initialize from integer or string
  - `add(other: BigInt) -> BigInt`: Addition operation
  - `subtract(other: BigInt) -> BigInt`: Subtraction operation
  - `multiply(other: BigInt) -> BigInt`: Multiplication operation
  - `divide(other: BigInt) -> BigInt`: Division operation
  - `mod(other: BigInt) -> BigInt`: Modulo operation
  - `pow(exp: Int) -> BigInt`: Power operation
  - `gcd(other: BigInt) -> BigInt`: Greatest Common Divisor
  - `to_string() -> String`: Convert to string
  - `to_int() -> Int`: Convert to integer
  - `dispose() -> Void`: Free memory resources

- **Complex**: Complex number implementation
  - `init(real: Float, imag: Float)`: Initialize with real and imaginary parts
  - `magnitude() -> Float`: Get magnitude of complex number
  - `phase() -> Float`: Get phase of complex number
  - `conjugate() -> Complex`: Get conjugate
  - `add(other: Complex) -> Complex`: Addition
  - `subtract(other: Complex) -> Complex`: Subtraction
  - `multiply(other: Complex) -> Complex`: Multiplication
  - `divide(other: Complex) -> Complex`: Division
  - `power(exp: Float) -> Complex`: Power operation

#### Vector Operations (`math.vector`)
- **Vec2**: 2D vector
  - `init(x: Float, y: Float)`
  - `magnitude()`, `magnitude_squared()`, `normalize()`, `dot()`, `cross()`, `distance_to()`, `angle_to()`, `add()`, `subtract()`, `multiply()`, `rotate()`
- **Vec3**: 3D vector  
  - `init(x: Float, y: Float, z: Float)`
  - `magnitude()`, `magnitude_squared()`, `normalize()`, `dot()`, `cross()`, `distance_to()`, `add()`, `subtract()`, `multiply()`, `angle_to()`
- **Vec4**: 4D vector
  - `init(x: Float, y: Float, z: Float, w: Float)`
  - `magnitude()`, `normalize()`, `dot()`, `add()`, `subtract()`

#### Matrix Operations (`math.matrix`)
- **Matrix2x2**, **Matrix3x3**, **Matrix4x4**: Matrix implementations
  - `init()`, `init(values: List[List[Float]])`
  - `multiply_vector()`, `multiply()`, `determinant()`, `transpose()`

#### Constants
- `PI`, `E`, `TAU`, `PHI`, `SQRT2`, `SQRT3`, `INV_SQRT2`

#### Mathematical Functions
- Trigonometric: `sin(x)`, `cos(x)`, `tan(x)`, `asin(x)`, `acos(x)`, `atan(x)`, `atan2(y, x)`
- Hyperbolic: `sinh(x)`, `cosh(x)`, `tanh(x)`, `asinh(x)`, `acosh(x)`, `atanh(x)`
- Exponential/Logarithmic: `sqrt(x)`, `cbrt(x)`, `pow(base, exp)`, `exp(x)`, `exp2(x)`, `log(x)`, `log2(x)`, `log10(x)`, `log1p(x)`
- Rounding: `ceil(x)`, `floor(x)`, `round(x)`, `trunc(x)`
- Utility: `abs(x)`, `min(a, b)`, `max(a, b)`, `clamp(value, min_val, max_val)`, `sign(x)`

#### Advanced Mathematical Functions (`math.advanced`)
- Special functions: `gamma(x)`, `lgamma(x)`, `erf(x)`, `erfc(x)`
- Statistical functions: `mean(values)`, `variance(values)`, `std_dev(values)`, `median(values)`
- Interpolation: `linear()`, `lerp()`, `smoothstep()`
- Polynomial: `quadratic()`, `cubic()`, `evaluate_coefficients()`

## Quantum Library

### Namespace: `quantum`

#### Classes
- **Qubit**: Quantum bit representation
  - `init(alpha: Complex, beta: Complex)`: Initialize with complex amplitudes
  - `zero() -> Qubit`: Create |0⟩ state
  - `one() -> Qubit`: Create |1⟩ state
  - `plus() -> Qubit`: Create |+⟩ state
  - `minus() -> Qubit`: Create |-⟩ state

- **QRegister**: Quantum register
  - `init(size: Int)`: Initialize register with given size
  - `size() -> Int`: Get register size
  - `get(index: Int) -> Qubit`: Get qubit at index
  - `set(index: Int, qubit: Qubit) -> Void`: Set qubit at index

#### Quantum Gates (`quantum.gate`)
- Single-qubit gates: `id()`, `x()`, `y()`, `z()`, `s()`, `sdg()`, `sx()`, `h()`, `t()`, `tdg()`, `p()`
- Rotation gates: `rx()`, `ry()`, `rz()`
- Two-qubit gates: `cx()`, `cy()`, `cz()`, `swap()`, `iswap()`, `cp()`, `cs()`
- Two-qubit interaction gates: `rxx()`, `ryy()`, `rzz()`
- Three-qubit gates: `ccx()` (Toffoli), `cswap()` (Fredkin)
- General gates: `u()`, `u1()`, `u2()`, `u3()`

#### Quantum Simulator (`quantum.sim`)
- **Circuit**: Quantum circuit simulation
  - `init(qubit_count: Int)`: Initialize circuit
  - `apply_single_gate()`, `apply_two_qubit_gate()`, `apply_three_qubit_gate()`
  - `measure(qubit_index: Int) -> Int`: Measure qubit
  - `get_statevector() -> List[Complex]`: Get current state vector
  - `reset() -> Void`: Reset circuit to |0⟩ state

## Crystal Library

### Namespace: `crystal`

#### Core Functions
- `manifest(msg: String) -> Void`: Print message with newline
- `print(msg: String) -> Void`: Print message without newline

#### I/O Namespace (`crystal.io`)
- `print(msg: String) -> Void`: Print message
- `println(msg: String) -> Void`: Print message with newline
- `printf(format: String, args: List[Any]) -> Void`: Formatted output
- `get_line() -> String`: Read input line
- File operations: `file.read(path) -> String`, `file.write(path, content) -> Bool`

#### File Operations (`crystal.file`)
- `dalan_shira(path: String) -> cpp.fstream.std.ifstream`: Open file for reading
- `dalan_lora(path: String) -> cpp.fstream.std.ofstream`: Open file for writing
- `dalan_aya(path: String) -> Bool`: Check if file exists
- `dalan_orin(path: String, content: String) -> Bool`: Write content to file
- `dalan_karma(path: String) -> String`: Read entire file content
- `dalan_mena(path: String) -> List[String]`: Read file as lines

#### C++ Interface (`crystal.cpp`)
- **C Standard Library**: Full bindings to C functions for stdlib, stdio, string, time, math
- **Streams**: `iostream`, `fstream` bindings
- **STL Containers**: Algorithm functions, memory management

#### Data Types
- **Pointer**: Memory pointer operations with address manipulation
- **OutputStream** / **InputStream**: Stream handles

#### Platform Interface (`crystal.platform`)
- `get_system_info() -> String`, `sleep(milliseconds) -> Void`, `get_time() -> Int`, `get_current_process_id() -> Int`

## DateTime Library

### Namespace: `datetime`

#### Classes
- **Timestamp**: Unix timestamp representation
  - `init(seconds: Int)` / `init()`: Initialize with seconds or current time
  - `to_string() -> String`, `add_seconds()`, `add_minutes()`, `add_hours()`, `add_days()`, `diff()`
- **Timezone**: Timezone information
  - `init(name, offset_seconds)`: Initialize timezone
  - Standard timezones: `utc()`, `gmt()`, `est()`, `edt()`, `pst()`, `pdt()`, `jst()`, `cet()`, `cest()`
- **DateTime**: Full date/time with timezone support
  - `init(timestamp, tz)`, `init(tz)`, `init()`: Initialize with various parameters
  - `now() -> DateTime`: Get current datetime
  - Static functions: `parse_iso(iso_string) -> DateTime`
  - Instance functions: `to_timezone()`, `to_iso_string() -> String`, `get_local_time() -> TimeComponents`
- **TimeComponents**: Date/time components structure
  - `init(year, day_of_year, hour, minute, second)`: Initialize components

#### Utility Functions
- `is_leap_year(year) -> Bool`, `get_days_in_month()`, `now_utc() -> DateTime`, `now_local() -> DateTime`

## Low-level Library

### Namespace: `lowlevel`

#### Bitwise Operations (`lowlevel.bitwise`)
- Basic operations: `and()`, `or()`, `xor()`, `not()`, `left_shift()`, `right_shift()`, `logical_right_shift()`
- Bit manipulation: `rotate_left()`, `rotate_right()`, `count_leading_zeros()`, `count_trailing_zeros()`, `pop_count()`
- Bit access: `test_bit()`, `set_bit()`, `clear_bit()`, `toggle_bit()`, `extract_bit_field()`, `insert_bit_field()`

#### Memory Operations (`lowlevel.memory`)
- **MemBlock**: Memory block management
  - `init(size_bytes)`: Initialize memory block
  - `dispose()`, `write_byte()`, `read_byte()`, `fill()`, `copy_from()`, `compare()`
- Direct memory functions: `allocate()`, `deallocate()`, `copy()`, `move()`, `set()`, `compare()`

#### Register Operations (`lowlevel.register`)
- **GPRegister**: General purpose register
  - `init(width_bits)`, `get_value()`, `set_value()`, `set_bit()`, `clear_bit()`, `toggle_bit()`, `test_bit()`, `shift_left()`, `shift_right()`, `arithmetic_shift_right()`, `rotate_left()`, `rotate_right()`
- **FlagRegister**: Flag register with common flags
  - `set_carry()`, `clear_carry()`, `is_carry()`, `set_zero()`, `clear_zero()`, `is_zero()`, `set_sign()`, `clear_sign()`, `is_sign()`, `set_overflow()`, `clear_overflow()`, `is_overflow()`
- **RegisterBank**: Collection of registers
  - `init(num_registers, register_width)`, `get_register()`, `set_register()`, `get_flag_register()`, `perform_operation()`

#### Utilities (`lowlevel.utils`)
- `swap_xor()`, `swap_endian_16()`, `swap_endian_32()`, `align_up()`, `align_down()`, `is_power_of_two()`, `next_power_of_two()`

## Machine Learning Library

### Namespace: `ml`

#### Classical ML (`ml.classical`)
- **Tensor**: Multi-dimensional array operations
  - `init(r: Int, c: Int)`: Initialize tensor
  - `add(other: Tensor) -> Tensor`, `multiply(other: Tensor) -> Tensor`
  - `scalar_multiply(scalar: Float) -> Tensor`, `transpose() -> Tensor`
  - `apply_activation(func_name: String) -> Tensor`, `get_shape() -> String`
- **Layer**: Neural network layer
  - `init(input_size: Int, output_size: Int, activation_func: String)`
  - `forward(input: Tensor) -> Tensor`
- **NeuralNetwork**: Neural network container
  - `add_layer(layer: Layer) -> Void`, `predict(input: Tensor) -> Tensor`
- Activation functions: `sigmoid(x)`, `relu(x)`, `tanh_activation(x)`
- Loss functions: `mean_squared_error()`, `cross_entropy_loss()`
- Training utilities: `simulate_training()`

#### Quantum ML (`ml.quantum_ml`)
- **ParameterizedCircuit**: Parameterized quantum circuit
  - `init(n_qubits: Int)`, `apply_circuit()`, `measure_all() -> List[Int]`, `get_statevector()`, `update_parameters()`
- **VariationalClassifier**: Quantum variational classifier
  - `init(n_qubits: Int, n_classes: Int)`, `forward(input_data) -> List[Float]`, `predict(input_data: List[Float]) -> Int`
- **QuantumSVM**: Quantum Support Vector Machine
  - `init(feature_dim: Int)`, `fit(training_data, labels)`, `predict_single()`, `predict_batch()`
- **QuantumNeuralLayer**: Quantum neural network layer
  - `init(n_qubits: Int)`, `forward(inputs: List[Float]) -> List[Float]`

#### Training Utilities (`ml.training_utils`)
- `generate_simple_dataset()`, `generate_labels()`, `calculate_accuracy()`, `normalize_data()`

## Quantum Algorithms

### Namespace: `quantum.alg`

#### Algorithms Implemented
- **Deutsch-Jozsa**: `deutsch_jozsa(circuit, n, oracle_func) -> String` - Determines if function is constant or balanced
- **Bernstein-Vazirani**: `bernstein_vazirani(circuit, n, oracle_func) -> List[Int]` - Finds hidden string in single query
- **Simon's Algorithm**: `simon(circuit, n, oracle_func) -> String` - Finds period of function exponentially faster than classical
- **Quantum Phase Estimation**: `quantum_phase_estimation(circuit, precision_qubits, target_qubits, unitary) -> Float` - Estimates eigenvalue of unitary operator
- **Shor's Algorithm**: `shors(circuit, number_to_factor, oracle_func) -> List[Int]` - Quantum factoring algorithm
- **Grover's Algorithm**: `grovers(circuit, n_qubits, oracle_func) -> Int` - Quantum search algorithm providing quadratic speedup
- **Quantum Fourier Transform**: `quantum_fourier_transform(circuit, qubits)`, `inverse_quantum_fourier_transform()`
- **Quantum Counting**: `quantum_counting(circuit, n_search_qubits, oracle_func, n_counting_qubits) -> Int` - Counts number of marked entries
- **QAOA (Quantum Approximate Optimization Algorithm)**: `qaoa(circuit, hamiltonian, p, beta_params, gamma_params) -> List[Float]`
- **VQE (Variational Quantum Eigensolver)**: `vqe(circuit, hamiltonian, ansatz_params, optimizer) -> Float` - Finds ground state of Hamiltonian

## Networking Library

### Namespace: `networking`

#### Classical Networking (`networking.classical`)
- `ping(host: String) -> Float`, `estimate_latency()`, `ping_system_command()`
- `measure_download_speed()`, `measure_upload_speed()`
- `get_subnet()`, `split_ip()`, `scan_network()`, `scan_port()`, `connect_tcp()`, `resolve_dns()`
- **NetworkInterface**: Network interface information with `init()`, `get_info()`

#### Quantum Networking (`networking.quantum`)
- `establish_entanglement()`, `create_quantum_field()`, `quantum_nonlocal_send()`, `share_quantum_state()`
- **QuantumChannel**: Quantum communication channel with `init()`, `transmit()`, `get_status()`
- **QuantumNetwork**: Quantum network topology with `add_node()`, `connect_nodes()`, `get_topology()`

#### Quantum Random Number Generator
- **QRNG**: Quantum Random Number Generator with `init()`, `generate_float()`, `generate_uint()`, `generate_binary_string()`, `generate_secure_key()`

#### Encryption (`networking.encryption`)
- **RingEncryption**: Quantum-resistant encryption with `init()`, `generate_keypair()`, `encrypt()`, `decrypt()`
- **NestedQuantumRingEncryption**: Multi-layer quantum encryption with `init()`, `generate_keypairs()`, `encrypt_nested()`, `decrypt_nested()`

#### Photonic Driver (`networking.photonic_driver`)
- **PhotonicChipDriver**: Interface for quantum photonic chips with `init()`, `configure_chip()`, `generate_photon_states()`, `execute_quantum_circuit()`, `get_chip_status()`
- `detect_photonic_chips() -> List[String]`, `initialize_chip()`

#### Utility Functions
- `simulate_qubit_memory_usage()`

## System Library

### Namespace: `system`

#### System Commands (`system.commands`)
- `echo(args: List[String]) -> Int`: Print arguments with consciousness-aware processing
- `echo_ca()`: Enhanced consciousness-aware echo
- Additional variants: `echo_timestamped()`, `echo_to_file()`, `echo_hex()`, `echo_reverse()`

#### System Utilities (`system.sysutils`)
- `sleep(seconds: Float)`, `true_cmd() -> Int`, `false_cmd() -> Int`
- `pwd() -> String`, `whoami() -> String`, `hostname() -> String`

## Image Library

### Namespace: `image`

#### Features
- Basic image operations and processing functions similar to STB libraries
- Extended image functionality with advanced processing capabilities
- Image generation tools for quantum-enhanced processing (as referenced by `test_image_gen.nym`)

---
**Note**: This documentation is based on the current state of the codebase. As the compiler and runtime develop, more functions and features may be added or modified.