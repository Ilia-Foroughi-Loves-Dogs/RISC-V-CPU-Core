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
repository, installs the required simulation tools, prints tool versions, and
executes the full Makefile regression.

## Workflow Triggers

The CI workflow is configured to run on:

- `push`: every time commits are pushed to the repository.
- `pull_request`: every time a pull request is opened or updated.

## CI Dependencies

The workflow installs:

- `make`: runs the repository's test targets.
- `iverilog`: provides Icarus Verilog and `vvp` for compiling and running the
  SystemVerilog simulations.

## CI Command

The CI regression command is:

```sh
make test-all
```

This target runs module tests, single-cycle core tests, directed instruction
program tests, pipelined core tests, hazard tests, and pipeline control-flow
tests.

## Viewing Results on GitHub

To view CI results:

1. Open the repository on GitHub.
2. Select the Actions tab.
3. Choose the `RISC-V CPU Core CI` workflow.
4. Open the latest run to inspect each step and its log output.

Pull requests also show the workflow result directly in the pull request checks
section.

## Debugging a Failing CI Run

Start by opening the failed GitHub Actions run and expanding the `Run all
tests` step. The log should show which Makefile target or simulation failed.

Common debugging steps:

- Reproduce the same command locally with `make test-all`.
- Run the failing subtarget directly, such as `make test-alu` or
  `make test-pipeline-jal`.
- Check the generated logs under `sim/logs/`.
- Confirm that the expected `.mem` program file exists under
  `tests/programs/`.
- Generate a waveform locally with `make wave-core` or `make wave-pipeline`
  when signal-level debugging is needed.

The CI workflow should be treated as an automated version of the local test
flow, not as a separate test system.
