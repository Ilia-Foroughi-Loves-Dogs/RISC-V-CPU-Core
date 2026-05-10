# Known Limitations

This project is intentionally scoped as an educational CPU model and portfolio
project. The current design is useful for studying CPU datapaths, pipelining,
hazards, and directed verification, but it is not a production processor or a
full RISC-V compliance target.

## Architecture and ISA Scope

- Educational CPU model intended for simulation.
- Limited RV32I subset rather than the complete RV32I base ISA.
- No compressed instructions.
- No multiplication or division instructions.
- No floating-point support.
- No atomics.
- No CSR instructions.
- No privilege modes.
- No interrupts or exceptions.

## Memory System

- Simple separate instruction and data memory model.
- No caches.
- No AXI, Wishbone, or other external bus interface.
- No memory-mapped peripherals.
- Word-only `lw` and `sw` support.
- No byte or halfword load/store instructions.
- No unaligned memory access support.

## Pipeline Behavior

- The pipelined core uses simple predict-not-taken control flow.
- Branches and jumps are resolved in EX.
- Taken branches and jumps flush younger wrong-path instructions.
- There is no dynamic branch predictor, branch target buffer, or return-address
  stack.

## Verification Scope

- Verification is based on directed simulation tests.
- No formal verification yet.
- No full RISC-V architectural compliance suite yet.
- No constrained-random verification environment yet.

These limitations are deliberate for the current phase. They keep the project
focused on a readable single-cycle core, a clear 5-stage pipeline, and a
repeatable simulation workflow.
