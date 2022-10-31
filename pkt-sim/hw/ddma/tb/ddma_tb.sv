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
  always @(posedge clock) begin
    if(~reset) begin
      #0;
      ddma_if.cmd_in = 0;
      ddma_if.addr_in = 55;
      ddma_if.nbytes_in = 9;
      #10; 
      ddma_if.cmd_in = 1;
      #100;
    end
  end

  // drive router signals
  always @(posedge clock) begin
    if(~reset) begin
      // sending wires
      router_if.credit_o = 1;

      // recv wires
      router_if.tx = 0;
      router_if.clock_tx = clock;
      router_if.data_o = 0;
    end 
  end 

  // ground unused memory port
  always @(posedge clock) begin
    mem_if.enable_in = 0;
    mem_if.wb_in = 0;
    mem_if.data_in = 23;
    mem_if.addr_in = 0;
  end 

  // prints 
  always @(ddma_if.status_out) begin
    $display(ddma_if.status_out);
  end 

  always @(ddma_if.irq_out) begin
    $display(ddma_if.irq_out);
  end 


endmodule: ddma_tb

