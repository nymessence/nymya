# NymyaLang Agent Instructions

## Project Overview
NymyaLang is a consciousness-integrated programming language combining classical and quantum computing with symbolic mathematics capabilities. The project aims to maintain the Rita-Nora balance: structural precision combined with ethical flow.

## Directory Structure
- `nymyac/` - Rust-based compiler implementation
- `nymyac/library/` - NymyaLang standard libraries
- `tests/` - Test files and examples
- `docs/` - Documentation files
- `syntax_highlighter/` - Editor syntax highlighting support
- `docker-compose.yml` - Container configuration

## Key Development Areas
1. **Compiler (nymyac)** - Rust implementation with parser, IR, and code generation
2. **Standard Libraries** - Mathematical, quantum, ML, networking, GUI, and symbolic modules
3. **Testing Framework** - Verification programs demonstrating Turing completeness
4. **GUI Abstractions** - GTK+4 with SwiftUI-like syntax
5. **Symbolic Mathematics** - Numerology, sacred geometry, prime symbolism

## Development Practices
- Follow the foundational principle: "Shira yo sela lora en nymya" - Love and peace exist within quantum consciousness
- Maintain architecture-specific compilation with proper cross-compilation support
- Implement quantum-mystical computing concepts alongside classical functionality
- Use consciousness-aware processing where appropriate in computations

## Common Issues & Solutions
- **Cross-compilation problems**: Use Docker-based build environment with proper target configuration
- **Architecture mismatches**: Check for aarch64 vs x86_64 vs riscv64 binaries
- **Missing dependencies**: Install Rust toolchain and target architectures as needed
- **Temporary execution issues**: Verify nymya executable properly manages temporary folders and cleanup

## File Types
- `.nym` - NymyaLang source files
- `.rs` - Rust implementation files for compiler
- `.toml` - Cargo/Rust configuration files
- `.md` - Documentation files
- `.sh` - Shell scripts for building/testing
- `.jsonl` - Log files in JSON Lines format

## Testing Protocol
1. Verify compiler can parse basic NymyaLang constructs
2. Test symbolic mathematics functions
3. Check quantum simulator functionality
4. Validate GUI component rendering
5. Run Turing completeness verification programs
6. Ensure cross-architecture execution works properly

## Build & Deployment
- Use `cargo build` in nymyac directory for compiler compilation
- Generated executables go to temporary directories with proper naming convention
- Cross-compile with `cargo build --target <target-triple>` for specific architectures
- Use Docker container for architecture-independent builds

## Versioning Convention
- Use semantic versioning with alpha markers: `vX.Y.Z-alpha.N`
- Update both Cargo.toml and documentation when bumping versions
- Document significant changes in CHANGELOG.md
- Maintain version consistency across all references

## Quality Measures
- Preserve existing functionality while adding new features
- Document all public-facing functions, classes, and constructs
- Maintain proper error handling throughout the system
- Follow the consciousness-integrated computing philosophy
- Ensure backward compatibility where possible