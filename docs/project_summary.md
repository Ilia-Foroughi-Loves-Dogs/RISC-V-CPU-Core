# Project Summary

## What This Project Is

RISC-V CPU Core is a SystemVerilog implementation of a small single-cycle
RV32I processor. It supports a focused integer instruction subset, runs
directed machine-code programs in simulation, and includes documentation for
the architecture, datapath, control signals, instruction set, testing workflow,
and waveform inspection.

## Skills Demonstrated

- CPU datapath design
- RISC-V instruction decoding
- SystemVerilog RTL implementation
- Register file, ALU, immediate generator, and memory design
- Single-cycle control logic
- Branch and jump target handling
- Testbench-based verification
- Makefile-based simulation automation
- Waveform-oriented debugging
- Technical documentation for hardware projects

## Main Technical Accomplishments

- Implemented a 32-bit single-cycle RV32I subset CPU core.
- Integrated program counter, instruction memory, register file, immediate
  generator, control unit, ALU control, ALU, and data memory modules.
- Implemented register-register ALU, immediate ALU, load/store, branch, jump,
  `lui`, and `auipc` behavior.
- Preserved RISC-V `x0` behavior by hardwiring register zero to zero.
- Added directed instruction program tests for each supported instruction
  group.
- Added repeatable simulation targets for module tests, core tests, program
  tests, logs, and waveforms.

## Verification Approach

Verification is based on directed simulation:

- Module-level testbenches validate individual RTL blocks.
- The integrated CPU testbench executes instruction memory images.
- Instruction program tests check ALU, immediate, memory, branch, jump, upper
  immediate, and combined program behavior.
- Logs provide cycle-by-cycle traces.
- VCD waveforms support manual inspection of PC, instruction, ALU result, and
  writeback behavior.

This is an appropriate verification approach for the current project size. It
is not a substitute for full constrained-random verification or formal proof.

## Current Limitations

- Single-cycle CPU only
- No pipelining yet
- No hazard detection or forwarding yet
- No interrupts, exceptions, CSRs, or privilege modes
- No compressed instruction support
- No byte or halfword load/store support
- No caches or external bus interface
- Simulation-oriented memory model

## Planned Future Upgrades

- Convert the single-cycle core into a 5-stage pipeline.
- Add pipeline registers and stage-level debug visibility.
- Add hazard detection, forwarding, stalls, and flushes.
- Improve control-flow handling for pipeline correctness.
- Expand tooling around assembly-to-memory-image generation.
- Add more diagrams, waveform screenshots, and final portfolio polish.
