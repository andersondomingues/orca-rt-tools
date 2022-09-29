
interface interface_tcd #(parameter MEMORY_BUS_WIDTH, FLIT_WIDTH)
(input clock, input reset);
  
  //from cpu
  logic[MEMORY_BUS_WIDTH-3:0] addr_in;
  logic[MEMORY_BUS_WIDTH-3:0] nbytes_in;
  logic req_in;
  logic ack_in;
  logic[4:0] irq_out;

  modport TCD (
    input clock, reset, addr_in, nbytes_in, req_in, ack_in,
    output irq_out);

  modport MMIO (
    input clock, reset, irq_out,
    output addr_in, nbytes_in, req_in, ack_in);

endinterface: interface_tcd