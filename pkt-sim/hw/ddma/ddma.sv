/**
 * This module is a double dma that can asyncronously sends and receive packets.
 * There is only one memory bus, which is shared between sending and receiving 
 * processes. Access to the port is given to one of the processess in a round-robin
 * fashion priority schema. The cpu must configure the DMA to send packets. The 
 * interruption wire raises when a packet is tranferred to the memory. */
module ddma #(parameter MEMORY_BUS_WIDTH, 
  FLIT_WIDTH, INTERLEAVING_GRAIN, ADDRESS
)(
  input logic clock,
  input logic reset,

  interface_router_port.DDMA router_if,
  interface_memory.DUT mem_if,
  interface_ddma.DDMA ddma_if,
  
  output logic irq
);

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
    IDLE_REC = 0,
    REC_HEADER = 1,
    REC_SIZE = 2,
    REC_PAYLOAD = 3,
    IRQ_REC = 4
  } recv_state_t;

  // token status (which process has priority, either send or recv)
  token_t i_token;

  // remaining cycles until interleaving priority switching  
  integer i_flip_counter;

  // recv state variables 
  recv_state_t rstate = IDLE_REC;
  integer flits_to_recv = 0;

  integer RECV_BASE_POINTER = 1024;
  integer RECV_BUFFER_SIZE = 500;
  integer recv_addr = RECV_BASE_POINTER;

  // send state variables 
  send_state_t sstate = WAIT_CONFIG;
  integer temp_addr_in = 0;
  integer temp_nbytes_in = 0;

  // token request for recv and send states 
  logic has_data_to_send;
  logic has_data_to_recv;

  assign has_data_to_send = (sstate != WAIT_CONFIG && sstate != HANDSHAKE);
  assign has_data_to_recv = (rstate != IDLE_REC && rstate != IRQ_REC);

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
        if(i_flip_counter != 1) begin 
          i_flip_counter = i_flip_counter - 1; // decrease one time unit
        end 

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

          if ($past(sstate) == WAIT_CONFIG) begin
            $display("S %b (%d) -> %b (%d) : %d ut", 
              ADDRESS, ADDRESS,
              (mem_if.data_out << 16) >> 16,
              (mem_if.data_out << 16) >> 16,
              $time / 1000);
          end

          ddma_if.status_out <=  1;
          if (i_token == TOKEN_SEND) begin
            if (temp_nbytes_in > 0) begin
              if (router_if.credit_o == 1) begin
                router_if.rx <= 1;
                temp_addr_in += 1; 
                temp_nbytes_in -= 1;
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
          ddma_if.status_out <= 0;
          router_if.rx <= 0;
          sstate <= WAIT_CONFIG;
        end 
      endcase
    end else begin 
      sstate = WAIT_CONFIG;
    end 
  end 


  // !<<
  logic[FLIT_WIDTH -1 :0] r_data_o;

  always @(posedge clock) begin
    if(~reset) begin
      case (rstate)
        
        IDLE_REC: begin
          router_if.credit_i <= 0;  // keep credit down until first flit arrives
          if(router_if.tx == 1) begin  
            rstate <= REC_HEADER;
            recv_addr = RECV_BASE_POINTER;
          end
        end

        /** header is at the interface, must receive it and proceed to the next state **/ 
        REC_HEADER: begin
          if(i_token == TOKEN_RECV && router_if.tx == 1) begin
            router_if.credit_i <= 1;
            recv_addr <= (recv_addr + 1);
            rstate <= REC_SIZE;
            r_data_o <= router_if.data_o;

            $display("R %b (%d) <- %b (%d) : %d ut", 
              ADDRESS, ADDRESS,
              (router_if.data_o >> 16), (router_if.data_o >> 16),
              $time / 1000);

          end else begin 
            router_if.credit_i <= 0;
          end
        end

        /** header is at the interface, must receive it and proceed to the next state **/ 
        REC_SIZE: begin
          if(i_token == TOKEN_RECV && router_if.tx == 1) begin
            router_if.credit_i <= 1;
            recv_addr <= (recv_addr + 1);
            flits_to_recv <= router_if.data_o;
            rstate <= REC_PAYLOAD;            

            $display("R %b (%d) <- %d flits %d ut", 
              ADDRESS, ADDRESS,
              router_if.data_o,
              $time / 1000);

          end else begin 
            router_if.credit_i <= 0;
          end
        end 

        REC_PAYLOAD: begin



          if(flits_to_recv >= 0) begin
            if(i_token == TOKEN_RECV && router_if.tx == 1) begin
              router_if.credit_i <= 1;
              recv_addr <= (recv_addr + 1);
              flits_to_recv <= flits_to_recv -1;
            end else begin 
              router_if.credit_i <= 0;  
            end 
          end else begin
            rstate <= IRQ_REC;
            router_if.credit_i <= 0;
            ddma_if.irq_out <= 1;
          end
        end

        IRQ_REC: begin
          ddma_if.irq_out <= 0;
          ddma_if.status_out <= ddma_if.status_out & 2'b01;
          rstate <= IDLE_REC;

          $display("R %b (%d) <- %b (%d) : %d ut", 
              ADDRESS, ADDRESS,
              (r_data_o >> 16), (r_data_o >> 16),
              $time / 1000);

        end 
      endcase
    end else begin 
      rstate <= IDLE_REC;
    end 
  end 

  // always_comb begin
  // address can come from either send or receiving processess. 
  // memory will be set to write mode only when receiving flits,
  // otherwise it'll reside in read mode 
  assign mem_if.addr_in = (i_token == TOKEN_RECV) ? recv_addr : temp_addr_in;
  assign mem_if.wb_in = (i_token == TOKEN_RECV) && (has_data_to_recv) && (router_if.tx == 1);
  //end 

  // logic[FLIT_WIDTH-1:0] reg_mem_router;

  // router input data always comes from the sending process, which 
  // reads data from the memory  

  always @(posedge clock) begin
    router_if.data_i <= mem_if.data_out; 
  end

  assign router_if.clock_rx = clock;
  assign mem_if.data_in = router_if.data_o;
  assign mem_if.enable_in = 1;
  

endmodule: ddma

