import testbench::memword;
import testbench::memoffset;

interface ITcni (input logic clock_in, logic reset_in);
  
  // to memory
  memword data_out;
  memword addr_out;
  memword data_in;
  logic[3:0] wb_out;

  // to mmio
  memword injection_time_in;
  memoffset data_location_in;
  logic[2:0] status;

  modport TCNI (
    input data_in, clock_in, reset_in, injection_time_in, data_location_in,
    output data_out, addr_out, wb_out, status
  );

endinterface: ITcni