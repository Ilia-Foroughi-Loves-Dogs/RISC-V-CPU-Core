# Formal Verification

This directory contains small SymbiYosys/Yosys formal checks for selected RTL
modules.

The current checks are intentionally beginner-friendly. They verify basic
module contracts for:

- `program_counter`: reset and next-PC update behavior.
- `register_file`: `x0`, reset clearing, write/read behavior, and read-port consistency.
- `alu`: arithmetic, logic, compare, and zero-flag behavior.

Formal checks are optional and separate from the normal simulation regression.
They require SymbiYosys, Yosys, and an SMT solver such as Boolector, Yices, or
Z3.

Run all checks:

```sh
make formal-all
```

Run one check:

```sh
make formal-pc
make formal-regfile
make formal-alu
```

Clean generated formal output:

```sh
make formal-clean
```
