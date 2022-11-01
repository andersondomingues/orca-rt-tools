`timescale 1 ns / 1 ns

module ddma_tb #(parameter MEMORY_BUS_WIDTH, FLIT_WIDTH)(
  input logic clock,
  input logic reset,
  interface_router_port.ROUTER router_if,
  interface_memory.DUT mem_if, // mmio, grounded
  interface_ddma.TCD ddma_if
);
  
  logic cpu_irq;

  // drive tcd signals
  initial begin
    // ================================== [TEST 1]
    //      free sending, no interleaving
    // ===========================================

    router_if.credit_o = 1;      // enable sending (router)
    router_if.tx = 0;            // disable receiving
    router_if.clock_tx = clock;
    router_if.data_o = 0;

    #0;
    ddma_if.cmd_in = 0;
    #2;
    ddma_if.addr_in = 55;        // configure mem copy addr
    #2;
    ddma_if.nbytes_in = 9;       // configure num of bytes
    #2;
    ddma_if.cmd_in = 1;          // start copy
    #6;
    ddma_if.cmd_in = 0;          // acknowledgement

    #2;
    ddma_if.addr_in = 15;        // configure mem copy addr
    #2;
    ddma_if.nbytes_in = 19;       // configure num of bytes
    #2;
    ddma_if.cmd_in = 1;          // start copy
    #7;
    ddma_if.cmd_in = 0;          // acknowledgement

  end

  // drive router signals
  always @(posedge clock) begin
    if(~reset) begin
      // sending wires
      

      // recv wires
      
    end 
  end 

  // ground unused memory port
  always @(posedge clock) begin
    if(~reset) begin
      mem_if.enable_in = 0;
      mem_if.wb_in = 0;
      mem_if.data_in = 0;
      mem_if.addr_in = 0;
    end 
  end 

  // prints 
  always @(ddma_if.status_out) begin
    $display(ddma_if.status_out);
  end 

  always @(ddma_if.irq_out) begin
    $display(ddma_if.irq_out);
  end 


endmodule: ddma_tb

