import orca_pkg::*;

`include "orca_defs.svh"

/**
 * This module is a double dma that can asyncronously sends and receive packets.
 * There is only one memory bus, which is shared between sending and receiving 
 * processes. Access to the port is given to one of the processess in a round-robin
 * fashion priority schema. The cpu must configure the DMA to send packets. The 
 * interruption wire raises when a packet is tranferred to the memory. */
module ddma #(parameter 
  MEMORY_BUS_WIDTH, 
  FLIT_WIDTH, 
  INTERLEAVING_GRAIN, 
  ADDRESS,
  RAM_MSIZE
)(
  input logic clock,
  input logic reset,

  interface_router_port.DDMA router_if,
  interface_memory.DUT mem_if,
  interface_ddma.DDMA ddma_if
);

  //==============================================================

  // interleaving_state_t represents the process which has priority in 
  // the interleaving system. 
  typedef enum logic[3:0] {
    TOKEN_SEND = 4'b0001,
    TOKEN_RECV = 4'b0010,
    TOKEN_SEND_TO_RECV = 4'b0100,
    TOKEN_RECV_TO_SEND = 4'b1000
  } interleaving_state_t;
  
  // send process state machine states 
  typedef enum logic[7:0] {
    SENDING_IDLE            = 8'b0000_0001,
    SENDING_HEADER          = 8'b0000_0010,
    SENDING_SIZE            = 8'b0000_0100,
    SENDING_PAYLOAD_DELAYER = 8'b0000_1000,
    SENDING_PAYLOAD         = 8'b0001_0000,
    SENDING_PAYLOAD_CLEANUP = 8'b0010_0000,
    SENDING_HANDSHAKE       = 8'b0100_0000
  } send_state_t;

  // recv process state machine states 
  typedef enum logic[7:0] {
    RECEIVING_HEADER        = 8'b0000_0001,
    RECEIVING_SIZE_DELAYER  = 8'b0000_0010,
    RECEIVING_SIZE          = 8'b0000_0100,    
    RECEIVING_IRQ_ADDR      = 8'b0000_1000,
    RECEIVING_PAYLOAD_DELAY = 8'b0001_0000,
    RECEIVING_PAYLOAD       = 8'b0010_0000,
    RECEIVING_HANDSHAKE     = 8'b0100_0000
  } recv_state_t;
  
  // token status (which process has priority, either send or recv)
  interleaving_state_t istate;

  // remaining cycles until interleaving priority switching  
  word_t i_flip_counter;

  // send/recv state variables 
  send_state_t sstate;
  recv_state_t rstate;

  // send regs
  word_t temp_addr_in;
  word_t temp_num_flits_in;
  word_t temp_destination;

  // recv regs
  word_t temp_flits_to_recv;
  word_t temp_recv_addr;
  
  // token request for recv and send states 
  logic has_data_to_send;
  logic has_data_to_recv;

  assign has_data_to_send = (sstate != SENDING_IDLE   && sstate != SENDING_HANDSHAKE);
  assign has_data_to_recv = (rstate == RECEIVING_PAYLOAD_DELAY || rstate == RECEIVING_PAYLOAD);

  // ============================== INTERLEAVING ============================
  // process for handling interleaving arbitration. 
  // rules:
  // - interleaving changes between sending and receiving actions
  // - an action changes if it timeouts or finish before the timeout
  // - if an action chaging would cause no effect, it won't change instead

  integer send_serial_counter = 0;

  // address can come from either send or receiving processess. 
  // memory will be set to write mode only when receiving flits,
  // otherwise it'll reside in read mode 
  // ** addr_in is 4-byte aligned
  // ** addr_in is capped to memory size
  always_comb begin
    if(istate == TOKEN_SEND || istate == TOKEN_RECV_TO_SEND) begin
      mem_if.addr_in = (temp_addr_in & (RAM_MSIZE -1)) >> 2;
    end else begin
      mem_if.addr_in = (temp_recv_addr & (RAM_MSIZE -1)) >> 2;
    end
  end

  always @(posedge clock) begin
    if(~reset) begin
      case (istate) 

        TOKEN_SEND: begin
          if (i_flip_counter == 1) begin
            if(has_data_to_recv) begin
              istate <= TOKEN_SEND_TO_RECV;
            end
          end else begin
            i_flip_counter <= i_flip_counter - 1;
          end
        end 

        TOKEN_RECV: begin
          if (i_flip_counter == 1) begin
            if(has_data_to_send) begin
              istate <= TOKEN_RECV_TO_SEND;
            end
          end else begin
            i_flip_counter <= i_flip_counter - 1;
          end
        end 

        TOKEN_SEND_TO_RECV: begin
          istate <= TOKEN_RECV;
          i_flip_counter <= INTERLEAVING_GRAIN;
        end

        TOKEN_RECV_TO_SEND: begin 
          istate <= TOKEN_SEND;
          i_flip_counter <= INTERLEAVING_GRAIN;
        end 
      endcase

    end else begin
      istate <= TOKEN_SEND; // default state
      i_flip_counter <= INTERLEAVING_GRAIN;
    end
  end 

  // ============================== SENDING FSM ============================
   always @(posedge clock) begin : SENDING_FSM
    if(~reset) begin
      case (sstate)
        SENDING_IDLE: begin
          if (ddma_if.send_cmd_in == 1) begin
            sstate <= SENDING_HEADER;
          end 
        end

        SENDING_HEADER: begin
          if (router_if.credit_o == 1) begin
            sstate <= SENDING_SIZE;
          end
        end 

        SENDING_SIZE: begin         
          if (router_if.credit_o == 1)  begin
            sstate <= SENDING_PAYLOAD_DELAYER;
          end
        end

        SENDING_PAYLOAD_DELAYER: begin
          if (istate == TOKEN_SEND && router_if.credit_o == 1) begin
            sstate <= SENDING_PAYLOAD;
          end
        end 

        SENDING_PAYLOAD: begin 
          if (temp_num_flits_in == 0) begin
            sstate <= SENDING_HANDSHAKE;
          end else if (istate != TOKEN_SEND || router_if.credit_o == 0) begin
            sstate <= SENDING_PAYLOAD_DELAYER;
          end else begin
            sstate <= SENDING_PAYLOAD;
          end
        end

        SENDING_HANDSHAKE: begin
          if(ddma_if.send_cmd_in == 0) begin
            sstate <= SENDING_IDLE;
            //$display("%0t network -> done %h %h %0d %0d", ($realtime), ADDRESS, temp_destination, temp_num_flits_in, send_serial_counter);
          end
        end

      endcase
    end else begin
      sstate <= SENDING_IDLE;
    end
  end

  // ============================== SENDING BH ============================
  send_state_t a_sstate;
  always @(posedge clock) begin
    a_sstate <= sstate;
  end

  always @(posedge clock) begin : SENDING_BEHAVIOR
    if(~reset) begin
      case (sstate)
        SENDING_IDLE: begin   // wait for sw configuration
          temp_addr_in <= ddma_if.send_addr_in;
          temp_num_flits_in <= ddma_if.send_size_in;
          temp_destination <= ddma_if.send_dest_in;
          router_if.rx <= 0;
        end

        SENDING_HEADER: begin  // send header flit (hw)
          if (router_if.credit_o == 1) begin
            router_if.data_i <= temp_destination;
            router_if.rx <= 1;
            //$display("%0t network -> start %h %h %0d %0d", ($realtime), ADDRESS, temp_destination, temp_num_flits_in, ++send_serial_counter);
            //`warn(("TX %h: %s %h %h", ADDRESS, sstate, temp_destination, temp_addr_in));

          end else begin
            router_if.data_i <= 0;
            router_if.rx <= 0;
          end
        end

        SENDING_SIZE: begin  // send size flit (hw)
          if (router_if.credit_o == 1) begin
            router_if.data_i <= temp_num_flits_in;
            router_if.rx <= 1;
            //`warn(("TX %h: %s %h", ADDRESS, sstate, temp_num_flits_in));
          end else begin 
            router_if.rx <= 0;
          end
        end

        SENDING_PAYLOAD_DELAYER: begin
          router_if.rx <= 0;
          router_if.data_i <= mem_if.data_out;

          if (istate == TOKEN_SEND && router_if.credit_o == 1) begin
            temp_addr_in <= temp_addr_in + 4;
          end
        end

        SENDING_PAYLOAD: begin // copy payload onto router port
          router_if.data_i <= mem_if.data_out;

          if (temp_num_flits_in > 0) begin
            if (istate == TOKEN_SEND && router_if.credit_o == 1) begin
            
              temp_addr_in <= temp_addr_in + 4; 
              temp_num_flits_in <= temp_num_flits_in - 1;
              router_if.rx <= 1;

              //`warn(("TX %h: %s %h", ADDRESS, sstate, mem_if.data_out));
              //$display("%h %h", $past(mem_if.addr_in), mem_if.data_out);
            end else begin 
              router_if.rx <= 0;

              if(a_sstate != SENDING_PAYLOAD_DELAYER) begin
                temp_num_flits_in <= temp_num_flits_in + 1;
                temp_addr_in <= temp_addr_in - 8;
              end else begin 
                temp_addr_in <= temp_addr_in - 4;
              end
            end
          end else begin
            router_if.rx <= 0;
          end 
        end

        SENDING_HANDSHAKE: begin
          router_if.rx <= 0;
        end
      endcase

    end else begin
      router_if.rx <= 0;
      router_if.data_i <= 0;
      temp_addr_in <= 0;
      temp_num_flits_in <= 0;
      temp_destination <= 0;
    end
  end 

  

  // ============================== RECEIVING FSM ============================

  logic[FLIT_WIDTH-1:0] old_recv_cmd_in;
  
  always @(posedge clock) begin
    old_recv_cmd_in <= ddma_if.recv_cmd_in;
  end 

  always @(posedge clock) begin
    if(~reset) begin
      case (rstate)
        RECEIVING_HEADER: begin
          if(router_if.tx == 1) begin
            rstate <= RECEIVING_SIZE_DELAYER;
          end
        end 

        RECEIVING_SIZE_DELAYER: begin
          if(router_if.tx == 1) begin
            rstate <= RECEIVING_SIZE;
          end
        end 

        RECEIVING_SIZE: begin
          if(router_if.tx == 1) begin
            rstate <= RECEIVING_IRQ_ADDR;
          end
        end

        RECEIVING_IRQ_ADDR: begin
          if(ddma_if.recv_cmd_in != old_recv_cmd_in) begin
            rstate <= RECEIVING_PAYLOAD_DELAY;
          end
        end 

        RECEIVING_PAYLOAD_DELAY: begin
          if((istate == TOKEN_RECV && router_if.tx == 1) || temp_flits_to_recv == 0) begin
            rstate <= RECEIVING_PAYLOAD;
          end
        end
        
        RECEIVING_PAYLOAD: begin
          if(temp_flits_to_recv == 1) begin
            rstate <= RECEIVING_HANDSHAKE;
          end
        end

        RECEIVING_HANDSHAKE: begin
          if(ddma_if.recv_cmd_in != old_recv_cmd_in) begin
            rstate <= RECEIVING_HEADER;
          end
        end

      endcase 
    end else begin
      rstate <= RECEIVING_HEADER;
    end 
  end 


  integer recv_serial_counter = 0;
  // ============================== RECEIVING BH ============================
  always @(posedge clock) begin
    if(~reset) begin
      case (rstate)
        
         // TODO: add security checking, wrong destination?            
        RECEIVING_HEADER: begin  // keep credit down until first flit arrives
          if(router_if.tx == 1) begin
            router_if.credit_i <= 1;
            //`info(("RX %h: %s %h", ADDRESS,rstate, router_if.data_o));            
            //$display("%0t network <- start %h %h %0d", ($realtime), ADDRESS, router_if.data_o, ++recv_serial_counter);
          end else begin
            router_if.credit_i <= 0;
          end
          mem_if.wb_in <= 0;
          temp_flits_to_recv <= 0;
        end

        RECEIVING_SIZE_DELAYER: begin
          router_if.credit_i <= 0;
          mem_if.wb_in <= 0;
        end

        RECEIVING_SIZE: begin
          if(router_if.tx == 1) begin
            router_if.credit_i <= 1;
            temp_flits_to_recv <= router_if.data_o;
            ddma_if.recv_size_out <= router_if.data_o;
            //`info(("RX %h: %s %h", ADDRESS, rstate, router_if.data_o));
          end else begin 
            router_if.credit_i <= 0;
          end
          mem_if.wb_in <= 0;          
        end 

        RECEIVING_IRQ_ADDR: begin
          temp_recv_addr <= ddma_if.recv_addr_in;
          ddma_if.recv_addr_out <= ddma_if.recv_addr_in;
          router_if.credit_i <= 0;
          mem_if.wb_in <= 0;
        end

        RECEIVING_PAYLOAD_DELAY: begin
          if(istate == TOKEN_RECV && router_if.tx == 1) begin
            router_if.credit_i <= 1;
            mem_if.wb_in <= 'b1111;
          end else begin
            router_if.credit_i <= 0;
          end
        end 

        RECEIVING_PAYLOAD: begin
          if(istate == TOKEN_RECV && router_if.tx == 1 && temp_flits_to_recv > 1) begin
            //`info(("RX %h: %s %h %h %s", ADDRESS, rstate, temp_recv_addr, router_if.data_o, router_if.data_o));
            router_if.credit_i <= 1;
            mem_if.wb_in <= 'b1111;
            temp_recv_addr <= temp_recv_addr + 4;
            temp_flits_to_recv <= temp_flits_to_recv -1;            
          end else begin 
            mem_if.wb_in <= 0;
            router_if.credit_i <= 0;
            temp_recv_addr <= temp_recv_addr - 4;
            temp_flits_to_recv <= temp_flits_to_recv +1;
          end
        end

        RECEIVING_HANDSHAKE: begin
          // $display("%0t network <- done %h %0d", ($realtime), ADDRESS, ddma_if.recv_cmd_in);          
          mem_if.wb_in <= 0;
          router_if.credit_i <= 0;
        end 
      endcase
    end else begin
      mem_if.wb_in <= 0;
      temp_recv_addr <= 0;
    end
  end 

  // export send/recv state to status register
  assign ddma_if.state_recv_out = rstate;
  assign ddma_if.state_send_out = sstate;

  // router input data always comes from the sending process, 
  // which reads data from the memory  
  assign mem_if.data_in = router_if.data_o;

  // memory always engit statabled, rx clock mirrors top clock
  assign router_if.clock_rx = clock;

  // keep sending interruption risen until cpu ack
  assign ddma_if.irq_send_out = (sstate == SENDING_HANDSHAKE);
  assign ddma_if.irq_recv_size_out = (rstate == RECEIVING_IRQ_ADDR);
  assign ddma_if.irq_recv_hshk_out = (rstate == RECEIVING_HANDSHAKE);

endmodule: ddma

