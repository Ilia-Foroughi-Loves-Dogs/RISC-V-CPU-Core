# Development Plan

This project is organized into phases so the CPU can grow from a clearly
defined RV32I subset into a tested single-cycle core and then a pipelined core.

| Phase | Status | Goal |
| --- | --- | --- |
| Phase 0 - Project setup | Complete | Create repository structure, starter documentation, and baseline project files |
| Phase 1 - ISA definition and CPU scope | Current | Define supported instructions, architecture scope, control signals, and test plan |
| Phase 2 - Core datapath modules | Planned | Implement foundational blocks such as the ALU, register file, immediate generator, and memories |
| Phase 3 - Single-cycle CPU integration | Planned | Connect datapath and control into a working single-cycle RV32I core |
| Phase 4 - Simulation and testbench system | Planned | Add repeatable simulation commands, module testbenches, and waveform flow |
| Phase 5 - Instruction test programs | Planned | Add directed instruction programs and small end-to-end CPU programs |
| Phase 6 - Documentation and diagrams | Planned | Add datapath diagrams, control-flow diagrams, and implementation notes |
| Phase 7 - 5-stage pipeline upgrade | Planned | Split the single-cycle design into fetch, decode, execute, memory, and writeback stages |
| Phase 8 - Hazard detection and forwarding | Planned | Add stall, flush, and forwarding logic for pipeline correctness |
| Phase 9 - Control flow improvements | Planned | Improve branch and jump handling in the pipelined design |
| Phase 10 - Final polish and portfolio release | Planned | Clean documentation, tests, diagrams, and repository presentation for review |

## Current Focus

Phase 1 is focused only on documentation and planning. No RTL modules,
testbenches, or CPU implementation files should be added during this phase.
