module mux3 #(
    parameter int  DW   = 8,
    parameter type dw_t = logic [DW-1 : 0]
) (
  input  dw_t        d0,
  input  dw_t        d1,
  input  dw_t        d2,
  input  logic [1:0] s,
  output dw_t        y
);

  assign y = s[1] ? d2 : (s[0] ? d1 : d0);

endmodule

