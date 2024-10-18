
module controller(
	input logic clk, reset,
	// Decode stage control signals
	input logic [6:0] opD,
	input logic [2:0] funct3D,
	input logic funct7b5D,
	output logic [2:0] ImmSrcD,
	// Execute stage control signals
	input logic FlushE,
	input logic ZeroE,
	output logic PCSrcE, // for datapath and Hazard Unit
	output logic [2:0] ALUControlE,
	output logic ALUSrcAE,
	output logic ALUSrcBE, // for lui
	output logic ResultSrcEb0, // for Hazard Unit
	// Memory stage control signals
	output logic MemWriteM,
	output logic RegWriteM, // for Hazard Unit
	// Writeback stage control signals
	output logic RegWriteW, // for datapath and	Hazard Unit
	output logic [1:0] ResultSrcW
);

	// pipelined control signals
	logic RegWriteD, RegWriteE;
	logic [1:0] ResultSrcD, ResultSrcE, ResultSrcM;
	logic MemWriteD, MemWriteE;
	logic JumpD, JumpE;
	logic BranchD, BranchE;
	logic [1:0] ALUOpD;
	logic [2:0] ALUControlD;
	logic ALUSrcAD;
	logic ALUSrcBD; // for lui

//============================== Decode stage ==============================
	maindec md(
		.op			(opD		),
		.ResultSrc	(ResultSrcD	),
		.MemWrite	(MemWriteD	),
		.Branch		(BranchD	),
		.ALUSrcA	(ALUSrcAD	), // for lui
		.ALUSrcB	(ALUSrcBD	),
		.RegWrite	(RegWriteD	),
		.Jump		(JumpD		),
		.ImmSrc		(ImmSrcD	),
		.ALUOp		(ALUOpD		)
		);
		
	aludec ad(
		.opb5		(opD[5]		),
		.funct3		(funct3D	),
		.funct7b5	(funct7b5D	),
		.ALUOp		(ALUOpD		),
		.ALUControl	(ALUControlD)
		);

//============================== Execute stage ==============================
	floprc #(11) controlregE(
		.clk	(clk													), 
		.reset	(reset													), 
		.clear	(FlushE													),
		.d		({RegWriteD, ResultSrcD, MemWriteD, JumpD, BranchD,
					ALUControlD, ALUSrcAD, ALUSrcBD}					), 
		.q		({RegWriteE, ResultSrcE, MemWriteE, JumpE, BranchE,
					ALUControlE, ALUSrcAE, ALUSrcBE}					)
		);

	assign PCSrcE = (BranchE & ZeroE) | JumpE;
	assign ResultSrcEb0 = ResultSrcE[0];

//============================== Memory stage ==============================
	flopr #(4) controlregM(
		.clk	(clk								), 
		.reset	(reset								), 
		.d		({RegWriteE, ResultSrcE, MemWriteE}	), 
		.q		({RegWriteM, ResultSrcM, MemWriteM}	)
		);

//============================== Writeback stage ==============================
	flopr #(3) controlregW(
		.clk	(clk						), 
		.reset	(reset						), 
		.d		({RegWriteM, ResultSrcM}	), 
		.q		({RegWriteW, ResultSrcW}	)
		);

endmodule
