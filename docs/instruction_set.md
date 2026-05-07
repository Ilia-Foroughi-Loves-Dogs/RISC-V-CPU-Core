# Instruction Set

This document defines the initial RV32I instruction subset for the first
single-cycle CPU implementation. The goal is to support enough integer
instructions to run small hand-written programs while keeping the first hardware
version focused and testable.

All instructions are 32 bits wide. Immediate values are sign-extended unless
noted otherwise. Register `x0` always reads as zero, and writes to `x0` are
ignored by the register file.

## Supported Instruction Summary

| Instruction | Type | Opcode | Funct3 | Funct7 | Description |
| --- | --- | --- | --- | --- | --- |
| `add` | R | `0110011` | `000` | `0000000` | `rd = rs1 + rs2` |
| `sub` | R | `0110011` | `000` | `0100000` | `rd = rs1 - rs2` |
| `and` | R | `0110011` | `111` | `0000000` | `rd = rs1 & rs2` |
| `or` | R | `0110011` | `110` | `0000000` | `rd = rs1 \| rs2` |
| `xor` | R | `0110011` | `100` | `0000000` | `rd = rs1 ^ rs2` |
| `sll` | R | `0110011` | `001` | `0000000` | Logical left shift by `rs2[4:0]` |
| `srl` | R | `0110011` | `101` | `0000000` | Logical right shift by `rs2[4:0]` |
| `sra` | R | `0110011` | `101` | `0100000` | Arithmetic right shift by `rs2[4:0]` |
| `slt` | R | `0110011` | `010` | `0000000` | Set to 1 if signed `rs1 < rs2` |
| `sltu` | R | `0110011` | `011` | `0000000` | Set to 1 if unsigned `rs1 < rs2` |
| `addi` | I | `0010011` | `000` | N/A | `rd = rs1 + imm` |
| `andi` | I | `0010011` | `111` | N/A | `rd = rs1 & imm` |
| `ori` | I | `0010011` | `110` | N/A | `rd = rs1 \| imm` |
| `xori` | I | `0010011` | `100` | N/A | `rd = rs1 ^ imm` |
| `slli` | I | `0010011` | `001` | `0000000` | Logical left shift by `shamt` |
| `srli` | I | `0010011` | `101` | `0000000` | Logical right shift by `shamt` |
| `srai` | I | `0010011` | `101` | `0100000` | Arithmetic right shift by `shamt` |
| `slti` | I | `0010011` | `010` | N/A | Set to 1 if signed `rs1 < imm` |
| `sltiu` | I | `0010011` | `011` | N/A | Set to 1 if unsigned `rs1 < imm` |
| `lw` | I | `0000011` | `010` | N/A | Load 32-bit word from `rs1 + imm` |
| `sw` | S | `0100011` | `010` | N/A | Store 32-bit word to `rs1 + imm` |
| `beq` | B | `1100011` | `000` | N/A | Branch if `rs1 == rs2` |
| `bne` | B | `1100011` | `001` | N/A | Branch if `rs1 != rs2` |
| `blt` | B | `1100011` | `100` | N/A | Branch if signed `rs1 < rs2` |
| `bge` | B | `1100011` | `101` | N/A | Branch if signed `rs1 >= rs2` |
| `jal` | J | `1101111` | N/A | N/A | Jump and link using PC-relative offset |
| `jalr` | I | `1100111` | `000` | N/A | Jump and link using `rs1 + imm` |
| `lui` | U | `0110111` | N/A | N/A | Load upper immediate into `rd` |
| `auipc` | U | `0010111` | N/A | N/A | Add upper immediate to current PC |

## R-Type ALU Instructions

Format:

| Bits | Field |
| --- | --- |
| `[31:25]` | `funct7` |
| `[24:20]` | `rs2` |
| `[19:15]` | `rs1` |
| `[14:12]` | `funct3` |
| `[11:7]` | `rd` |
| `[6:0]` | `opcode` |

Opcode: `0110011`

Supported instructions: `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`,
`sra`, `slt`, `sltu`.

R-type instructions read two source registers and write one destination
register. Shift instructions use only the lower 5 bits of `rs2` as the shift
amount because RV32 registers are 32 bits wide.

## I-Type Arithmetic and Logical Instructions

Format:

| Bits | Field |
| --- | --- |
| `[31:20]` | `imm[11:0]` or shift encoding |
| `[19:15]` | `rs1` |
| `[14:12]` | `funct3` |
| `[11:7]` | `rd` |
| `[6:0]` | `opcode` |

Opcode: `0010011`

Supported instructions: `addi`, `andi`, `ori`, `xori`, `slli`, `srli`,
`srai`, `slti`, `sltiu`.

Normal I-type immediates are 12-bit signed values sign-extended to 32 bits
before entering the ALU. Shift-immediate instructions use `shamt = instr[24:20]`
and distinguish logical versus arithmetic right shift with `funct7`.

## Load Instruction

Format:

| Bits | Field |
| --- | --- |
| `[31:20]` | `imm[11:0]` |
| `[19:15]` | `rs1` |
| `[14:12]` | `funct3` |
| `[11:7]` | `rd` |
| `[6:0]` | `opcode` |

Opcode: `0000011`

Supported instruction: `lw`

`lw` computes the address as `rs1 + sign_extend(imm[11:0])` and loads one
32-bit word into `rd`. The initial CPU assumes little-endian memory and supports
word loads only.

## Store Instruction

Format:

| Bits | Field |
| --- | --- |
| `[31:25]` | `imm[11:5]` |
| `[24:20]` | `rs2` |
| `[19:15]` | `rs1` |
| `[14:12]` | `funct3` |
| `[11:7]` | `imm[4:0]` |
| `[6:0]` | `opcode` |

Opcode: `0100011`

Supported instruction: `sw`

`sw` computes the address as `rs1 + sign_extend({imm[11:5], imm[4:0]})` and
stores the 32-bit value from `rs2`. Byte and halfword stores are out of scope
for the initial version.

## Branch Instructions

Format:

| Bits | Field |
| --- | --- |
| `[31]` | `imm[12]` |
| `[30:25]` | `imm[10:5]` |
| `[24:20]` | `rs2` |
| `[19:15]` | `rs1` |
| `[14:12]` | `funct3` |
| `[11:8]` | `imm[4:1]` |
| `[7]` | `imm[11]` |
| `[6:0]` | `opcode` |

Opcode: `1100011`

Supported instructions: `beq`, `bne`, `blt`, `bge`.

Branch immediates are sign-extended, shifted left by 1 bit, and added to the
current PC when the branch condition is true. The low bit is always zero because
branch targets are at least 2-byte aligned in the RISC-V encoding. The initial
CPU will only implement the listed signed branch comparisons plus equality and
inequality.

## Jump Instructions

### `jal`

Format:

| Bits | Field |
| --- | --- |
| `[31]` | `imm[20]` |
| `[30:21]` | `imm[10:1]` |
| `[20]` | `imm[11]` |
| `[19:12]` | `imm[19:12]` |
| `[11:7]` | `rd` |
| `[6:0]` | `opcode` |

Opcode: `1101111`

`jal` writes `PC + 4` to `rd` and updates the PC to
`PC + sign_extend(j_imm)`. The encoded immediate represents a signed
PC-relative offset with an implied low zero bit.

### `jalr`

Format:

| Bits | Field |
| --- | --- |
| `[31:20]` | `imm[11:0]` |
| `[19:15]` | `rs1` |
| `[14:12]` | `funct3` |
| `[11:7]` | `rd` |
| `[6:0]` | `opcode` |

Opcode: `1100111`
Funct3: `000`

`jalr` writes `PC + 4` to `rd` and updates the PC to
`(rs1 + sign_extend(imm[11:0])) & ~1`. Clearing bit 0 matches the RISC-V target
address rule for `jalr`.

## Upper Immediate Instructions

Format:

| Bits | Field |
| --- | --- |
| `[31:12]` | `imm[31:12]` |
| `[11:7]` | `rd` |
| `[6:0]` | `opcode` |

Supported instructions:

| Instruction | Opcode | Behavior |
| --- | --- | --- |
| `lui` | `0110111` | `rd = imm[31:12] << 12` |
| `auipc` | `0010111` | `rd = PC + (imm[31:12] << 12)` |

U-type immediates occupy the upper 20 bits of the instruction and are placed in
bits `[31:12]` of the result, with bits `[11:0]` set to zero.
