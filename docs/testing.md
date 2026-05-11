# Testing

This document explains the simulation and verification workflow for the
single-cycle and pipelined RISC-V CPU cores.

## Required Tools

- GNU Make
- Icarus Verilog with SystemVerilog support (`iverilog -g2012`)
- `vvp`
- GTKWave for waveform viewing

The existing `.mem` files are checked into the repository. A RISC-V assembler
is useful for future automation, but it is not required for the current test
flow.

## Major Makefile Targets

| Target | What it runs |
| --- | --- |
| `make help` | Prints the available commands. |
| `make test-all` | Runs the full regression. |
| `make test-modules` | Runs all standalone module tests. |
| `make test-core` | Runs the integrated single-cycle CPU test. |
| `make test-programs` | Runs all directed single-cycle instruction program tests. |
| `make test-pipeline` | Runs the baseline pipelined CPU test. |
| `make test-pipeline-hazards` | Runs forwarding, hazard unit, load-use, and branch flush tests. |
| `make test-pipeline-control-flow` | Runs pipelined branch, `jal`, and `jalr` tests. |
| `make wave-core` | Runs the single-cycle core test and writes a VCD file. |
| `make wave-pipeline` | Runs the pipelined core test and writes a VCD file. |
| `make clean` | Removes generated simulation outputs. |

Run the full regression with:

```sh
make test-all
```

`test-all` runs module tests, the integrated single-cycle core test, all
single-cycle instruction program tests, the baseline pipelined core test,
pipeline hazard tests, and pipeline control-flow tests.

## Continuous Integration

GitHub Actions is configured to run the same full regression used locally:

```sh
make test-all
```

The CI job runs on GitHub-hosted Ubuntu runners and installs Icarus Verilog so
`iverilog` can compile the SystemVerilog testbenches and `vvp` can execute the
simulations. Running the full regression in CI helps catch test failures and
behavioral regressions automatically on pushes and pull requests.

## Module Tests

Run all module tests:

```sh
make test-modules
```

Individual module targets:

| Target | Testbench | RTL under test |
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

## Single-Cycle Core Tests

Run the default integrated single-cycle CPU test:

```sh
make test-core
```

Load a specific memory image through the same testbench:

```sh
make test-core PROGRAM=tests/programs/alu_tests.mem
```

When `PROGRAM=...` is passed to `make test-core`, the Makefile also passes
`+CHECK_NONE`, so the testbench runs the trace without applying a mismatched
built-in final check.

## Instruction Program Tests

Run all directed single-cycle instruction programs:

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

Each named target passes a matching `+CHECK_*` flag to the core testbench so
the final register or memory state is checked for that program.

## Pipelined Core Tests

Run the baseline pipelined CPU test:

```sh
make test-pipeline
```

This loads:

```text
tests/programs/pipeline_basic.mem
```

Run all pipeline hazard tests:

```sh
make test-pipeline-hazards
```

Run individual hazard programs:

```sh
make test-pipeline-forwarding
make test-pipeline-load-use
make test-pipeline-branch-flush
```

Run all pipeline control-flow tests:

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

The pipelined testbench can also load any checked-in program image:

```sh
make test-pipeline PROGRAM=tests/programs/pipeline_forwarding.mem
```

## Test Programs

Files under `tests/programs/` include readable `.asm` listings and matching
simulation-ready `.mem` files.

| Program | Make target | What it checks |
| --- | --- | --- |
| `program.mem` | `make test-core` | Default smoke program: immediate add, register add/sub, store, and load. |
| `basic_arithmetic.mem` | Manual `PROGRAM=...` load | Same core arithmetic and memory sequence as the default program. |
| `alu_tests.mem` | `make test-alu-program` | R-type ALU instructions. |
| `immediate_tests.mem` | `make test-immediate-program` | I-type ALU and shift-immediate instructions. |
| `load_store_tests.mem` | `make test-load-store-program` | `sw`, `lw`, address calculation, memory write, and load writeback. |
| `branch_tests.mem` | `make test-branch-program` | Taken `beq`, `bne`, `blt`, and `bge`. |
| `jump_tests.mem` | `make test-jump-program` | `jal`, `jalr`, link writeback, and target selection. |
| `upper_tests.mem` | `make test-upper-program` | `lui` and `auipc`. |
| `full_program_test.mem` | `make test-full-program` | Combined instruction behavior. |
| `pipeline_basic.mem` | `make test-pipeline` | Basic 5-stage pipeline flow with legacy NOP padding. |
| `pipeline_forwarding.mem` | `make test-pipeline-forwarding` | ALU dependencies and forwarded store data. |
| `pipeline_load_use.mem` | `make test-pipeline-load-use` | One-cycle load-use stall and MEM/WB forwarding. |
| `pipeline_branch_flush.mem` | `make test-pipeline-branch-flush` | Taken branch and jump wrong-path flushes. |
| `pipeline_branch_taken.mem` | `make test-pipeline-branch-taken` | Forwarded branch operands and taken redirect. |
| `pipeline_branch_not_taken.mem` | `make test-pipeline-branch-not-taken` | Forwarded branch operands with sequential PC. |
| `pipeline_jal.mem` | `make test-pipeline-jal` | Pipelined `jal`, link writeback, and flush. |
| `pipeline_jalr.mem` | `make test-pipeline-jalr` | Pipelined `jalr`, forwarded base, link writeback, and flush. |

Expected final values are summarized in
[../tests/programs/README.md](../tests/programs/README.md).

## How `.asm` and `.mem` Files Relate

- `.asm` files are human-readable assembly listings with comments.
- `.mem` files contain one 32-bit hexadecimal instruction word per line.
- Instruction memory loads `.mem` files directly during simulation.
- `.mem` files intentionally avoid comments so `$fscanf` can read them cleanly.

The repository stores both forms side by side. The `.asm` files explain intent;
the `.mem` files are the actual simulation inputs.

## Adding a New Test Program

1. Add a readable assembly listing under `tests/programs/name.asm`.
2. Add the matching machine-code memory image under `tests/programs/name.mem`.
3. Keep the `.mem` file to one 32-bit hexadecimal instruction per line.
4. Add final expected checks to the relevant testbench if the program should be
   self-checking.
5. Add a Makefile target if the program should become part of the standard
   workflow.
6. Document the new program in `tests/programs/README.md` and this file.

## Debugging Failed Tests

Start with the failing Makefile target and read the printed trace. The
integrated testbenches print the program path, cycle count, PC, instruction,
ALU result, writeback data, and pipeline debug signals where available.

Useful checks:

- Confirm that the intended `.mem` file is being loaded.
- Compare the `.mem` file against the matching `.asm` listing.
- Check whether the failure is in decode, ALU result, memory access, writeback,
  stall, flush, or forwarding.
- Generate a waveform with `make wave-core` or `make wave-pipeline`.
- Inspect the corresponding log under `sim/logs/`.

## Logs and Waveforms

Default logs are written under:

```text
sim/logs/
```

Common log files include:

```text
sim/logs/riscv_core.log
sim/logs/riscv_pipelined_core.log
sim/logs/alu_tests.log
sim/logs/immediate_tests.log
sim/logs/load_store_tests.log
sim/logs/branch_tests.log
sim/logs/jump_tests.log
sim/logs/upper_tests.log
sim/logs/full_program_test.log
sim/logs/pipeline_forwarding.log
sim/logs/pipeline_load_use.log
sim/logs/pipeline_branch_flush.log
sim/logs/pipeline_branch_taken.log
sim/logs/pipeline_branch_not_taken.log
sim/logs/pipeline_jal.log
sim/logs/pipeline_jalr.log
```

Compiled simulation binaries are written under:

```text
sim/build/
```

Waveforms are written under:

```text
sim/waves/
```

Main VCD files:

```text
sim/waves/riscv_core.vcd
sim/waves/riscv_pipelined_core.vcd
```

## Cleaning Generated Files

Remove generated simulation outputs:

```sh
make clean
```

This removes generated files from `sim/build/`, `sim/waves/`, and `sim/logs/`
while keeping each directory's `.gitkeep` placeholder.
