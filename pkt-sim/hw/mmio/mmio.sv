module mmio (
  input logic clock,
  input logic reset,
  interface_memory.DUT mem_if,
  interface_tcd.MMIO tcd_if
);
  
  assign mem_if.enable_in = 0;
  assign mem_if.data_in = 0;
      
  assign tcd_if.addr_in = 0;
  assign tcd_if.nbytes_in = 0;
  assign tcd_if.req_in = 0;
  assign tcd_if.ack_in = 0;

  

// module mmio (
//   input logic clock,
//   input logic reset,
//   interface_memory.MEM mem_if_cpu,
//   interface_memory.DUT mem_if_mem,
//   interface_tcd.MMIO tcd_if
// );
  
//   assign mem_if_mem.enable_in = mem_if_cpu.enable_in;
//   assign mem_if_mem.data_in = mem_if_cpu.data_in;
//   assign mem_if_mem.wb_in = mem_if_cpu.wb_in;
//   assign mem_if_cpu.data_out = mem_if_mem.data_out;

      
//   assign tcd_if.addr_in = 0;
//   assign tcd_if.nbytes_in = 0;
//   assign tcd_if.req_in = 0;
//   assign tcd_if.ack_in = 0;

// endmodule: mmio



endmodule: mmio

