# RISC-V CPU Core

A portfolio-level RISC-V CPU core project written in SystemVerilog.

Current status: Phase 5 - Instruction Test Programs

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
- Phase 1 - ISA definition and CPU scope: complete
- Phase 2 - Core datapath modules: complete
- Phase 3 - Single-cycle CPU integration: complete
- Phase 4 - Simulation and testbench system: complete
- Phase 5 - Instruction test programs: current
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

The current simulation flow uses Icarus Verilog with `iverilog -g2012` and
`vvp`. Makefile targets compile simulations into `sim/build/`, write core logs
into `sim/logs/`, and write core waveforms into `sim/waves/`.

## Repository Structure

```text
RISC-V-CPU-Core/
├── docs/             # Architecture, ISA, control, testing, and planning docs
├── rtl/              # SystemVerilog RTL modules
├── tb/               # SystemVerilog testbenches
├── sim/              # Simulation build outputs, waveforms, and logs
├── tests/
│   └── programs/     # RISC-V assembly and machine-code test programs
├── scripts/          # Future helper scripts
├── Makefile
├── LICENSE
└── README.md
```

## Phase 2 Implemented Modules

Phase 2 adds standalone, reusable SystemVerilog blocks for the first
single-cycle CPU datapath:

- `program_counter`
- `register_file`
- `alu`
- `immediate_generator`
- `control_unit`
- `alu_control`
- `instruction_memory`
- `data_memory`

## Phase 3 Single-Cycle Core

Phase 3 integrates the Phase 2 blocks into `rtl/riscv_core.sv`, with
`rtl/riscv_top.sv` providing a simple wrapper. The CPU can now fetch and execute
a small program from instruction memory, perform register and ALU operations,
use word load/store through data memory, and update the PC for normal,
branch, and jump flows in the supported RV32I subset.

## Phase 5 Instruction Programs

Phase 5 adds directed instruction-level programs under `tests/programs/`.
Assembly files (`.asm`) are readable source listings with comments, while
memory files (`.mem`) contain 32-bit hexadecimal machine code loaded by the
testbench.

Instruction test categories:

- R-type ALU instructions
- I-type immediate instructions
- Load/store instructions
- Branch instructions
- Jump instructions
- Upper-immediate instructions
- A combined full-program test

## Running Simulations

Run all Phase 2 module-level tests:

```sh
make test-modules
```

Run the integrated single-cycle CPU test:

```sh
make test-core
```

Run all Phase 5 instruction program tests:

```sh
make test-programs
```

Run one self-checking instruction program:

```sh
make test-alu-program
```

Load a specific memory image through the core testbench:

```sh
make test-core PROGRAM=tests/programs/alu_tests.mem
```

Run the integrated CPU test and generate the waveform at
`sim/waves/riscv_core.vcd`:

```sh
make wave-core
```

Run all module tests, the integrated CPU test, and the instruction program
tests:

```sh
make test-all
```

Remove generated files from `sim/build/`, `sim/waves/`, and `sim/logs/` while
keeping the repository placeholder files:

```sh
make clean
```

## Future Improvements

- Add waveform-based debugging examples
- Add architecture diagrams for the datapath and control flow
- Add a 5-stage pipeline version of the CPU
- Add hazard detection, forwarding, stalls, and improved branch handling
- Prepare final documentation suitable for portfolio review
