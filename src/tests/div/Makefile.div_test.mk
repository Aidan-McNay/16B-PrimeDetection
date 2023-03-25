# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM = icarus
TOPLEVEL_LANG = verilog

VERILOG_SOURCES = $(PWD)/tests/div/div_test_tb.v 
VERILOG_SOURCES += $(PWD)/itr_div.v
VERILOG_SOURCES += $(PWD)/shift_div.v
VERILOG_SOURCES += $(PWD)/div.v

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = div_test_tb

# MODULE is the basename of the Python test file
MODULE = div_test
export PYTHONPATH := tests/div:$(PYTHONPATH)

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim