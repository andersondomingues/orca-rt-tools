import defs::memword;
import defs::memoffset;

interface interface_tcni #(parameter MEMORY_BUS_WIDTH = 32, FLIT_WIDTH = 32 )
(input clock, input reset);
  
  logic[MEMORY_BUS_WIDTH-3:0] addr_out;
  logic[MEMORY_BUS_WIDTH-3:0] nbytes_out;
  logic cmd_out;
  logic[4:0] status_in;

  modport TCNI (
    input clock, reset, status_in, 
    output addr_out, nbytes_out, cmd_out);

  modport DUT (
    output status_in, 
    input addr_out, nbytes_out, cmd_out, clock, reset);

endinterface: interface_tcni