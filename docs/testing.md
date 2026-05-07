# Testing

This document defines the testing plan and current module-level test flow for
the RISC-V CPU Core project.

## Phase 2 Testing Status

Phase 2 includes simple directed SystemVerilog testbenches for the standalone
datapath and control modules. The full CPU is not integrated yet, so current
tests focus on individual module behavior.

## Running Tests

Run all current module-level tests with:

```sh
make test-modules
```

Individual test targets are also available:

- `make test-pc`
- `make test-regfile`
- `make test-alu`
- `make test-immgen`
- `make test-control`
- `make test-alu-control`
- `make test-dmem`

The Makefile uses Icarus Verilog with SystemVerilog support:

```sh
iverilog -g2012
```

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

## Verification Flow

The current verification flow includes:

1. Module-level testbenches for datapath blocks such as the ALU, register file,
   immediate generator, and control decoder.
2. Makefile targets to run repeatable simulations with Icarus Verilog.
3. Small self-checking tests using `$error` for failures.

Later phases will add:

- Directed instruction tests for each supported instruction.
- Small hand-written RISC-V programs loaded into instruction memory.
- Full single-cycle CPU integration tests.
- Waveform inspection examples using GTKWave.
