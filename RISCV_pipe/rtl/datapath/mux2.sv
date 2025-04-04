module mux2 #(
    parameter int  DW   = 8,
    parameter type dw_t = logic [DW-1 : 0]
) (
  input  dw_t  d0,
  input  dw_t  d1,
  input  logic s,
  output dw_t  y
);

  assign y = s ? d1 : d0;

endmodule

