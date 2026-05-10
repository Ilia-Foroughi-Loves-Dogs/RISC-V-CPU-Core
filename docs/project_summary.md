# Project Summary

## What the Project Is

RISC-V CPU Core is a SystemVerilog hardware design project that implements a
small RV32I-inspired 32-bit CPU. It includes a single-cycle core, a 5-stage
pipelined core, directed instruction programs, SystemVerilog testbenches, VCD
waveform output, and documentation intended for technical review.

The design is educational and simulation-oriented. It is not a full RISC-V
compliance implementation, but it demonstrates the major building blocks of a
simple integer CPU.

## Why It Was Built

The project was built as a portfolio-quality computer architecture project. The
main goal is to show the ability to design, integrate, test, debug, and document
a CPU core from reusable RTL modules through end-to-end instruction programs.

The repository is organized so another engineer, professor, or recruiter can
inspect the RTL, run the tests, read the architecture notes, and understand the
current scope without needing hidden tooling.

## Engineering Concepts Demonstrated

- RV32I instruction decoding
- Register file design with `x0` hardwired to zero
- ALU arithmetic, logical, shift, and compare operations
- Immediate generation for I, S, B, U, and J formats
- Single-cycle datapath and control design
- 5-stage pipeline organization
- Pipeline register design
- Data forwarding
- Load-use hazard detection and stalling
- Branch and jump flush handling
- Simulation memory models
- Directed testbench-based verification
- VCD waveform debugging
- Makefile-based simulation automation

## CPU Architectures Implemented

The repository contains two CPU implementations:

- `rtl/riscv_core.sv`: a single-cycle core used as the baseline architecture.
- `rtl/riscv_pipelined_core.sv`: a 5-stage pipelined core with IF, ID, EX, MEM,
  and WB stages.

The pipelined core keeps control flow simple. It predicts not taken, resolves
branches and jumps in EX, and flushes younger wrong-path instructions when the
PC is redirected.

## Verification Strategy

Verification is based on directed simulation:

- Standalone module testbenches check individual RTL blocks.
- Integrated CPU testbenches run instruction memory images.
- Directed instruction programs check supported instruction groups.
- Pipeline-specific tests check forwarding, load-use stalls, branch flushes,
  `jal`, and `jalr`.
- VCD waveforms support manual inspection of PC, instruction flow, writeback,
  stalls, flushes, and forwarding.

This approach is appropriate for the current project size and educational
scope. It does not replace full RISC-V compliance testing, constrained-random
verification, or formal proof.

## Testing Workflow

Run the full regression with:

```sh
make test-all
```

Common targeted commands:

```sh
make test-modules
make test-core
make test-programs
make test-pipeline
make test-pipeline-hazards
make test-pipeline-control-flow
```

See [testing.md](testing.md) for the complete test target list and debugging
workflow.

## Current Limitations

- Limited RV32I subset
- Simple simulation memory model
- Word-only `lw` and `sw`
- No caches
- No interrupts, exceptions, CSRs, or privilege modes
- No compressed instructions
- No multiplication, division, atomics, or floating point
- No formal verification yet
- Pipelined branch handling is simple predict-not-taken behavior

See [known_limitations.md](known_limitations.md) for more detail.

## Future Work

Future improvements could include full RV32I compliance testing, assembler
automation, Verilator support, cocotb tests, GitHub Actions CI, formal
verification with SymbiYosys, improved branch prediction, cache experiments,
bus interface support, FPGA synthesis support, peripherals, interrupts,
exceptions, and CSR support.
