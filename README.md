# RISC-V CPU Core

A portfolio-level RISC-V CPU core project written in Verilog/SystemVerilog.
The project will start with a clear, testable RV32I single-cycle processor and
grow into a more complete CPU design with structured documentation,
simulation support, and verification infrastructure.

## Project Goals

- Build a clean and understandable RV32I CPU core from the ground up.
- Keep the design modular, documented, and easy to simulate.
- Develop a strong verification workflow using testbenches and small RISC-V
  programs.
- Create a professional hardware project suitable for portfolio review.
- Grow the design in phases instead of implementing every feature at once.

## Planned Architecture

The first implementation target is a single-cycle RV32I CPU. This version will
focus on correctness, readability, and a clear datapath/control structure.

After the single-cycle core is working and tested, the project will evolve into
a classic 5-stage pipeline:

1. Instruction Fetch
2. Instruction Decode
3. Execute
4. Memory
5. Write Back

Pipeline hazards, forwarding, stalls, branches, and memory behavior will be
added in later phases.

## Planned Phases

- Phase 0: Project setup, repository structure, and starter documentation.
- Phase 1: ISA notes, architecture planning, and test strategy.
- Phase 2: Single-cycle RV32I datapath and control implementation.
- Phase 3: Testbench development and directed instruction tests.
- Phase 4: Program-level simulation tests.
- Phase 5: 5-stage pipeline implementation.
- Phase 6: Hazard handling, forwarding, and branch support.
- Phase 7: Cleanup, documentation polish, and optional FPGA preparation.

## Toolchain

The project is intended to work with common open-source and industry hardware
development tools, including:

- Icarus Verilog or Verilator for simulation
- GTKWave for waveform viewing
- GNU Make for repeatable commands
- A RISC-V GNU toolchain for assembling or compiling test programs
- Optional commercial simulators if available

Exact tool versions and setup instructions will be documented as the project
develops.

## Repository Structure

```text
RISC-V-CPU-Core/
├── rtl/              # RTL SystemVerilog design modules
├── tb/               # Testbenches
├── sim/              # Simulation outputs and simulator configuration
├── docs/             # Architecture, ISA, and testing documentation
├── tests/
│   └── programs/     # RISC-V machine-code test programs
├── scripts/          # Helper scripts
├── README.md
├── LICENSE
├── .gitignore
└── Makefile
```

## Current Status

Phase 0 - Project Setup

The repository structure, starter documentation, simulation folders, and basic
project files are being created. No CPU implementation files have been added
yet.

## Future Improvements

- Add detailed RV32I instruction documentation.
- Define the single-cycle CPU block diagram and module boundaries.
- Add assembler or binary loading flow for test programs.
- Add automated simulation targets.
- Add directed and program-level tests.
- Add waveform generation and debugging documentation.
- Extend the design into a 5-stage pipelined CPU.
