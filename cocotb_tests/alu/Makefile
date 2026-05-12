TOPLEVEL_LANG ?= verilog
SIM ?= icarus

VERILOG_SOURCES := $(abspath ../../rtl/alu.sv)
TOPLEVEL := alu
COCOTB_TEST_MODULES := test_alu

COMPILE_ARGS += -g2012

include $(shell python3 -m cocotb_tools.config --makefiles)/Makefile.sim
