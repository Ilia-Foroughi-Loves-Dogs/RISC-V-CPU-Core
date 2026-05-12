#!/usr/bin/env python3
"""Check assembly programs and their matching .mem files."""

from __future__ import annotations

import argparse
import re
import sys
import tempfile
from pathlib import Path

from asm_to_mem import AssemblerError, assemble, write_mem


HEX_LINE_RE = re.compile(r"^[0-9a-fA-F]{8}$")


def read_mem_lines(path: Path) -> list[str]:
    return [line.strip().lower() for line in path.read_text().splitlines() if line.strip()]


def validate_mem_format(path: Path) -> list[str]:
    errors: list[str] = []
    lines = read_mem_lines(path)
    if not lines:
        errors.append(f"{path}: file is empty")
        return errors

    for line_number, line in enumerate(lines, start=1):
        if not HEX_LINE_RE.fullmatch(line):
            errors.append(
                f"{path}:{line_number}: expected exactly 8 hexadecimal characters, got '{line}'"
            )
    return errors


def verify_program_pair(asm_path: Path, compare_generated: bool) -> list[str]:
    errors: list[str] = []
    mem_path = asm_path.with_suffix(".mem")

    if not mem_path.exists():
        return [f"{asm_path}: missing matching memory file {mem_path}"]

    errors.extend(validate_mem_format(mem_path))
    if errors or not compare_generated:
        return errors

    try:
        generated_words = assemble(asm_path)
    except AssemblerError as exc:
        return [f"{asm_path}: assembler error: {exc}"]
    except OSError as exc:
        return [f"{asm_path}: read error: {exc}"]

    with tempfile.TemporaryDirectory() as temp_dir:
        generated_path = Path(temp_dir) / mem_path.name
        write_mem(generated_words, generated_path)
        generated_lines = read_mem_lines(generated_path)

    existing_lines = read_mem_lines(mem_path)
    if generated_lines != existing_lines:
        errors.append(f"{mem_path}: does not match regenerated output from {asm_path}")
        limit = min(len(generated_lines), len(existing_lines))
        for index in range(limit):
            if generated_lines[index] != existing_lines[index]:
                errors.append(
                    f"  first mismatch at line {index + 1}: "
                    f"existing={existing_lines[index]} generated={generated_lines[index]}"
                )
                break
        if len(generated_lines) != len(existing_lines):
            errors.append(
                f"  line count differs: existing={len(existing_lines)} generated={len(generated_lines)}"
            )

    return errors


def find_orphan_mem_files(program_dir: Path) -> list[str]:
    errors: list[str] = []
    for mem_path in sorted(program_dir.glob("*.mem")):
        if not mem_path.with_suffix(".asm").exists():
            errors.append(f"{mem_path}: missing matching assembly file {mem_path.with_suffix('.asm')}")
    return errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Verify tests/programs .asm and .mem files."
    )
    parser.add_argument(
        "--program-dir",
        type=Path,
        default=Path("tests/programs"),
        help="Directory containing .asm and .mem program files",
    )
    parser.add_argument(
        "--format-only",
        action="store_true",
        help="Only check that .mem files exist, are nonempty, and contain valid hex",
    )
    args = parser.parse_args(argv)

    program_dir = args.program_dir
    if not program_dir.is_dir():
        print(f"ERROR: program directory not found: {program_dir}", file=sys.stderr)
        return 1

    asm_files = sorted(program_dir.glob("*.asm"))
    if not asm_files:
        print(f"ERROR: no .asm files found in {program_dir}", file=sys.stderr)
        return 1

    all_errors: list[str] = []
    for asm_path in asm_files:
        all_errors.extend(verify_program_pair(asm_path, compare_generated=not args.format_only))
    all_errors.extend(find_orphan_mem_files(program_dir))

    if all_errors:
        print("FAIL: program memory verification found issues")
        for error in all_errors:
            print(f"- {error}")
        return 1

    mode = "format-only" if args.format_only else "regenerated comparison"
    print(f"PASS: verified {len(asm_files)} assembly program(s) in {program_dir} ({mode})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
