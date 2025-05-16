RTL_DIR = ./rtl
TB_DIR = ./tb
BUILD = ./build
DUT = $(RTL_DIR)/adder.v
TEST_BENCH = $(TB_DIR)/tb_adder.sv
LOG = simv.log
COMP_OPT = -full64 -sverilog -ntb_opts uvm-1.2

vcs:
	vcs $(COMP_OPT) $(DUT) $(TEST_BENCH)

simv:
	./simv +UVM_TESTNAME=test -l $(LOG)

.PHONY: vcs simv