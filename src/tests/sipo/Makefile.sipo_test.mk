# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM = icarus
TOPLEVEL_LANG = verilog

VERILOG_SOURCES = $(PWD)/tests/sipo/sipo_test_tb.v 
VERILOG_SOURCES += $(PWD)/sipo.v

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = sipo_test_tb

# MODULE is the basename of the Python test file
MODULE = sipo_test
export PYTHONPATH := tests/sipo:$(PYTHONPATH)

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim