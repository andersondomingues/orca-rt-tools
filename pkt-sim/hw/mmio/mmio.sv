module mmio #(parameter MEMORY_BUS_WIDTH, MEMORY_BASE, MEMORY_SIZE) (
  input logic clock,
  input logic reset,
  interface_memory.DUT mem_if,
  interface_tcd.MMIO tcd_if,
  interface_mmio.MMIO mmio_if
);
  
  always_comb begin
    mmio_if.data_out = mem_if.data_out;
    mem_if.enable_in = 1;
    mem_if.data_in = mmio_if.data_in;

    if(mmio_if.addr_in < MEMORY_BASE + MEMORY_SIZE && mmio_if.addr_in > MEMORY_BASE) begin
      mem_if.addr_in = mmio_if.addr_in;
      mem_if.wb_in = mmio_if.wb_in;
    end else begin
      mem_if.addr_in = 0;
      mem_if.wb_in = 0;
    end
  end

  always @(posedge clock) begin
    if (~reset) begin
      tcd_if.addr_in = 0;
      tcd_if.nbytes_in = 0;
      tcd_if.req_in = 0;
      tcd_if.ack_in = 0;
    end 
  end 
     


endmodule: mmio

