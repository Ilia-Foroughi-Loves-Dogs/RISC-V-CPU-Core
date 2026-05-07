.PHONY: help clean test test-core wave-core test-pc test-regfile test-alu test-immgen test-control test-alu-control test-dmem test-modules

CORE_RTL = \
	rtl/program_counter.sv \
	rtl/instruction_memory.sv \
	rtl/register_file.sv \
	rtl/immediate_generator.sv \
	rtl/control_unit.sv \
	rtl/alu_control.sv \
	rtl/alu.sv \
	rtl/data_memory.sv \
	rtl/riscv_core.sv

help:
	@echo "RISC-V CPU Core"
	@echo ""
	@echo "Available targets:"
	@echo "  make help             Show this help message"
	@echo "  make test             Run project tests"
	@echo "  make test-core        Run the integrated single-cycle CPU test"
	@echo "  make wave-core        Run the CPU test and generate sim/riscv_core.vcd"
	@echo "  make test-modules     Run all Phase 2 module tests"
	@echo "  make test-pc          Test the program counter"
	@echo "  make test-regfile     Test the register file"
	@echo "  make test-alu         Test the ALU"
	@echo "  make test-immgen      Test the immediate generator"
	@echo "  make test-control     Test the control unit"
	@echo "  make test-alu-control Test the ALU control decoder"
	@echo "  make test-dmem        Test the data memory"
	@echo "  make clean            Remove generated simulation and build outputs"

test: test-modules test-core

build:
	@mkdir -p build

sim:
	@mkdir -p sim

test-core: build sim
	iverilog -g2012 -o build/tb_riscv_core.out $(CORE_RTL) tb/tb_riscv_core.sv
	vvp build/tb_riscv_core.out

wave-core: test-core
	@echo "Waveform written to sim/riscv_core.vcd"

test-pc: build
	iverilog -g2012 -o build/tb_program_counter.out rtl/program_counter.sv tb/tb_program_counter.sv
	vvp build/tb_program_counter.out

test-regfile: build
	iverilog -g2012 -o build/tb_register_file.out rtl/register_file.sv tb/tb_register_file.sv
	vvp build/tb_register_file.out

test-alu: build
	iverilog -g2012 -o build/tb_alu.out rtl/alu.sv tb/tb_alu.sv
	vvp build/tb_alu.out

test-immgen: build
	iverilog -g2012 -o build/tb_immediate_generator.out rtl/immediate_generator.sv tb/tb_immediate_generator.sv
	vvp build/tb_immediate_generator.out

test-control: build
	iverilog -g2012 -o build/tb_control_unit.out rtl/control_unit.sv tb/tb_control_unit.sv
	vvp build/tb_control_unit.out

test-alu-control: build
	iverilog -g2012 -o build/tb_alu_control.out rtl/alu_control.sv tb/tb_alu_control.sv
	vvp build/tb_alu_control.out

test-dmem: build
	iverilog -g2012 -o build/tb_data_memory.out rtl/data_memory.sv tb/tb_data_memory.sv
	vvp build/tb_data_memory.out

test-modules: test-pc test-regfile test-alu test-immgen test-control test-alu-control test-dmem

clean:
	@echo "Cleaning generated files..."
	@rm -rf build sim/build obj_dir xsim.dir work
	@rm -f sim/riscv_core.vcd *.vcd *.fst *.ghw *.wdb *.jou *.log *.pb *.o *.out
