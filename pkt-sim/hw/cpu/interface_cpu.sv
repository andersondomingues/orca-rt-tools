
interface interface_cpu #(parameter MEMORY_BUS_WIDTH)
(input clock, input reset);

  logic[MEMORY_BUS_WIDTH-1:0] data_in;
  logic[MEMORY_BUS_WIDTH-1:0] data_out;
  logic irq;
  logic[MEMORY_BUS_WIDTH-3:0] addr_out;
  logic[3:0] wb_out;

  modport CPU (
    input clock, reset, irq, data_in, 
    output addr_out, data_out, wb_out);

  modport DUT (
    input clock, reset, addr_out, data_out, wb_out,
    output irq, data_in);

endinterface: interface_cpu