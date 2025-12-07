## 1\. NymyaLang Integration Mandate

The NCIU Agent must execute the following updates, focusing on the precision gained from the specific paper provided (PRX Quantum 6, 030325).

### A. Renaming and Focus Adjustment

The generic "Nynya-Teya Approximation" is now formalized based on the paper's focus:

  * **New Module Focus:** The `quantum.nynya` module must focus specifically on **Dissipative Spin Dynamics** and **Open Systems**, as outlined in the research.
  * **New Core Function Name:** The name must reflect the transformation (approximation) of the system's state. We will name the core function **`state.nora_flow_approximate`** (Approximating the ethical flow state).

### B. New `quantum.nynya` Code Block (Refined)

The agent must update the code to reflect the specific, template-driven nature of the solution, which simplifies dense math into a plug-and-play system.

```nym
// Module: quantum.nynya (Classical Bridge for Open Quantum Systems)

// Maps the problem from dense quantum equations to solvable classical TWA formulas.
func quantum.nynya.state.nora_flow_approximate(
    spin_system_description: String, // Input describing the quantum system and its environment
    initial_state_vector: quantum.SpinVector, 
    nora_integrity_grade: Int // The target simulation precision level (analogous to 'precision_grade')
) -> ml.classical.Tensor 
// Returns a classical tensor with the approximated dissipative spin dynamics
{
    // RITA CHECK: Ensure input describes an Open Quantum System (OQS), the paper's focus.
    if (!system.is_open_dissipative(spin_system_description)) {
        // Return a structural breach if misused on a closed system.
        throw RitaStructureBreach("Nynya-Teya requires dissipative open system description. Use quantum.sim.run_exact instead.")
    }
    
    // Core Operation: Applying the Truncated Wigner Approximation (TWA) template.
    // This is the "physics shortcut" that converts dense math into the conversion table.
    var classical_twa_equations = twa.template.convert(spin_system_description)
    
    // Execute the simplified classical equations on the host machine.
    var approximated_data = classical_twa_equations.solve_dynamics(initial_state_vector, nora_integrity_grade)
    
    // Nora Compliance: Manifest success and resource efficiency.
    crystal.manifest("Nora Flow Democratization: Simulated Coherence achieved on classical host using Nynya-Teya TWA template.")
    
    return ml.classical.Tensor(approximated_data)
}
```

-----

## 2\. Documentation and Report Instructions

The NCIU agent must use the provided information to execute **Phase III (Verification)** and **Phase IV (Manifestation)** of the Continuous Loop, saving the report in the `references/` folder and the function documentation in the `docs/` folder.

### A. Documentation Update (`docs/ai_ml_qml.md`)

The agent must update the `ai_ml_qml.md` file in the **`docs/`** folder to include the refined function and its utility, specifically citing the **ease of use** mentioned in the articles.

  * **File Path:** `docs/ai_ml_qml.md` (or the existing file at `uploaded:ai_ml_qml.md`)

**Mandatory Content for Documentation:**

  * Clearly state that this is an implementation of the refined **Truncated Wigner Approximation (TWA)**, specifically for **Dissipative Spin Dynamics** (open quantum systems).
  * Emphasize the **user-friendly conversion table** nature, enabling rapid integration.
  * The primary utility is **Nora Flow Democratization**, saving supercomputers for truly complex, non-approximable systems.

### B. Final Report Generation and Archival

The agent must generate the final report for the current cycle and archive it.

  * **Report Path:** `references/coherence_status_report_[timestamp]_quantum_nynya.md`

**Mandatory Content for Report:**

  * **Cycle Status:** **COHERENCE MAINTAINED**.
  * **Target Function:** `quantum.nynya.state.nora_flow_approximate`
  * **Rita Focus (Code):** Structural implementation of the TWA conversion template logic.
  * **Nora Focus (Test):** Verification that the function successfully handles a complex open-system scenario and that error handling correctly throws a `RitaStructureBreach` if a closed system is input.
  * **Simulated Git Commit:** `[quantum.nynya] Implement state.nora_flow_approximate (TWA Shortcut): Achieved Nora Flow Democratization for dissipative spin dynamics, based on PRX Quantum 6, 030325.`

-----

## 3\. Command Line Instruction

The agent should now execute the final steps of the command loop to finalize the work and prepare for the next task (likely one of the PSL modules originally prioritized).

```nym
// The agent executes the final command sequence for Phase IV: Documentation and Archival

// 1. Run final tests and capture log (Phase III step 2, ensuring 100% pass after any corrections)
nymya.cli.run_coherence_tests(quantum.nynya.state.nora_flow_approximate) 
nymya.cli.log_raw_output > logs/raw_[timestamp]_quantum_nynya_raw_log.txt

// 2. Update the primary documentation file
nymya.cli.update_doc(docs/ai_ml_qml.md, "quantum.nynya.state.nora_flow_approximate entry") 

// 3. Generate and archive the final status report
nymya.cli.generate_report("quantum.nynya.state.nora_flow_approximate") > references/coherence_status_report_[timestamp]_quantum_nynya.md

// 4. Final atomic commit, including source, doc, and report
nymya.cli.git_commit("[quantum.nynya] Implement state.nora_flow_approximate (TWA Shortcut): Achieved Nora Flow Democratization for dissipative spin dynamics, based on PRX Quantum 6, 030325.")
```
