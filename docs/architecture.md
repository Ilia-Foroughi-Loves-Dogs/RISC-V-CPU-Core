# Architecture

This document defines the initial CPU architecture scope for the project. The
first implementation will be a simple single-cycle RV32I core. A 5-stage
pipelined version is planned after the single-cycle core is implemented,
simulated, and tested.

## Initial CPU Scope

| Feature | Initial Decision |
| --- | --- |
| ISA base | RV32I subset |
| CPU word size | 32-bit |
| Instruction width | 32-bit |
| Register count | 32 general-purpose registers |
| Register width | 32 bits |
| `x0` behavior | Hardwired to zero |
| Initial design | Single-cycle CPU |
| Later design | 5-stage pipelined CPU |
| Instruction memory | Separate instruction memory |
| Data memory | Separate data memory |
| Memory byte order | Little-endian |
| Initial memory operations | Word load and word store only |

The first version will not include interrupts, exceptions, CSRs, privilege
modes, or compressed instructions. Keeping these features out of scope makes the
initial datapath and control logic easier to understand and verify.

## Register File

The CPU will include 32 architectural registers named `x0` through `x31`.
Each register is 32 bits wide.

Register `x0` is special:

- Reads from `x0` always return `32'h00000000`.
- Writes to `x0` have no visible effect.

The initial register file is expected to support two read ports and one write
port so R-type, branch, store, and ALU-immediate instructions can be executed in
a single cycle.

## Memory Model

The initial CPU will use separate instruction memory and data memory. This is a
simple Harvard-style organization that avoids structural conflicts in the
single-cycle design.

Initial memory assumptions:

- Instruction memory returns one 32-bit instruction for the current PC.
- Data memory supports `lw` and `sw` only.
- Word accesses are 32 bits wide.
- Memory is little-endian.
- Byte, halfword, unaligned access behavior, and memory-mapped I/O are out of
  scope for the first version.

## Initial Single-Cycle Datapath

The planned single-cycle CPU will complete each instruction in one clock cycle.
The major blocks are:

| Block | Purpose |
| --- | --- |
| Program counter | Holds the address of the current instruction |
| Instruction memory | Provides the 32-bit instruction at the current PC |
| Register file | Reads source operands and writes destination results |
| Immediate generator | Extracts and sign-extends instruction immediates |
| Control unit | Decodes opcode-level instruction behavior |
| ALU control | Converts decode information into a specific ALU operation |
| ALU | Performs arithmetic, logical, shift, compare, and address operations |
| Data memory | Handles word loads and word stores |
| Writeback mux | Selects ALU result, memory data, `PC + 4`, or upper-immediate result |
| Next-PC logic | Selects `PC + 4`, branch target, `jal` target, or `jalr` target |

At a high level, the PC fetches an instruction, the control logic decodes it,
the register file and immediate generator provide operands, the ALU computes a
result or address, memory is accessed when needed, and the writeback mux selects
the value written to the destination register.

## Phase 2 Implemented Modules

The following standalone modules are implemented under `rtl/`:

| Module | Description |
| --- | --- |
| `program_counter` | Holds the current 32-bit instruction address and updates to `next_pc` each clock cycle. |
| `register_file` | Provides 32 general-purpose 32-bit registers with two asynchronous read ports, one synchronous write port, reset clearing, and hardwired `x0`. |
| `alu` | Performs RV32I arithmetic, logical, shift, and compare operations and produces a zero flag. |
| `immediate_generator` | Extracts and sign-extends I-type, S-type, B-type, U-type, and J-type immediates. |
| `control_unit` | Decodes opcode-level instruction classes into datapath control signals. |
| `alu_control` | Converts `alu_op`, `funct3`, and `funct7` fields into a specific ALU operation. |
| `instruction_memory` | Provides simple simulation-only instruction storage loaded from `tests/programs/program.mem`. |
| `data_memory` | Provides simple simulation-only word-addressed data memory with combinational reads and synchronous writes. |

These modules are now integrated by the Phase 3 single-cycle core.

## Phase 3 Single-Cycle Core Integration

The Phase 3 core connects the Phase 2 blocks into one single-cycle datapath.
Each instruction is fetched, decoded, executed, and committed using the current
PC value in one architectural cycle.

High-level datapath flow:

1. The program counter provides the current instruction address.
2. Instruction memory returns the 32-bit instruction at that PC.
3. The core decodes `opcode`, `funct3`, `funct7`, `rs1`, `rs2`, and `rd`.
4. The control unit selects register write, ALU source, memory access, branch,
   jump, ALU operation class, and immediate format signals.
5. The register file reads `rs1` and `rs2` while the immediate generator builds
   the sign-extended immediate.
6. The ALU executes arithmetic, logical, shift, compare, address, or AUIPC
   addition work.
7. Data memory is accessed for `lw` and `sw`.
8. The writeback mux selects the value written to `rd`.
9. Next-PC logic chooses the address for the next cycle.

Writeback selection:

| Instruction class | Writeback value |
| --- | --- |
| R-type and I-type ALU | ALU result |
| `lw` | Data memory read data |
| `jal`, `jalr` | `PC + 4` |
| `lui` | U-type immediate |
| `auipc` | `PC + U-type immediate` |

Next-PC logic:

| Flow | Next PC |
| --- | --- |
| Normal instruction | `PC + 4` |
| Taken branch | `PC + B-type immediate` |
| `jal` | `PC + J-type immediate` |
| `jalr` | `(rs1 + I-type immediate) & 32'hffff_fffe` |

Branch and jump handling is intentionally simple in the single-cycle core.
Branches are resolved directly from the register operands in the same cycle:
`beq` compares equality, `bne` compares inequality, `blt` uses signed less-than,
and `bge` uses signed greater-than-or-equal. `jal` uses the J-type immediate
relative to the current PC, while `jalr` uses `rs1 + immediate` with bit 0
cleared as required by RV32I.

## Planned 5-Stage Pipeline

The later pipeline target will split instruction execution into:

1. Instruction Fetch
2. Instruction Decode
3. Execute
4. Memory
5. Write Back

The pipeline version will build on the single-cycle design after the basic
datapath, control signals, and instruction behavior are already verified.

## Out of Scope for Initial Version

- Multiplication and division
- Floating point
- Compressed instructions
- Interrupts
- Exceptions
- Control and status registers
- Privilege modes
- Virtual memory
- Caches
- Branch prediction
- Byte and halfword memory operations
- Atomic instructions
