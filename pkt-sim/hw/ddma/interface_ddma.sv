
interface interface_ddma #(parameter MEMORY_BUS_WIDTH, 
  FLIT_WIDTH, INTERLEAVING_GRAIN, ADDRESS)
  
(input clock, input reset);
  
  //to dma
  logic[MEMORY_BUS_WIDTH-3:0] addr_in;
  logic[MEMORY_BUS_WIDTH-3:0] nbytes_in;
  logic cmd_in;
  logic[4:0] status_out;
  logic[4:0] irq_out;

  modport DDMA (
    input clock, reset, addr_in, nbytes_in, cmd_in,
    output status_out, irq_out);

  modport TCD (
    output addr_in, nbytes_in, cmd_in,
    input clock, reset, status_out, irq_out);

endinterface: interface_ddma