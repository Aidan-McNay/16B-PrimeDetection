# Makefile to run tests for the PrimeDetector design

TESTS := itr_div_test shift_div_test div_test combo_div_test counter_test sipo_test change_detect_test PrimeDetector_test

all: clean_build $(TESTS)

clean_build:
	@rm -rf build
	@mkdir build

$(TESTS):
	@echo "Running $@..."
	@$(eval testdir=$(subst _test,,$@))
	@mkdir build/$(testdir)
	@$(MAKE) -C $(PWD)/.. -sf tests/$(testdir)/Makefile.$@.mk &> build/$(testdir)/$@_output.txt

	@mv ../sim_build build/$(testdir)/sim_build_$@
	@mv ../results.xml build/$(testdir)/results_$@.xml
	@mv ../$@_tb.vcd build/$(testdir)
	@if grep failure build/$(testdir)/results_$@.xml &> /dev/null; then echo "\033[37;41m - $@ failed\033[0m"; else echo "\033[37;42m - $@ passed!\033[0m"; fi;

