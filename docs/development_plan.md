# Development Plan

This project is organized into phases so the CPU grows from a defined RV32I
subset into a tested single-cycle core and later a pipelined core.

| Phase | Status | Goal |
| --- | --- | --- |
| Phase 0 - Project setup | Complete | Create repository structure, starter documentation, and baseline project files. |
| Phase 1 - ISA definition and CPU scope | Complete | Define supported instructions, architecture scope, control signals, and test plan. |
| Phase 2 - Core datapath modules | Complete | Implement foundational blocks such as the ALU, register file, immediate generator, and memories. |
| Phase 3 - Single-cycle CPU integration | Complete | Connect datapath and control into a working single-cycle RV32I core. |
| Phase 4 - Simulation and testbench system | Complete | Add repeatable simulation commands, module testbenches, logs, and waveform flow. |
| Phase 5 - Instruction test programs | Complete | Add directed instruction programs and small end-to-end CPU programs. |
| Phase 6 - Documentation and diagrams | Complete | Improve README, architecture notes, datapath documentation, control signal docs, waveform guide, and portfolio summary. |
| Phase 7 - 5-stage pipeline upgrade | Complete | Split the single-cycle design into fetch, decode, execute, memory, and writeback stages. |
| Phase 8 - Hazard detection and forwarding | Current | Add stall, flush, and forwarding logic for pipeline correctness. |
| Phase 9 - Control flow improvements | Planned | Improve branch and jump handling in the pipelined design. |
| Phase 10 - Final polish and portfolio release | Planned | Clean documentation, tests, diagrams, and repository presentation for review. |

## Current Focus

Phase 8 is focused on making the 5-stage pipeline handle common hazards while
keeping the original single-cycle CPU working. The current pipeline supports
EX/MEM forwarding, MEM/WB forwarding, one-cycle load-use stalls, bubbles, and
simple taken branch/jump flushes.

## Future Phase Notes

Phase 9 will refine control-flow behavior for the pipelined design. Phase 10
will prepare the project for final portfolio presentation.
