module testbench();
	logic clk;
	logic reset;
	logic [31:0] WriteData, DataAdr;
	logic MemWrite;
	// instantiate device to be tested

	top dut(clk, reset, WriteData, DataAdr, MemWrite);
// initialize test

// dump wave file
    initial begin
        $dumpfile("rv_pipe.vcd");
        $dumpvars(0, testbench);
    end

	initial
	begin
		clk = 0;
		#5000 $stop;
	end

	initial
	begin
		reset <= 1; # 22; reset <= 0;
	end

// generate clock to sequence tests
	always
	begin
		clk <= 1; # 5; clk <= 0; # 5;
	end

// check results
	always @(negedge clk)
	begin
		if(MemWrite) begin
			if(DataAdr === 132 & WriteData === 32'hABCDE02E) begin
			$display("Simulation succeeded");
			$stop;
			end
		end
	end

endmodule
