vcs:
	vcs -full64 -sverilog -ntb_opts uvm-1.2 ./rtl/adder.v ./tb/tb_adder.sv

simv:
	./simv +UVM_TESTNAME=test -l simv.log

.PHONY: vcs simv