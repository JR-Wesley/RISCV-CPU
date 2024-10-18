module top(input  logic        clk, reset, 
           output logic [31:0] WriteData, DataAdr, 
           output logic        MemWrite);

  logic [31:0] PC, Instr, ReadData;
  
  // instantiate processor and memories
  riscvsingle rvsingle(    
    .clk        (clk      ), 
    .reset      (reset    ),
    .PC         (PC       ),
    .Instr      (Instr    ),
    .MemWrite   (MemWrite ),
    .ALUResult  (DataAdr  ), 
    .WriteData  (WriteData),
    .ReadData   (ReadData )
    );
                   
  // instruction memory
  imem imem(
    .a  (PC   ), 
    .rd (Instr)
    );

  // data memory
  dmem dmem(
    .clk    (clk      ), 
    .we     (MemWrite ), 
    .a      (DataAdr  ), 
    .wd     (WriteData), 
    .rd     (ReadData )
    );

endmodule
