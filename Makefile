.PHONY: help clean test test-all test-core test-pipeline wave-core wave-pipeline test-pc test-regfile test-alu test-immgen test-control test-alu-control test-dmem test-modules test-alu-program test-immediate-program test-load-store-program test-branch-program test-jump-program test-upper-program test-full-program test-programs sim-dirs

SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

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

PIPELINE_RTL = \
	rtl/program_counter.sv \
	rtl/instruction_memory.sv \
	rtl/register_file.sv \
	rtl/immediate_generator.sv \
	rtl/control_unit.sv \
	rtl/alu_control.sv \
	rtl/alu.sv \
	rtl/data_memory.sv \
	rtl/if_id_reg.sv \
	rtl/id_ex_reg.sv \
	rtl/ex_mem_reg.sv \
	rtl/mem_wb_reg.sv \
	rtl/riscv_pipelined_core.sv \
	rtl/riscv_pipelined_top.sv

SIM_BUILD_DIR = sim/build
SIM_WAVE_DIR  = sim/waves
SIM_LOG_DIR   = sim/logs
CORE_OUT      = $(SIM_BUILD_DIR)/tb_riscv_core.out
CORE_LOG      = $(SIM_LOG_DIR)/riscv_core.log
CORE_WAVE     = $(SIM_WAVE_DIR)/riscv_core.vcd
PIPELINE_OUT  = $(SIM_BUILD_DIR)/tb_riscv_pipelined_core.out
PIPELINE_LOG  = $(SIM_LOG_DIR)/riscv_pipelined_core.log
PIPELINE_WAVE = $(SIM_WAVE_DIR)/riscv_pipelined_core.vcd
CORE_PROGRAM_ARG = $(if $(PROGRAM),+PROGRAM=$(PROGRAM) +CHECK_NONE,)
PIPELINE_PROGRAM_ARG = +PROGRAM=$(if $(PROGRAM),$(PROGRAM),tests/programs/pipeline_basic.mem)

define RUN_CORE_PROGRAM
	iverilog -g2012 -o $(CORE_OUT) $(CORE_RTL) tb/tb_riscv_core.sv
	vvp $(CORE_OUT) +PROGRAM=$(1) +$(3) | tee $(SIM_LOG_DIR)/$(2).log
endef

help:
	@echo "RISC-V CPU Core"
	@echo ""
	@echo "Available targets:"
	@echo "  make help             Show this help message"
	@echo "  make clean            Remove generated simulation files"
	@echo "  make test-modules     Run all Phase 2 module tests"
	@echo "  make test-core        Run the integrated single-cycle CPU test"
	@echo "  make test-pipeline    Run the Phase 7 pipelined CPU test"
	@echo "  make test-programs    Run all Phase 5 instruction program tests"
	@echo "  make wave-core        Run the CPU test and generate $(CORE_WAVE)"
	@echo "  make wave-pipeline    Run the pipelined CPU test and generate $(PIPELINE_WAVE)"
	@echo "  make test-all         Run module tests, core tests, and instruction program tests"
	@echo "  make test-pc          Test the program counter"
	@echo "  make test-regfile     Test the register file"
	@echo "  make test-alu         Test the ALU"
	@echo "  make test-immgen      Test the immediate generator"
	@echo "  make test-control     Test the control unit"
	@echo "  make test-alu-control Test the ALU control decoder"
	@echo "  make test-dmem        Test the data memory"

test: test-all

test-all: test-modules test-core test-programs test-pipeline

sim-dirs:
	@mkdir -p $(SIM_BUILD_DIR) $(SIM_WAVE_DIR) $(SIM_LOG_DIR)

test-core: sim-dirs
	iverilog -g2012 -o $(CORE_OUT) $(CORE_RTL) tb/tb_riscv_core.sv
	vvp $(CORE_OUT) $(CORE_PROGRAM_ARG) | tee $(CORE_LOG)

test-pipeline: sim-dirs
	iverilog -g2012 -s tb_riscv_pipelined_core -o $(PIPELINE_OUT) $(PIPELINE_RTL) tb/tb_riscv_pipelined_core.sv
	vvp $(PIPELINE_OUT) $(PIPELINE_PROGRAM_ARG) | tee $(PIPELINE_LOG)

wave-core: test-core
	@echo "Waveform written to $(CORE_WAVE)"

wave-pipeline: test-pipeline
	@echo "Waveform written to $(PIPELINE_WAVE)"

test-alu-program: sim-dirs
	$(call RUN_CORE_PROGRAM,tests/programs/alu_tests.mem,alu_tests,CHECK_ALU)

test-immediate-program: sim-dirs
	$(call RUN_CORE_PROGRAM,tests/programs/immediate_tests.mem,immediate_tests,CHECK_IMMEDIATE)

test-load-store-program: sim-dirs
	$(call RUN_CORE_PROGRAM,tests/programs/load_store_tests.mem,load_store_tests,CHECK_LOAD_STORE)

test-branch-program: sim-dirs
	$(call RUN_CORE_PROGRAM,tests/programs/branch_tests.mem,branch_tests,CHECK_BRANCH)

test-jump-program: sim-dirs
	$(call RUN_CORE_PROGRAM,tests/programs/jump_tests.mem,jump_tests,CHECK_JUMP)

test-upper-program: sim-dirs
	$(call RUN_CORE_PROGRAM,tests/programs/upper_tests.mem,upper_tests,CHECK_UPPER)

test-full-program: sim-dirs
	$(call RUN_CORE_PROGRAM,tests/programs/full_program_test.mem,full_program_test,CHECK_FULL)

test-programs: test-alu-program test-immediate-program test-load-store-program test-branch-program test-jump-program test-upper-program test-full-program

test-pc: sim-dirs
	iverilog -g2012 -o $(SIM_BUILD_DIR)/tb_program_counter.out rtl/program_counter.sv tb/tb_program_counter.sv
	vvp $(SIM_BUILD_DIR)/tb_program_counter.out

test-regfile: sim-dirs
	iverilog -g2012 -o $(SIM_BUILD_DIR)/tb_register_file.out rtl/register_file.sv tb/tb_register_file.sv
	vvp $(SIM_BUILD_DIR)/tb_register_file.out

test-alu: sim-dirs
	iverilog -g2012 -o $(SIM_BUILD_DIR)/tb_alu.out rtl/alu.sv tb/tb_alu.sv
	vvp $(SIM_BUILD_DIR)/tb_alu.out

test-immgen: sim-dirs
	iverilog -g2012 -o $(SIM_BUILD_DIR)/tb_immediate_generator.out rtl/immediate_generator.sv tb/tb_immediate_generator.sv
	vvp $(SIM_BUILD_DIR)/tb_immediate_generator.out

test-control: sim-dirs
	iverilog -g2012 -o $(SIM_BUILD_DIR)/tb_control_unit.out rtl/control_unit.sv tb/tb_control_unit.sv
	vvp $(SIM_BUILD_DIR)/tb_control_unit.out

test-alu-control: sim-dirs
	iverilog -g2012 -o $(SIM_BUILD_DIR)/tb_alu_control.out rtl/alu_control.sv tb/tb_alu_control.sv
	vvp $(SIM_BUILD_DIR)/tb_alu_control.out

test-dmem: sim-dirs
	iverilog -g2012 -o $(SIM_BUILD_DIR)/tb_data_memory.out rtl/data_memory.sv tb/tb_data_memory.sv
	vvp $(SIM_BUILD_DIR)/tb_data_memory.out

test-modules: test-pc test-regfile test-alu test-immgen test-control test-alu-control test-dmem

clean:
	@echo "Cleaning generated files..."
	@find $(SIM_BUILD_DIR) $(SIM_WAVE_DIR) $(SIM_LOG_DIR) -type f ! -name .gitkeep -delete
	@rm -rf build obj_dir xsim.dir work
	@rm -f sim/riscv_core.vcd *.vcd *.fst *.ghw *.wdb *.jou *.log *.pb *.o *.out
