# Verilator

Verilator is an open-source SystemVerilog and Verilog tool widely used for RTL
linting, elaboration, and high-performance compiled simulation. In this
project, Verilator is used as an additional design-checking tool alongside the
existing Icarus Verilog simulation flow.

## Why Verilator Is Useful

Verilator catches many issues that are easy to miss in a small educational
testbench flow, including width mismatches, unused signals, incomplete
combinational logic, ambiguous constructs, and tool-portability problems.

For this CPU core, Verilator support helps show that the RTL is written in a
more industry-relevant style while keeping the project beginner-friendly.

## Installation

On Ubuntu or Debian:

```sh
sudo apt-get update
sudo apt-get install -y verilator
```

On macOS with Homebrew:

```sh
brew install verilator
```

Check the installed version:

```sh
verilator --version
```

## Running Lint Checks

Run Verilator lint on both CPU implementations:

```sh
make verilator-lint
```

Run only the single-cycle core lint check:

```sh
make verilator-lint-core
```

Run only the pipelined core lint check:

```sh
make verilator-lint-pipeline
```

## Makefile Targets

| Target | Purpose |
| --- | --- |
| `make verilator-lint` | Runs both Verilator lint checks. |
| `make verilator-lint-core` | Lints the single-cycle top-level design and RTL dependencies. |
| `make verilator-lint-pipeline` | Lints the pipelined top-level design and RTL dependencies. |
| `make verilator-build-core` | Elaborates the single-cycle design with Verilator and generates C++ output under `obj_dir/`. |
| `make verilator-build-pipeline` | Elaborates the pipelined design with Verilator and generates C++ output under `obj_dir/`. |
| `make verilator-clean` | Removes Verilator generated outputs. |

The lint targets use:

```sh
verilator --lint-only -Wall --timing -sv
```

The build targets use:

```sh
verilator --cc -Wall --timing -sv
```

The build targets elaborate the RTL and generate Verilator output. They do not
run a complete C++ simulation testbench.

## Relationship to Icarus Verilog Tests

Icarus Verilog remains the main simulator for this repository. The existing
testbenches are compiled with `iverilog -g2012` and executed with `vvp` through:

```sh
make test-all
```

Verilator lint checks are not a replacement for those simulations. They are an
additional RTL quality pass that checks the single-cycle and pipelined designs
from a stricter tool's perspective.

Before major commits, run:

```sh
make test-all
make verilator-lint
```

## Continuous Integration

GitHub Actions installs Verilator in addition to Icarus Verilog and GNU Make.
The CI workflow runs the existing simulation regression first:

```sh
make test-all
```

It then runs the Verilator lint checks:

```sh
make verilator-lint
```

This keeps behavioral simulation coverage and static RTL checking in the same
automated workflow.
