#!/usr/bin/env python3
"""Assemble a small RV32I subset into a .mem hex file.

This is intentionally a tiny project helper, not a full RISC-V assembler. It
supports the instructions used by tests/programs and reports clear errors when
an input program uses syntax outside that subset.
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


class AssemblerError(Exception):
    """Raised when assembly input cannot be encoded."""


@dataclass(frozen=True)
class Instruction:
    mnemonic: str
    operands: list[str]
    line_number: int
    source: str
    pc: int


R_TYPE = {
    "add": (0x00, 0x0),
    "sub": (0x20, 0x0),
    "sll": (0x00, 0x1),
    "slt": (0x00, 0x2),
    "sltu": (0x00, 0x3),
    "xor": (0x00, 0x4),
    "srl": (0x00, 0x5),
    "sra": (0x20, 0x5),
    "or": (0x00, 0x6),
    "and": (0x00, 0x7),
}

I_TYPE = {
    "addi": 0x0,
    "slti": 0x2,
    "sltiu": 0x3,
    "xori": 0x4,
    "ori": 0x6,
    "andi": 0x7,
}

SHIFT_I_TYPE = {
    "slli": (0x00, 0x1),
    "srli": (0x00, 0x5),
    "srai": (0x20, 0x5),
}

BRANCH_TYPE = {
    "beq": 0x0,
    "bne": 0x1,
    "blt": 0x4,
    "bge": 0x5,
}

UPPER_TYPE = {
    "lui": 0x37,
    "auipc": 0x17,
}

REGISTER_RE = re.compile(r"^x([0-9]|[12][0-9]|3[01])$")
MEMORY_RE = re.compile(r"^(.+)\((x[0-9]+)\)$")


def parse_register(token: str, inst: Instruction) -> int:
    match = REGISTER_RE.fullmatch(token.strip())
    if not match:
        raise AssemblerError(
            f"{location(inst)}: invalid register '{token}'. Use x0 through x31."
        )
    return int(match.group(1))


def parse_int(token: str, inst: Instruction) -> int:
    try:
        return int(token, 0)
    except ValueError as exc:
        raise AssemblerError(f"{location(inst)}: invalid immediate '{token}'.") from exc


def require_operand_count(inst: Instruction, count: int) -> None:
    if len(inst.operands) != count:
        operands = ", ".join(inst.operands)
        raise AssemblerError(
            f"{location(inst)}: '{inst.mnemonic}' expects {count} operands, "
            f"got {len(inst.operands)} ({operands})."
        )


def check_signed_range(value: int, bits: int, inst: Instruction, name: str) -> None:
    low = -(1 << (bits - 1))
    high = (1 << (bits - 1)) - 1
    if value < low or value > high:
        raise AssemblerError(
            f"{location(inst)}: {name} {value} does not fit in signed {bits} bits."
        )


def check_unsigned_range(value: int, bits: int, inst: Instruction, name: str) -> None:
    high = (1 << bits) - 1
    if value < 0 or value > high:
        raise AssemblerError(
            f"{location(inst)}: {name} {value} does not fit in unsigned {bits} bits."
        )


def location(inst: Instruction) -> str:
    return f"line {inst.line_number} at PC 0x{inst.pc:08x}"


def split_operands(text: str) -> list[str]:
    if not text.strip():
        return []
    return [part.strip() for part in text.split(",")]


def strip_comment(line: str) -> str:
    return line.split("#", 1)[0].strip()


def parse_assembly(path: Path) -> tuple[list[Instruction], dict[str, int]]:
    instructions: list[Instruction] = []
    labels: dict[str, int] = {}
    pc = 0

    for line_number, raw_line in enumerate(path.read_text().splitlines(), start=1):
        line = strip_comment(raw_line)
        if not line:
            continue

        while ":" in line:
            label, rest = line.split(":", 1)
            label = label.strip()
            if not label or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", label):
                raise AssemblerError(f"line {line_number}: invalid label '{label}'.")
            if label in labels:
                raise AssemblerError(f"line {line_number}: duplicate label '{label}'.")
            labels[label] = pc
            line = rest.strip()
            if not line:
                break

        if not line:
            continue

        parts = line.split(None, 1)
        mnemonic = parts[0].lower()
        operands = split_operands(parts[1] if len(parts) == 2 else "")
        if mnemonic == "nop":
            if operands:
                raise AssemblerError(f"line {line_number}: 'nop' takes no operands.")
            mnemonic = "addi"
            operands = ["x0", "x0", "0"]

        instructions.append(
            Instruction(
                mnemonic=mnemonic,
                operands=operands,
                line_number=line_number,
                source=raw_line.rstrip(),
                pc=pc,
            )
        )
        pc += 4

    return instructions, labels


def encode_r_type(funct7: int, rs2: int, rs1: int, funct3: int, rd: int) -> int:
    return (
        (funct7 << 25)
        | (rs2 << 20)
        | (rs1 << 15)
        | (funct3 << 12)
        | (rd << 7)
        | 0x33
    )


def encode_i_type(imm: int, rs1: int, funct3: int, rd: int, opcode: int = 0x13) -> int:
    return ((imm & 0xFFF) << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode


def encode_s_type(imm: int, rs2: int, rs1: int, funct3: int) -> int:
    imm12 = imm & 0xFFF
    return (
        ((imm12 >> 5) << 25)
        | (rs2 << 20)
        | (rs1 << 15)
        | (funct3 << 12)
        | ((imm12 & 0x1F) << 7)
        | 0x23
    )


def encode_b_type(imm: int, rs2: int, rs1: int, funct3: int) -> int:
    imm13 = imm & 0x1FFF
    return (
        (((imm13 >> 12) & 0x1) << 31)
        | (((imm13 >> 5) & 0x3F) << 25)
        | (rs2 << 20)
        | (rs1 << 15)
        | (funct3 << 12)
        | (((imm13 >> 1) & 0xF) << 8)
        | (((imm13 >> 11) & 0x1) << 7)
        | 0x63
    )


def encode_u_type(imm: int, rd: int, opcode: int) -> int:
    return ((imm & 0xFFFFF) << 12) | (rd << 7) | opcode


def encode_j_type(imm: int, rd: int) -> int:
    imm21 = imm & 0x1FFFFF
    return (
        (((imm21 >> 20) & 0x1) << 31)
        | (((imm21 >> 1) & 0x3FF) << 21)
        | (((imm21 >> 11) & 0x1) << 20)
        | (((imm21 >> 12) & 0xFF) << 12)
        | (rd << 7)
        | 0x6F
    )


def parse_memory_operand(token: str, inst: Instruction) -> tuple[int, int]:
    match = MEMORY_RE.fullmatch(token.replace(" ", ""))
    if not match:
        raise AssemblerError(
            f"{location(inst)}: expected memory operand like 0(x1), got '{token}'."
        )
    imm = parse_int(match.group(1), inst)
    rs1 = parse_register(match.group(2), inst)
    return imm, rs1


def resolve_label_or_immediate(token: str, labels: dict[str, int], inst: Instruction) -> int:
    if token in labels:
        return labels[token] - inst.pc
    return parse_int(token, inst)


def encode_instruction(inst: Instruction, labels: dict[str, int]) -> int:
    m = inst.mnemonic

    if m in R_TYPE:
        require_operand_count(inst, 3)
        rd = parse_register(inst.operands[0], inst)
        rs1 = parse_register(inst.operands[1], inst)
        rs2 = parse_register(inst.operands[2], inst)
        funct7, funct3 = R_TYPE[m]
        return encode_r_type(funct7, rs2, rs1, funct3, rd)

    if m in I_TYPE:
        require_operand_count(inst, 3)
        rd = parse_register(inst.operands[0], inst)
        rs1 = parse_register(inst.operands[1], inst)
        imm = parse_int(inst.operands[2], inst)
        check_signed_range(imm, 12, inst, "immediate")
        return encode_i_type(imm, rs1, I_TYPE[m], rd)

    if m in SHIFT_I_TYPE:
        require_operand_count(inst, 3)
        rd = parse_register(inst.operands[0], inst)
        rs1 = parse_register(inst.operands[1], inst)
        shamt = parse_int(inst.operands[2], inst)
        check_unsigned_range(shamt, 5, inst, "shift amount")
        funct7, funct3 = SHIFT_I_TYPE[m]
        imm = (funct7 << 5) | shamt
        return encode_i_type(imm, rs1, funct3, rd)

    if m == "lw":
        require_operand_count(inst, 2)
        rd = parse_register(inst.operands[0], inst)
        imm, rs1 = parse_memory_operand(inst.operands[1], inst)
        check_signed_range(imm, 12, inst, "load offset")
        return encode_i_type(imm, rs1, 0x2, rd, opcode=0x03)

    if m == "sw":
        require_operand_count(inst, 2)
        rs2 = parse_register(inst.operands[0], inst)
        imm, rs1 = parse_memory_operand(inst.operands[1], inst)
        check_signed_range(imm, 12, inst, "store offset")
        return encode_s_type(imm, rs2, rs1, 0x2)

    if m in BRANCH_TYPE:
        require_operand_count(inst, 3)
        rs1 = parse_register(inst.operands[0], inst)
        rs2 = parse_register(inst.operands[1], inst)
        imm = resolve_label_or_immediate(inst.operands[2], labels, inst)
        check_signed_range(imm, 13, inst, "branch offset")
        if imm % 2 != 0:
            raise AssemblerError(f"{location(inst)}: branch offset must be 2-byte aligned.")
        return encode_b_type(imm, rs2, rs1, BRANCH_TYPE[m])

    if m == "jal":
        require_operand_count(inst, 2)
        rd = parse_register(inst.operands[0], inst)
        imm = resolve_label_or_immediate(inst.operands[1], labels, inst)
        check_signed_range(imm, 21, inst, "jump offset")
        if imm % 2 != 0:
            raise AssemblerError(f"{location(inst)}: jump offset must be 2-byte aligned.")
        return encode_j_type(imm, rd)

    if m == "jalr":
        rd = None
        rs1 = None
        imm = None
        if len(inst.operands) == 2:
            rd = parse_register(inst.operands[0], inst)
            imm, rs1 = parse_memory_operand(inst.operands[1], inst)
        elif len(inst.operands) == 3:
            rd = parse_register(inst.operands[0], inst)
            rs1 = parse_register(inst.operands[1], inst)
            imm = parse_int(inst.operands[2], inst)
        else:
            raise AssemblerError(
                f"{location(inst)}: 'jalr' expects rd, imm(rs1) or rd, rs1, imm."
            )
        check_signed_range(imm, 12, inst, "jalr offset")
        return encode_i_type(imm, rs1, 0x0, rd, opcode=0x67)

    if m in UPPER_TYPE:
        require_operand_count(inst, 2)
        rd = parse_register(inst.operands[0], inst)
        imm = parse_int(inst.operands[1], inst)
        check_unsigned_range(imm, 20, inst, "upper immediate")
        return encode_u_type(imm, rd, UPPER_TYPE[m])

    raise AssemblerError(f"{location(inst)}: unsupported instruction '{m}'.")


def assemble(input_path: Path) -> list[int]:
    instructions, labels = parse_assembly(input_path)
    if not instructions:
        raise AssemblerError(f"{input_path}: no instructions found.")
    return [encode_instruction(inst, labels) for inst in instructions]


def write_mem(words: list[int], output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("".join(f"{word:08x}\n" for word in words))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Convert a small supported RV32I assembly subset into a .mem file."
    )
    parser.add_argument("input", type=Path, help="Input .asm file")
    parser.add_argument("output", type=Path, help="Output .mem file")
    args = parser.parse_args(argv)

    try:
        words = assemble(args.input)
        write_mem(words, args.output)
    except OSError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    except AssemblerError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    print(f"Assembled {len(words)} instruction(s)")
    print(f"Input : {args.input}")
    print(f"Output: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
