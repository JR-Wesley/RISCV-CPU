module flopenrc #(
    parameter int DW = 8
) (
  input  logic            clk,
  input  logic            rst,
  input  logic            clr,
  input  logic            en,
  input  logic [DW-1 : 0] d,
  output logic [DW-1 : 0] q
);

  always_ff @(posedge clk, posedge rst)
    if (rst) q <= 0;
    else if (en)
      if (clr) q <= 0;
      else q <= d;

endmodule

