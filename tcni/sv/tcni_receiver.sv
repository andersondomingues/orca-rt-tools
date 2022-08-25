import Testbench::memword;
import Testbench::memoffset;

package Tcni;

module tcni_receiver (
  input bit clock,
  input bit reset,

  // mem. interface
  input  memword data_in,
  input  memword addr_in,
  output memword data_out,
  output bit[3:0] wb_in
);

endmodule: tcni_receiver

endpackage: Tcni