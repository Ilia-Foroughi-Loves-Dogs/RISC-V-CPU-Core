# RISC-V CPU Core

[![RISC-V CPU Core CI](https://github.com/Ilia-Foroughi-Loves-Dogs/RISC-V-CPU-Core/actions/workflows/ci.yml/badge.svg)](https://github.com/Ilia-Foroughi-Loves-Dogs/RISC-V-CPU-Core/actions/workflows/ci.yml)

![Language: SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-blue)
![Simulation: Icarus Verilog](https://img.shields.io/badge/Simulation-Icarus%20Verilog-green)
![Lint: Verilator](https://img.shields.io/badge/Lint-Verilator-orange)
![Verification: cocotb](https://img.shields.io/badge/Verification-cocotb-blueviolet)
![Status: Educational / Portfolio Project](https://img.shields.io/badge/Status-Educational%20%2F%20Portfolio%20Project-lightgrey)

A portfolio-level SystemVerilog implementation of a small RV32I-inspired
32-bit CPU core. The repository includes both a single-cycle core and a
5-stage pipelined core, directed instruction tests, VCD waveform generation,
and documentation for the architecture, datapath, pipeline, testing flow, and
known limitations.

Current status: **Phase 13 - cocotb Python verification**

## Key Features

- RV32I-inspired 32-bit CPU core
- Single-cycle CPU implementation
- 5-stage pipelined CPU implementation
- IF, ID, EX, MEM, and WB pipeline stages
- Register file with `x0` hardwired to zero
- ALU arithmetic and logical operations
- Immediate generator
- Control unit
- Instruction memory
- Data memory
- Forwarding unit
- Hazard detection unit
- Load-use stall support
- Branch and jump flush handling
- Makefile-based simulation workflow
- Instruction-level test programs
- VCD waveform generation
- Verilator lint checks
- cocotb Python verification for key RTL modules

## Architecture Overview

The project contains two CPU implementations:

- `rtl/riscv_core.sv`: a single-cycle baseline core.
- `rtl/riscv_pipelined_core.sv`: a 5-stage pipelined core.

The single-cycle core completes one instruction per architectural cycle. The
pipelined core splits instruction execution into the classic five stages:

```text
IF -> ID -> EX -> MEM -> WB
```

Both cores use separate instruction and data memories for simulation. The
pipelined core includes forwarding, load-use stall handling, and simple
predict-not-taken branch/jump handling with flushes when control flow is
redirected.

## Supported Instruction Subset

This is a focused RV32I subset, not a full compliance implementation.

| Group | Instructions |
| --- | --- |
| R-type ALU | `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu` |
| I-type ALU | `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu` |
| Memory | `lw`, `sw` |
| Branch | `beq`, `bne`, `blt`, `bge` |
| Jump | `jal`, `jalr` |
| Upper immediate | `lui`, `auipc` |

See [docs/instruction_set.md](docs/instruction_set.md) for instruction format
and encoding notes.

## Repository Structure

```text
RISC-V-CPU-Core/
├── docs/             # Architecture, pipeline, testing, waveform, and release docs
├── rtl/              # SystemVerilog RTL modules
├── tb/               # SystemVerilog testbenches
├── cocotb_tests/     # Python cocotb module tests
├── sim/              # Generated build outputs, logs, and waveforms
├── tests/programs/   # Assembly listings and .mem instruction images
├── scripts/          # Placeholder for future helper scripts
├── Makefile          # Repeatable simulation workflow
├── LICENSE
└── README.md
```

## Toolchain

The primary simulation flow uses:

- GNU Make
- Icarus Verilog with SystemVerilog support (`iverilog -g2012`)
- `vvp`

Additional design checking uses:

- Verilator for linting and RTL elaboration checks
- GTKWave for optional waveform viewing
- Python 3 and cocotb for Python-driven RTL verification

Icarus Verilog is used for the main SystemVerilog testbench simulations.
Verilator is used for linting and additional design checking. cocotb adds
Python-based verification for selected key modules.

## Quick Start

Install GNU Make, Icarus Verilog with SystemVerilog support, and `vvp`, then run
the full regression:

```sh
make test-all
```

If Verilator is installed, run the RTL lint checks:

```sh
make verilator-lint
```

If Python dependencies are installed, run the cocotb tests:

```sh
python3 -m pip install -r requirements.txt
make cocotb-test
```

Useful commands:

```sh
make test-modules
make test-core
make test-programs
make test-pipeline
make test-pipeline-hazards
make test-pipeline-control-flow
make wave-core
make wave-pipeline
make verilator-lint
make verilator-lint-core
make verilator-lint-pipeline
make cocotb-test
make cocotb-alu
make cocotb-register-file
make cocotb-immgen
make clean
```

## Running Tests

The main test target is:

```sh
make test-all
```

It runs module-level tests, the integrated single-cycle core test, directed
single-cycle instruction programs, the baseline pipelined core test, pipeline
hazard tests, and pipeline control-flow tests.

Individual test groups are available through the Makefile:

| Target | Purpose |
| --- | --- |
| `make test-modules` | Run standalone RTL module tests. |
| `make test-core` | Run the integrated single-cycle CPU test. |
| `make test-programs` | Run directed single-cycle instruction programs. |
| `make test-pipeline` | Run the baseline pipelined CPU program. |
| `make test-pipeline-hazards` | Run forwarding, hazard unit, load-use, and flush tests. |
| `make test-pipeline-control-flow` | Run branch, `jal`, and `jalr` pipeline tests. |
| `make cocotb-test` | Run all Python cocotb module tests. |
| `make cocotb-alu` | Run the ALU cocotb test. |
| `make cocotb-register-file` | Run the register file cocotb test. |
| `make cocotb-immgen` | Run the immediate generator cocotb test. |

See [docs/testing.md](docs/testing.md) for the complete testing workflow.

Traditional SystemVerilog testbenches are still included under `tb/` and remain
part of the main regression. cocotb complements those benches with
Python-based verification for the ALU, register file, and immediate generator.

## Verilator Checks

Run Verilator lint on both CPU implementations:

```sh
make verilator-lint
```

Individual lint targets are also available:

```sh
make verilator-lint-core
make verilator-lint-pipeline
```

Verilator checks are additional RTL quality checks. They do not replace the
Icarus Verilog simulation tests.

See [docs/verilator.md](docs/verilator.md) for the full Verilator guide.

## Continuous Integration

GitHub Actions is configured to run automatically on every push and pull
request. The CI workflow installs Icarus Verilog, Verilator, and GNU Make, then
runs:

```sh
make test-all
make verilator-lint
make cocotb-test
```

The workflow file is located at
[.github/workflows/ci.yml](.github/workflows/ci.yml). See
[docs/ci.md](docs/ci.md) for CI details and debugging notes.

## Generating Waveforms

Generate the single-cycle core waveform:

```sh
make wave-core
```

Generate the pipelined core waveform:

```sh
make wave-pipeline
```

Waveforms are written to:

```text
sim/waves/riscv_core.vcd
sim/waves/riscv_pipelined_core.vcd
```

Open a waveform with GTKWave:

```sh
gtkwave sim/waves/riscv_core.vcd
```

See [docs/waveforms.md](docs/waveforms.md) for useful signals to inspect.

## Documentation Links

- [Documentation index](docs/README.md)
- [Architecture overview](docs/architecture.md)
- [Datapath](docs/datapath.md)
- [Pipeline](docs/pipeline.md)
- [Instruction set](docs/instruction_set.md)
- [Control signals](docs/control_signals.md)
- [Testing](docs/testing.md)
- [Verilator](docs/verilator.md)
- [cocotb](docs/cocotb.md)
- [Continuous integration](docs/ci.md)
- [Waveforms](docs/waveforms.md)
- [Project summary](docs/project_summary.md)
- [Known limitations](docs/known_limitations.md)
- [Future work](docs/future_work.md)
- [Demo guide](docs/demo.md)
- [Development plan](docs/development_plan.md)

## Example Test Programs

Readable `.asm` files and matching simulation-ready `.mem` files live in
`tests/programs/`.

Examples include:

- `alu_tests.asm` / `alu_tests.mem`
- `immediate_tests.asm` / `immediate_tests.mem`
- `load_store_tests.asm` / `load_store_tests.mem`
- `branch_tests.asm` / `branch_tests.mem`
- `jump_tests.asm` / `jump_tests.mem`
- `full_program_test.asm` / `full_program_test.mem`
- `pipeline_forwarding.asm` / `pipeline_forwarding.mem`
- `pipeline_load_use.asm` / `pipeline_load_use.mem`
- `pipeline_branch_taken.asm` / `pipeline_branch_taken.mem`
- `pipeline_jal.asm` / `pipeline_jal.mem`
- `pipeline_jalr.asm` / `pipeline_jalr.mem`

## Current Limitations

- Educational CPU model intended for simulation and portfolio review.
- Limited RV32I subset; not a full RISC-V compliance target.
- Simple separate instruction and data memories.
- Word-only `lw` and `sw` memory access.
- No caches, interrupts, exceptions, CSRs, privilege modes, compressed
  instructions, multiplication, division, floating point, or atomics.
- No formal verification yet.
- Pipelined control flow uses simple predict-not-taken behavior.

See [docs/known_limitations.md](docs/known_limitations.md) for more detail.

## Future Improvements

Possible future work includes full RV32I compliance testing, an assembler flow,
formal verification with SymbiYosys, broader cocotb coverage, better branch
prediction, cache experiments, a bus interface, FPGA synthesis support, and
basic peripherals.

See [docs/future_work.md](docs/future_work.md).

## Skills Demonstrated

- Computer architecture and CPU datapath design
- Single-cycle and pipelined processor implementation
- RISC-V instruction decode and immediate handling
- Pipeline registers, forwarding, stalls, and flushes
- SystemVerilog RTL design
- Directed simulation testbenches
- Python-based cocotb verification
- Makefile-based verification workflow
- Verilator lint integration
- VCD waveform debugging
- Technical documentation for a hardware project

## License

This project is released under the license in [LICENSE](LICENSE).
