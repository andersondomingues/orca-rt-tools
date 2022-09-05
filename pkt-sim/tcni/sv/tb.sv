`timescale 1 ns / 1 ps

import defs::*;

module tb #(parameter NOC_DIM_X = 4, NOC_DIM_Y = 4, FLIT_WIDTH = 32, MEMORY_BUS_WIDTH = 32)();
  bit clock = 0;
  bit reset = 1; 
  bit irq = 0;

  // clock generator 
  always #1 clock = ~clock;

  // reset goes down after 2nd cycle
  always #2 reset = 0;

  // interfaces
  interface_memory mem_if(clock, reset);
  interface_noc noc_if(clock, reset);
  interface_tcni tcni_if(clock, reset);
  interface_cpu cpu_if(clock, reset);

  // ddma instance and bindings
  ddma ddma_mod (
    .clock(clock), .reset(reset), .irq(irq),

    .data_out(mem_if.data_in), //mem_if
    .addr_out(mem_if.addr_in),
    .data_in(mem_if.data_out),
    .wb_out(mem_if.wb_in),

    .tx(noc_if.rx),
    .clock_tx(noc_if.clock_rx),
    .data_o(noc_if.data_i),
    .credit_i(noc_if.credit_o),

    .rx(noc_if.tx),
    .clock_rx(noc_if.clock_tx),
    .data_i(noc_if.data_o),
    .credit_o(noc_if.credit_i)
  );



endmodule: tb