# Datapath

This document explains how data and control move through the current
single-cycle RISC-V CPU core.

## High-Level Datapath Explanation

The datapath starts at the program counter and ends with state updates to the
program counter, register file, and data memory. For each instruction, the core
fetches an instruction from instruction memory, decodes register and immediate
fields, computes an ALU result or target address, optionally accesses data
memory, selects writeback data, and computes the next PC.

```text
PC -> Instruction Memory -> Register File / Immediate Generator -> ALU -> Memory -> Writeback
```

## Signal Flow

1. `pc` addresses instruction memory.
2. `instruction` is split into `opcode`, `rd`, `funct3`, `rs1`, `rs2`, and
   `funct7`.
3. `control_unit` generates high-level datapath control signals.
4. `immediate_generator` produces `imm_out` from the selected immediate format.
5. `register_file` reads `read_data1` from `rs1` and `read_data2` from `rs2`.
6. `alu_control` selects the concrete ALU operation.
7. ALU operands are selected and passed into the ALU.
8. Data memory is accessed for `lw` or `sw`.
9. Writeback data is selected for instructions that write `rd`.
10. Next-PC logic selects the address for the next instruction.

## ALU Operand Selection

ALU operand A:

| Instruction class | Operand A |
| --- | --- |
| `auipc` | Current `pc` |
| All other supported classes | `read_data1` from `rs1` |

ALU operand B:

| `alu_src` | Operand B |
| --- | --- |
| `0` | `read_data2` from `rs2` |
| `1` | `imm_out` from the immediate generator |

This lets the same ALU handle register-register operations, immediate
operations, load/store address calculation, and `auipc`.

## Immediate Selection

The immediate generator supports the immediate formats needed by the current
instruction subset.

| `imm_src` category | Format | Used by |
| --- | --- | --- |
| I-type | 12-bit signed immediate | I-type ALU, `lw`, `jalr` |
| S-type | Split 12-bit signed store immediate | `sw` |
| B-type | Signed branch offset with low bit `0` | `beq`, `bne`, `blt`, `bge` |
| U-type | Upper 20 bits shifted left by 12 | `lui`, `auipc` |
| J-type | Signed jump offset with low bit `0` | `jal` |

## Writeback Selection

The core selects register writeback data with local mux logic:

| Instruction class | Writeback data |
| --- | --- |
| R-type ALU | `alu_result` |
| I-type ALU | `alu_result` |
| `lw` | `data_memory_read_data` |
| `jal`, `jalr` | `pc_plus_4` |
| `lui` | `imm_out` |
| `auipc` | `alu_result` |

The register file only writes when `reg_write` is asserted. Writes to `x0` are
ignored.

## PC Update Path

The core computes four candidate PC values:

| Candidate | Expression |
| --- | --- |
| Sequential PC | `pc + 4` |
| Branch target | `pc + imm_out` |
| `jal` target | `pc + imm_out` |
| `jalr` target | `(read_data1 + imm_out) & 32'hffff_fffe` |

The default is `pc + 4`. A taken branch overrides the default. If no branch is
taken, `jalr` and then `jal` can select a jump target.

## Branch Decision Logic

The current branch subset is resolved directly in `riscv_core.sv` using source
register values.

| Instruction | Decision |
| --- | --- |
| `beq` | Taken when `read_data1 == read_data2` |
| `bne` | Taken when `read_data1 != read_data2` |
| `blt` | Taken when signed `read_data1 < read_data2` |
| `bge` | Taken when signed `read_data1 >= read_data2` |

When a branch is taken, `next_pc = pc + B-type immediate`.

## Jump Decision Logic

`jal` and `jalr` both write the link value `pc + 4` to `rd`.

| Instruction | Target |
| --- | --- |
| `jal` | `pc + J-type immediate` |
| `jalr` | `(rs1 + I-type immediate) & ~1` |

The `jalr` target clears bit 0, matching the RISC-V target address rule.

## Memory Access Path

The ALU computes the byte address for `lw` and `sw` as:

```text
rs1 + sign_extended_immediate
```

Data memory uses `address[31:2]` as a word index.

| Instruction | Memory behavior |
| --- | --- |
| `lw` | Reads a 32-bit word and writes it back to `rd`. |
| `sw` | Writes the 32-bit value from `rs2` on the rising clock edge. |

Byte, halfword, and unaligned accesses are not implemented.

## Debug Outputs

The integrated core exposes these top-level debug outputs:

| Signal | Meaning |
| --- | --- |
| `pc_debug` | Current program counter value |
| `instruction_debug` | Current fetched instruction |
| `alu_result_debug` | Current ALU result |
| `writeback_data_debug` | Current selected writeback data |

These signals are used by the core testbench trace and are useful in VCD
waveforms.

## Single-Cycle Instruction Flow

In a single-cycle CPU, one instruction completes all major work in one clock
cycle:

1. The current `pc` fetches the instruction.
2. Decode logic identifies the instruction type and control settings.
3. The register file read ports provide source operands.
4. The immediate generator builds the instruction immediate when needed.
5. The ALU computes the operation result, memory address, comparison helper, or
   `auipc` value.
6. Data memory reads or writes for load/store instructions.
7. The writeback mux selects the value for `rd`.
8. Branch and jump logic computes `next_pc`.
9. On the clock edge, architectural state updates.

This design is easy to reason about because there are no overlapping
instructions. The tradeoff is that the clock period must be long enough for the
slowest supported instruction path.
