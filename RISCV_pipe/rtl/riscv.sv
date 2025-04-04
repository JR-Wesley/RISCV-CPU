module riscv (
    input  logic        clk,
    rst,
    output logic [31:0] PCF,
    input  logic [31:0] InstrF,
    output logic        MemWriteM,
    output logic [31:0] ALUResultM,
    output logic [31:0] WriteDataM,
    input  logic [31:0] ReadDataM
);

  logic [6:0] opD;
  logic [2:0] funct3D;
  logic       funct7b5D;
  logic [2:0] ImmSrcD;
  logic       ZeroE;
  logic       PCSrcE;
  logic [2:0] ALUControlE;
  logic ALUSrcAE, ALUSrcBE;
  logic       ResultSrcEb0;
  logic       RegWriteM;
  logic [1:0] ResultSrcW;
  logic       RegWriteW;
  logic [1:0] ForwardAE, ForwardBE;
  logic StallF, StallD, FlushD, FlushE;
  logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;

  controller c (
    .reset(rst),
    .*
  );

  datapath dp (.*);

  hazard hu (.*);

endmodule
