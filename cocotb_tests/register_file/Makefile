TOPLEVEL_LANG ?= verilog
SIM ?= icarus

VERILOG_SOURCES := $(abspath ../../rtl/register_file.sv)
TOPLEVEL := register_file
COCOTB_TEST_MODULES := test_register_file

COMPILE_ARGS += -g2012

include $(shell python3 -m cocotb_tools.config --makefiles)/Makefile.sim
