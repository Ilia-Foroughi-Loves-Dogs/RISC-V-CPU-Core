# Pipeline

## Overview

Phase 7 introduces a basic 5-stage RV32I pipeline alongside the original
single-cycle CPU. The pipeline is intentionally simple: it demonstrates stage
separation and pipeline registers, but it does not yet implement forwarding,
automatic stalls, or flushes.

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

## Current Phase 7 Limitation

There is no forwarding or hazard detection yet. If one instruction writes a
register and the next instruction reads that register too soon, the consumer may
see the old value.

Problem without NOPs:

```asm
addi x1, x0, 5
add  x2, x1, x1
```

The `add` can read `x1` before the `addi` writes it back. Phase 7 programs
avoid this by inserting NOPs:

```asm
addi x1, x0, 5
nop
nop
nop
add  x2, x1, x1
```

The NOP encoding is:

```text
32'h00000013
```

## Planned Phase 8 Improvements

- Forwarding unit
- Hazard detection unit
- Load-use stalls
- Branch flushes
