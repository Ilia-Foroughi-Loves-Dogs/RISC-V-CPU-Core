# Pipeline

## Overview

Phase 7 introduced a basic 5-stage RV32I pipeline alongside the original
single-cycle CPU. Phase 8 adds the first hazard handling: forwarding, load-use
stalls, bubbles, and simple taken branch/jump flushes.

```text
IF -> ID -> EX -> MEM -> WB
```

## Stages

| Stage | Name | Main work |
| --- | --- | --- |
| IF | Instruction Fetch | Read instruction memory using the PC and compute `PC + 4`. |
| ID | Instruction Decode | Decode instruction fields, control signals, immediates, and source operands. |
| EX | Execute | Run the ALU, compute addresses, and calculate branch/jump targets. |
| MEM | Memory Access | Perform `lw` reads and `sw` writes through data memory. |
| WB | Write Back | Select the final result and write the register file. |

## Pipeline Registers

| Register | Module | Description |
| --- | --- | --- |
| IF/ID | `rtl/if_id_reg.sv` | Carries fetch PC, `PC + 4`, and instruction into decode. |
| ID/EX | `rtl/id_ex_reg.sv` | Carries register operands, immediate, register IDs, function fields, opcode, and control into execute. |
| EX/MEM | `rtl/ex_mem_reg.sv` | Carries ALU result, store data, branch information, destination register, and memory/writeback control. |
| MEM/WB | `rtl/mem_wb_reg.sv` | Carries memory read data, ALU result, immediate, destination register, and writeback control. |

Each pipeline register clears to safe zero/default values on reset. The IF/ID
register resets to a NOP instruction, `32'h00000013`.

## Instruction Movement

An instruction is fetched in IF, advances into ID on the next rising clock edge,
then moves through EX, MEM, and WB on later rising edges. Once the pipeline is
full, independent instructions can occupy different stages at the same time.

For example:

```text
cycle N:     addi is in IF
cycle N + 1: addi is in ID
cycle N + 2: addi is in EX
cycle N + 3: addi is in MEM
cycle N + 4: addi is in WB
```

## Phase 8 Hazard Handling

Pipeline hazards happen when overlapping instructions need values or control
decisions that are not naturally available yet. Phase 8 keeps the design simple
and handles the most important cases for small directed programs.

### Data Hazards and Forwarding

For ALU-to-ALU dependencies, the producer result may already exist before it
has reached the register file. The forwarding unit compares the source
registers in ID/EX with destination registers in EX/MEM and MEM/WB:

- EX/MEM forwarding uses the newest ALU, `lui`, or jump-link result.
- MEM/WB forwarding uses the final writeback value.
- EX/MEM has priority over MEM/WB when both match.
- Register `x0` is never forwarded.

Example:

```asm
addi x1, x0, 5
addi x2, x1, 3
```

The second instruction needs `x1` before `addi x1, x0, 5` writes back. Phase 8
forwards the `x1` result into the EX stage, so this sequence no longer needs
manual NOPs.

Forwarded `rs2` is also used as store write data, so a sequence such as an ALU
operation followed by `sw` can store the fresh value.

### Load-Use Hazards

A load value is not available early enough for the very next instruction's EX
stage. This sequence still needs one automatic stall:

```asm
lw  x2, 0(x0)
add x3, x2, x1
```

When ID/EX is a load and its `rd` matches IF/ID `rs1` or `rs2`, the hazard
detection unit:

- Holds the PC.
- Holds the IF/ID register.
- Flushes ID/EX to insert a bubble.

After that one-cycle bubble, the dependent instruction advances and can receive
the loaded value through MEM/WB forwarding.

### Bubbles, Stalls, and Flushes

A stall prevents younger instructions from advancing. A bubble is a safe NOP-like
instruction inserted into the pipeline by clearing control signals. A flush
removes wrong-path instructions by resetting pipeline register contents to safe
defaults.

Taken branches and jumps resolve in EX. When a branch or jump is taken, IF/ID
and ID/EX are flushed so younger wrong-path instructions do not commit.

### Remaining Limitations

- Branch and jump resolution still happens in EX.
- There is no branch prediction.
- There are no exceptions, interrupts, CSRs, privilege modes, caches,
  compressed instructions, multiplication, division, or floating point.
- Memory support remains word-only `lw` and `sw`.

The NOP encoding used by tests and pipeline flush defaults is:

```text
32'h00000013
```
