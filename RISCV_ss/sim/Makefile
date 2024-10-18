all: build run wave

prj = rv_ss

file:
	find . -name "*.sv" > file.f
	find ../rtl/ -name "*.sv" >> file.f

build:
	iverilog -f file.f -y ./ -o ./$(prj) -g2005-sv
	
run:
	vvp -n ./$(prj)

wave:
	gtkwave $(prj).vcd

clear:
	rm $(prj) $(prj).vcd
	