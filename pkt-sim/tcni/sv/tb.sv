`timescale 1 ns / 1 ps

import defs::*;
import HermesPackage::*;

module tb #(parameter NOC_DIM_X = 4, NOC_DIM_Y = 4, FLIT_WIDTH = 32, MEMORY_BUS_WIDTH = 32)();
  bit clock = 0;
  bit reset = 1; 

  // clock generator 
  always #1 clock = ~clock;

  // reset goes down after 2nd cycle
  always #2 reset = 0;

  // generate one pe per noc node 
  genvar i, j;
  generate
    for(i = 0; i < NOC_DIM_X; i++) begin : pe_x
      for(j = 0; j < NOC_DIM_Y; j++) begin : pe_y

        // interfaces
        interface_memory mem_if(clock, reset);
        interface_router router_if(clock, reset);
        interface_tcni tcni_if(clock, reset);
        interface_cpu cpu_if(clock, reset);

        // router instance
        routercc #(12345) router_mod (
          .clock(clock),
          .reset(reset),

          .clock_rx(router_if.clock_rx), // ni to router
          .rx(router_if.rx),
          .data_in(router_if.data_i),
          .credit_o(router_if.credit_o),

          .clock_tx(router_if.clock_tx), // router to ni
          .tx(router_if.tx),
          .data_out(router_if.data_o),
          .credit_i(router_if.credit_i)
        );


        // ddma instance and bindings
        ddma #(MEMORY_BUS_WIDTH, FLIT_WIDTH) ddma_mod(
          .clock(clock), .reset(reset), 
          .irq(cpu_if.irq),

          .data_out(mem_if.data_in), // mem_if
          .addr_out(mem_if.addr_in),
          .data_in(mem_if.data_out),
          .wb_out(mem_if.wb_in),

          .addr_in(tcni_if.addr_out), // ni to memory
          .nbytes_in(tcni_if.nbytes_out),
          .cmd_in(tcni_if.cmd_out),
          .status_out(tcni_if.status_in),

          .tx(router_if.rx[LOCAL]), // ni to router
          .clock_tx(router_if.clock_rx[LOCAL]),
          .data_o(router_if.data_i[TAM_FLIT * 5 - 1: TAM_FLIT * 4 - 1]),
          .credit_i(router_if.credit_o[LOCAL]),

          .rx(router_if.tx[LOCAL]), // router to ni
          .clock_rx(router_if.clock_tx[LOCAL]),
          .data_i(router_if.data_o[TAM_FLIT * 5 - 1: TAM_FLIT * 4 - 1]),
          .credit_o(router_if.credit_i[LOCAL])
        );

        // router_if.clock_rx[4:1] = 'z;
        // router_if.rx[4:1] <= 0;
        // router_if.data_i[4:1] <= 0;
        // router_if.credit_o[4:1] <= 0;

        // router_if.clock_tx[4:1] = 0;
        // router_if.tx[4:1] = 0;
        // router_if.data_o[4:1] = 0;
        // router_if.credit_i[4:1] = 0;

      end
    end
  endgenerate

endmodule: tb