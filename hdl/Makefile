run_simulation:
	clear
	iverilog -o qrs_tb.vvp stimulus.v top.v
	vvp qrs_tb.vvp
	gtkwave qrs_results.vcd
