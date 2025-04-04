module top (
  input  logic        clk,
  input  logic        rst,
  output logic [31:0] WriteDataM,
  output logic [31:0] DataAdrM,
  output logic        MemWriteM
);

  logic [31:0] PCF, InstrF, ReadDataM;

  // instantiate processor and memories
  riscv riscv (
    .*,
    .reset     (rst),
    .ALUResultM(DataAdrM)
  );

  imem imem (
    .a (PCF),
    .rd(InstrF)
  );

  dmem dmem (
    .*,
    .we(MemWriteM),
    .a (DataAdrM),
    .wd(WriteDataM),
    .rd(ReadDataM)
  );

endmodule

