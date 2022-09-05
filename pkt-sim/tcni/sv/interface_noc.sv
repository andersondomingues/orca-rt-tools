import defs::memword;
import defs::memoffset;

interface interface_noc #(parameter FLIT_WIDTH = 32)(input clock, input reset);

  logic clock_tx;
  logic tx;
  logic credit_i;
  logic[FLIT_WIDTH-1:0] data_o;

  logic clock_rx;
  logic rx;
  logic credit_o;
  logic[FLIT_WIDTH-1:0] data_i;

  modport NOC (
    input clock, reset, clock_rx, rx, data_i, credit_i, 
    output clock_tx, tx, credit_o, data_o);

  modport DUT (
    output clock_rx, rx, data_i, credit_i, 
    input clock_tx, tx, credit_o, data_o, clock, reset);

endinterface: interface_noc