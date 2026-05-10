# Testing

This document explains the simulation and verification workflow for the
single-cycle and Phase 9 pipelined RISC-V CPU cores.

## Required Tools

- GNU Make
- Icarus Verilog with SystemVerilog support (`iverilog -g2012`)
- `vvp`
- GTKWave for waveform viewing

The existing `.mem` files are already checked in. A RISC-V assembler is useful
for future automation, but it is not required for the current test flow.

## How to Run All Tests

Run the full regression:

```sh
make test-all
```

This runs:

- All module-level tests
- The integrated core test
- All directed instruction program tests
- The pipelined core test
- The Phase 8 pipeline hazard tests
- The Phase 9 pipeline control-flow tests

## How to Run Module Tests

Run all standalone module tests:

```sh
make test-modules
```

Individual module targets:

| Target | Testbench | Main RTL under test |
| --- | --- | --- |
| `make test-pc` | `tb/tb_program_counter.sv` | `rtl/program_counter.sv` |
| `make test-regfile` | `tb/tb_register_file.sv` | `rtl/register_file.sv` |
| `make test-alu` | `tb/tb_alu.sv` | `rtl/alu.sv` |
| `make test-immgen` | `tb/tb_immediate_generator.sv` | `rtl/immediate_generator.sv` |
| `make test-control` | `tb/tb_control_unit.sv` | `rtl/control_unit.sv` |
| `make test-alu-control` | `tb/tb_alu_control.sv` | `rtl/alu_control.sv` |
| `make test-dmem` | `tb/tb_data_memory.sv` | `rtl/data_memory.sv` |
| `make test-forwarding-unit` | `tb/tb_forwarding_unit.sv` | `rtl/forwarding_unit.sv` |
| `make test-hazard-unit` | `tb/tb_hazard_detection_unit.sv` | `rtl/hazard_detection_unit.sv` |

## How to Run the Core Test

Run the integrated single-cycle CPU test:

```sh
make test-core
```

This compiles the core RTL with `tb/tb_riscv_core.sv`, loads the default program
image, prints an execution trace, and performs final self-checks.

Load a different program image through the core testbench:

```sh
make test-core PROGRAM=tests/programs/alu_tests.mem
```

When `PROGRAM=...` is passed to `make test-core`, the Makefile also passes
`+CHECK_NONE`, so the testbench runs the trace without applying a mismatched
built-in final check.

## How to Run the Pipelined Core Test

Run the pipelined CPU test:

```sh
make test-pipeline
```

This compiles `rtl/riscv_pipelined_core.sv` with its pipeline registers and
`tb/tb_riscv_pipelined_core.sv`. The test loads:

```text
tests/programs/pipeline_basic.mem
```

The testbench prints a cycle trace with IF PC, ID instruction, EX ALU result,
MEM ALU result, WB writeback data, stall, flush, and forwarding debug signals.
It checks that the program writes the expected register and memory values.

`pipeline_basic.asm` tests basic pipelined execution with:

- `addi` into `x1`
- `addi` into `x2`
- `add x3, x1, x2`
- `sw x3, 4(x0)`
- `lw x4, 4(x0)`

NOPs remain in this legacy program so it continues to exercise the original
Phase 7-style flow. Phase 8 adds separate programs that remove many manual NOPs.

## How to Run Pipeline Hazard Tests

Run the forwarding unit test:

```sh
make test-forwarding-unit
```

Run the hazard detection unit test:

```sh
make test-hazard-unit
```

Run all Phase 8 pipeline hazard tests:

```sh
make test-pipeline-hazards
```

Run individual pipelined hazard programs:

```sh
make test-pipeline-forwarding
make test-pipeline-load-use
make test-pipeline-branch-flush
```

The same pipelined testbench can load any checked-in program image with:

```sh
make test-pipeline PROGRAM=tests/programs/pipeline_forwarding.mem
```

## How to Run Pipeline Control-Flow Tests

Run all Phase 9 pipeline control-flow tests:

```sh
make test-pipeline-control-flow
```

Run individual control-flow programs:

```sh
make test-pipeline-branch-taken
make test-pipeline-branch-not-taken
make test-pipeline-jal
make test-pipeline-jalr
```

These targets use the same `tb/tb_riscv_pipelined_core.sv` testbench and
`+PROGRAM=tests/programs/name.mem` plusarg. The trace prints IF PC, next PC, ID
instruction, EX/MEM/WB values, stall, flush, branch taken, jump taken, branch
target, jump target, and forwarding select signals.

Interpretation notes:

- A taken branch or jump should show `fl = 1` while IF/ID and ID/EX are flushed.
- `br = 1` means the EX-stage branch condition was true.
- `jp = 1` means an EX-stage `jal` or `jalr` redirected the PC.
- `pc_next` should match the printed branch or jump target on a redirect.
- The final self-checks verify the expected register and data memory state.

The Phase 9 programs check:

| Program | What it checks | Expected behavior |
| --- | --- | --- |
| `pipeline_branch_taken.mem` | Forwarded `beq` operands, taken branch redirect, wrong-path flush | `x3 = 42`, `memory[20] = 42` |
| `pipeline_branch_not_taken.mem` | Forwarded `beq` operands with sequential PC | `x3 = 42`, `memory[24] = 42` |
| `pipeline_jal.mem` | `jal` target selection, link writeback, wrong-path flush | `x1 = 4`, `x3 = 42`, `memory[28] = 42` |
| `pipeline_jalr.mem` | Forwarded `jalr` base, target bit 0 clear, link writeback, wrong-path flush | `x1 = 8`, `x3 = 42`, `memory[32] = 42` |

## How to Run Instruction Program Tests

Run all directed instruction programs:

```sh
make test-programs
```

Run one program category:

```sh
make test-alu-program
make test-immediate-program
make test-load-store-program
make test-branch-program
make test-jump-program
make test-upper-program
make test-full-program
```

Each named target passes a matching `+CHECK_*` flag to the core testbench so the
final register or memory state is checked for that program.

## How to Generate Waveforms

Generate the integrated core VCD:

```sh
make wave-core
```

Expected VCD path:

```text
sim/waves/riscv_core.vcd
```

Generate the pipelined core VCD:

```sh
make wave-pipeline
```

Expected VCD path:

```text
sim/waves/riscv_pipelined_core.vcd
```

Open with GTKWave:

```sh
gtkwave sim/waves/riscv_core.vcd
```

See [waveforms.md](waveforms.md) for suggested signals.

## Where Logs Are Stored

The default core test log is written to:

```text
sim/logs/riscv_core.log
```

Instruction program targets write named logs:

```text
sim/logs/alu_tests.log
sim/logs/immediate_tests.log
sim/logs/load_store_tests.log
sim/logs/branch_tests.log
sim/logs/jump_tests.log
sim/logs/upper_tests.log
sim/logs/full_program_test.log
sim/logs/pipeline_branch_taken.log
sim/logs/pipeline_branch_not_taken.log
sim/logs/pipeline_jal.log
sim/logs/pipeline_jalr.log
```

Compiled simulation binaries are stored in:

```text
sim/build/
```

## Where VCD Files Are Stored

Waveforms are stored in:

```text
sim/waves/
```

The integrated core waveform is:

```text
sim/waves/riscv_core.vcd
```

The pipelined core waveform is:

```text
sim/waves/riscv_pipelined_core.vcd
```

## How `.asm` Files Relate to `.mem` Files

Files under `tests/programs/` follow this convention:

- `.asm` files are readable assembly listings with comments.
- `.mem` files contain one 32-bit hexadecimal instruction word per line.
- The instruction memory loads `.mem` files directly during simulation.
- The `.mem` files intentionally avoid comments so `$fscanf` can read them
  cleanly.

The current repository stores both forms side by side. The `.asm` files explain
intent, while the `.mem` files are the actual simulation inputs.

## What Each Test Program Checks

| Program | Make target | What it checks |
| --- | --- | --- |
| `program.mem` | `make test-core` | Default smoke program: immediate add, register add/sub, store, and load. |
| `basic_arithmetic.mem` | Load manually with `PROGRAM=...` | Same core arithmetic and memory sequence as the default program. |
| `alu_tests.mem` | `make test-alu-program` | R-type `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu`. |
| `immediate_tests.mem` | `make test-immediate-program` | I-type `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu`. |
| `load_store_tests.mem` | `make test-load-store-program` | `sw`, `lw`, address calculation, memory write, and load writeback. |
| `branch_tests.mem` | `make test-branch-program` | Taken branch behavior for `beq`, `bne`, `blt`, and `bge`. |
| `jump_tests.mem` | `make test-jump-program` | `jal`, `jalr`, link register writeback, skipped instructions, and target selection. |
| `upper_tests.mem` | `make test-upper-program` | `lui` and `auipc` immediate writeback behavior. |
| `full_program_test.mem` | `make test-full-program` | Combined arithmetic, immediate, load/store, branch, jump, and upper-immediate behavior. |
| `pipeline_basic.mem` | `make test-pipeline` | Basic 5-stage pipeline flow with manual NOPs around data dependencies. |
| `pipeline_forwarding.mem` | `make test-pipeline-forwarding` | ALU dependencies without manual NOPs and forwarded store data. |
| `pipeline_load_use.mem` | `make test-pipeline-load-use` | A load-use dependency that requires one automatic stall and MEM/WB forwarding. |
| `pipeline_branch_flush.mem` | `make test-pipeline-branch-flush` | Taken branch and jump behavior with wrong-path instruction flushes. |

Expected final values are also summarized in
[tests/programs/README.md](../tests/programs/README.md).

## Cleaning Generated Files

Remove generated simulation outputs:

```sh
make clean
```

This removes generated files from `sim/build/`, `sim/waves/`, and `sim/logs/`
while keeping each directory's `.gitkeep` placeholder.
