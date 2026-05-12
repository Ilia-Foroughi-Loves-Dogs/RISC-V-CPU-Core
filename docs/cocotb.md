# cocotb Python Verification

cocotb is a Python-based verification framework for HDL designs. It lets tests
drive RTL signals directly from Python while an HDL simulator, such as Icarus
Verilog, runs the design.

## Why cocotb Is Useful

cocotb makes it easier to write expressive checks, reuse Python helper
functions, generate directed or randomized stimulus, and compare RTL results
against software reference models. For this project, cocotb adds a modern
Python verification layer without replacing the existing SystemVerilog
testbenches.

## Tested Modules

The current cocotb tests cover:

- `rtl/alu.sv`: arithmetic, logic, shifts, signed and unsigned comparisons, and
  zero flag behavior.
- `rtl/register_file.sv`: reset, normal register writes and reads, hardwired
  `x0`, ignored writes to `x0`, and both read ports.
- `rtl/immediate_generator.sv`: I-type, S-type, B-type, U-type, and J-type
  immediates, including sign extension.

## Installing Dependencies

Install the simulator and Python dependencies:

```sh
sudo apt-get install iverilog
python3 -m pip install -r requirements.txt
```

On non-Ubuntu systems, install Icarus Verilog through the platform package
manager, then use the same `pip` command.

## Running Tests

Run all cocotb tests:

```sh
make cocotb-test
```

Run individual cocotb tests:

```sh
make cocotb-alu
make cocotb-register-file
make cocotb-immgen
```

Remove generated cocotb outputs:

```sh
make cocotb-clean
```

## Relationship to SystemVerilog Testbenches

The SystemVerilog testbenches under `tb/` remain part of the main regression.
They verify modules, the single-cycle CPU core, program execution, and the
pipelined CPU flow. The cocotb tests complement those benches by adding
Python-based checks for key datapath modules.

## CI Integration

GitHub Actions installs Icarus Verilog, Verilator, and the Python dependencies
from `requirements.txt`. CI runs:

```sh
make test-all
make verilator-lint
make cocotb-test
```
