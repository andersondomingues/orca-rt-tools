`timescale 1 ns / 1 ps

module Testbench #(parameter NOC_DIM_X = 4, NOC_DIM_Y = 4)();

    logic clock;
    logic reset;

    // clock generator 
    always #10 clock = ~clock;

    // reset goes down after 5th cycle
    initial begin
        reset = 1;
        repeat (5) begin 
            @(posedge clock);
        end
        reset = 0;
    end

    // interfaces 
    mem_ifs IMemory[NOC_DIM_X, NOC_DIM_Y](clock, reset);
    noc_if INoc[NOC_DIM_X, NOC_DIM_Y](clock, reset);
    tcni_if ITcni[NOC_DIM_X, NOC_DIM_Y](clock, reset);

endmodule