import defs::memword;
import defs::memoffset;

typedef enum logic {
  A_SEND = 0, // wait configuration from the network
  A_RECV = 1  // push received configuration into the queue
} arbiter_state;

typedef enum integer {
  R_IDLE = 0,
  R_HEADER = 1,
  R_SIZE = 2,  
  R_PAYLOAD = 3
} recv_state;

typedef enum integer {
  S_IDLE = 0,
  S_PAYLOAD = 1
} send_state;

/**
 * This module is a double dma that can asyncronously sends and receive packets.
 * There is only one memory bus, which is shared between sending and receiving 
 * processes. Access to the port is given to one of the processess in a round-robin
 * fashion priority schema. The cpu must configure the DMA to send packets. The 
 * interruption wire raises when a packet is tranferred to the memory. */
module ddma #(parameter MEMORY_BUS_WIDTH = 32, FLIT_WIDTH = 32)(
  input logic clock,
  input logic reset,

  output logic irq, //cpu interface 

  output logic[MEMORY_BUS_WIDTH-1:0] data_out, // mem. interface
  output logic[MEMORY_BUS_WIDTH-1:0] addr_out,
  input  logic[MEMORY_BUS_WIDTH-1:0] data_in,
  output logic[3:0] wb_out,

  output logic clock_tx,   // output to router (router in)
  output logic tx,
  input  logic credit_i,
  output logic[FLIT_WIDTH-1:0] data_o,

  input  logic clock_rx, // input from router (router out)
  input  logic rx,
  output logic credit_o,
  input  logic[FLIT_WIDTH-1:0] data_i,

  input logic[MEMORY_BUS_WIDTH-3:0] addr_in, // tcd interface (TODO: aligned access?)
  input logic[MEMORY_BUS_WIDTH-3:0] nbytes_in,
  input logic cmd_in,
  output logic[4:0] status_out
);
  arbiter_state arbiter;
  recv_state recv;
  send_state send;

  /** Memory will be set to read mode unless there 
    * is any data to be received */
  assign arbiter = (arbiter == A_SEND && rx == 1) ? A_RECV : A_SEND;

  // tx clock is the same as global clock
  assign clock_tx = clock;

  // recv state machine 
  always @(posedge clock) 
  begin
    if (arbiter == A_RECV) begin
      case (recv)
        R_IDLE: if (rx == 1) begin
          recv = R_HEADER;
        end 
        R_HEADER : if (rx == 1) begin
          recv <= R_SIZE;
        end
        R_SIZE : if (rx == 1) begin
          recv <= R_PAYLOAD;
        end
        R_PAYLOAD : if (rx == 1) begin
          recv <= R_IDLE;
        end
      endcase 
    end
  end

  // send state machine 
  always @(posedge clock) 
  begin
    if (arbiter == A_SEND) begin
      case (send)
        S_IDLE: if (tx == 1) begin
          send = S_PAYLOAD;
        end 
        S_PAYLOAD : if (tx == 1) begin
          send <= S_IDLE;
        end
      endcase 
    end
  end

endmodule: ddma

