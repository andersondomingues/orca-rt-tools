
interface interface_ddma #(parameter 
  MEMORY_BUS_WIDTH = 32, 
  FLIT_WIDTH = 32, 
  INTERLEAVING_GRAIN = 3, 
  ADDRESS = 0
)(input clock, input reset);
  
  //to dma
  logic[MEMORY_BUS_WIDTH-1:0] addr_in;
  logic[MEMORY_BUS_WIDTH-1:0] size_in;
  logic[MEMORY_BUS_WIDTH-1:0] dest_in;
  logic cmd_in;

  // soft. status byte = X X XXX XXX
  logic irq_send_out;
  logic irq_recv_out;
  logic[2:0] state_recv_out;
  logic[2:0] state_send_out;
  

  modport DDMA (
    input clock, reset, 
          addr_in, size_in, cmd_in, dest_in,
    output state_recv_out, state_send_out, 
           irq_recv_out, irq_send_out);

  modport TCD (
    output addr_in, size_in, cmd_in, dest_in,
    input clock, reset, state_recv_out, state_send_out,
          irq_recv_out, irq_send_out);

endinterface: interface_ddma