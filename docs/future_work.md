# Future Work

This document lists possible improvements that could be added after the Phase
10 portfolio release. These items are not required for the current project
scope.

## Verification and Tooling

- Full RV32I compliance testing
- RISC-V assembler flow for generating `.mem` files from assembly
- Verilator support
- cocotb tests
- GitHub Actions CI
- Formal verification with SymbiYosys
- Additional waveform examples and screenshots

## Pipeline and Microarchitecture

- Better branch prediction
- Branch target buffer experiments
- More detailed performance counters for simulation
- More pipeline debug visibility

## Memory and Bus Interfaces

- Cache implementation
- AXI or Wishbone bus interface
- More realistic memory latency models
- Byte and halfword load/store support

## FPGA and System Integration

- FPGA synthesis support
- FPGA board top-level wrapper
- UART/peripheral memory map
- Simple boot or demo program flow

## ISA and Privileged Features

- Interrupt and exception support
- CSR support
- Privilege mode support

Any future work should be added carefully so it does not obscure the current
educational value of the single-cycle and pipelined cores.
