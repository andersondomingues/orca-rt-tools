
interface interface_tcd #(parameter MEMORY_BUS_WIDTH, FLIT_WIDTH)
(input clock, input reset);
  
  logic[MEMORY_BUS_WIDTH-3:0] addr_out;
  logic[MEMORY_BUS_WIDTH-3:0] nbytes_out;
  logic cmd_out;
  logic[4:0] status_in;

  modport TCD (
    input clock, reset, status_in, 
    output addr_out, nbytes_out, cmd_out);

  modport DUT (
    output status_in, 
    input addr_out, nbytes_out, cmd_out, clock, reset);

endinterface: interface_tcd