# RTL

This directory contains the SystemVerilog RTL for the RISC-V CPU Core project.

## Main Cores

- `riscv_core.sv`: single-cycle RV32I-inspired CPU core.
- `riscv_pipelined_core.sv`: 5-stage pipelined CPU core with forwarding,
  load-use stall handling, and branch/jump flush support.
- `riscv_top.sv`: simple wrapper for the single-cycle core.
- `riscv_pipelined_top.sv`: simple wrapper for the pipelined core.

## Shared Modules

- `program_counter.sv`
- `instruction_memory.sv`
- `register_file.sv`
- `immediate_generator.sv`
- `control_unit.sv`
- `alu_control.sv`
- `alu.sv`
- `data_memory.sv`

## Pipeline Modules

- `if_id_reg.sv`
- `id_ex_reg.sv`
- `ex_mem_reg.sv`
- `mem_wb_reg.sv`
- `forwarding_unit.sv`
- `hazard_detection_unit.sv`

Run RTL simulations from the repository root with the Makefile targets
documented in the top-level README and `docs/testing.md`.
