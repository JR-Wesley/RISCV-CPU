
module datapath (
  input  logic        clk,
  input  logic        rst,
  // Fetch stage signals
  input  logic        StallF,
  output logic [31:0] PCF,
  input  logic [31:0] InstrF,
  // Decode stage signals
  output logic [ 6:0] opD,
  output logic [ 2:0] funct3D,
  output logic        funct7b5D,
  input  logic        StallD,
  input  logic        FlushD,
  input  logic [ 2:0] ImmSrcD,
  // Execute stage signals
  input  logic        FlushE,
  input  logic [ 1:0] ForwardAE,
  input  logic [ 1:0] ForwardBE,
  input  logic        PCSrcE,
  input  logic [ 2:0] ALUControlE,
  input  logic        ALUSrcAE,     // needed for lui
  input  logic        ALUSrcBE,
  output logic        ZeroE,
  // Memory stage signals
  input  logic        MemWriteM,
  output logic [31:0] WriteDataM,
  output logic [31:0] ALUResultM,
  input  logic [31:0] ReadDataM,
  // Writeback stage signals
  input  logic        RegWriteW,
  input  logic [ 1:0] ResultSrcW,
  // Hazard Unit signals
  output logic [ 4:0] Rs1D,
  output logic [ 4:0] Rs2D,
  output logic [ 4:0] Rs1E,
  output logic [ 4:0] Rs2E,
  output logic [ 4:0] RdE,
  output logic [ 4:0] RdM,
  output logic [ 4:0] RdW
);

  // Fetch stage signals
  logic [31:0] PCNextF, PCPlus4F;
  // Decode stage signals
  logic [31:0] InstrD;
  logic [31:0] PCD, PCPlus4D;
  logic [31:0] RD1D, RD2D;
  logic [31:0] ImmExtD;
  logic [4:0] RdD;
  // Execute stage signals
  logic [31:0] RD1E, RD2E;
  logic [31:0] PCE, ImmExtE;
  logic [31:0] SrcAE, SrcBE;
  logic [31:0] SrcAEforward;
  logic [31:0] ALUResultE;
  logic [31:0] WriteDataE;
  logic [31:0] PCPlus4E;
  logic [31:0] PCTargetE;
  // Memory stage signals
  logic [31:0] PCPlus4M;
  // Writeback stage signals
  logic [31:0] ALUResultW;
  logic [31:0] ReadDataW;
  logic [31:0] PCPlus4W;
  logic [31:0] ResultW;

  //============================== Fetch stage ==============================
  // select the next PC
  mux2 #(32) pcmux (
    .d0(PCPlus4F),
    .d1(PCTargetE),
    .s (PCSrcE),
    .y (PCNextF)
  );

  flopenr #(32) pcreg (
    .clk(clk),
    .rst(rst),
    .en (~StallF),
    .d  (PCNextF),
    .q  (PCF)
  );

  adder pcadd (
    .a(PCF),
    .b(32'h4),
    .s(PCPlus4F)
  );

  //============================== Decode stage ==============================
  flopenrc #(96) regD (
    .clk(clk),
    .rst(rst),
    .clr(FlushD),
    .en (~StallD),
    .d  ({InstrF, PCF, PCPlus4F}),
    .q  ({InstrD, PCD, PCPlus4D})
  );

  assign opD = InstrD[6 : 0];
  assign funct3D = InstrD[14 : 12];
  assign funct7b5D = InstrD[30];
  assign Rs1D = InstrD[19 : 15];
  assign Rs2D = InstrD[24 : 20];
  assign RdD = InstrD[11 : 7];

  regfile rf (
    .clk(clk),
    .a1 (Rs1D),
    .a2 (Rs2D),
    .rd1(RD1D),
    .rd2(RD2D),
    .a3 (RdW),
    .we3(RegWriteW),
    .wd3(ResultW)
  );

  extend ext (
    .instr (InstrD[31:7]),
    .immsrc(ImmSrcD),
    .immext(ImmExtD)
  );

  //============================== Execute stage ==============================
  floprc #(175) regE (
    .clk(clk),
    .rst(rst),
    .clr(FlushE),
    .d  ({RD1D, RD2D, PCD, Rs1D, Rs2D, RdD, ImmExtD, PCPlus4D}),
    .q  ({RD1E, RD2E, PCE, Rs1E, Rs2E, RdE, ImmExtE, PCPlus4E})
  );

  // oprand A select if forward
  mux3 #(32) faemux (
    .d0(RD1E),
    .d1(ResultW),
    .d2(ALUResultM),
    .s (ForwardAE),
    .y (SrcAEforward)
  );

  // for lui
  mux2 #(32) srcamux (
    .d0(SrcAEforward),
    .d1(32'b0),
    .s (ALUSrcAE),
    .y (SrcAE)
  );

  // oprand B select if forward
  mux3 #(32) fbemux (
    .d0(RD2E),
    .d1(ResultW),
    .d2(ALUResultM),
    .s (ForwardBE),
    .y (WriteDataE)
  );

  // for lui
  mux2 #(32) srcbmux (
    .d0(WriteDataE),
    .d1(ImmExtE),
    .s (ALUSrcBE),
    .y (SrcBE)
  );

  alu alu (
    .a         (SrcAE),
    .b         (SrcBE),
    .alucontrol(ALUControlE),
    .result    (ALUResultE),
    .zero      (ZeroE)
  );

  // branch address adder
  adder branchadd (
    .a(ImmExtE),
    .b(PCE),
    .s(PCTargetE)
  );

  //============================== Memory stage ==============================
  flopr #(101) regM (
    .clk(clk),
    .rst(rst),
    .d  ({ALUResultE, WriteDataE, RdE, PCPlus4E}),
    .q  ({ALUResultM, WriteDataM, RdM, PCPlus4M})
  );

  //============================== Writeback stage ==============================
  flopr #(101) regW (
    .clk(clk),
    .rst(rst),
    .d  ({ALUResultM, ReadDataM, RdM, PCPlus4M}),
    .q  ({ALUResultW, ReadDataW, RdW, PCPlus4W})
  );

  // select from ALU result, data memory, PC+4
  mux3 #(32) resultmux (
    .d0(ALUResultW),
    .d1(ReadDataW),
    .d2(PCPlus4W),
    .s (ResultSrcW),
    .y (ResultW)
  );

endmodule
