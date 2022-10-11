`timescale 1 ns / 1 ns

module fake_cpu_injector (
  input logic clock,
  input logic reset,
  interface_mmio.CPU mmio_if,
  input logic irq
);

  initial begin
    // cfg addr_in
    #4 mmio_if.addr_in = 12345;
    #0 mmio_if.data_in = 67890;
    #0 mmio_if.wb_in = 1;

    // cfg nbytes_in
    #1 mmio_if.addr_in = 12345;
    #0 mmio_if.data_in = 12;
    #0 mmio_if.wb_in = 1;

    // cfg timer
    #1 mmio_if.addr_in = 12345;
    #0 mmio_if.data_in = 30;
    #0 mmio_if.wb_in = 1;
  end

endmodule: fake_cpu_injector

