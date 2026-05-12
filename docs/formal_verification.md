# Formal Verification

Formal verification uses mathematical proof engines to check whether a design
can ever violate a stated property. Instead of running one directed stimulus
sequence, the formal tool explores all possible input values within the proof
setup.

In this project, formal verification is a complement to the existing
SystemVerilog testbenches, Verilator lint checks, cocotb tests, and instruction
program simulations. It does not replace those flows.

## Why It Is Useful

CPU projects have many small blocks with precise contracts. Formal checks are
useful for these blocks because they can prove simple invariants over many
possible inputs:

- The program counter should reset and update predictably.
- Register `x0` should never stop reading as zero.
- ALU operations should match their arithmetic and logic definitions.

These are good starter properties because they are local, easy to understand,
and directly tied to expected CPU behavior.

## Checked Modules

The current formal setup checks:

| Module | Formal files |
| --- | --- |
| Program counter | `formal/program_counter/program_counter_formal.sv`, `formal/program_counter/program_counter.sby` |
| Register file | `formal/register_file/register_file_formal.sv`, `formal/register_file/register_file.sby` |
| ALU | `formal/alu/alu_formal.sv`, `formal/alu/alu.sby` |

## Checked Properties

Program counter:

- Reset sets `pc` to `0`.
- When reset is low, `pc` updates to the previous cycle's `next_pc`.
- `pc` does not become unknown when reset and `next_pc` are known.

Register file:

- `x0` always reads as `0`.
- Writes to `x0` do not change `x0`.
- Reset clears all registers.
- A write to a normal register is stored.
- Read ports match the selected register values.
- If both read ports select the same register, they return the same value.

ALU:

- ADD matches `operand_a + operand_b`.
- SUB matches `operand_a - operand_b`.
- AND matches `operand_a & operand_b`.
- OR matches `operand_a | operand_b`.
- XOR matches `operand_a ^ operand_b`.
- SLT matches signed less-than behavior.
- SLTU matches unsigned less-than behavior.
- `zero` is high exactly when `result` is zero.

## Required Tools

Install the formal tools at a high level:

1. Install Yosys.
2. Install SymbiYosys.
3. Install at least one SMT solver, such as Boolector, Yices, or Z3.

Exact package names vary by operating system. Some package managers include
Yosys but not SymbiYosys, so local installation may require following the
SymbiYosys project instructions.

## Running Checks

Run every formal check:

```sh
make formal-all
```

Run individual checks:

```sh
make formal-pc
make formal-regfile
make formal-alu
```

Remove generated proof output:

```sh
make formal-clean
```

Formal checks are intentionally not part of `make test-all`, because many
machines have simulation tools installed but do not have SymbiYosys and an SMT
solver available.

## Limitations

This is a starter formal setup. The current checks are module-level properties,
not full CPU proofs. They do not prove complete RV32I compliance, pipeline
correctness, forwarding correctness, memory ordering, or end-to-end program
behavior.

The proofs also use short bounded depths for the sequential modules. That is
enough for the simple reset and one-cycle update properties here, but deeper
CPU-level properties would need more careful assumptions and stronger proof
structure.

## Future Ideas

Useful future formal work could include:

- Formal checks for the control unit and ALU control decoder.
- Hazard detection and forwarding unit properties.
- Pipeline stall and flush invariants.
- Instruction decode properties for the supported RV32I subset.
- Memory interface assumptions and assertions.
- End-to-end checks that compare selected single-cycle and pipelined behavior.
- Integration with an optional CI workflow once tool installation is reliable.
