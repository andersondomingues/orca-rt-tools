
interface interface_pe #(parameter MEMORY_BUS_WIDTH, FLIT_WIDTH )
(input clock, input reset);
  
  logic[0:3] clock_tx;   // output to router (router in)
  logic[0:3] tx;
  logic[0:3] credit_i;
  logic[FLIT_WIDTH-1:0][0:3] data_o;

  logic clock_rx; // input from router (router out)
  logic rx;
  logic credit_o;
  logic[FLIT_WIDTH-1:0][0:3] data_i;

  modport PE (
    input clock, reset, clock_rx, rx, credit_i, data_i,
    output clock_tx, tx, credit_o, data_o);

  modport DUT (
    input clock, reset, clock_tx, tx, credit_o, data_o,
    output clock_rx, rx, credit_i, data_i);

endinterface: interface_pe