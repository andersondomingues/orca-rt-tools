`timescale 1 ns / 1 ps
`define NOC_DIM_X 4
`define NOC_DIM_Y 4


import hermes_pkg;


module tb (
    clock, reset
);


// clock generator 
bit clock;
always #10 clock = ~clock;

// reset generator 
bit reset;
initial begin
    reset = 1;
    repeat (5) begin 
        @(posedge clock);
    end
    reset = 0;
end


//
