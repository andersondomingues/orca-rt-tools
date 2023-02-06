interface interface_mmio #(parameter MEMORY_BUS_WIDTH)
(input clock, input reset);

  logic[MEMORY_BUS_WIDTH-3:0] addr_in;
  logic[MEMORY_BUS_WIDTH-1:0] data_in;
  logic[MEMORY_BUS_WIDTH-1:0] data_out;
  logic[3:0] wb_in;

  modport CPU (
    input clock, reset, data_out, 
    output addr_in, data_in, wb_in);

  modport MMIO (
    input clock, reset, data_in, addr_in, wb_in,
    output data_out);

endinterface: interface_mmio