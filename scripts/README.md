# Scripts

Helper scripts for building, testing, assembling programs, and processing
simulation outputs live in this directory.

## Assembly Helpers

- `asm_to_mem.py`: converts the supported project assembly subset into `.mem`
  files with one 32-bit hex instruction per line.
- `verify_mem_files.py`: checks that `tests/programs/*.asm` files have matching,
  valid, synchronized `.mem` files.

Common commands:

```sh
python3 scripts/asm_to_mem.py tests/programs/basic_arithmetic.asm tests/programs/basic_arithmetic.mem
make verify-mem
make regenerate-programs
```
