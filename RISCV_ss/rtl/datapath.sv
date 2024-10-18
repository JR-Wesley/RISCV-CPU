module datapath(input logic        clk, reset,
                // control
                input  logic [1 : 0]  i_ResultSrc, 
                input  logic          i_PCSrc, 
                input  logic          i_ALUSrc,
                input  logic          i_RegWrite,
                input  logic [1 : 0]  i_ImmSrc,
                input  logic [2 : 0]  i_ALUControl,
                // data
                output logic          o_Zero,
                output logic [31 : 0] o_PC,
                input  logic [31 : 0] i_Instr,
                output logic [31 : 0] o_ALUResult,
                output logic [31 : 0] o_WriteData,
                input  logic [31 : 0] i_ReadData);

  logic [31:0] PCNext, PCPlus4, PCTarget;
  logic [31:0] ImmExt;
  logic [31:0] SrcA, SrcB;
  logic [31:0] Result;

//===================== PC addr =====================
  // next PC logic
  flopr #(32) pcreg(
    .clk    (clk    ), 
    .reset  (reset  ), 
    .d      (PCNext ), 
    .q      (o_PC   )
  );

  adder       pcadd4(
    .a  (o_PC     ), 
    .b  (32'd4    ), 
    .s  (PCPlus4  )
  );

// for branch/jump
  adder       pcaddbranch(
    .a  (o_PC     ), 
    .b  (ImmExt   ), 
    .s  (PCTarget )
  );

  mux2 #(32)  pcmux(
    // PC+4
    .d0 (PCPlus4    ),
    // PC+ imme - target PC addr
    .d1 (PCTarget   ),
    .s  (i_PCSrc    ),
    .y  (PCNext     )
  );
 
  // register file logic
  regfile     rf(
    .clk  (clk            ), 
    .we3  (i_RegWrite     ), 
    // rs1
    .a1   (i_Instr[19:15] ), 
    // rs2
    .a2   (i_Instr[24:20] ), 
    // rd
    .a3   (i_Instr[11:7]  ), 
    // result write back to RF
    .wd3  (Result         ), 
    .rd1  (SrcA           ), 
    .rd2  (o_WriteData    )
  );

  extend      ext(
    .instr  (i_Instr[31:7]  ), 
    .immsrc (i_ImmSrc       ), 
    .immext (ImmExt         )
    );

// ALU operand select
  mux2 #(32)  srcbmux(
    .d0 (o_WriteData), 
    .d1 (ImmExt     ), 
    .s  (i_ALUSrc   ), 
    .y  (SrcB       )
    );

  // ALU logic
  alu         alu(
    .a          (SrcA         ), 
    .b          (SrcB         ), 
    .alucontrol (i_ALUControl ), 
    .result     (o_ALUResult  ), 
    .zero       (o_Zero       )
    );

  mux3 #(32)  resultmux(
    // for the result of calculation
    .d0 (o_ALUResult),
    // for loading data form data memory to RF
    .d1 (i_ReadData ),
    // jal, store PC+4 to rd
    .d2 (PCPlus4    ),
    .s  (i_ResultSrc),
    .y  (Result     )
  );

endmodule