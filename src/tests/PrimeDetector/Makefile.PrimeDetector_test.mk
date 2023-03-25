# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM = icarus
TOPLEVEL_LANG = verilog

VERILOG_SOURCES = $(PWD)/tests/PrimeDetector/PrimeDetector_test_tb.v 
VERILOG_SOURCES += $(PWD)/PrimeDetector.v
VERILOG_SOURCES += $(PWD)/sipo.v
VERILOG_SOURCES += $(PWD)/reg.v
VERILOG_SOURCES += $(PWD)/change_detect.v
VERILOG_SOURCES += $(PWD)/counter.v
VERILOG_SOURCES += $(PWD)/itr_div.v
VERILOG_SOURCES += $(PWD)/fsm_control.v
VERILOG_SOURCES += $(PWD)/debouncer.v

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = PrimeDetector_test_tb

# MODULE is the basename of the Python test file
MODULE = PrimeDetector_test
export PYTHONPATH := tests/PrimeDetector:$(PYTHONPATH)

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim