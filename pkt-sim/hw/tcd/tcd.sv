module tcd #(parameter MEMORY_BUS_WIDTH)(
  input logic clock,
  input logic reset,

  interface_tcd.TCD tcd_if,
  interface_ddma.TCD ddma_if
);

  integer counter = 0;

  always @(posedge clock)  begin
    counter = counter + 1;
  end
endmodule: tcd

