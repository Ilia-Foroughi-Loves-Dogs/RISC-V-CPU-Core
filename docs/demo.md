# Demo Guide

This guide shows a short path for demonstrating the project from the command
line.

## Run All Tests

Run the full regression:

```sh
make test-all
```

This runs the module tests, integrated single-cycle core test, instruction
program tests, baseline pipelined core test, pipeline hazard tests, and
pipeline control-flow tests.

## Run the Single-Cycle CPU Demo

Run the default single-cycle CPU program:

```sh
make test-core
```

Run all directed single-cycle instruction programs:

```sh
make test-programs
```

Run one specific program:

```sh
make test-alu-program
make test-immediate-program
make test-load-store-program
make test-branch-program
make test-jump-program
make test-upper-program
make test-full-program
```

## Run the Pipelined CPU Demo

Run the baseline pipelined program:

```sh
make test-pipeline
```

Run pipeline hazard tests:

```sh
make test-pipeline-hazards
```

Run pipeline branch and jump tests:

```sh
make test-pipeline-control-flow
```

## Generate VCD Waveforms

Generate the single-cycle waveform:

```sh
make wave-core
```

Generated file:

```text
sim/waves/riscv_core.vcd
```

Generate the pipelined waveform:

```sh
make wave-pipeline
```

Generated file:

```text
sim/waves/riscv_pipelined_core.vcd
```

## Open Waveforms in GTKWave

Open the single-cycle core waveform:

```sh
gtkwave sim/waves/riscv_core.vcd
```

Open the pipelined core waveform:

```sh
gtkwave sim/waves/riscv_pipelined_core.vcd
```

## Suggested Signals to Inspect

For the single-cycle core, start with:

- `clk`
- `reset`
- `pc_debug`
- `instruction_debug`
- `alu_result_debug`
- `writeback_data_debug`

For the pipelined core, start with:

- `if_pc_debug`
- `pc_next_debug`
- `id_instruction_debug`
- `ex_alu_result_debug`
- `mem_alu_result_debug`
- `wb_writeback_data_debug`
- `stall_debug`
- `flush_debug`
- `branch_taken_debug`
- `jump_taken_debug`
- `branch_target_debug`
- `jump_target_debug`
- `forward_a_debug`
- `forward_b_debug`

When reviewing the pipeline, watch instructions move from IF to WB, check that
writeback happens after the correct instruction reaches WB, and confirm that
stalls, flushes, and forwarding select signals appear around dependent
instructions and taken control-flow changes.
