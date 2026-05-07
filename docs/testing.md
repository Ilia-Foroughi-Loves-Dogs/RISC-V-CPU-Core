# Testing

This document defines the testing workflow for the RISC-V CPU Core project.

## Testing Status

Phase 2 includes simple directed SystemVerilog testbenches for the standalone
datapath and control modules. Phase 3 adds a self-checking integrated CPU test
for the single-cycle core. Phase 4 organizes the simulation outputs, waveforms,
logs, and Makefile commands. Phase 5 adds directed instruction-level programs
for the supported RV32I subset.

## Running Tests

Run all current module-level tests with:

```sh
make test-modules
```

This runs the Phase 2 testbenches for the program counter, register file, ALU,
immediate generator, control unit, ALU control decoder, and data memory.

Run the integrated CPU test with:

```sh
make test-core
```

This compiles the single-cycle CPU and runs `tb/tb_riscv_core.sv`. The testbench
prints a cycle-by-cycle trace showing the cycle count, PC, instruction, ALU
result, and writeback data. The same output is saved to
`sim/logs/riscv_core.log`. It also performs final self-checks using `$error`.

Run all instruction program tests with:

```sh
make test-programs
```

Run one specific instruction program with its dedicated target:

```sh
make test-alu-program
```

or pass a program image directly for an execution trace:

```sh
make test-core PROGRAM=tests/programs/alu_tests.mem
```

Generate a waveform for the integrated CPU test with:

```sh
make wave-core
```

The waveform is written to:

```text
sim/waves/riscv_core.vcd
```

The integrated core log is written to:

```text
sim/logs/riscv_core.log
```

Compiled simulation outputs are placed in:

```text
sim/build/
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
- `make test-alu-program`
- `make test-immediate-program`
- `make test-load-store-program`
- `make test-branch-program`
- `make test-jump-program`
- `make test-upper-program`
- `make test-full-program`
- `make test-programs`

The Makefile uses Icarus Verilog with SystemVerilog support:

```sh
iverilog -g2012
```

Remove generated simulation files with:

```sh
make clean
```

This cleans generated files from `sim/build/`, `sim/waves/`, and `sim/logs/`
but keeps each directory's `.gitkeep` file.

## Test Categories

| Category | Planned Coverage |
| --- | --- |
| ALU instruction tests | R-type arithmetic, logical, shift, and compare instructions |
| Immediate instruction tests | I-type arithmetic, logical, shift, and compare instructions |
| Immediate generation tests | I-type, S-type, B-type, J-type, and U-type immediate extraction and sign extension |
| Register file tests | Register reads, register writes, write-enable behavior, and hardwired `x0` behavior |
| Load/store tests | `lw`, `sw`, address calculation, word alignment assumptions, and memory write enable behavior |
| Branch tests | Taken and not-taken behavior for `beq`, `bne`, `blt`, and `bge` |
| Jump tests | `jal`, `jalr`, link register writeback, target generation, and `jalr` bit-0 clearing |
| Full small program tests | Short instruction sequences that combine ALU, memory, branch, and jump behavior |

## Phase 5 Instruction Program Tests

The integrated CPU testbench loads `tests/programs/program.mem` by default.
The program can be changed with a plusarg:

```sh
vvp sim/build/tb_riscv_core.out +PROGRAM=tests/programs/alu_tests.mem
```

The Makefile wraps this flow with named targets.

The convention is:

- `.asm` files contain readable RISC-V assembly plus comments explaining the
  program.
- `.mem` files contain one 32-bit instruction word per line in hexadecimal.
- `.mem` files do not include comments, so the instruction memory loader can
  read them directly.

The basic arithmetic program is stored in:

- `tests/programs/basic_arithmetic.asm`
- `tests/programs/basic_arithmetic.mem`

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

Phase 5 adds these instruction program images:

| Program | How to run | What it checks |
| --- | --- | --- |
| `alu_tests.mem` | `make test-alu-program` | `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu` |
| `immediate_tests.mem` | `make test-immediate-program` | `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu` |
| `load_store_tests.mem` | `make test-load-store-program` | `sw`, `lw`, data memory writes and readback |
| `branch_tests.mem` | `make test-branch-program` | taken `beq`, `bne`, `blt`, and `bge` paths |
| `jump_tests.mem` | `make test-jump-program` | `jal`, `jalr`, link registers, and skipped instructions |
| `upper_tests.mem` | `make test-upper-program` | `lui` and `auipc` writeback behavior |
| `full_program_test.mem` | `make test-full-program` | arithmetic, immediate, load/store, branch, jump, and upper-immediate behavior together |

The core testbench performs final register or memory checks for each listed
program where the expected result is simple and deterministic. Expected final
values are documented in `tests/programs/README.md`.

## Verification Flow

The current verification flow includes:

1. Module-level testbenches for datapath blocks such as the ALU, register file,
   immediate generator, and control decoder.
2. Makefile targets to run repeatable simulations with Icarus Verilog.
3. Small self-checking tests using `$error` for failures.
4. An integrated single-cycle CPU test that runs a short machine-code program
   from instruction memory.

Later phases will add waveform inspection examples using GTKWave and broader
program-level verification as the CPU grows.
