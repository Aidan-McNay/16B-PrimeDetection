# Makefile to run tests for the PrimeDetector design

TESTS := itr_div_test counter_test sipo_test change_detect_test
DESIGNS := itr_div counter sipo change_detect
RTL_LIBRARY = $(PWD)/..

all: clean_build $(DESIGNS)

clean_build:
	@rm -rf build
	@mkdir build

$(TESTS):
	@echo "Running $@..."
	@$(MAKE) -sf Makefile.$@.mk &> build/$@_output.txt

$(DESIGNS): % : %_test
	@mv sim_build build/sim_build_$@
	@mv results.xml build/results_$@.xml
	@mv $@_test_tb.vcd build
	@if grep failure build/results_$@.xml &> /dev/null; then echo "\033[37;41m - $@ failed\033[0m"; else echo "\033[37;42m - $@ passed!\033[0m"; fi;

