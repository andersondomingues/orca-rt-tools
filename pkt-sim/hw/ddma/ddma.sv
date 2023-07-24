/**
 * This module is a double dma that can asyncronously sends and receive packets.
 * There is only one memory bus, which is shared between sending and receiving 
 * processes. Access to the port is given to one of the processess in a round-robin
 * fashion priority schema. The cpu must configure the DMA to send packets. The 
 * interruption wire raises when a packet is tranferred to the memory. */
module ddma #(parameter 
  MEMORY_BUS_WIDTH = 32, 
  FLIT_WIDTH = 32, 
  INTERLEAVING_GRAIN = 3, 
  ADDRESS = 0
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
  typedef enum integer {
    TOKEN_SEND = 0,
    TOKEN_RECV = 1,
    TOKEN_SEND_TO_RECV = 2,
    TOKEN_RECV_TO_SEND = 3
  } interleaving_state_t;
  
  // send process state machine states 
  typedef enum integer {
    SENDING_IDLE = 0,
    SENDING_HEADER = 1,
    SENDING_SIZE = 2,
    SENDING_PAYLOAD_DELAYER = 3,
    SENDING_PAYLOAD = 4,
    SENDING_HANDSHAKE = 5
  } send_state_t;

  // recv process state machine states 
  typedef enum integer {
    RECEIVING_IDLE = 0,
    RECEIVING_HEADER = 1,
    RECEIVING_SIZE = 2,
    RECEIVING_SIZE_DELAY = 3,
    RECEIVING_SIZE_IRQ = 4,
    RECEIVING_PAYLOAD = 5,
    RECEIVING_HANDSHAKE = 6
  } recv_state_t;

  typedef logic[MEMORY_BUS_WIDTH-1:0] word;
  
  // token status (which process has priority, either send or recv)
  interleaving_state_t istate;

  // remaining cycles until interleaving priority switching  
  word i_flip_counter;

  // send/recv state variables 
  send_state_t sstate;
  recv_state_t rstate;

  // send regs
  word temp_addr_in;
  word temp_num_flits_in;
  word temp_destination;

  // recv regs
  word temp_flits_to_recv;
  word temp_recv_addr;
  
  // token request for recv and send states 
  logic has_data_to_send;
  logic has_data_to_recv;

  assign has_data_to_send = (sstate != SENDING_IDLE   && sstate != SENDING_HANDSHAKE);
  assign has_data_to_recv = (rstate != RECEIVING_IDLE && rstate != RECEIVING_SIZE_IRQ);

  // ============================== INTERLEAVING ============================
  // process for handling interleaving arbitration. 
  // rules:
  // - interleaving changes between sending and receiving actions
  // - an action changes if it timeouts or finish before the timeout
  // - if an action chaging would cause no effect, it won't change instead
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
          if (istate == TOKEN_SEND && router_if.credit_o == 1) begin
            sstate <= SENDING_SIZE;
          end
        end 

        SENDING_SIZE: begin         
          if (istate == TOKEN_SEND && router_if.credit_o == 1)  begin
            sstate <= SENDING_PAYLOAD_DELAYER;
          end
        end

        SENDING_PAYLOAD_DELAYER: begin
          if (istate == TOKEN_SEND && router_if.credit_o == 1)  begin
            sstate <= SENDING_PAYLOAD;
          end
        end 

        SENDING_PAYLOAD: begin 
          if (temp_num_flits_in == 0) begin
            sstate <= SENDING_HANDSHAKE;
          end
        end

        SENDING_HANDSHAKE: begin
          if(ddma_if.send_cmd_in == 0) begin
            sstate <= SENDING_IDLE;
          end
        end 

      endcase
    end else begin
      sstate <= SENDING_IDLE;
    end
  end

  // ============================== SENDING BH ============================
  always @(posedge clock) begin : SENDING_BEHAVIOR
    if(~reset) begin
      case (sstate)
        SENDING_IDLE: begin   // wait for sw configuration
          temp_addr_in <= ddma_if.send_addr_in;
          temp_num_flits_in <= ddma_if.send_size_in;
          temp_destination <= ddma_if.send_dest_in;
          router_if.rx <= 0;
          router_if.data_i <= 0;
        end

        SENDING_HEADER: begin  // send header flit (hw)
          if (istate == TOKEN_SEND && router_if.credit_o == 1) begin
            router_if.data_i <= temp_destination;
            router_if.rx <= 1;

            $display("ddma_mod: %s %h %h %h", 
              "SENDING_IDLE", ddma_if.send_addr_in, 
              ddma_if.send_size_in, ddma_if.send_dest_in);

            $display("ddma_mod: %s %h", sstate, temp_destination);
          end else begin
            router_if.data_i <= 0;
            router_if.rx <= 0;
          end
        end

        SENDING_SIZE: begin  // send size flit (hw)
          if (istate == TOKEN_SEND && router_if.credit_o == 1) begin
            router_if.data_i <= temp_num_flits_in;
            router_if.rx <= 1;
            $display("ddma_mod: %s %h", sstate, temp_num_flits_in);
          end else begin 
            router_if.data_i <= 0;
            router_if.rx <= 0;
          end
        end

        SENDING_PAYLOAD_DELAYER: begin
          if (istate == TOKEN_SEND && router_if.credit_o == 1) begin
            temp_addr_in <= temp_addr_in + 4; 
            temp_num_flits_in <= temp_num_flits_in - 1;
            $display("ddma_mod: %s --", sstate);
          end
          router_if.rx <= 0;
        end 

        SENDING_PAYLOAD: begin // copy payload onto router port
          if (istate == TOKEN_SEND && router_if.credit_o == 1) begin
            temp_addr_in <= temp_addr_in + 4; 
            temp_num_flits_in <= temp_num_flits_in - 1;
            router_if.data_i <= mem_if.data_out;
            router_if.rx <= 1;
            $display("ddma_mod: %s %h %s", sstate, mem_if.data_out, mem_if.data_out);
          end else begin 
            temp_addr_in <= temp_addr_in;
            temp_num_flits_in <= temp_num_flits_in;
            router_if.data_i <= 0;
            router_if.rx <= 0;
          end
        end

        SENDING_HANDSHAKE: begin
          if(ddma_if.send_cmd_in == 0) begin
            $display("ddma_mod: %s %h", sstate, ddma_if.send_cmd_in);
          end
          router_if.rx <= 0;
        end
      endcase

    end else begin
      router_if.rx <= 0;
    end
  end 

  logic recv_ack_past, recv_ack;

  // ============================== RECEIVING FSM ============================

  logic[FLIT_WIDTH-1:0] old_recv_cmd_in;

  always @(posedge clock) begin
    old_recv_cmd_in <= ddma_if.recv_cmd_in;
  end 

  always @(posedge clock) begin
    if(~reset) begin
      case (rstate)
        RECEIVING_IDLE: begin
          if(router_if.tx == 1) begin
            rstate <= RECEIVING_HEADER;
          end
        end

        RECEIVING_HEADER: begin
          if(istate == TOKEN_RECV && router_if.tx == 1) begin
            rstate <= RECEIVING_SIZE;
          end
        end 

        RECEIVING_SIZE: begin
          if(istate == TOKEN_RECV && router_if.tx == 1) begin
            rstate <= RECEIVING_SIZE_DELAY;
          end
        end 

        RECEIVING_SIZE_DELAY: begin
          rstate <= RECEIVING_SIZE_IRQ;
        end 

        RECEIVING_SIZE_IRQ: begin
          if(ddma_if.recv_cmd_in != old_recv_cmd_in) begin
            rstate <= RECEIVING_PAYLOAD;
          end
        end 
        
        RECEIVING_PAYLOAD: begin
          if(temp_flits_to_recv == 0) begin
            rstate <= RECEIVING_HANDSHAKE;
          end
        end

        RECEIVING_HANDSHAKE: begin
          if(ddma_if.recv_cmd_in != old_recv_cmd_in) begin
            rstate <= RECEIVING_IDLE;
          end
        end

      endcase 
    end else begin
      rstate <= RECEIVING_IDLE;
    end 
  end 

  // always @(posedge clock) begin
  //   if(router_if.credit_i == 1 && router_if.tx == 1) begin
  //     $display("router.data_in: 0x%h %s", router_if.data_i, rstate);
  //   end
  // end 

  // ============================== RECEIVING BH ============================
  always @(posedge clock) begin
    if(~reset) begin
      case (rstate)
        
        RECEIVING_IDLE: begin  // keep credit down until first flit arrives
          router_if.credit_i <= 0;
          mem_if.wb_in <= 0;
        end

        RECEIVING_HEADER: begin  // header flit arrived
          if(istate == TOKEN_RECV && router_if.tx == 1) begin
            router_if.credit_i <= 1;
            mem_if.wb_in <= 1;
            $display("ddma_mod: %s %h",rstate, router_if.data_o); // TODO: add security checking, wrong destination?            
          end else begin
            router_if.credit_i <= 0;
            mem_if.wb_in <= 0;
          end
        end

        RECEIVING_SIZE: begin
          if(istate == TOKEN_RECV && router_if.tx == 1) begin
            router_if.credit_i <= 1;
            mem_if.wb_in <= 1;
            $display("ddma_mod: %s %h", rstate, router_if.data_o);
          end else begin 
            router_if.credit_i <= 0;
            mem_if.wb_in <= 0;
          end
        end 

        RECEIVING_SIZE_DELAY: begin
          $display("ddma_mod: %s %h", rstate, router_if.data_o);
          temp_flits_to_recv <= router_if.data_o;
          ddma_if.recv_size_out <= router_if.data_o;
        end 

        RECEIVING_SIZE_IRQ: begin
          temp_recv_addr <= ddma_if.recv_addr_in;

          if($past(rstate == RECEIVING_SIZE)) begin
            $display("ddma_mod: %s %h", rstate, router_if.data_o);
          end
          router_if.credit_i <= 0;
          mem_if.wb_in <= 0;          
        end 

        RECEIVING_PAYLOAD: begin

          if(istate == TOKEN_RECV && router_if.tx == 1 && temp_flits_to_recv > 0) begin
            $display("ddma_mod: %s %h %s", rstate, router_if.data_o, router_if.data_o);
            router_if.credit_i <= 1;
            mem_if.wb_in <= 1;
            temp_recv_addr <= temp_recv_addr + 4;
            temp_flits_to_recv <= temp_flits_to_recv -1;            
          end else begin 
            mem_if.wb_in <= 0;
            router_if.credit_i <= 0;
          end
        end

        RECEIVING_HANDSHAKE: begin
          if($past(rstate == RECEIVING_PAYLOAD)) begin
            $display("ddma_mod: %s %h", rstate, ddma_if.recv_cmd_in);
          end 
          mem_if.wb_in <= 0;
          router_if.credit_i <= 0;           
        end 
      endcase
    end 
  end 

  // export send/recv state to status register
  assign ddma_if.state_recv_out = rstate;
  assign ddma_if.state_send_out = sstate;

  // address can come from either send or receiving processess. 
  // memory will be set to write mode only when receiving flits,
  // otherwise it'll reside in read mode 
  assign mem_if.addr_in = (istate == TOKEN_SEND || istate == TOKEN_RECV_TO_SEND )
    ? temp_addr_in 
    : temp_recv_addr;

  // router input data always comes from the sending process, 
  // which reads data from the memory  
  assign mem_if.data_in = router_if.data_o;

  // memory always engit statabled, rx clock mirrors top clock
  assign router_if.clock_rx = clock;
  assign mem_if.enable_in = 1;

  // keep sending interruption risen until cpu ack
  assign ddma_if.irq_send_out = (sstate == SENDING_HANDSHAKE);
  assign ddma_if.irq_recv_size_out = (rstate == RECEIVING_SIZE_IRQ);
  assign ddma_if.irq_recv_hshk_out = (rstate == RECEIVING_HANDSHAKE);

endmodule: ddma

