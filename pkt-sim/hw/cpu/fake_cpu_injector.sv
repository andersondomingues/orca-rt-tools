module fake_cpu_injector (
  input logic clock,
  input logic reset,
  interface_mmio.CPU mmio_if,
  input logic irq
);

  always @(posedge clock) begin
    if (~reset) begin
      mmio_if.data_in = 67890;
      mmio_if.addr_in = 12345;
      mmio_if.wb_in = 0;
    end 
  end 


endmodule: fake_cpu_injector

