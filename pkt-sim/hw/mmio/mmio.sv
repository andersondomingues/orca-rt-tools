`define TCD_CONFIG_ADDR 12345

module mmio #(parameter MEMORY_BUS_WIDTH, MEMORY_BASE, MEMORY_SIZE, TCD_CONFIG_ADDR = 12345) (
  input logic clock,
  input logic reset,
  interface_memory.DUT mem_if,
  interface_tcd.MMIO tcd_if,
  interface_mmio.MMIO mmio_if
);
  always_comb begin

    // connects wiring between memory and cpu.
    mem_if.enable_in = 1;
    mem_if.data_in = mmio_if.data_in;

    // redirects input to the tcd module
    tcd_if.data_in = mmio_if.data_in;

    // prevents cpu from accessing addresses
    // out of the memory space
    if(mmio_if.addr_in < MEMORY_BASE + MEMORY_SIZE && mmio_if.addr_in > MEMORY_BASE) begin
      mem_if.addr_in = mmio_if.addr_in;
      mem_if.wb_in = mmio_if.wb_in;
      mmio_if.data_out = mem_if.data_out;
    end else begin
      // "ground memory" for invalid address range
      mem_if.addr_in = MEMORY_BASE;
      mem_if.wb_in = 0;

      // enable tcd interaction if reading/writing to TCD_CONFIG_ADDR 
      if(mmio_if.addr_in == TCD_CONFIG_ADDR) begin 
        tcd_if.input_in = mmio_if.wb_in;
        mmio_if.data_out = tcd_if.status_out;
      end
    end
  end
endmodule: mmio

