import testbench::memword;
import testbench::memoffset;

interface IMemory (input logic clock_in, logic reset_in);

  memword data_in;
  memword addr_in;
  memword data_out;
  logic[3:0] wb_in;

  modport MEM (
    input data_in, addr_in, wb_in, clock_in, reset_in,
    output data_out
  );

  modport CON (
    input data_out, clock_in, reset_in,
    output data_in, addr_in, wb_in
  );

endinterface: IMemory

