# Waveforms

This guide explains how to generate and inspect VCD waveforms for the
single-cycle and pipelined CPU cores.

## Generate Waveforms

Generate the single-cycle core waveform:

```sh
make wave-core
```

Generated file:

```text
sim/waves/riscv_core.vcd
```

Generate the pipelined core waveform:

```sh
make wave-pipeline
```

Generated file:

```text
sim/waves/riscv_pipelined_core.vcd
```

## Open with GTKWave

Open the single-cycle waveform:

```sh
gtkwave sim/waves/riscv_core.vcd
```

Open the pipelined waveform:

```sh
gtkwave sim/waves/riscv_pipelined_core.vcd
```

If GTKWave is not installed, install it through your normal package manager and
rerun the command.

## Useful Single-Cycle Core Signals

Start with these top-level debug signals in `tb_riscv_core`:

| Signal | Why it is useful |
| --- | --- |
| `clk` | Confirms cycle boundaries. |
| `reset` | Shows when state is cleared before execution. |
| `pc_debug` | Shows instruction address progression and branch/jump targets. |
| `instruction_debug` | Shows the instruction currently being executed. |
| `alu_result_debug` | Shows arithmetic results, compare helper results, and memory addresses. |
| `writeback_data_debug` | Shows the selected value being written back to the register file. |

Additional useful internal signals may include register file write enable,
destination register, data memory write enable, data memory address, and data
memory write data.

## Useful Pipelined Core Signals

Start with these top-level debug signals in `tb_riscv_pipelined_core`:

| Signal | Why it is useful |
| --- | --- |
| `if_pc_debug` | Shows the instruction fetch PC. |
| `pc_next_debug` | Shows the next PC selected by sequential or redirected control flow. |
| `id_instruction_debug` | Shows the instruction currently in decode. |
| `ex_alu_result_debug` | Shows the execute-stage ALU result. |
| `mem_alu_result_debug` | Shows the memory-stage ALU result or address. |
| `wb_writeback_data_debug` | Shows the value being written back in WB. |
| `stall_debug` | Shows load-use stalls. |
| `flush_debug` | Shows bubbles or wrong-path instruction flushes. |
| `branch_taken_debug` | Shows a resolved taken branch. |
| `jump_taken_debug` | Shows a resolved `jal` or `jalr`. |
| `branch_target_debug` | Shows the computed branch target. |
| `jump_target_debug` | Shows the computed jump target. |
| `forward_a_debug` | Shows forwarding selection for EX operand A. |
| `forward_b_debug` | Shows forwarding selection for EX operand B. |

## Interpreting PC, Instruction, and Writeback

For the single-cycle core, one instruction is visible at a time:

- `pc_debug` selects the instruction.
- `instruction_debug` shows the fetched instruction.
- `alu_result_debug` shows the operation result or memory address.
- `writeback_data_debug` shows the value selected for register writeback.

For the pipelined core, multiple instructions are active at once. Compare the
stage-specific signals instead of expecting one instruction to complete in the
same cycle it is fetched:

- IF shows the newest fetched instruction address.
- ID shows the decoded instruction.
- EX shows the current ALU or target calculation.
- MEM shows memory-stage address/result information.
- WB shows the value being committed to the register file.

## Inspecting Stalls, Flushes, and Forwarding

For a load-use program such as `tests/programs/pipeline_load_use.mem`, inspect
`stall_debug`. A load-use dependency should hold fetch/decode briefly and insert
a bubble before the dependent instruction advances.

For branch and jump programs such as `pipeline_branch_taken.mem`,
`pipeline_jal.mem`, and `pipeline_jalr.mem`, inspect `flush_debug`,
`branch_taken_debug`, `jump_taken_debug`, `branch_target_debug`, and
`jump_target_debug`. A taken branch or jump should redirect `pc_next_debug` and
flush younger wrong-path instructions.

For forwarding programs such as `pipeline_forwarding.mem`, inspect
`forward_a_debug` and `forward_b_debug`. Nonzero forwarding select values
indicate that a source operand is coming from a later pipeline stage instead of
the register file value originally read in decode.
