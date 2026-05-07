# Control Signals

This document describes the main control signals used by the current
single-cycle RV32I core. The control unit decodes `opcode` into broad datapath
control, and the ALU control unit decodes `alu_op`, `funct3`, and `funct7` into
a specific ALU operation.

## Control Signal Table

| Signal | Width | Meaning |
| --- | --- | --- |
| `reg_write` | 1 | Enables writing `writeback_data` into destination register `rd`. |
| `alu_src` | 1 | Selects ALU operand B: `0 = rs2`, `1 = immediate`. |
| `mem_read` | 1 | Enables combinational data memory read for `lw`. |
| `mem_write` | 1 | Enables synchronous data memory write for `sw`. |
| `mem_to_reg` | 1 | Selects data memory read data for register writeback. |
| `branch` | 1 | Marks a conditional branch instruction. |
| `jump` | 1 | Marks `jal` or `jalr`. |
| `jalr` | 1 | Selects register-relative jump target generation for `jalr`. |
| `alu_op` | 3 | Selects the broad ALU operation category. |
| `imm_src` | 3 | Selects which immediate format the immediate generator builds. |

The core also has local next-PC and writeback selection logic. There is no
separate exported `pc_src` or wide writeback-select signal in the current RTL.

## Opcode-Level Control

| Instruction type | Opcode | `reg_write` | `alu_src` | `mem_read` | `mem_write` | `mem_to_reg` | `branch` | `jump` | `jalr` | `alu_op` | `imm_src` |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R-type ALU | `0110011` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | R-type | I default |
| I-type ALU | `0010011` | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | I-type | I |
| `lw` | `0000011` | 1 | 1 | 1 | 0 | 1 | 0 | 0 | 0 | Add | I |
| `sw` | `0100011` | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | Add | S |
| Branch | `1100011` | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | Branch | B |
| `jal` | `1101111` | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | Add default | J |
| `jalr` | `1100111` | 1 | 1 | 0 | 0 | 0 | 0 | 1 | 1 | Add | I |
| `lui` | `0110111` | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | LUI | U |
| `auipc` | `0010111` | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | AUIPC | U |
| Unsupported | other | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | Add | I |

## Meaning by Instruction Type

| Signal | Used by | Notes |
| --- | --- | --- |
| `reg_write` | R-type, I-type, `lw`, `jal`, `jalr`, `lui`, `auipc` | Disabled for stores, branches, and unsupported opcodes. |
| `alu_src` | I-type, `lw`, `sw`, `jalr`, `lui`, `auipc` | Selects the generated immediate as operand B. |
| `mem_read` | `lw` | Data memory returns zero when `mem_read` is not asserted. |
| `mem_write` | `sw` | Data memory writes on the rising clock edge. |
| `mem_to_reg` | `lw` | Selects data memory read data instead of the ALU result. |
| `branch` | `beq`, `bne`, `blt`, `bge` | Enables branch decision logic in the core. |
| `jump` | `jal`, `jalr` | Selects link writeback and jump next-PC logic. |
| `jalr` | `jalr` | Distinguishes `jalr` from PC-relative `jal`. |

## ALU Operation Categories

The `alu_op` signal is a 3-bit category passed from `control_unit` to
`alu_control`.

| Category | Encoded value in RTL | Used by | ALU control behavior |
| --- | --- | --- | --- |
| Add | `3'd0` | `lw`, `sw`, `jalr`, defaults | Selects addition. |
| Branch | `3'd1` | Branch instructions | Selects compare-related ALU operations from `funct3`. |
| R-type | `3'd2` | R-type ALU instructions | Uses `funct3` and `funct7[5]`. |
| I-type | `3'd3` | I-type ALU instructions | Uses `funct3` and shift `funct7[5]`. |
| LUI | `3'd4` | `lui` | ALU category exists, but writeback uses `imm_out`. |
| AUIPC | `3'd5` | `auipc` | Adds current PC and U-type immediate. |

## Specific ALU Operations

| ALU operation | Encoded value in RTL | Used for |
| --- | --- | --- |
| ADD | `4'd0` | `add`, `addi`, load/store address calculation, `auipc` |
| SUB | `4'd1` | `sub`, branch equality helper category |
| AND | `4'd2` | `and`, `andi` |
| OR | `4'd3` | `or`, `ori` |
| XOR | `4'd4` | `xor`, `xori` |
| SLL | `4'd5` | `sll`, `slli` |
| SRL | `4'd6` | `srl`, `srli` |
| SRA | `4'd7` | `sra`, `srai` |
| SLT | `4'd8` | `slt`, `slti`, signed branch helper category |
| SLTU | `4'd9` | `sltu`, `sltiu`, unsigned compare helper category |

The current branch decision in `riscv_core.sv` compares register operands
directly. The branch ALU category remains useful for keeping ALU control decode
consistent with branch comparison classes.

## Immediate Source Categories

| Immediate source | Encoded value in RTL | Format | Used by |
| --- | --- | --- | --- |
| I | `3'd0` | `instruction[31:20]` sign-extended | I-type ALU, `lw`, `jalr` |
| S | `3'd1` | `{instruction[31:25], instruction[11:7]}` sign-extended | `sw` |
| B | `3'd2` | Branch immediate with low bit `0` | Branches |
| U | `3'd3` | `instruction[31:12] << 12` | `lui`, `auipc` |
| J | `3'd4` | Jump immediate with low bit `0` | `jal` |

## Writeback Source Explanation

The current RTL uses local priority logic for writeback:

| Condition | Register writeback value |
| --- | --- |
| `mem_to_reg == 1` | Data memory read data |
| `jump == 1` | `PC + 4` link value |
| `opcode == LUI` | U-type immediate |
| Otherwise | ALU result |

This covers R-type, I-type, `lw`, `jal`, `jalr`, `lui`, and `auipc`. Stores,
branches, and unsupported opcodes do not assert `reg_write`.

## Safe Defaults for Unsupported Opcodes

The control unit initializes all outputs to safe defaults before the opcode
case statement:

- No register write
- No memory read
- No memory write
- No branch or jump
- ALU add category
- I-type immediate selection

With these defaults, unsupported opcodes do not intentionally modify the
register file or data memory. They still pass through the single-cycle datapath
and the PC advances normally by `PC + 4`.
