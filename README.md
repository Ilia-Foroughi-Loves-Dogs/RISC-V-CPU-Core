# RISC-V CPU Core

A SystemVerilog implementation of a small RV32I CPU core, built as a serious
portfolio project with readable RTL, directed tests, and implementation-focused
documentation.

Current status: **Phase 9 - Control Flow Improvements**

## Project Summary

This repository implements a 32-bit RISC-V CPU project for a focused subset of
the RV32I base integer ISA. It includes the original single-cycle core and a
first 5-stage pipelined core. The current design prioritizes clarity,
testability, and architectural correctness over performance.

The original single-cycle CPU remains preserved, and the 5-stage pipelined CPU
now includes hazard handling plus clearer branch, `jal`, and `jalr` control
flow behavior.

## Current Features

- Single-cycle RV32I CPU core
- Basic 5-stage pipelined RV32I CPU core
- Pipeline forwarding and load-use hazard detection
- 32-bit datapath
- 32-register register file
- x0 hardwired to zero
- ALU arithmetic and logic operations
- Immediate generator
- Control unit
- Instruction memory
- Data memory
- Branch and jump support, including pipelined `jal` and `jalr`
- Instruction-level test programs
- Makefile-based simulation workflow

## Features Implemented So Far

- Standalone datapath and control RTL modules under `rtl/`
- Integrated single-cycle core in `rtl/riscv_core.sv`
- Basic pipelined core in `rtl/riscv_pipelined_core.sv`
- Simple top-level wrapper in `rtl/riscv_top.sv`
- Simple pipelined top-level wrapper in `rtl/riscv_pipelined_top.sv`
- Module-level SystemVerilog testbenches under `tb/`
- Self-checking integrated CPU testbench
- Directed instruction programs under `tests/programs/`
- Simulation output organization under `sim/build/`, `sim/logs/`, and
  `sim/waves/`
- VCD waveform generation for the integrated core
- VCD waveform generation for the pipelined core

## Phase 9 Pipeline Status

A classic 5-stage pipeline is available:

```text
IF -> ID -> EX -> MEM -> WB
```

The original single-cycle CPU in `rtl/riscv_core.sv` is still the baseline
core and remains part of the regression. The pipeline uses dedicated pipeline
registers between stages and runs both the original NOP-padded
`tests/programs/pipeline_basic.mem` program and Phase 8 hazard programs.

Pipeline hazard and control-flow handling includes:

- `rtl/forwarding_unit.sv` selects EX/MEM or MEM/WB results for EX operands.
- `rtl/hazard_detection_unit.sv` detects load-use hazards and control hazards.
- Load-use hazards hold the PC and IF/ID register while inserting an ID/EX
  bubble.
- Taken branches and jumps flush younger wrong-path instructions.
- Store data uses forwarded `rs2` values when needed.
- Branch comparisons use forwarded operands in EX.
- `jal` writes `PC + 4`, redirects to the J-type target, and flushes the
  wrong path.
- `jalr` writes `PC + 4`, redirects to `(rs1 + imm) & ~1`, and uses forwarded
  `rs1` when needed.

The current pipeline keeps control flow simple and honest: it predicts not
taken, fetches sequentially, resolves branches and jumps in EX, and flushes
IF/ID plus ID/EX when the PC is redirected. There is no branch target buffer or
advanced branch prediction.

## Phase 9 Control-Flow Tests

New directed programs cover the pipelined branch and jump paths:

- `pipeline_branch_taken.mem`: forwarded `beq` operands, taken redirect, and
  wrong-path flush; expects `memory[20] = 42`.
- `pipeline_branch_not_taken.mem`: forwarded `beq` operands with sequential PC;
  expects `memory[24] = 42`.
- `pipeline_jal.mem`: `jal` link writeback and wrong-path flush; expects
  `x1 = 4` and `memory[28] = 42`.
- `pipeline_jalr.mem`: forwarded `jalr` base register, link writeback, target
  bit 0 clear behavior, and wrong-path flush; expects `x1 = 8` and
  `memory[32] = 42`.

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

The baseline CPU is a single-cycle Harvard-style RV32I core, and Phase 7 adds a
separate 5-stage pipelined core. Instruction memory and data memory are separate
simulation memories, which keeps the implementation simple and avoids structural
memory conflicts.

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

Run the pipelined CPU test:

```sh
make test-pipeline
```

Run the Phase 8 hazard tests:

```sh
make test-forwarding-unit
make test-hazard-unit
make test-pipeline-hazards
make test-all
```

Run the Phase 9 control-flow tests:

```sh
make test-pipeline-control-flow
make test-all
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

Generate the pipelined core waveform:

```sh
make wave-pipeline
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
- Phase 6 - Documentation and diagrams: complete
- Phase 7 - 5-stage pipeline upgrade: complete
- Phase 8 - Hazard detection and forwarding: current
- Phase 9 - Control flow improvements
- Phase 10 - Final polish and portfolio release

See [docs/development_plan.md](docs/development_plan.md) for the phase plan.

## Future Improvements

- Expand branch and jump handling for the pipelined design
- Add more automated assembly-to-memory-image tooling
- Add more waveform screenshots and exported diagrams
- Add broader verification coverage and regression reporting

## Portfolio Summary

This project demonstrates CPU architecture fundamentals, SystemVerilog RTL
design, module integration, instruction decoding, datapath control,
testbench-driven verification, waveform debugging, and technical documentation.
The current implementation is intentionally modest: it has a working
single-cycle RV32I subset core, a hazard-aware pipelined core, directed tests,
and documented limitations for future control-flow work.
