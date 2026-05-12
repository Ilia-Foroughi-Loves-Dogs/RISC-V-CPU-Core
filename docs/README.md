# Documentation Index

This directory contains the main technical documentation for the RISC-V CPU
Core project.

## Architecture and RTL

- [architecture.md](architecture.md): CPU organization, datapath blocks,
  memory model, and pipeline overview.
- [datapath.md](datapath.md): Single-cycle datapath signal flow.
- [pipeline.md](pipeline.md): 5-stage pipeline, hazards, forwarding, stalls,
  and flushes.
- [instruction_set.md](instruction_set.md): Supported RV32I instruction subset
  and encoding notes.
- [control_signals.md](control_signals.md): Main control signals and decode
  behavior.

## Simulation and Debug

- [testing.md](testing.md): Makefile targets, test programs, `.asm`/`.mem`
  workflow, logs, and debugging tips.
- [assembler_workflow.md](assembler_workflow.md): Generating and verifying
  simulation `.mem` files from readable assembly programs.
- [verilator.md](verilator.md): Verilator lint targets, installation, and CI
  integration.
- [cocotb.md](cocotb.md): Python-based cocotb verification setup, targets,
  and CI integration.
- [formal_verification.md](formal_verification.md): Optional SymbiYosys/Yosys
  formal checks for selected RTL modules.
- [gui.md](gui.md): Desktop GUI helper for running common Makefile simulation,
  verification, waveform, and cleanup commands.
- [ci.md](ci.md): GitHub Actions CI workflow, triggers, commands, and
  debugging notes.
- [waveforms.md](waveforms.md): VCD generation and suggested signals to inspect.
- [demo.md](demo.md): Short command-line demo guide.

## Portfolio and Planning

- [project_summary.md](project_summary.md): Polished summary of goals,
  architecture, verification, and scope.
- [known_limitations.md](known_limitations.md): Honest limitations of the
  current design.
- [future_work.md](future_work.md): Possible post-release improvements.
- [development_plan.md](development_plan.md): Project phase history and current
  Phase 16 desktop GUI simulator status.
