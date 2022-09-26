module pe #(parameter MEMORY_BUS_WIDTH, FLIT_WIDTH, ADDRESS)(
  interface_pe.PE pe_if
);

  interface_memory #(MEMORY_BUS_WIDTH) mem_if(pe_if.clock, pe_if.reset);
  interface_router #(FLIT_WIDTH) router_if(pe_if.clock, pe_if.reset);
  interface_tcd    #(MEMORY_BUS_WIDTH, FLIT_WIDTH) tcd_if(pe_if.clock, pe_if.reset);
  interface_cpu    #(MEMORY_BUS_WIDTH) cpu_if(pe_if.clock, pe_if.reset);

  // ddma instance and bindings
  ddma #(MEMORY_BUS_WIDTH, FLIT_WIDTH) ddma_mod(
    .clock(pe_if.clock), .reset(pe_if.reset), 
    .cpu_if(cpu_if.DUT),
    .mem_if(mem_if.DUT),
    .router_if(router_if.DUT),
    .tcd_if(tcd_if.DUT)
  );

  router #(FLIT_WIDTH, ADDRESS) router_mod (router_if.ROUTER);

  // assign pe_if.clock_tx[3:0] = router_if.clock_tx[3:0];
  // assign pe_if.tx[3:0] = router_if.tx[3:0];
  // assign pe_if.credit_i[3:0] = router_if.credit_i[3:0];
  // assign pe_if.data_o[3:0] = router_if.data_o[3:0];

endmodule: pe

