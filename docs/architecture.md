# Architecture

## Overview

The current RISC-V CPU Core is a 32-bit single-cycle processor implementing a
focused subset of RV32I. The design uses separate instruction and data memories,
a 32-register integer register file, an immediate generator, main control
decode, ALU control decode, an ALU, data memory, writeback selection, and
next-PC logic.

Simple block view:

```text
PC -> Instruction Memory -> Decode -> Register File -> ALU -> Data Memory -> Writeback
```

## CPU Design Goals

- Keep the first CPU implementation readable and easy to debug.
- Implement a practical RV32I subset before adding pipeline complexity.
- Use clear module boundaries for datapath, control, memory, and testbenches.
- Support directed instruction-level programs for the implemented instruction
  groups.
- Document the architecture honestly, including current limitations.

## Single-Cycle Architecture

The CPU completes each instruction in one architectural cycle. During that
cycle, the core fetches an instruction, decodes it, reads source operands,
generates immediates, computes an ALU result or memory address, optionally
accesses data memory, selects writeback data, and computes the next PC.

State updates occur on the clock edge:

- The program counter loads `next_pc`.
- The register file writes `rd` when `reg_write` is asserted and `rd != x0`.
- Data memory stores a word when `mem_write` is asserted.

## Major Datapath Blocks

| Block | RTL module | Purpose |
| --- | --- | --- |
| Program counter | `program_counter` | Holds the current instruction address and updates to `next_pc`. |
| Instruction memory | `instruction_memory` | Loads a `.mem` file and returns the instruction at `pc[31:2]`. |
| Register file | `register_file` | Provides two asynchronous read ports and one synchronous write port. |
| Immediate generator | `immediate_generator` | Builds sign-extended I, S, B, U, and J immediates. |
| Control unit | `control_unit` | Decodes opcode-level control signals. |
| ALU control | `alu_control` | Converts `alu_op`, `funct3`, and `funct7` into an ALU operation. |
| ALU | `alu` | Performs arithmetic, logical, shift, compare, and address operations. |
| Data memory | `data_memory` | Provides word load/store memory for simulation. |
| Core integration | `riscv_core` | Connects blocks and implements branch, jump, writeback, and debug outputs. |

## Detailed Datapath Diagram

```text
                         +----------------------+
                         |      next_pc mux     |
                         | PC+4 / branch / jump |
                         +----------+-----------+
                                    |
                                    v
+---------+      address      +-------------+      instruction      +--------+
|   PC    +------------------>| Instr Mem   +---------------------->| Decode |
+----+----+                   +-------------+                       +---+----+
     |                                                                 |
     | pc                                                              |
     |                                                                 v
     |                   +----------------+       +-------------------------+
     |                   | Control Unit   |------>| control signals         |
     |                   +----------------+       +-------------------------+
     |                                                                 |
     |               rs1/rs2/rd                                        |
     |                     v                                           v
     |              +---------------+        read_data1        +---------------+
     |              | Register File +------------------------->| ALU op A mux  |
     |              +-------+-------+                          +-------+-------+
     |                      | read_data2                                |
     |                      |                                           v
     |                      |      +--------------------+        +-------------+
     |                      +----->| ALU op B mux       +------->|     ALU     |
     |                             | rs2 or immediate   |        +------+------+ 
     |                             +---------+----------+               |
     |                                       ^                          |
     |                                       | imm_out                  v
     |                             +---------+----------+        +-------------+
     |                             | Immediate Gen      |        | Data Memory |
     |                             +--------------------+        +------+------+ 
     |                                                                 |
     |                                  +------------------------------+
     |                                  v
     |                         +----------------+
     +------------------------>| Writeback mux  |
                               | ALU/mem/PC+4/ |
                               | LUI immediate |
                               +-------+--------+
                                       |
                                       v
                                 register rd
```

## Instruction Fetch

The program counter provides the current byte address. Instruction memory uses
`address[31:2]` as a word index, so instruction addresses are treated as
word-aligned. The instruction memory initializes unused locations to a NOP
encoding, `addi x0, x0, 0`.

The default program image is:

```text
tests/programs/program.mem
```

The testbench can load another program with the `+PROGRAM=...` plusarg, wrapped
by Makefile targets.

## Instruction Decode

The core extracts standard RISC-V fields:

- `opcode = instruction[6:0]`
- `rd = instruction[11:7]`
- `funct3 = instruction[14:12]`
- `rs1 = instruction[19:15]`
- `rs2 = instruction[24:20]`
- `funct7 = instruction[31:25]`

The control unit decodes the opcode into register write, ALU source, memory
access, branch, jump, ALU operation class, and immediate source signals. The
ALU control block refines the ALU operation using `alu_op`, `funct3`, and
`funct7`.

## Execute Stage

The ALU is used for:

- R-type arithmetic, logic, shift, and compare operations
- I-type arithmetic, logic, shift, and compare operations
- Load/store address calculation
- `jalr` target calculation support
- `auipc` result calculation

For most instructions, ALU operand A is `rs1`. For `auipc`, operand A is the
current PC. ALU operand B is selected between `rs2` and the generated immediate
using `alu_src`.

## Memory Access

Data memory supports the current memory subset:

- `lw`: combinational word read when `mem_read` is asserted
- `sw`: synchronous word write on the rising clock edge when `mem_write` is
  asserted

The data memory indexes words with `address[31:2]`. Byte, halfword, and
unaligned memory behavior are outside the current implementation.

## Writeback

The core writes a value to `rd` when `reg_write` is asserted. The selected
writeback value is:

| Instruction class | Writeback value |
| --- | --- |
| R-type ALU | ALU result |
| I-type ALU | ALU result |
| `lw` | Data memory read data |
| `jal`, `jalr` | `PC + 4` |
| `lui` | U-type immediate |
| `auipc` | ALU result, computed as `PC + U-type immediate` |

Writes to `x0` are ignored by the register file.

## Next-PC Logic

The default next PC is `PC + 4`. The core overrides this value for taken
branches and jumps:

| Flow | Next PC |
| --- | --- |
| Normal instruction | `PC + 4` |
| Taken branch | `PC + B-type immediate` |
| `jal` | `PC + J-type immediate` |
| `jalr` | `(rs1 + I-type immediate) & 32'hffff_fffe` |

## Branch and Jump Handling

Branches are resolved in the same cycle using the register operands:

| Instruction | Condition |
| --- | --- |
| `beq` | `rs1 == rs2` |
| `bne` | `rs1 != rs2` |
| `blt` | signed `rs1 < rs2` |
| `bge` | signed `rs1 >= rs2` |

`jal` uses a PC-relative J-type immediate. `jalr` uses `rs1 + I-type immediate`
and clears bit 0 of the target address.

## Pipeline Hazard Handling

The pipelined core in `rtl/riscv_pipelined_core.sv` includes basic Phase 8
hazard handling while the single-cycle core remains unchanged.

- The forwarding unit selects EX/MEM or MEM/WB results for ID/EX source
  operands when an instruction depends on a recent register write.
- The hazard detection unit detects load-use hazards and taken branch/jump
  control hazards.
- Stall control holds the PC and IF/ID register for a load-use hazard.
- Flush control clears IF/ID and ID/EX to safe NOP-like values for bubbles and
  wrong-path instructions.

Forwarding feeds ALU operands, branch comparisons, `jalr` target calculation,
and store write data. Load-use hazards still require one bubble because the
loaded data is not available soon enough for the immediately following EX
stage.

## Control Flow in the Pipelined Core

The pipelined core uses predict-not-taken control flow. IF fetches `PC + 4`
until EX resolves a taken branch, `jal`, or `jalr`.

Branch comparison happens in EX using forwarded `rs1` and `rs2` values. The
implemented branch conditions are `beq`, `bne`, signed `blt`, and signed `bge`.
The branch target is generated as the branch instruction PC plus the B-type
immediate.

Jump target generation also happens in EX. `jal` uses the instruction PC plus
the J-type immediate. `jalr` uses forwarded `rs1` plus the I-type immediate and
clears target bit 0. Both jump forms write `PC + 4` to `rd`.

PC selection gives priority to a resolved jump or taken branch over sequential
fetch. When the PC redirects, IF/ID and ID/EX are flushed so younger wrong-path
instructions cannot write registers or memory. Older valid instructions already
in later stages continue normally.

## Memory Model

The current memory model is simulation-oriented:

- Separate instruction and data memories
- 1024 32-bit words in each memory module
- Instruction memory initialized from a `.mem` file
- Data memory initialized to zero
- Word addressing through `address[31:2]`
- Word loads and stores only

This is enough for directed instruction programs but does not model caches,
memory-mapped I/O, byte enables, bus protocols, or real external memory timing.

## Register File Behavior

The register file has 32 architectural registers, `x0` through `x31`.

- Registers are 32 bits wide.
- Reads are asynchronous.
- Writes are synchronous on the rising clock edge.
- Reset clears all registers to zero.
- `x0` always reads as zero.
- Writes to `x0` have no visible effect.

## Phase 7 5-Stage Pipeline Architecture

Phase 7 adds a separate pipelined CPU in `rtl/riscv_pipelined_core.sv`. The
single-cycle CPU remains in `rtl/riscv_core.sv` and is still tested.

The pipelined core splits instruction execution into five stages:

| Stage | Purpose |
| --- | --- |
| IF | Fetch the instruction at the current PC and compute `PC + 4`. |
| ID | Decode fields, generate control signals and immediates, and read the register file. |
| EX | Select ALU operands, execute ALU operations, and calculate branch or jump targets. |
| MEM | Access data memory for `lw` and `sw`. |
| WB | Select ALU, memory, `PC + 4`, or LUI immediate data and write `rd`. |

Pipeline registers separate the stages:

| Register | RTL module | Stored values |
| --- | --- | --- |
| IF/ID | `if_id_reg` | Fetch PC, `PC + 4`, and instruction. |
| ID/EX | `id_ex_reg` | Decoded operands, immediate, register fields, function fields, opcode, and control. |
| EX/MEM | `ex_mem_reg` | ALU result, store data, branch target/decision, destination register, and MEM/WB control. |
| MEM/WB | `mem_wb_reg` | Memory read data, ALU result, immediate, destination register, and WB control. |

In Phase 7, the PC normally advances by 4. Branch and jump target calculation is
present, but there is no pipeline flush logic yet, so control-flow-heavy
programs are not the main validation target for this phase.

The major current limitation is that there is no forwarding or hazard detection
unit. A consumer instruction can read an old register value if it reaches ID
before the producer reaches WB. Test programs therefore insert
`32'h00000013` NOP instructions (`addi x0, x0, 0`) between dependent
instructions.

## Current Limitations

- Single-cycle and first pipelined implementations are both present
- No hazard detection, forwarding, stalls, or flushes
- No branch prediction
- No interrupts, exceptions, CSRs, or privilege modes
- No compressed instructions
- No multiplication, division, atomics, or floating point
- No byte or halfword load/store instructions
- No unaligned memory access support
- Simulation memory model only

Later phases will add hazard detection, forwarding, stalls, flushes, and
improved control-flow handling. The single-cycle design remains the baseline
used to validate instruction behavior while the pipeline grows.
