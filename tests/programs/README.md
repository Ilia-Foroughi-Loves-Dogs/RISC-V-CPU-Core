# Instruction Test Programs

This directory contains human-readable RISC-V assembly programs and matching
machine-code memory images for the single-cycle RV32I CPU testbench.

- `.asm` files are commented source listings for people to read.
- `.mem` files contain one 32-bit hexadecimal instruction per line and are
  loaded by the simulation through the instruction memory.
- `.mem` files intentionally have no comments.

## Programs

| Program | Checks | Expected final behavior |
| --- | --- | --- |
| `program.asm` / `program.mem` | Default core smoke test | `x3 = 12`, `memory[0] = 12`, `x4 = 12`, `x5 = 7` |
| `basic_arithmetic.asm` / `basic_arithmetic.mem` | Same sequence as the default program | `x3 = 12`, `memory[0] = 12`, `x4 = 12`, `x5 = 7` |
| `alu_tests.asm` / `alu_tests.mem` | R-type `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu` | `x5..x14` hold the directed ALU results checked by the testbench |
| `immediate_tests.asm` / `immediate_tests.mem` | I-type `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu` | `x3..x11` hold the directed immediate-operation results |
| `load_store_tests.asm` / `load_store_tests.mem` | `sw`, `lw`, word addressing, load data writeback | `memory[0] = 42`, `memory[1] = -7`, `x2 = 42`, `x4 = -7`, `x5 = 35` |
| `branch_tests.asm` / `branch_tests.mem` | Taken `beq`, `bne`, `blt`, `bge` branches | skipped writes are bypassed; `x10 = 11`, `x11 = 22`, `x12 = 33`, `x13 = 44` |
| `jump_tests.asm` / `jump_tests.mem` | `jal`, `jalr`, link register writeback, target selection | `x1 = 4`, `x2 = 20`, `x5 = 55`, `x6 = 24`, `x7 = 77` |
| `upper_tests.asm` / `upper_tests.mem` | `lui`, `auipc` | `x1 = 0x12345000`, `x2 = 0x00001004`, `x3 = 0x12346004` |
| `full_program_test.asm` / `full_program_test.mem` | Arithmetic, immediate operations, load/store, branch, jump, and `auipc` | `memory[0] = 13`, `x4 = 13`, `x5 = 13`, `x6 = 9`, `x7 = 11`, `x8 = 44`, `x9 = 48` |
| `pipeline_branch_taken.asm` / `pipeline_branch_taken.mem` | Pipelined taken `beq`, forwarded branch operands, and wrong-path flush | `x3 = 42`, `memory[20] = 42` |
| `pipeline_branch_not_taken.asm` / `pipeline_branch_not_taken.mem` | Pipelined not-taken `beq` with forwarded branch operands | `x3 = 42`, `memory[24] = 42` |
| `pipeline_jal.asm` / `pipeline_jal.mem` | Pipelined `jal`, link register writeback, target redirect, and wrong-path flush | `x1 = 4`, `x3 = 42`, `memory[28] = 42` |
| `pipeline_jalr.asm` / `pipeline_jalr.mem` | Pipelined `jalr`, forwarded base register, link register writeback, target redirect, and wrong-path flush | `x1 = 8`, `x3 = 42`, `x5 = 12`, `memory[32] = 42` |

Run all instruction programs with:

```sh
make test-programs
```

Run one self-checking program directly with:

```sh
make test-alu-program
```

Run the Phase 9 pipelined control-flow programs with:

```sh
make test-pipeline-control-flow
```

You can also load an arbitrary program image through the core testbench. This
prints the execution trace and disables built-in final checks unless a matching
`+CHECK_*` flag is supplied to `vvp`.

```sh
make test-core PROGRAM=tests/programs/alu_tests.mem
```
