import defs::memword;
import defs::memoffset;

interface interface_router #(parameter FLIT_WIDTH = 32)(
  input clock, input reset);

  logic[4:0] clock_tx;
  logic[4:0] tx;
  logic[4:0] credit_i;
  logic[FLIT_WIDTH * 5 -1 :0] data_o;

  logic[4:0] clock_rx;
  logic[4:0] rx;
  logic[4:0] credit_o;
  logic[FLIT_WIDTH * 5 -1 :0] data_i;
  
  modport DUT (
    output clock_rx, rx, data_i, credit_i, 
    input clock_tx, tx, credit_o, data_o, clock, reset);

  modport ROUTER (
    input clock, reset, clock_rx, rx, data_i, credit_i, 
    output clock_tx, tx, credit_o, data_o);

endinterface: interface_router