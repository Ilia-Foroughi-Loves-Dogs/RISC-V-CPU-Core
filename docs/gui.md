# Desktop GUI

Phase 16 adds a lightweight desktop GUI simulator helper for the RISC-V CPU
Core project. The GUI is written with Python and Tkinter, so it uses the Python
standard library and avoids extra desktop framework dependencies.

The GUI is a convenience layer over the existing Makefile flow. It does not
modify the CPU RTL, change testbench behavior, or add new CPU features.

## Launching the GUI

From the repository root:

```sh
make gui
```

You can also run the script directly:

```sh
python3 gui/riscv_gui.py
```

## Buttons

| Button | Command |
| --- | --- |
| Run All Tests | `make test-all` |
| Run Single-Cycle Core Test | `make test-core` |
| Run Pipelined Core Test | `make test-pipeline` |
| Run Pipeline Hazard Tests | `make test-pipeline-hazards` |
| Run Pipeline Control Flow Tests | `make test-pipeline-control-flow` |
| Run Verilator Lint | `make verilator-lint` |
| Run cocotb Tests | `make cocotb-test` |
| Verify .mem Files | `make verify-mem` |
| Generate Single-Cycle Waveform | `make wave-core` |
| Generate Pipeline Waveform | `make wave-pipeline` |
| Run Formal Checks | `make formal-all` |
| Clean Build Outputs | `make clean` |

## Output Area

Command output appears in the scrollable text area at the bottom of the window.
The GUI shows the command being run, the command output, and a pass/fail status
based on the command exit code. Commands run in a worker thread so the Tkinter
window remains responsive while simulations are active.

## Program Selector

The program selector lists `.mem` files from:

```text
tests/programs/
```

The **Run Selected Program** button runs the selected file with the Makefile
`PROGRAM` variable:

```sh
make test-core PROGRAM=tests/programs/example.mem
```

This works with the current Makefile support for custom single-cycle core
programs. The baseline pipelined target also supports `PROGRAM=...` from the
command line, but the GUI keeps the beginner action focused on the single-cycle
core path.

## Waveforms

The waveform buttons call the existing Makefile targets:

```sh
make wave-core
make wave-pipeline
```

Expected waveform paths:

```text
sim/waves/riscv_core.vcd
sim/waves/riscv_pipelined_core.vcd
```

The **Open Waveform Folder** button opens `sim/waves` with the platform file
browser using `open` on macOS, `xdg-open` on Linux, and `explorer` on Windows.
Use a waveform viewer such as GTKWave to inspect the generated `.vcd` files.

## Formal Checks

The **Run Formal Checks** button runs:

```sh
make formal-all
```

These checks require SymbiYosys, Yosys, and an SMT solver to be installed
locally. If those tools are missing, the output area will show the Makefile or
toolchain error.

## Limitations

- The GUI is a helper for existing Makefile commands, not a replacement for the
  command-line flow.
- It does not add FPGA synthesis support.
- It does not modify CPU RTL, tests, or instruction behavior.
- Toolchain commands still require their normal dependencies, such as Icarus
  Verilog, Verilator, cocotb, or SymbiYosys depending on the selected action.
