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

  // token_t represents the process which has priority in 
  // the interleaving system. 
  typedef enum integer {
    TOKEN_SEND = 0,
    TOKEN_RECV = 1
  } token_t;
  
  // send process state machine states 
  typedef enum integer {
    SENDING_IDLE = 0,
    SENDING_HEADER = 1,
    SENDING_SIZE = 2,
    SENDING_PAYLOAD = 3,
    SENDING_HANDSHAKE = 4
  } send_state_t;

  // recv process state machine states 
  typedef enum integer {
    RECEIVING_IDLE = 0,
    RECEIVING_HEADER = 1,
    RECEIVING_SIZE = 2,
    RECEIVING_PAYLOAD = 3,
    RECEIVING_HANDSHAKE = 4
  } recv_state_t;

  // token status (which process has priority, either send or recv)
  token_t i_token;

  // remaining cycles until interleaving priority switching  
  integer i_flip_counter;

  // send/recv state variables 
  send_state_t sstate = SENDING_IDLE;
  recv_state_t rstate = RECEIVING_IDLE; 

  // send regs
  logic[MEMORY_BUS_WIDTH-1:0] temp_addr_in;
  logic[MEMORY_BUS_WIDTH-1:0] temp_num_flits_in;
  logic[MEMORY_BUS_WIDTH-1:0] temp_destination;

  // recv regs
  logic[MEMORY_BUS_WIDTH-1:0] temp_flits_to_recv;
  logic[MEMORY_BUS_WIDTH-1:0] temp_recv_addr;
  
  // token request for recv and send states 
  logic has_data_to_send;
  logic has_data_to_recv;

  assign has_data_to_send = (sstate != SENDING_IDLE   && sstate != SENDING_HANDSHAKE);
  assign has_data_to_recv = (rstate != RECEIVING_IDLE && rstate != RECEIVING_HANDSHAKE);

  // ============================== INTERLEAVING ============================
  // process for handling interleaving arbitration. 
  // rules:
  // - interleaving changes between sending and receiving actions
  // - an action changes if it timeouts or finish before the timeout
  // - if an action chaging would cause no effect, it won't change instead
  always @(posedge clock) begin
    if(~reset) begin
      if(i_flip_counter == 1) begin
        if (i_token == TOKEN_SEND && has_data_to_recv) begin
          i_token <= TOKEN_RECV;
          i_flip_counter <= INTERLEAVING_GRAIN; // reset counter
        end else if (i_token == TOKEN_RECV && has_data_to_send) begin
          i_token <= TOKEN_SEND;
          i_flip_counter <= INTERLEAVING_GRAIN; // reset counter
        end
      end else begin
        if(i_flip_counter != 1) begin 
          i_flip_counter <= i_flip_counter - 1; // decrease one time unit
        end 

        if (i_token == TOKEN_SEND && ~has_data_to_send && has_data_to_recv) begin
          i_token <= TOKEN_RECV;
          i_flip_counter <= INTERLEAVING_GRAIN; // reset counter
        end else if (i_token == TOKEN_RECV && ~has_data_to_recv && has_data_to_send) begin
          i_token <= TOKEN_SEND;
          i_flip_counter <= INTERLEAVING_GRAIN; // reset counter
        end 
      end
    end else begin
      i_flip_counter <= 1;
      i_token <= TOKEN_SEND;
    end 
  end

  // ============================== SENDING FSM ============================

  logic[FLIT_WIDTH-1:0] s_flit_counter;
  logic[FLIT_WIDTH-1:0] so_flit_counter;

  always @(posedge clock) begin
    so_flit_counter <= s_flit_counter;
  end 

  always @(posedge clock) begin : SENDING_FSM
    if(~reset) begin
      case (sstate)
        SENDING_IDLE: begin
          if (ddma_if.cmd_in == 1) begin
            sstate <= SENDING_HEADER;
          end 
        end

        SENDING_HEADER: begin
          if (i_token == TOKEN_SEND && router_if.credit_o == 1) begin
            sstate <= SENDING_SIZE;
          end
        end 

        SENDING_SIZE: begin         
          if (i_token == TOKEN_SEND && router_if.credit_o == 1)  begin
            sstate <= SENDING_PAYLOAD;
          end
        end

        SENDING_PAYLOAD: begin 
          if (temp_num_flits_in == 0) begin
            sstate <= SENDING_HANDSHAKE;
          end
        end

        SENDING_HANDSHAKE: begin
          if(ddma_if.cmd_in == 0) begin
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
          temp_addr_in <= ddma_if.addr_in;
          temp_num_flits_in <= ddma_if.size_in;
          temp_destination <= ddma_if.dest_in;
          router_if.rx <= 0;
          router_if.data_i <= 0;
          s_flit_counter <= 0;
        end

        SENDING_HEADER: begin  // send header flit (hw)

          temp_addr_in <= temp_addr_in;
          temp_num_flits_in <= temp_num_flits_in;
          temp_destination <= temp_destination;

          if (i_token == TOKEN_SEND && router_if.credit_o == 1) begin
            router_if.data_i <= temp_destination;
            router_if.rx <= 1;
            s_flit_counter <= s_flit_counter + 1;

            $display("ddma_mod: %s %h %h %h", 
              "SENDING_IDLE", ddma_if.addr_in, 
              ddma_if.size_in, ddma_if.dest_in);

            $display("ddma_mod: %s %h", sstate, temp_destination);
          end else begin
            s_flit_counter <= s_flit_counter;
            router_if.data_i <= 0;
            router_if.rx <= 0;
          end
        end

        SENDING_SIZE: begin  // send size flit (hw)

          temp_addr_in <= temp_addr_in;
          temp_num_flits_in <= temp_num_flits_in;
          temp_destination <= temp_destination;

          if (i_token == TOKEN_SEND && router_if.credit_o == 1) begin
            router_if.data_i <= temp_num_flits_in;
            router_if.rx <= 1;
            $display("ddma_mod: %s %h", sstate, temp_num_flits_in);
            s_flit_counter <= s_flit_counter + 1;
          end else begin 
            router_if.data_i <= 0;
            router_if.rx <= 0;
            s_flit_counter <= s_flit_counter;
          end
        end

        SENDING_PAYLOAD: begin // copy payload onto router port

          temp_destination <= temp_destination;

          if (i_token == TOKEN_SEND && router_if.credit_o == 1) begin
            temp_addr_in <= temp_addr_in + 4; 
            temp_num_flits_in <= temp_num_flits_in - 1;
            router_if.data_i <= mem_if.data_out;
            router_if.rx <= 1;
            s_flit_counter <= s_flit_counter + 1;
            $display("ddma_mod: %s %h %s", sstate, mem_if.data_out, mem_if.data_out);
          end else begin 
            temp_addr_in <= temp_addr_in;
            temp_num_flits_in <= temp_num_flits_in;
            router_if.data_i <= 0;
            router_if.rx <= 0;
            s_flit_counter <= s_flit_counter;
          end
        end

        SENDING_HANDSHAKE: begin
          temp_addr_in <= temp_addr_in;
          temp_num_flits_in <= temp_num_flits_in;
          temp_destination <= temp_destination;
          router_if.data_i <= 0;
          router_if.rx <= 0;
          s_flit_counter <= s_flit_counter;
        end
      endcase

    end else begin 
      temp_addr_in <= 0;
      temp_num_flits_in <= 0;
      temp_destination <= 0;
      router_if.data_i <= 0;
      router_if.rx <= 0;

      so_flit_counter <= 0;
      s_flit_counter <= 0;
    end
  end 

  logic recv_ack_past, recv_ack;

  // ============================== RECEIVING FSM ============================

  logic[FLIT_WIDTH-1:0] r_flit_counter;
  logic[FLIT_WIDTH-1:0] ro_flit_counter;

  always @(posedge clock) begin
    ro_flit_counter <= r_flit_counter;
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
          if (r_flit_counter != ro_flit_counter) begin
            rstate <= RECEIVING_SIZE;
          end
        end 

        RECEIVING_SIZE: begin
          if (r_flit_counter != ro_flit_counter) begin
            rstate <= RECEIVING_PAYLOAD;
          end
        end 
        
        RECEIVING_PAYLOAD: begin
           if(temp_flits_to_recv == 0) begin
            rstate <= RECEIVING_HANDSHAKE;
          end
        end 

        RECEIVING_HANDSHAKE: begin
          if(recv_ack != recv_ack_past) begin
            rstate <= RECEIVING_IDLE;
          end
        end 

      endcase 
    end else begin
      rstate <= RECEIVING_IDLE;
    end 
  end 

  // ============================== RECEIVING BH ============================

  // !<<
  logic[FLIT_WIDTH-1:0] temp_next_addr;

  always @(posedge clock) begin
    if(~reset) begin
      case (rstate)
        
        RECEIVING_IDLE: begin  // keep credit down until first flit arrives
          temp_recv_addr <= temp_next_addr;   // ! from mmio config
          router_if.credit_i <= 0;
          mem_if.wb_in <= 0;
          r_flit_counter <= 0;
        end

        RECEIVING_HEADER: begin  // header flit arrived
          if(i_token == TOKEN_RECV && router_if.tx == 1) begin
            router_if.credit_i <= 1;
            mem_if.wb_in <= 1;
            r_flit_counter <= r_flit_counter + 1;

            $display("ddma_mod: %s %h",rstate, router_if.data_o);
            // TODO: add security checking, wrong destination?

          end else begin
            router_if.credit_i <= 0;
            mem_if.wb_in <= 0;
          end
        end

        RECEIVING_SIZE: begin
          if(i_token == TOKEN_RECV && router_if.tx == 1) begin
            router_if.credit_i <= 1;
            mem_if.wb_in <= 1;
            temp_flits_to_recv <= router_if.data_o;
            r_flit_counter <= r_flit_counter + 1;

            $display("ddma_mod: %s %h", rstate, router_if.data_o);
          end else begin 
            router_if.credit_i <= 0;
            mem_if.wb_in <= 0;
          end
        end 

        RECEIVING_PAYLOAD: begin
          if(i_token == TOKEN_RECV && router_if.tx == 1 && temp_flits_to_recv > 0) begin
            router_if.credit_i <= 1;
            mem_if.wb_in <= 1;
            temp_recv_addr <= temp_recv_addr + 4;
            temp_flits_to_recv <= temp_flits_to_recv -1;
            $display("ddma_mod: %s %h %s", rstate, router_if.data_o, router_if.data_o);
          end else begin 
            mem_if.wb_in <= 0;
            router_if.credit_i <= 0;  
          end
        end

        RECEIVING_HANDSHAKE: begin
          mem_if.wb_in <= 0;
          router_if.credit_i <= 0;
        end 
      endcase
    end else begin 
      recv_ack = 0;
      recv_ack_past = 0;
    end 
  end 

  always @(posedge clock) begin
    recv_ack_past <= recv_ack;
  end 

  // export send/recv state to status register
  assign ddma_if.state_recv_out = rstate;
  assign ddma_if.state_send_out = sstate;

  // address can come from either send or receiving processess. 
  // memory will be set to write mode only when receiving flits,
  // otherwise it'll reside in read mode 
  assign mem_if.addr_in = (i_token == TOKEN_SEND) ? temp_addr_in : temp_recv_addr;

  // router input data always comes from the sending process, 
  // which reads data from the memory  
  assign mem_if.data_in = router_if.data_o;

  // memory always enabled, rx clock mirrors top clock
  assign router_if.clock_rx = clock;
  assign mem_if.enable_in = 1;

  // keep sending interruption risen until cpu ack
  assign ddma_if.irq_send_out = (sstate == SENDING_HANDSHAKE);
  assign ddma_if.irq_recv_out = (rstate == RECEIVING_HANDSHAKE);

endmodule: ddma

