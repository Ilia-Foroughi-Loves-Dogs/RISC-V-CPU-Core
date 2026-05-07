# Testing

This document defines the Phase 1 testing plan for the RISC-V CPU Core project.
Actual SystemVerilog testbenches and executable instruction tests will be added
in later phases after the datapath modules and integrated CPU exist.

## Phase 1 Testing Status

No hardware testbenches are implemented yet. During Phase 1, testing work is
limited to planning the categories of behavior that must be verified once RTL
implementation begins.

## Planned Test Categories

| Category | Planned Coverage |
| --- | --- |
| ALU instruction tests | R-type and I-type arithmetic, logical, shift, and compare instructions |
| Immediate generation tests | I-type, S-type, B-type, J-type, and U-type immediate extraction and sign extension |
| Register file tests | Register reads, register writes, write-enable behavior, and hardwired `x0` behavior |
| Load/store tests | `lw`, `sw`, address calculation, word alignment assumptions, and memory write enable behavior |
| Branch tests | Taken and not-taken behavior for `beq`, `bne`, `blt`, and `bge` |
| Jump tests | `jal`, `jalr`, link register writeback, target generation, and `jalr` bit-0 clearing |
| Full small program tests | Short instruction sequences that combine ALU, memory, branch, and jump behavior |

## Planned Verification Flow

The first verification flow will likely include:

1. Module-level testbenches for datapath blocks such as the ALU, register file,
   immediate generator, and control decoder.
2. Directed instruction tests for each supported instruction.
3. Small hand-written RISC-V programs loaded into instruction memory.
4. Waveform inspection using GTKWave for debugging.
5. Makefile targets to run repeatable simulations.

## Later Testbench Work

Future phases will add actual testbench code under `tb/`, instruction programs
under `tests/programs/`, and simulator output handling under `sim/`.

Until those phases begin, this repository intentionally contains documentation
only for the test strategy.
