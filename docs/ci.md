# Continuous Integration

Continuous integration, or CI, means running automated checks whenever changes
are pushed to the repository or proposed in a pull request. For this project,
CI verifies that the SystemVerilog simulation regression can still compile and
run from a clean GitHub-hosted environment.

## GitHub Actions Workflow

This project uses GitHub Actions for CI. The workflow is defined in:

```text
.github/workflows/ci.yml
```

The workflow runs on GitHub-hosted Ubuntu runners. Each run checks out the
repository, installs the required simulation and lint tools, prints tool
versions, and executes the full Makefile regression plus Verilator lint checks.

## Workflow Triggers

The CI workflow is configured to run on:

- `push`: every time commits are pushed to the repository.
- `pull_request`: every time a pull request is opened or updated.

## CI Dependencies

The workflow installs:

- `make`: runs the repository's test targets.
- `iverilog`: provides Icarus Verilog and `vvp` for compiling and running the
  SystemVerilog simulations.
- `verilator`: provides linting and additional RTL design checks.

## CI Commands

The CI regression commands are:

```sh
make test-all
make verilator-lint
```

`make test-all` runs module tests, single-cycle core tests, directed
instruction program tests, pipelined core tests, hazard tests, and pipeline
control-flow tests.

`make verilator-lint` runs Verilator lint on the single-cycle and pipelined RTL
top-level designs.

## Viewing Results on GitHub

To view CI results:

1. Open the repository on GitHub.
2. Select the Actions tab.
3. Choose the `RISC-V CPU Core CI` workflow.
4. Open the latest run to inspect each step and its log output.

Pull requests also show the workflow result directly in the pull request checks
section.

## Debugging a Failing CI Run

Start by opening the failed GitHub Actions run and expanding either the `Run
all tests` step or the `Run Verilator lint` step. The log should show which
Makefile target, simulation, or lint check failed.

Common debugging steps:

- Reproduce the same command locally with `make test-all`.
- Reproduce Verilator failures locally with `make verilator-lint`.
- Run the failing subtarget directly, such as `make test-alu` or
  `make test-pipeline-jal`.
- For lint-only failures, run `make verilator-lint-core` or
  `make verilator-lint-pipeline`.
- Check the generated logs under `sim/logs/`.
- Confirm that the expected `.mem` program file exists under
  `tests/programs/`.
- Generate a waveform locally with `make wave-core` or `make wave-pipeline`
  when signal-level debugging is needed.

The CI workflow should be treated as an automated version of the local test
flow, not as a separate test system.
