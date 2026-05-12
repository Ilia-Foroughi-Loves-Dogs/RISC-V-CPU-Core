TOPLEVEL_LANG ?= verilog
SIM ?= icarus

VERILOG_SOURCES := $(abspath ../../rtl/immediate_generator.sv)
TOPLEVEL := immediate_generator
COCOTB_TEST_MODULES := test_immediate_generator

COMPILE_ARGS += -g2012

include $(shell python3 -m cocotb_tools.config --makefiles)/Makefile.sim
