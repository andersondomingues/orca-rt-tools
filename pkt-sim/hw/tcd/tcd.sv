module tcd #(parameter MEMORY_BUS_WIDTH, FLIT_WIDTH)(
  input logic clock,
  input logic reset,

  interface_tcd.TCD tcd_if
);

  integer counter = 0;

  always @(posedge clock)  begin
    counter = counter + 1;
  end
endmodule: tcd

