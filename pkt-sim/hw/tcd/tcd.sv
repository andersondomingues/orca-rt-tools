module tcd #(parameter MEMORY_BUS_WIDTH, TCD_CONFIG_ADDR, HYPERPERIOD)(
  input logic clock,
  input logic reset,

  interface_tcd.TCD tcd_if,
  interface_ddma.TCD ddma_if
);
  integer timer;
  integer timer_unlock = 0;

  always @(posedge clock)  begin
    if (~reset) begin
      timer = (timer != HYPERPERIOD) ? timer++ : 0;
    end else begin
      timer = 0
    end 
  end

  /** Configuration is performed in 3 cycles. First cycle
   * sets the target address (from where data comes from).
   * The second cycle sets the number of bytes to be transfered.
   * Third cycle enables the request signal (req_in).
   * Request can be performed only if the previous request is
   * finished, thus we watch the status signal. */
  typedef enum { CFG_ADDR, CFG_SIZE, CFG_TIMER, WAIT_TIMER, WAIT_DMA_OP } tcd_state;
  
  tcd_state state;

  always @(posedge clock) begin
    if (~reset) begin
      case (state)
        CFG_ADDR: begin
          if(tcd_if.input_in == 1) begin
            ddma_if.addr_in = tcd_if.data_in;
            state <= CFG_SIZE;
          end
        end
        CFG_SIZE: begin
          if(tcd_if.input_in == 1) begin
            ddma_if.nbytes_in = tcd_if.data_in;
            state <= CFG_TIMER;
          end 
        end
        CFG_TIMER: begin 
          if(tcd_if.input_in == 1) begin
            timer_unlock = tcd_if.data_in;
            state <= WAIT_TIMER;
          end 
        end
        WAIT_TIMER: begin
          if(timer_unlock == timer) begin
            state = WAIT_DMA_OP;
          end
        end
        WAIT_DMA_OP: begin
          if (ddma_if.status_out == 0) begin
            state = CFG_ADDR;
          end
        end
      endcase
    end else begin
      state <= CFG_ADDR;
    end 
  end

  always_comb begin
    ddma_if.cmd_in = (state == WAIT_DMA_OP);
  end

endmodule: tcd

