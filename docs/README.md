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
- [waveforms.md](waveforms.md): VCD generation and suggested signals to inspect.
- [demo.md](demo.md): Short command-line demo guide.

## Portfolio and Planning

- [project_summary.md](project_summary.md): Polished summary of goals,
  architecture, verification, and scope.
- [known_limitations.md](known_limitations.md): Honest limitations of the
  current design.
- [future_work.md](future_work.md): Possible post-release improvements.
- [development_plan.md](development_plan.md): Project phase history and final
  Phase 10 status.
