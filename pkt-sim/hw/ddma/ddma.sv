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

  // token_t represents the process which has priority in 
  // the interleaving system. 
  typedef enum integer {
    TOKEN_SEND = 0,
    TOKEN_RECV = 1
  } token_t;

  // <<<<<<<<<

  logic has_data_to_send;
  logic has_data_to_recv;

  // ========== TO BE REMOVED ===================================

  integer RECV_BUFFER_SIZE = 1024;

  integer memory_pointer_recv = 123456;
  integer memory_pointer_send = 123456;  

  //==============================================================

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

  // send process state machine states 
  typedef enum integer {
    WAIT_CONFIG = 0,
    SENDING = 1,
    HANDSHAKE = 2
  } send_state_t;

  // send state variables 
  send_state_t sstate = WAIT_CONFIG;
  integer temp_addr_in = 0;
  integer temp_nbytes_in = 0;

  assign has_data_to_send = (sstate == SENDING);

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
              router_if.rx <= 0;
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
    end 
  end 

  // recv process state machine states 
  typedef enum integer {
    RIDLE = 0
    WAIT_HEADER = 1,
    WAIT_SIZE = 2,
    DATA_COPY = 3,
  } recv_state_t;

  // recv state variables 
  recv_state_t rstate = WAIT_HEADER;
  
  integer packet_size;
  integer flits_to_recv;


  assign has_data_to_recv = (rstate != RIDLE);

  // recv process 
  always @(posedge clock) begin
    if(~reset) begin
      case (rstate)
        RIDLE: begin
          if(i_token == TOKEN_RECV && router_if.tx == 1) begin
            rstate <= WAIT_HEADER;
            router_if.credit_i <= 1; // keep credit down 
          end else begin 
            router_if.credit_i <= 0; // keep credit down 
          end 
        end
        /* Wait until the header flit arrive at the local port. 
         * A rose router_if.tx means that there are flits to be 
         * received. Besides, interleaving token must be respected. */
        WAIT_HEADER: begin
          if(i_token == TOKEN_RECV && router_if.tx == 1) begin
            rstate <= WAIT_SIZE;
            router_if.credit_i <= 1; // keep credit down 
          end else begin 
            router_if.credit_i <= 0; // keep credit down 
          end 
        end
        WAIT_SIZE: begin
          if(i_token == TOKEN_RECV && router_if.tx == 1) begin
            router_if.credit_i <= 1;
            flits_to_recv <= router_if.data_i;
            packet_size <= router_if.data_i;
          end else begin 
            router_if.credit_i <= 0;
          end 
        end 
        DATA_COPY: begin
          if(i_token == TOKEN_RECV && router_if.tx == 1) begin
            router_if.credit_i <= 1;
            flits_to_recv = flits_to_recv -1;
            if(flits_to_recv == 0) begin
              rstate <= WAIT_HEADER;
              memory_pointer_recv <= memory_pointer_recv % RECV_BUFFER_SIZE;
            end 
          end else begin
            router_if.credit_i <= 0;
          end
        end
      endcase
    end 
  end 


///=====================
  always_comb begin
    irq = 0;
  end

  always_comb begin
    // address can come from either send or receiving processess. 
    // memory will be set to write mode only when receiving flits,
    // otherwise it'll reside in read mode 
    mem_if.addr_in = (i_token == TOKEN_RECV && has_data_to_recv) ? memory_pointer_recv : memory_pointer_send;
    mem_if.wb_in = (i_token == TOKEN_RECV && has_data_to_recv) ? 1 : 0;
    mem_if.data_in = router_if.data_o;
    mem_if.enable_in = 1;
    
    // router input data always comes from the sending process, which 
    // reads data from the memory
    router_if.data_i = mem_if.data_out;

    router_if.clock_rx = clock;
  end 

endmodule: ddma

