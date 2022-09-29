module pe #(parameter MEMORY_BUS_WIDTH, FLIT_WIDTH, ADDRESS, MEMORY_SIZE)(
  input logic clock,
  input logic reset,
  interface_pe.PE pe_if
);
  interface_router #(FLIT_WIDTH) router_if(clock, reset); // router and pe
  interface_router_port #(FLIT_WIDTH) router_port_if(clock, reset); // router and ddma
  interface_memory #(MEMORY_BUS_WIDTH) mem_if_dma(clock, reset); // mem and ddma
  interface_memory #(MEMORY_BUS_WIDTH) mem_if_mmio(clock, reset); // mem and mmio
  interface_ddma   #(MEMORY_BUS_WIDTH, FLIT_WIDTH) ddma_if(clock, reset); //tcd and ddma
  interface_tcd    #(MEMORY_BUS_WIDTH, FLIT_WIDTH) tcd_if(clock, reset); //tcd to mmio

  // create a new router
  router #(FLIT_WIDTH, ADDRESS) router_mod (
    .clock(clock), .reset(reset),
    .router_if(router_if.ROUTER)
  );

  // connect router interface to pe interface (only SNWE ports)
  always_comb begin
    pe_if.clock_tx[3:0] = router_if.clock_tx[3:0];
    pe_if.tx[3:0] = router_if.tx[3:0];
    pe_if.data_o[3:0] = router_if.data_o[3:0];
    pe_if.credit_o[3:0] = router_if.credit_o[3:0];

    router_if.clock_rx[3:0] = pe_if.clock_rx[3:0];
    router_if.rx[3:0] = pe_if.rx[3:0];
    router_if.data_i[3:0] = pe_if.data_i[3:0];
    router_if.credit_i[3:0] = pe_if.credit_i[3:0];
  end

  // create new ddma module
  ddma #(MEMORY_BUS_WIDTH, FLIT_WIDTH) ddma_mod(
    .clock(clock), .reset(reset), 
    .router_if(router_port_if.DDMA),
    .mem_if(mem_if_dma.DUT),
    .ddma_if(ddma_if.DDMA)
  );

  // connect router local port to the ddma
  always_comb begin
    router_port_if.clock_tx = router_if.clock_tx[4];
    router_port_if.tx = router_if.tx[4];
    router_port_if.data_o = router_if.data_o[4];
    router_port_if.credit_o = router_if.credit_o[4];

    router_if.clock_rx[4] = router_port_if.clock_rx;
    router_if.rx[4] = router_port_if.rx;
    router_if.data_i[4] = router_port_if.data_i;
    router_if.credit_i[4] = router_port_if.credit_i;
  end

  // create new scratchpad 
  dual_port_ram #(MEMORY_BUS_WIDTH, MEMORY_SIZE) memory_mod(
    .clock(clock), .reset(reset),
    .mem_if_a(mem_if_dma),
    .mem_if_b(mem_if_mmio)
  );

  // create new mmio module
  mmio mmio_mod (
    .clock(clock),
    .reset(reset),
    .mem_if(mem_if_mmio.DUT),
    .tcd_if(tcd_if.MMIO)
  );
  
  

endmodule: pe

