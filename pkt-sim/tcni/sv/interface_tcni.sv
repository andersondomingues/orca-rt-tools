import defs::memword;
import defs::memoffset;

interface interface_tcni #(parameter MEMORY_BUS_WIDTH = 32, FLIT_WIDTH = 32 )
(input clock, input reset);
  
  logic[MEMORY_BUS_WIDTH-3:0] addr_out;
  logic[MEMORY_BUS_WIDTH-3:0] nbytes_out;
  logic cmd;
  logic[4:0] status;

  modport TCNI (
    input clock, reset, status, 
    output addr_out, nbytes_out, cmd);

  modport DUT (
    output status, 
    input addr_out, nbytes_out, cmd, clock, reset);

endinterface: interface_tcni