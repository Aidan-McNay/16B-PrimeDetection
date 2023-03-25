# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM = icarus
TOPLEVEL_LANG = verilog

VERILOG_SOURCES = $(PWD)/tests/shift_div/shift_div_test_tb.v 
VERILOG_SOURCES += $(PWD)/shift_div.v

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = shift_div_test_tb

# MODULE is the basename of the Python test file
MODULE = shift_div_test
export PYTHONPATH := tests/shift_div:$(PYTHONPATH)

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim