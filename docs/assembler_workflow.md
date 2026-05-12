# Assembly Test Program Workflow

This project keeps readable assembly programs and simulation-ready memory
images side by side under `tests/programs/`.

## Why `.mem` Files Are Needed

The SystemVerilog instruction memory loads instructions from plain text `.mem`
files during simulation. Each nonempty line is one 32-bit instruction word in
hexadecimal:

```text
00500093
00700113
002081b3
```

This format is easy for the testbenches to load with Verilog file I/O. It is
less readable than assembly, so the repository also keeps matching `.asm`
files that document the intended instruction sequence.

## How Assembly Maps to Memory Hex

The helper script `scripts/asm_to_mem.py` parses a small RV32I subset and
encodes each assembly instruction into its 32-bit machine-code word. The output
file contains one lowercase 8-character hex word per line, in program order.

For example:

```asm
addi x1, x0, 5
addi x2, x0, 7
add  x3, x1, x2
```

becomes:

```text
00500093
00700113
002081b3
```

Labels are resolved relative to the current instruction PC for branches and
jumps. The first instruction starts at byte address `0`, and each instruction
advances the PC by 4 bytes.

## Generate One `.mem` File

Run the assembler with an input `.asm` path and output `.mem` path:

```sh
python3 scripts/asm_to_mem.py tests/programs/basic_arithmetic.asm tests/programs/basic_arithmetic.mem
```

The script prints how many instructions it assembled and fails with a clear
line-numbered error for unsupported instructions, invalid registers, bad
immediates, duplicate labels, or malformed memory operands.

## Verify All Program Files

Run:

```sh
make verify-mem
```

This runs `scripts/verify_mem_files.py`, which checks that:

- every `.asm` file in `tests/programs/` has a matching `.mem` file
- every `.mem` file is nonempty
- every `.mem` line is exactly 8 hexadecimal characters
- regenerated assembler output matches the checked-in `.mem` files

## Regenerate All Supported Programs

Run:

```sh
make regenerate-programs
```

This assembles every `tests/programs/*.asm` file and overwrites the matching
`.mem` file. Review the resulting diff before committing regenerated images.

## Supported Syntax

The assembler currently supports the project instruction subset:

| Group | Instructions |
| --- | --- |
| R-type ALU | `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu` |
| I-type ALU | `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu` |
| Memory | `lw`, `sw` |
| Branch | `beq`, `bne`, `blt`, `bge` |
| Jump | `jal`, `jalr` |
| Upper immediate | `lui`, `auipc` |

It also supports:

- `nop`, encoded as `addi x0, x0, 0`
- labels for branches and jumps
- comments beginning with `#`
- blank lines
- registers written as `x0` through `x31`
- decimal and `0x` hexadecimal immediates
- `jalr rd, imm(rs1)` and `jalr rd, rs1, imm`

## Current Limitations

This is a beginner-friendly project assembler, not a complete RISC-V toolchain.
Current limitations include:

- no pseudoinstructions except `nop`
- no ABI register names such as `zero`, `ra`, or `a0`
- no assembler directives such as `.text`, `.data`, `.word`, or `.org`
- no data-section generation
- no compressed, multiply/divide, CSR, privilege, or system instructions
- no relocation, linking, or ELF support

For larger programs, use a real RISC-V assembler. For this repository's small
directed test programs, the local helper keeps the assembly and `.mem` files
easy to inspect and verify.
