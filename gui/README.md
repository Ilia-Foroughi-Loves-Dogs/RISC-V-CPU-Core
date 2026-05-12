# RISC-V CPU Core GUI

This folder contains a small Tkinter desktop helper for the RISC-V CPU Core
project. It gives beginners clickable access to the existing Makefile
simulation, verification, waveform, and cleanup commands.

Launch it from the repository root:

```sh
make gui
```

or run the script directly:

```sh
python3 gui/riscv_gui.py
```

The GUI does not change CPU behavior or add new simulation features. It runs
the same commands that are already available in the root Makefile and displays
their output in a scrollable text area.
