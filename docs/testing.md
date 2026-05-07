# Testing

This document defines the testing plan and current module-level test flow for
the RISC-V CPU Core project.

## Phase 2 Testing Status

Phase 2 includes simple directed SystemVerilog testbenches for the standalone
datapath and control modules. Phase 3 adds a self-checking integrated CPU test
for the single-cycle core.

## Running Tests

Run all current module-level tests with:

```sh
make test-modules
```

Run the integrated CPU test with:

```sh
make test-core
```

Generate a waveform for the integrated CPU test with:

```sh
make wave-core
```

The waveform is written to:

```text
sim/riscv_core.vcd
```

Individual test targets are also available:

- `make test-pc`
- `make test-regfile`
- `make test-alu`
- `make test-immgen`
- `make test-control`
- `make test-alu-control`
- `make test-dmem`
- `make test-core`

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

## Integrated CPU Test Program

The integrated CPU testbench loads `tests/programs/program.mem` through the
instruction memory. The matching assembly source is in
`tests/programs/program.asm`.

The program executes:

1. `addi x1, x0, 5`
2. `addi x2, x0, 7`
3. `add x3, x1, x2`
4. `sw x3, 0(x0)`
5. `lw x4, 0(x0)`
6. `sub x5, x4, x1`

At a high level, the expected result is that `x3` becomes 12, data memory word
0 stores 12, `x4` loads 12 back from memory, and `x5` becomes 7. The testbench
uses `$error` if these final checks fail and prints PC, instruction, ALU result,
and writeback data while the program runs.

## Verification Flow

The current verification flow includes:

1. Module-level testbenches for datapath blocks such as the ALU, register file,
   immediate generator, and control decoder.
2. Makefile targets to run repeatable simulations with Icarus Verilog.
3. Small self-checking tests using `$error` for failures.
4. An integrated single-cycle CPU test that runs a short machine-code program
   from instruction memory.

Later phases will add:

- Directed instruction tests for each supported instruction.
- Small hand-written RISC-V programs loaded into instruction memory.
- Waveform inspection examples using GTKWave.
