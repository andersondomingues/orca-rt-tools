module manycore_pe #(parameter
  MEMORY_WIDTH, 
  FLIT_WIDTH,
  MEMORY_SIZE,
  ADDRESS = 0,
  INTERLEAVING_GRAIN
)(
  input logic clock,
  input logic reset,
  interface_pe.PE pe_if
);

  // =========================================================
  //                    INTERFACES
  // =========================================================
  interface_router #(FLIT_WIDTH) router_if(clock, reset); // router and pe
  interface_router_port #(FLIT_WIDTH) router_port_if(clock, reset); // router and ddma
  interface_ddma   #(MEMORY_WIDTH, FLIT_WIDTH, INTERLEAVING_GRAIN, ADDRESS) ddma_if(clock, reset); //tcd and ddma
  interface_memory #(MEMORY_WIDTH) mem_if_dma(clock, reset); // mem and ddma
  interface_memory #(MEMORY_WIDTH) mem_if_mmio(clock, reset); // mem and mmio
  interface_peripherals #(MEMORY_WIDTH) perif_if(clock, reset);
  interface_core_rv32e #(MEMORY_WIDTH) cpu_if(clock, reset); // cpu to mmio
  interface_tcd #(MEMORY_WIDTH) tcd_if(clock, reset);

  // =========================================================
  //                    MODULES
  // =========================================================
  peripherals #(MEMORY_WIDTH) prif_mod(
    .pheripherals_if(perif_if.PERIPHERALS)
  );

  tcd #(MEMORY_WIDTH) tcd_mod(
    .clock(clock), .reset(reset),
    .tcd_if(tcd_if),
    .ddma_if(ddma_if)
  );

  dual_port_ram #(MEMORY_WIDTH, MEMORY_SIZE) memory_mod(
    .clock(clock), .reset(reset),
    .mem_if_a(mem_if_dma.MEM),
    .mem_if_b(mem_if_mmio.MEM)
  );

  ddma #(MEMORY_WIDTH, FLIT_WIDTH, INTERLEAVING_GRAIN, ADDRESS) ddma_mod(
    .clock(clock), .reset(reset), 
    .router_if(router_port_if.DDMA),
    .mem_if(mem_if_dma.DUT),
    .ddma_if(ddma_if.DDMA),
    .irq(cpu_irq)
  );

  router #(ADDRESS) router_mod (
    .clock(clock), .reset(reset),
    .router_if(router_if.ROUTER)
  );

  core_rv32e #(MEMORY_WIDTH) cpu_mod (
    .clock(clock), .reset(reset),
    .cpu_if(cpu_if.CPU)
  );

  // =========================================================
  //                    MEME / CPU / PERIPHERALS
  // =========================================================
  const int PERIPHERALS_ADDR_RANGE_START = 'he1000000;
  assign cpu_if.extio_in = { 'h0000000, 'b00, ddma_if.irq_out, perif_if.irq };
  assign cpu_if.stall_in = 0;
  
  assign perif_if.addr_in = cpu_if.addr_out;
  assign mem_if_mmio.addr_in = cpu_if.addr_out;

  assign cpu_if.data_in = (cpu_if.addr_out < PERIPHERALS_ADDR_RANGE_START) 
    ? mem_if_mmio.data_out 
    : perif_if.data_out;

  assign mem_if_mmio.data_in = cpu_if.data_out;
  assign perif_if.data_in = cpu_if.data_out;

  assign mem_if_mmio.wb_in = (cpu_if.addr_out < PERIPHERALS_ADDR_RANGE_START) 
    ? cpu_if.wb_out
    : 0;

  assign perif_if.wr_in = (cpu_if.addr_out < PERIPHERALS_ADDR_RANGE_START) 
    ? 0
    : cpu_if.wb_out;

  assign perif_if.sel_in = (cpu_if.addr_out[31:24] == 'he1);

  // =========================================================
  //                    ROUTER CONNECTION
  // =========================================================
  // connect router inout to the pe (only S, N, W, and E ports)
  assign pe_if.clock_tx[3:0] = router_if.clock_tx[3:0];
  assign pe_if.tx[3:0] = router_if.tx[3:0];
  assign pe_if.data_o[3:0] = router_if.data_o[3:0];
  assign pe_if.credit_o[3:0] = router_if.credit_o[3:0];

  assign router_if.clock_rx[3:0] = pe_if.clock_rx[3:0];
  assign router_if.rx[3:0] = pe_if.rx[3:0];
  assign router_if.data_i[3:0] = pe_if.data_i[3:0];
  assign router_if.credit_i[3:0] = pe_if.credit_i[3:0];

  // connect router local port to the ddma (only L port)
  assign router_port_if.clock_tx = router_if.clock_tx[4];
  assign router_port_if.tx = router_if.tx[4];
  assign router_port_if.data_o = router_if.data_o[4];
  assign router_port_if.credit_o = router_if.credit_o[4];

  assign router_if.clock_rx[4] = router_port_if.clock_rx;
  assign router_if.rx[4] = router_port_if.rx;
  assign router_if.data_i[4] = router_port_if.data_i;
  assign router_if.credit_i[4] = router_port_if.credit_i;


endmodule: manycore_pe

