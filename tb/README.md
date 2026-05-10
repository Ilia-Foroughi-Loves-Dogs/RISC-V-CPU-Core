# Testbenches

This directory contains SystemVerilog testbenches for standalone RTL modules,
the integrated single-cycle CPU, and the pipelined CPU.

## Integrated CPU Testbenches

- `tb_riscv_core.sv`: runs the single-cycle core, loads `.mem` instruction
  images, prints an execution trace, checks final register/memory state, and
  writes `sim/waves/riscv_core.vcd`.
- `tb_riscv_pipelined_core.sv`: runs the 5-stage pipelined core, prints
  stage-level debug traces, checks final register/memory state, and writes
  `sim/waves/riscv_pipelined_core.vcd`.

## Module Testbenches

Module-level tests cover the program counter, register file, ALU, immediate
generator, control unit, ALU control decoder, data memory, forwarding unit, and
hazard detection unit.

Run the complete test suite from the repository root:

```sh
make test-all
```
