`timescale 1 ns / 1 ps

module tb #(parameter NOC_DIM_X = 1, NOC_DIM_Y = 1, FLIT_WIDTH = 32, MEMORY_BUS_WIDTH = 32)();
  bit clock = 0;
  bit reset = 1; 

  logic[3:0] clock_tx;
  logic[3:0] tx;
  logic[3:0] credit_i;
  logic[3:0][FLIT_WIDTH-1:0] data_o;

  logic[3:0] clock_rx;
  logic[3:0] rx;
  logic[3:0] credit_o;
  logic[3:0][FLIT_WIDTH-1:0] data_i;

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
        interface_pe #(MEMORY_BUS_WIDTH, FLIT_WIDTH) pe_if(clock, reset);
        
        // actual pe module
        pe #(MEMORY_BUS_WIDTH, FLIT_WIDTH) pe_mod(
          .pe_if(pe_if.PE)
        );

      end
    end
  endgenerate

endmodule: tb