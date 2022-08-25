import Testbench::memword;
import Testbench::memoffset;

interface INoc (input logic clock_in, logic reset_in);

  // memword data_in,
  // memword addr_in,
  // memword data_out,
  // logic[3:0] wb_in,

  // modport MEM (
  //   input data_in, addr_in, wb_in, 
  //   output logic[3:0]
  // );

  // modport CON (
  //   input logic[3:0],
  //   output data_in, addr_in, wb_in
  // );

endinterface: INoc