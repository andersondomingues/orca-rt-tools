package Testbench;

`define MEM_BUS_WIDTH 32

typedef logic[(`MEM_BUS_WIDTH - 1):0] memword;
typedef logic[(`MEM_BUS_WIDTH - 1):2] memoffset;

endpackage: Testbench