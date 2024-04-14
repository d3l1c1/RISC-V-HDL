.PHONY: all
all:
	yosys build.ys

test_alu_dec:
	iverilog -o alu_dec_wave testbench/alu_dec_tb.v alu_decoder.v
	vvp alu_dec_wave -lx2
	gtkwave control.vcd

test_control: test_wave
	vvp test_wave -lxt2
	gtkwave control.vcd

test_wave:
	iverilog -o test_wave testbench/control_path_tb.v alu_decoder.v control_decoder.v  forwarding_unit.v hazard_unit.v control_path.v

.PHONY: clean
clean:
	rm control.vcd
	rm alu_dec_wave
	rm test_wave
	rm hardware.json