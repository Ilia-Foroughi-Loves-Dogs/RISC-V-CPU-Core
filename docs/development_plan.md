# Development Plan

This project was developed in phases so the CPU could grow from a defined
RV32I subset into a tested single-cycle core, then into a simple pipelined core
with hazard and control-flow handling.

| Phase | Status | Goal |
| --- | --- | --- |
| Phase 0 - Project setup | Complete | Create repository structure, starter documentation, and baseline project files. |
| Phase 1 - ISA definition and CPU scope | Complete | Define supported instructions, architecture scope, control signals, and test plan. |
| Phase 2 - Core datapath modules | Complete | Implement foundational blocks such as the ALU, register file, immediate generator, and memories. |
| Phase 3 - Single-cycle CPU integration | Complete | Connect datapath and control into a working single-cycle RV32I-inspired core. |
| Phase 4 - Simulation and testbench system | Complete | Add repeatable simulation commands, module testbenches, logs, and waveform flow. |
| Phase 5 - Instruction test programs | Complete | Add directed instruction programs and small end-to-end CPU programs. |
| Phase 6 - Documentation and diagrams | Complete | Improve README, architecture notes, datapath documentation, control signal docs, waveform guide, and portfolio summary. |
| Phase 7 - 5-stage pipeline upgrade | Complete | Split the design into fetch, decode, execute, memory, and writeback stages. |
| Phase 8 - Hazard detection and forwarding | Complete | Add forwarding, load-use stall handling, and basic flush support. |
| Phase 9 - Control flow improvements | Complete | Improve branch, `jal`, and `jalr` handling in the pipelined design. |
| Phase 10 - Final polish and portfolio release | Complete | Polish documentation, test workflow, repository presentation, limitations, and future roadmap. |
| Phase 11 - GitHub Actions CI | Complete | Add GitHub Actions automation to run the full Makefile regression on pushes and pull requests. |
| Phase 12 - Verilator support | Complete | Add Verilator lint targets, CI checks, and documentation. |
| Phase 13 - cocotb Python verification | Complete | Add Python-based cocotb tests for key RTL modules and integrate them into CI and documentation. |
| Phase 14 - Assembly to memory file workflow | Complete | Add simple assembler tooling, memory-file verification, Make targets, CI checks, and documentation. |
| Phase 15 - Formal verification starter | Current | Add optional SymbiYosys/Yosys formal checks for selected RTL modules and document the local proof flow. |

## Current Phase Note

The current phase adds a lightweight formal verification starter without
changing CPU behavior or the existing Icarus Verilog, Verilator, or cocotb test
flows. The new checks use SymbiYosys/Yosys-style harnesses for selected
module-level properties in the program counter, register file, and ALU.

There are still meaningful future improvement opportunities, including full
RV32I compliance testing, deeper formal verification, a fuller assembler,
improved branch prediction, cache experiments, FPGA synthesis support,
peripherals, interrupts, exceptions, and CSR support.
