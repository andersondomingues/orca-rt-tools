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
module ddma #(parameter MEMORY_BUS_WIDTH, FLIT_WIDTH)(
  input logic clock,
  input logic reset,

  interface_router_port.DDMA router_if,
  interface_memory.DUT mem_if,
  interface_ddma.DDMA ddma_if
);
  arbiter_state arbiter;
  recv_state recv;
  send_state send;
  logic rx;
  logic tx;

  always_comb begin
    mem_if.data_in = router_if.data_o;
    mem_if.enable_in = 0;
    mem_if.addr_in = 0'b000;
    
    router_if.data_i = mem_if.data_out;
    router_if.credit_i = 0;
    router_if.clock_rx = clock;
    router_if.rx = 0;
  end 

  /** Memory will be set to read mode unless there 
    * is any data to be received */
  assign arbiter = (arbiter == A_SEND && rx == 1) ? A_RECV : A_SEND;


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

