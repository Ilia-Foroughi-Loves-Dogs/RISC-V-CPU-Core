# RISC-V CPU Core

A portfolio-level RISC-V CPU core project written in SystemVerilog.

Current status: Phase 1 - ISA Definition and CPU Scope

## Project Overview

This project will build a clear, testable RISC-V CPU core from the ground up.
The first implementation target is intentionally small: a 32-bit single-cycle
RV32I processor with a documented instruction subset, simple memory model, and
focused verification plan.

The project is organized in phases so the architecture, instruction behavior,
control signals, test strategy, and implementation can be developed in a
controlled way.

## Initial CPU Target

The initial hardware target is a 32-bit single-cycle RV32I CPU core.

Key scope decisions:

- 32-bit data path and instruction width
- 32 general-purpose registers, each 32 bits wide
- Register `x0` hardwired to zero
- Separate instruction memory and data memory for simpler first integration
- Little-endian memory assumption
- Word load and word store support only in the first version
- No interrupts, exceptions, CSR support, privilege modes, compressed
  instructions, caches, or virtual memory in the first version

The single-cycle design will prioritize correctness and readability before
performance.

## Future CPU Target

After the single-cycle CPU is implemented and tested, the project will evolve
into a classic 5-stage pipelined RV32I core:

1. Instruction Fetch
2. Instruction Decode
3. Execute
4. Memory
5. Write Back

Pipeline hazards, forwarding, stalls, control-flow handling, and performance
improvements will be added in later phases.

## Supported Instruction Subset

The initial CPU will support a practical subset of RV32I:

- R-type ALU: `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`,
  `sltu`
- I-type ALU: `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`,
  `sltiu`
- Load/store: `lw`, `sw`
- Branch: `beq`, `bne`, `blt`, `bge`
- Jump: `jal`, `jalr`
- Upper immediate: `lui`, `auipc`

See [docs/instruction_set.md](docs/instruction_set.md) for instruction formats,
encodings, and behavior notes.

## Project Phases

- Phase 0 - Project setup: complete
- Phase 1 - ISA definition and CPU scope: current
- Phase 2 - Core datapath modules
- Phase 3 - Single-cycle CPU integration
- Phase 4 - Simulation and testbench system
- Phase 5 - Instruction test programs
- Phase 6 - Documentation and diagrams
- Phase 7 - 5-stage pipeline upgrade
- Phase 8 - Hazard detection and forwarding
- Phase 9 - Control flow improvements
- Phase 10 - Final polish and portfolio release

See [docs/development_plan.md](docs/development_plan.md) for the full plan.

## Toolchain

The project is intended to use common hardware design tools:

- SystemVerilog for RTL implementation
- Icarus Verilog or Verilator for simulation
- GTKWave for waveform inspection
- GNU Make for repeatable build and simulation commands
- RISC-V GNU toolchain for assembling test programs in later phases

Exact simulator commands and tool versions will be documented as the
implementation and test flow are added.

## Repository Structure

```text
RISC-V-CPU-Core/
├── docs/             # Architecture, ISA, control, testing, and planning docs
├── rtl/              # Future SystemVerilog RTL modules
├── tb/               # Future testbenches
├── sim/              # Future simulation outputs and simulator configuration
├── tests/
│   └── programs/     # Future RISC-V assembly or machine-code tests
├── scripts/          # Future helper scripts
├── Makefile
├── LICENSE
└── README.md
```

## How to Run Tests

Automated CPU tests are not implemented yet. Testbenches and instruction-level
program tests will be added in later phases after the datapath modules exist.

For now, the repository contains planning documentation only for the CPU scope
and initial ISA subset.

## Future Improvements

- Implement the single-cycle datapath and control unit
- Add focused module-level testbenches
- Add instruction-level and small-program simulation tests
- Add waveform-based debugging examples
- Add architecture diagrams for the datapath and control flow
- Add a 5-stage pipeline version of the CPU
- Add hazard detection, forwarding, stalls, and improved branch handling
- Prepare final documentation suitable for portfolio review
