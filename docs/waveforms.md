# Waveforms

This guide explains how to generate and inspect the integrated core waveform.

## Generate the VCD File

Run:

```sh
make wave-core
```

Expected output path:

```text
sim/waves/riscv_core.vcd
```

## Open with GTKWave

Run:

```sh
gtkwave sim/waves/riscv_core.vcd
```

If GTKWave is not installed, install it through your normal package manager and
rerun the command.

## Useful Signals to Inspect

Start with these signals:

| Signal | Why it is useful |
| --- | --- |
| `clk` | Confirms cycle boundaries. |
| `reset` | Shows when state is cleared before execution. |
| `pc_debug` | Shows instruction address progression and branch/jump targets. |
| `instruction_debug` | Shows the instruction currently being executed. |
| `alu_result_debug` | Shows arithmetic results, compare helper results, and memory addresses. |
| `writeback_data_debug` | Shows the selected value being written back to the register file. |
| Register file write enable, if visible | Confirms which cycles commit register writes. |
| Memory write enable, if visible | Confirms store instructions update data memory. |

For branch and jump debugging, compare `pc_debug` against the expected target
addresses from the `.asm` program listing. For load/store debugging, inspect the
ALU result as the computed address and check memory write enable activity on
store cycles.
