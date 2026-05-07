# Control Signals

This document defines the planned control signals for the initial single-cycle
RV32I CPU. These names describe the intended control behavior before RTL
implementation begins.

Exact bit encodings may change during implementation if the datapath or module
interfaces need a cleaner representation. The architectural intent should remain
consistent with this document.

## Planned Main Control Signals

| Signal | Width | Purpose |
| --- | --- | --- |
| `reg_write` | 1 | Enables writing a value into the destination register `rd` |
| `alu_src` | 1 | Selects the second ALU operand: register `rs2` or immediate |
| `mem_read` | 1 | Enables a data memory read for load instructions |
| `mem_write` | 1 | Enables a data memory write for store instructions |
| `mem_to_reg` | 1 | Selects data memory output as the register writeback value |
| `branch` | 1 | Marks the instruction as a conditional branch |
| `jump` | 1 | Marks the instruction as an unconditional jump or link operation |
| `jalr` | 1 | Selects `jalr` target generation using `rs1 + immediate` |
| `alu_op` | TBD | Encodes the broad ALU operation class for ALU control decoding |
| `imm_src` | TBD | Selects the immediate format: I, S, B, U, or J |
| `pc_src` | TBD | Selects the next PC source, such as `PC + 4`, branch target, `jal`, or `jalr` |

## Signal Notes

- `reg_write` should be asserted for instructions that write `rd`, including
  ALU operations, loads, `jal`, `jalr`, `lui`, and `auipc`.
- `alu_src` should select an immediate for I-type ALU instructions, loads,
  stores, and address-generation operations.
- `mem_read` is initially only needed for `lw`.
- `mem_write` is initially only needed for `sw`.
- `mem_to_reg` is only one part of writeback selection. Later implementation
  may replace it with a wider writeback-select signal to also handle ALU
  results, memory data, `PC + 4`, and upper-immediate results.
- `branch` works with ALU comparison results or dedicated branch comparison
  logic to decide whether the next PC should use the branch target.
- `jump` is asserted for `jal` and `jalr`.
- `jalr` distinguishes register-based jump targets from PC-relative `jal`
  targets.
- `alu_op`, `imm_src`, and `pc_src` are intentionally marked as TBD-width
  signals because their exact encodings should be chosen when the RTL module
  boundaries are finalized.

## Expected Immediate Sources

| Immediate Source | Used By |
| --- | --- |
| I-type | ALU-immediate instructions, `lw`, `jalr` |
| S-type | `sw` |
| B-type | Conditional branches |
| U-type | `lui`, `auipc` |
| J-type | `jal` |

## Expected PC Sources

| PC Source | Used By |
| --- | --- |
| `PC + 4` | Default next instruction |
| Branch target | Taken conditional branches |
| `jal` target | PC-relative jump |
| `jalr` target | Register-relative jump with bit 0 cleared |
