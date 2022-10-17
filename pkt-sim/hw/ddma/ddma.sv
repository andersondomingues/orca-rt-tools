`timescale 1 ns/1 ns

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
module ddma #(parameter MEMORY_BUS_WIDTH, FLIT_WIDTH, INTERLEAVING_GRAIN)(
  input logic clock,
  input logic reset,

  interface_router_port.DDMA router_if,
  interface_memory.DUT mem_if,
  interface_ddma.DDMA ddma_if,
  
  output logic irq
);

//===============================
  arbiter_state arbiter;
  recv_state recv;
  send_state send;

  logic rx;
  logic tx;

  integer memory_pointer_recv = 123456;
//===============================

  typedef enum integer {
    DDMA_SEND = 0,
    DDMA_RECV = 1,
    DDMA_IDLE = 2
  } ddma_state_t;

  ddma_state_t i_state = DDMA_IDLE;

  bit has_data_to_send = 0;
  bit has_data_to_recv = 0;

  initial begin

    #10 has_data_to_recv = 1;
    #12 has_data_to_send = 1;
    #17 has_data_to_recv = 0;

    #26 has_data_to_recv = 1;
  end


  // token_t represents the process which has priority in 
  // the interleaving system. 
  typedef enum integer {
    TOKEN_SEND = 0,
    TOKEN_RECV = 1
  } token_t;

  // token status (which process has priority)
  token_t i_token = TOKEN_SEND;

  // remaining cycles until interleaving priority switching  
  integer i_flip_counter = 1;

  // process for handling interleaving arbitration. 
  // rules:
  // - interleaving changes between sending and receiving actions
  // - an action changes if it timeouts or finish before the timeout
  // - if an action chaging would cause no effect, it won't change instead
  always @(posedge clock) begin
    if(~reset) begin
      if(i_flip_counter == 1) begin
        if (i_token == TOKEN_SEND && has_data_to_recv) begin
          i_token = TOKEN_RECV;
          i_flip_counter = INTERLEAVING_GRAIN; // reset counter
        end else if (i_token == TOKEN_RECV && has_data_to_send) begin
          i_token = TOKEN_SEND;
          i_flip_counter = INTERLEAVING_GRAIN; // reset counter
        end   
      end else begin
        i_flip_counter = i_flip_counter - 1; // decrease one time unit
        if (i_token == TOKEN_SEND && ~has_data_to_send && has_data_to_recv) begin
          i_token = TOKEN_RECV;
          i_flip_counter = INTERLEAVING_GRAIN; // reset counter
        end else if (i_token == TOKEN_RECV && ~has_data_to_recv && has_data_to_send) begin
          i_token = TOKEN_SEND;
          i_flip_counter = INTERLEAVING_GRAIN; // reset counter
        end 
      end
    end 
  end

  always @(posedge clock) begin
    if(~reset && i_token == TOKEN_SEND) begin


    end 
  end 

  always @(posedge clock) begin
    if(~reset && i_token == TOKEN_RECV) begin


    end 
  end 


///=====================
  always_comb begin
    irq = 0;
  end

  always_comb begin
    mem_if.data_in = router_if.data_o;
    mem_if.enable_in = 1;
    mem_if.addr_in = memory_pointer_recv;
    mem_if.wb_in = 0;
    
    router_if.data_i = mem_if.data_out;
    router_if.credit_i = 1;
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

