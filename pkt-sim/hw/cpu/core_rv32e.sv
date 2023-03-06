module core_rv32e #(parameter MEMORY_WIDTH, ADDRESS) (
  input logic clock,
  input logic reset,
  interface_core_rv32e.CPU cpu_if
);

  // bind routercc (vhdl) to router_if
  core_rv32e #(MEMORY_WIDTH) processor(
    .clock(clock), 
    .reset(reset),

    .stall_i(stall_in),

    .addr_o(addr_out),
    .data_i(data_in),
    .data_o(data_out),
    .data_w_o(wb_out),

    .data_mode_o(data_mode_out),

    .extio_in(extio_in),
    .extio_out(extio_out)    
  );

endmodule: core_rv32e
