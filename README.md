# RISC-V CPU Core

A SystemVerilog implementation of a small RV32I CPU core, built as a serious
portfolio project with readable RTL, directed tests, and implementation-focused
documentation.

Current status: **Phase 6 - Documentation and Diagrams**

## Project Summary

This repository implements a 32-bit single-cycle RISC-V CPU core for a focused
subset of the RV32I base integer ISA. The current design prioritizes clarity,
testability, and architectural correctness over performance. It is intended to
show the full path from ISA scope definition through datapath modules, CPU
integration, simulation, instruction-level tests, and documentation.

The CPU is not pipelined yet. Hazard detection, forwarding, stalls, caches,
interrupts, exceptions, CSRs, privilege modes, and compressed instructions are
planned or out of scope for later phases.

## Current Features

- Single-cycle RV32I CPU core
- 32-bit datapath
- 32-register register file
- x0 hardwired to zero
- ALU arithmetic and logic operations
- Immediate generator
- Control unit
- Instruction memory
- Data memory
- Branch and jump support
- Instruction-level test programs
- Makefile-based simulation workflow

## Features Implemented So Far

- Standalone datapath and control RTL modules under `rtl/`
- Integrated single-cycle core in `rtl/riscv_core.sv`
- Simple top-level wrapper in `rtl/riscv_top.sv`
- Module-level SystemVerilog testbenches under `tb/`
- Self-checking integrated CPU testbench
- Directed instruction programs under `tests/programs/`
- Simulation output organization under `sim/build/`, `sim/logs/`, and
  `sim/waves/`
- VCD waveform generation for the integrated core

## Supported RV32I Instruction Subset

| Group | Instructions |
| --- | --- |
| R-type ALU | `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu` |
| I-type ALU | `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu` |
| Memory | `lw`, `sw` |
| Branch | `beq`, `bne`, `blt`, `bge` |
| Jump | `jal`, `jalr` |
| Upper immediate | `lui`, `auipc` |

See [docs/instruction_set.md](docs/instruction_set.md) for formats, opcodes,
`funct3`/`funct7` values, behavior, and immediate encoding notes.

## Repository Structure

```text
RISC-V-CPU-Core/
├── docs/             # Architecture, datapath, ISA, control, testing, and planning docs
├── rtl/              # SystemVerilog RTL modules
├── tb/               # SystemVerilog testbenches
├── sim/              # Generated simulation outputs, logs, and waveforms
├── tests/
│   └── programs/     # Assembly listings and .mem instruction images
├── scripts/          # Placeholder for future helper scripts
├── Makefile          # Repeatable simulation workflow
├── LICENSE
└── README.md
```

## Architecture Overview

The current CPU is a single-cycle Harvard-style RV32I core. Instruction memory
and data memory are separate simulation memories, which keeps the first
implementation simple and avoids structural memory conflicts.

High-level flow:

```text
PC -> Instruction Memory -> Decode -> Register File -> ALU -> Data Memory -> Writeback
```

In one clock cycle, the core fetches the instruction at the current PC, decodes
the instruction fields, reads source registers, generates an immediate, selects
ALU operands, executes the operation or computes an address, optionally accesses
data memory, selects writeback data, and computes the next PC. Register and data
memory writes commit on the rising clock edge.

More detail:

- [docs/architecture.md](docs/architecture.md) describes the CPU organization.
- [docs/datapath.md](docs/datapath.md) describes signal flow through the core.
- [docs/control_signals.md](docs/control_signals.md) documents main control
  signals and decode behavior.

## How to Run Tests

Run all module tests, the integrated core test, and all instruction programs:

```sh
make test-all
```

Run only module-level tests:

```sh
make test-modules
```

Run the integrated single-cycle CPU test:

```sh
make test-core
```

Run all instruction program tests:

```sh
make test-programs
```

Run a specific instruction program:

```sh
make test-alu-program
make test-immediate-program
make test-load-store-program
make test-branch-program
make test-jump-program
make test-upper-program
make test-full-program
```

Load a specific memory image through the core testbench:

```sh
make test-core PROGRAM=tests/programs/alu_tests.mem
```

See [docs/testing.md](docs/testing.md) for the full testing workflow.

## How to Generate Waveforms

Run:

```sh
make wave-core
```

The core waveform is written to:

```text
sim/waves/riscv_core.vcd
```

Open it with GTKWave:

```sh
gtkwave sim/waves/riscv_core.vcd
```

See [docs/waveforms.md](docs/waveforms.md) for useful signals to inspect.

## Toolchain Requirements

- SystemVerilog-capable simulator flow
- Icarus Verilog with SystemVerilog support (`iverilog -g2012`)
- `vvp`
- GNU Make
- GTKWave for VCD waveform inspection

The current `.mem` files are checked into the repository. A RISC-V GNU
toolchain is useful for future assembly automation, but it is not required to
run the existing tests.

## Development Phases

- Phase 0 - Project setup: complete
- Phase 1 - ISA definition and CPU scope: complete
- Phase 2 - Core datapath modules: complete
- Phase 3 - Single-cycle CPU integration: complete
- Phase 4 - Simulation and testbench system: complete
- Phase 5 - Instruction test programs: complete
- Phase 6 - Documentation and diagrams: current
- Phase 7 - 5-stage pipeline upgrade
- Phase 8 - Hazard detection and forwarding
- Phase 9 - Control flow improvements
- Phase 10 - Final polish and portfolio release

See [docs/development_plan.md](docs/development_plan.md) for the phase plan.

## Future Improvements

- Add a 5-stage pipeline version of the CPU
- Add pipeline registers, hazard detection, forwarding, stalls, and flushes
- Expand branch and jump handling for the pipelined design
- Add more automated assembly-to-memory-image tooling
- Add more waveform screenshots and exported diagrams
- Add broader verification coverage and regression reporting

## Portfolio Summary

This project demonstrates CPU architecture fundamentals, SystemVerilog RTL
design, module integration, instruction decoding, datapath control,
testbench-driven verification, waveform debugging, and technical documentation.
The current implementation is intentionally modest: it is a working
single-cycle RV32I subset core with directed tests, not yet a pipelined or
production-grade processor.
