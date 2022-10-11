
interface interface_memory #(parameter MEMORY_BUS_WIDTH)
(input clock, input reset);
  logic[MEMORY_BUS_WIDTH-1:0] data_in; // mem. interface
  logic[MEMORY_BUS_WIDTH-3:0] addr_in;
  logic[MEMORY_BUS_WIDTH-1:0] data_out;
  logic enable_in;
  logic wb_in;

  modport MEM (
    input data_in, addr_in, enable_in, wb_in, clock, reset,
    output data_out);

  modport DUT (
    output data_in, addr_in, wb_in, enable_in, 
    input data_out, clock, reset);

endinterface: interface_memory