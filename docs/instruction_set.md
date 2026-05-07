# Instruction Set

This document describes the RV32I subset implemented by the current
single-cycle CPU. All instructions are 32 bits wide. Register `x0` always reads
as zero, and writes to `x0` are ignored.

## Supported Instruction Summary

| Group | Instructions |
| --- | --- |
| R-type | `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu` |
| I-type | `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu` |
| Memory | `lw`, `sw` |
| Branch | `beq`, `bne`, `blt`, `bge` |
| Jump | `jal`, `jalr` |
| Upper | `lui`, `auipc` |

## R-Type Instructions

Format:

| Bits | Field |
| --- | --- |
| `[31:25]` | `funct7` |
| `[24:20]` | `rs2` |
| `[19:15]` | `rs1` |
| `[14:12]` | `funct3` |
| `[11:7]` | `rd` |
| `[6:0]` | opcode |

Opcode: `0110011`

| Instruction | `funct3` | `funct7` | Behavior |
| --- | --- | --- | --- |
| `add` | `000` | `0000000` | `rd = rs1 + rs2` |
| `sub` | `000` | `0100000` | `rd = rs1 - rs2` |
| `and` | `111` | `0000000` | `rd = rs1 & rs2` |
| `or` | `110` | `0000000` | `rd = rs1 \| rs2` |
| `xor` | `100` | `0000000` | `rd = rs1 ^ rs2` |
| `sll` | `001` | `0000000` | `rd = rs1 << rs2[4:0]` |
| `srl` | `101` | `0000000` | `rd = rs1 >> rs2[4:0]`, logical |
| `sra` | `101` | `0100000` | `rd = signed(rs1) >>> rs2[4:0]` |
| `slt` | `010` | `0000000` | `rd = 1` if signed `rs1 < rs2`, else `0` |
| `sltu` | `011` | `0000000` | `rd = 1` if unsigned `rs1 < rs2`, else `0` |

Immediate behavior: R-type instructions do not use an immediate. Both operands
come from the register file.

## I-Type ALU Instructions

Format:

| Bits | Field |
| --- | --- |
| `[31:20]` | `imm[11:0]` or shift encoding |
| `[19:15]` | `rs1` |
| `[14:12]` | `funct3` |
| `[11:7]` | `rd` |
| `[6:0]` | opcode |

Opcode: `0010011`

| Instruction | `funct3` | `funct7` / imm bits | Behavior |
| --- | --- | --- | --- |
| `addi` | `000` | N/A | `rd = rs1 + sign_extend(imm[11:0])` |
| `andi` | `111` | N/A | `rd = rs1 & sign_extend(imm[11:0])` |
| `ori` | `110` | N/A | `rd = rs1 \| sign_extend(imm[11:0])` |
| `xori` | `100` | N/A | `rd = rs1 ^ sign_extend(imm[11:0])` |
| `slli` | `001` | `0000000` | `rd = rs1 << shamt` |
| `srli` | `101` | `0000000` | `rd = rs1 >> shamt`, logical |
| `srai` | `101` | `0100000` | `rd = signed(rs1) >>> shamt` |
| `slti` | `010` | N/A | `rd = 1` if signed `rs1 < imm`, else `0` |
| `sltiu` | `011` | N/A | `rd = 1` if unsigned `rs1 < imm`, else `0` |

Immediate behavior: normal I-type immediates are 12-bit signed values extended
to 32 bits. Shift-immediate instructions use `shamt = instruction[24:20]`.
For `slli`, `srli`, and `srai`, `instruction[31:25]` distinguishes the shift
variant.

## Memory Instructions

### `lw`

Format: I-type load

| Bits | Field |
| --- | --- |
| `[31:20]` | `imm[11:0]` |
| `[19:15]` | `rs1` |
| `[14:12]` | `funct3` |
| `[11:7]` | `rd` |
| `[6:0]` | opcode |

| Instruction | Opcode | `funct3` | Behavior |
| --- | --- | --- | --- |
| `lw` | `0000011` | `010` | `rd = memory[rs1 + sign_extend(imm[11:0])]` |

Immediate behavior: the 12-bit I-type immediate is sign-extended and added to
`rs1` to form the byte address. The current memory indexes words using
`address[31:2]`.

### `sw`

Format: S-type store

| Bits | Field |
| --- | --- |
| `[31:25]` | `imm[11:5]` |
| `[24:20]` | `rs2` |
| `[19:15]` | `rs1` |
| `[14:12]` | `funct3` |
| `[11:7]` | `imm[4:0]` |
| `[6:0]` | opcode |

| Instruction | Opcode | `funct3` | Behavior |
| --- | --- | --- | --- |
| `sw` | `0100011` | `010` | `memory[rs1 + sign_extend(S-imm)] = rs2` |

Immediate behavior: the S-type immediate is reconstructed from
`instruction[31:25]` and `instruction[11:7]`, sign-extended, and added to
`rs1`.

## Branch Instructions

Format: B-type

| Bits | Field |
| --- | --- |
| `[31]` | `imm[12]` |
| `[30:25]` | `imm[10:5]` |
| `[24:20]` | `rs2` |
| `[19:15]` | `rs1` |
| `[14:12]` | `funct3` |
| `[11:8]` | `imm[4:1]` |
| `[7]` | `imm[11]` |
| `[6:0]` | opcode |

Opcode: `1100011`

| Instruction | `funct3` | Behavior |
| --- | --- | --- |
| `beq` | `000` | Branch if `rs1 == rs2` |
| `bne` | `001` | Branch if `rs1 != rs2` |
| `blt` | `100` | Branch if signed `rs1 < rs2` |
| `bge` | `101` | Branch if signed `rs1 >= rs2` |

Immediate behavior: the B-type immediate is sign-extended, includes an implied
low zero bit, and is added to the current PC when the condition is true.

Current branch subset note: unsigned branches such as `bltu` and `bgeu` are not
part of the supported instruction program set.

## Jump Instructions

### `jal`

Format: J-type

| Bits | Field |
| --- | --- |
| `[31]` | `imm[20]` |
| `[30:21]` | `imm[10:1]` |
| `[20]` | `imm[11]` |
| `[19:12]` | `imm[19:12]` |
| `[11:7]` | `rd` |
| `[6:0]` | opcode |

| Instruction | Opcode | Behavior |
| --- | --- | --- |
| `jal` | `1101111` | `rd = PC + 4`; `PC = PC + sign_extend(J-imm)` |

Immediate behavior: the J-type immediate is sign-extended, includes an implied
low zero bit, and is relative to the current PC.

### `jalr`

Format: I-type jump

| Bits | Field |
| --- | --- |
| `[31:20]` | `imm[11:0]` |
| `[19:15]` | `rs1` |
| `[14:12]` | `funct3` |
| `[11:7]` | `rd` |
| `[6:0]` | opcode |

| Instruction | Opcode | `funct3` | Behavior |
| --- | --- | --- | --- |
| `jalr` | `1100111` | `000` | `rd = PC + 4`; `PC = (rs1 + sign_extend(imm[11:0])) & ~1` |

Immediate behavior: the 12-bit I-type immediate is sign-extended and added to
`rs1`. Bit 0 of the target address is cleared.

## Upper Immediate Instructions

Format: U-type

| Bits | Field |
| --- | --- |
| `[31:12]` | `imm[31:12]` |
| `[11:7]` | `rd` |
| `[6:0]` | opcode |

| Instruction | Opcode | Behavior |
| --- | --- | --- |
| `lui` | `0110111` | `rd = imm[31:12] << 12` |
| `auipc` | `0010111` | `rd = PC + (imm[31:12] << 12)` |

Immediate behavior: the U-type immediate occupies the upper 20 bits of the
instruction and is placed in bits `[31:12]` of the generated immediate, with
bits `[11:0]` set to zero.

## Unsupported RV32I Features

The current subset does not include byte or halfword loads/stores, unsigned
branches, `fence`, `ecall`, `ebreak`, CSR instructions, multiplication,
division, atomics, floating point, or compressed instructions.
