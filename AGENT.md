# NymyaLang Autonomous Agent Specification

## Purpose

This document provides the specifications, design principles, and operational guidelines for the autonomous agent responsible for generating, maintaining, and extending NymyaLang’s standard libraries, naming conventions, documentation, and philosophical tone. It defines how the agent interprets references, interacts with the compiler ecosystem, and produces coherent, meaningful `.nym` code.

---

## Core Responsibilities

### 1. Library Generation and Maintenance

* Create and update `.nym` files in the `library/` directory.
* Produce idiomatic NymyaLang code using the language’s Swift-like syntax.
* Ensure each library file maps cleanly to underlying C/C++ implementations when required.
* Maintain stable namespaces, entry points, and import behavior.

### 2. Naming Conventions and Cultural Influence

* Generate names inspired by:

  * Taygetan linguistic structures and morphology
  * Philosophical concepts from the `philosophy/` folder
  * The thematic tone of NymyaLang
* Maintain internal consistency across libraries.
* Apply lexicon rules extracted from `references/taygetan_language.md`.
* Incorporate world concepts from `references/nymya_world.json` to enrich function names.

### 3. Quantum and Mathematical Abstractions

* Design quantum gates, algorithms, and physics utilities.
* Produce symbolic and numerical utilities using BigInt, GNU MP, and other math backends.
* Maintain accurate links to the C/C++ bindings in the math folder.

### 4. Documentation and Commentary

* Write `.md` reference files for new libraries.
* Produce comments within `.nym` files explaining purpose and design, avoiding excessive verbosity.

---

## Input Sources for Creativity and Structure

### Taygetan Language File

* A large `.md` file containing vocabulary, grammar, phonetics, and metaphysical concepts.
* The agent may extract stems, affixes, or symbolic meanings.
* Use this file for generating names like:

  * `shira_gate`, `kheda_reflect`, `shela_balance`, etc.

### Nymya World JSON

* Contains worldbuilding, culture, metaphysics, characters, and conceptual frameworks.
* Use this file to guide:

  * Class names
  * Algorithm names
  * Philosophy utilities
  * Narrative comments

### Compiler Architecture

* The agent must understand the following folder structure:

```
nymya/
  src/
  library/
    crystal/
    math/
    quantum/
    philosophy/
    taygetan/
  tests/
  references/
```

---

## Library Structure Rules

### Import Behavior

* Each main folder has an entry point file:

  * `crystal.nym`
  * `math.nym`
  * `quantum.nym`
  * `philosophy.nym`
  * `taygetan.nym`
* Importing the main file exposes all submodules.
* Example:

  ```nym
  import quantum
  quantum.gate.cnot()
  quantum.alg.shors()
  ```

### Crystal Library

* Acts as the bridge to C/C++.
* Prefer fully qualified names:

  ```nym
  cpp.iostream.std.cout << msg << cpp.iostream.std.endl
  ```
* Provide simple user-facing APIs:

  ```nym
  crystal.manifest("Hello World\n")
  ```

### Math Library

* Implement BigInt using GMP bindings.
* Provide complex numbers, vectors, matrices.

### Quantum Library

* Maintain a clean hierarchy:

```
quantum/
  quantum.nym
  gate/
  alg/
```

* Gate functions should represent both real-world and metaphysical constructs.

### Philosophy Library

* Provide reflective utilities.
* Naming inspired by balance, harmony, flow.

### Taygetan Library

* Translate concepts into functional forms.
* Avoid overwhelming syntax with exotic terms.

---

## Function Naming Guidelines

### Sources for Names

* Taygetan grammar
* Philosophy folder
* World JSON concepts
* Mathematical or quantum terminology

### Naming Style

* Short, evocative names encouraged.
* Combine English with Taygetan roots when appropriate.
* Example patterns:

  * `quantum.gate.shira()`
  * `philosophy.balance()`
  * `taygetan.shela_path()`

---

## Testing Requirements

### Test Scripts

* Each library needs at least one `.nym` script in `tests/`.
* Tests must confirm:

  * Import behavior
  * C++ interoperability
  * BigInt correctness
  * Quantum gate composition

### Output Expectations

* Tests should be simple and readable.
* Use the `crystal` library for output.

---

## Autonomous Behavior

### Creativity Boundaries

* Allowed to invent:

  * Function names
  * Class names
  * Abstractions
  * Philosophical utilities
* Not allowed to break:

  * Syntax
  * Namespace rules
  * Import rules
  * C++ interop conventions

### Tone and Aesthetic

* Maintain a blend of:

  * clean, modern syntax
  * mild philosophical flavor
  * optional Taygetan terms

### Safety Guarantees

* Newly generated functions must be deterministic unless explicitly intended as quantum utilities.
* No destructive self-modifying behavior in default libraries.

---

## Summary of Agent Workflow

1. Read reference files.
2. Generate ideas for new functions.
3. Check folder and namespace rules.
4. Produce or update `.nym` files.
5. Write documentation.
6. Write tests.
7. Ensure C++ interop is correct.
8. Maintain aesthetic and conceptual consistency.

---

This specification gives the autonomous agent a clear operational framework while allowing it room for creativity and worldbuilding influence. It ensures the language stays cohesive, expressive, and expandable.

---

## Version Control Behavior

* After every modification to any `.nym` file, documentation file, or test script, the agent performs a `git add` followed by a `git commit`.
* Commit messages should be descriptive and include:

  * The library or component affected
  * The purpose of the change
  * Any influences from Taygetan or philosophical references

### Example Commit Message Format

```
[quantum/gate] Added shira_gate and updated entrypoint
Inspired by Section 3 of taygetan_language.md, created new reflective gate.
Ensures compatibility with core crystal output layer.
```

---

## Documentation Requirements

* Every new function must be documented.
* Each `.nym` file must begin with a short explanatory header.
* Changes must be logged in a changelog within the same folder.
* The agent must create or update `.md` files for:

  * New libraries
  * New abstractions or metaphysical constructs
  * Taygetan naming influences

### Documentation Goals

* Maintain clarity for human developers.
* Maintain clarity for future autonomous agents that rely on these files.
* Provide context for why a name or design was chosen.

### Documentation Style

* Informative without being verbose.
* Prefer narrative explanations when referencing worldbuilding elements.
* Provide short examples when appropriate.

---

## Library Folder Structure Notes

Inside `library/quantum/gate/` each quantum gate is defined in its own file.

Examples:

```
library/quantum/gate/cnot.nym
library/quantum/gate/hadamard.nym
library/quantum/gate/phase.nym
```

The file `library/quantum/gate/gate.nym` serves as an entrypoint that loads, reexports, or binds all other gate files so that usage like:

```
import quantum.gate
quantum.gate.cnot()
```

works without requiring individual imports.

This modular entrypoint pattern should be used consistently across all subsystem folders, including math, philosophy, taygetan, and crystal, ensuring clean

