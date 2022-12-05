`timescale 1 ns/1 ns

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
  // ========== TO BE REMOVED ===================================

  integer RECV_BUFFER_SIZE = 1024;
  integer memory_pointer_recv = 100;

  //==============================================================

  // token_t represents the process which has priority in 
  // the interleaving system. 
  typedef enum integer {
    TOKEN_SEND = 0,
    TOKEN_RECV = 1
  } token_t;
  
  // send process state machine states 
  typedef enum integer {
    WAIT_CONFIG = 0,
    SENDING = 1,
    HANDSHAKE = 2
  } send_state_t;

  // recv process state machine states 
  typedef enum integer {
    WAIT_HEADER = 0,
    WAIT_SIZE = 1,
    DATA_COPY = 2,
    INTERRUPTION = 3
  } recv_state_t;

  // token status (which process has priority)
  token_t i_token;

  // remaining cycles until interleaving priority switching  
  integer i_flip_counter;

  // recv state variables 
  recv_state_t rstate;
  integer flits_to_recv;
  integer packet_size;

  // token request for recv and send states 
  logic has_data_to_send;
  logic has_data_to_recv;

  // send state variables 
  send_state_t sstate = WAIT_CONFIG;
  integer temp_addr_in = 0;
  integer temp_nbytes_in = 0;

  assign has_data_to_send = (sstate == SENDING);
  assign has_data_to_recv = router_if.tx;

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
    end else begin
      i_flip_counter = 1;
      i_token = TOKEN_SEND;
    end 
  end

  // send state process 
  always @(posedge clock) begin
    if(~reset) begin
      case (sstate)
        WAIT_CONFIG: begin
          if(ddma_if.cmd_in == 1) begin
            temp_addr_in <= ddma_if.addr_in;
            temp_nbytes_in <= ddma_if.nbytes_in;
            sstate <= SENDING;
            ddma_if.status_out <= 1;
          end else begin 
            ddma_if.status_out <= 0;
          end 
          router_if.rx <= 0;
        end 

        SENDING: begin 
          ddma_if.status_out <=  1;
          if (i_token == TOKEN_SEND) begin
            if (temp_nbytes_in > 0) begin
              if (router_if.credit_o == 1) begin
                router_if.rx <= 1;
                temp_addr_in += 4;
                temp_nbytes_in -= 4;
              end else begin
                router_if.rx <= 0;
              end
            end else begin
              router_if.rx <= 1;
              sstate <= HANDSHAKE;
            end 
          end else begin 
            router_if.rx <= 0;
          end 
        end 

        HANDSHAKE: begin 
          router_if.rx <= 0;
          if(ddma_if.cmd_in == 0) begin
            sstate <= WAIT_CONFIG;
          end
        end 
      endcase
    end else begin 
      sstate = WAIT_CONFIG;
    end 
  end 

  // recv process 
  always @(posedge clock) begin
    if(~reset) begin
      case (rstate)
        WAIT_HEADER: begin
          if(i_token == TOKEN_RECV && router_if.tx == 1) begin
            rstate <= WAIT_SIZE;
            router_if.credit_i <= 1;
          end else begin
            router_if.credit_i <= 0; // keep credit down 
          end 
        end
        WAIT_SIZE: begin
          if(i_token == TOKEN_RECV && router_if.tx == 1) begin
            router_if.credit_i <= 1;
            flits_to_recv <= router_if.data_o;
            packet_size <= router_if.data_o;
            rstate <= DATA_COPY;
          end else begin 
            router_if.credit_i <= 0;
          end 
        end 
        DATA_COPY: begin
          if(flits_to_recv >= 0) begin
            if(i_token == TOKEN_RECV && router_if.tx == 1) begin
              router_if.credit_i <= 1;
              flits_to_recv = flits_to_recv -1;

              memory_pointer_recv <= (memory_pointer_recv < RECV_BUFFER_SIZE)
                ? memory_pointer_recv : RECV_BUFFER_SIZE;
            end else begin 
              router_if.credit_i <= 0;  
            end 
          end else begin
            rstate <= INTERRUPTION;
            router_if.credit_i <= 0;
            ddma_if.irq_out <= 1;
          end
        end
        INTERRUPTION: begin
          ddma_if.irq_out <= 0;
          ddma_if.status_out <= ddma_if.status_out & 2'b01;
          rstate <= WAIT_HEADER;
        end 
      endcase
    end else begin 
      rstate = WAIT_HEADER;
    end 
  end 

  always_comb begin
    // address can come from either send or receiving processess. 
    // memory will be set to write mode only when receiving flits,
    // otherwise it'll reside in read mode 
    mem_if.addr_in = (i_token == TOKEN_RECV && has_data_to_recv) ? memory_pointer_recv : temp_addr_in;
    mem_if.wb_in = (i_token == TOKEN_RECV && router_if.tx == 1);
        
  end 

  // router input data always comes from the sending process, which 
  // reads data from the memory  
  assign router_if.clock_rx = clock;
  assign router_if.data_i = mem_if.data_out;
  assign mem_if.enable_in = 1;
  assign mem_if.data_in = router_if.data_o;

endmodule: ddma

