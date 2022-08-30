import testbench::memword;
import testbench::memoffset;

typedef enum logic[1:0] {
    CONFIG_WAIT = 0, // wait configuration from the network
    CONFIG_PUSH = 1  // push received configuration into the queue
} tcni_send_state;


module tcni_sender #(parameter MEMORY_BUS_WIDTH = 32)(
  input logic clock_in,
  input logic reset_in,

  // mem. interface
  input  logic[MEMORY_BUS_WIDTH-1:0] data_in,
  input  logic[MEMORY_BUS_WIDTH-1:0] addr_in,
  output logic[MEMORY_BUS_WIDTH-1:0] data_out,
  output logic[3:0] wb_in,

  // mmio interface
  input  logic[MEMORY_BUS_WIDTH-1:0] injection_time_in,
  input  logic[MEMORY_BUS_WIDTH-1:2] data_location_in,
  output logic[2:0] status
);

  integer counter;

  // counter generation
  always @(posedge clock_in) begin
    if(reset_in) begin
      counter <= counter + 1;
    end else begin
      counter <= 0;
    end
  end

  // state machine 
  always @(posedge clock_in) begin
    if(reset_in) begin
      status <= 0;
    end else begin
      status <= 1;
    end
  end

endmodule: tcni_sender

