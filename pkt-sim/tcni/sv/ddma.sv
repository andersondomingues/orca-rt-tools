import defs::memword;
import defs::memoffset;

typedef enum logic {
    SEND = 0, // wait configuration from the network
    RECV = 1  // push received configuration into the queue
} arbiter_state;

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
  input logic cmd,
  output logic[4:0] status
);
  arbiter_state arbiter;

  /** Memory will be set to read mode unless there 
    * is any data to be received */
  assign arbiter = (arbiter == SEND && rx == 1) ? RECV : SEND;

  // tx clock is the same as global clock
  assign clock_tx = clock;


endmodule: ddma

