module manycore_pe #(parameter
  MEMORY_WIDTH, 
  FLIT_WIDTH,
  RAM_MSIZE,
  BOOT_MSIZE,
  ADDRESS = 0,
  INTERLEAVING_GRAIN
)(
  input logic clock,
  input logic reset,
  interface_pe.PE pe_if
);

  // =========================================================
  //                    LIMITS
  // =========================================================
  const int BOOT_START = 'h00000000;
  const int RAM_START  = 'h40000000;
  const int PERIPH_START = 'he1000000;

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

  interface_memory #(MEMORY_WIDTH) mem_if_boot(clock, reset); // boot rom

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

  dual_port_ram #(MEMORY_WIDTH, RAM_MSIZE, ADDRESS) memory_mod(
    .clock(clock), .reset(reset),
    .mem_if_a(mem_if_dma.MEM),
    .mem_if_b(mem_if_mmio.MEM)
  );

  single_port_ram #(MEMORY_WIDTH, BOOT_MSIZE, ADDRESS) boot_mod(
    .clock(clock), .reset(reset),
    .mem_if(mem_if_boot.MEM)
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
  //                    PRINTF 
  // =========================================================
  always @(posedge clock) begin
    if (cpu_if.addr_out == 'he1030400) begin
      $display("%c %c %c %c", 
        cpu_if.data_out[31:24],
        cpu_if.data_out[23:16],
        cpu_if.data_out[15:8],
        cpu_if.data_out[7:0]
      );
    end
  end 

  // =========================================================
  //                    MEME / CPU / PERIPHERALS
  // =========================================================

  // assign cpu_if.extio.in = { 'b000000, ddma_if.irq_out, perif_if.irq};
  assign cpu_if.extio_in[7:2] = 'b000000;
  assign cpu_if.extio_in[1] = ddma_if.irq_out;
  assign cpu_if.extio_in[0] = perif_if.irq;
  
  assign cpu_if.stall_in = 0;
  
  assign perif_if.addr_in = cpu_if.addr_out;

  always_comb begin
    if (cpu_if.addr_out < RAM_START) begin
      cpu_if.data_in = { << 8 {mem_if_boot.data_out}};
    end else if (cpu_if.addr_out < PERIPH_START) begin 
      cpu_if.data_in = { << 8 {mem_if_mmio.data_out}};
    end else begin
      cpu_if.data_in = { << 8 {perif_if.data_out}};
    end
    // if (cpu_if.addr_out == PERIPHERALS_ADDR_RANGE_START) begin 
    //   cpu_if.data_in = { << 8 {ADDRESS}};
  end 

  // ! disable rom after boot up?
  assign mem_if_boot.enable_in = 1; 
  assign mem_if_boot.wb_in = 0;
  assign mem_if_boot.data_in = 0;
  assign mem_if_boot.addr_in = (cpu_if.addr_out > BOOT_START && cpu_if.addr_out < BOOT_START + BOOT_MSIZE)
    ? cpu_if.addr_out
    : 0;

  assign mem_if_mmio.addr_in = cpu_if.addr_out & 'h00001111;
  assign mem_if_mmio.data_in = { << 8 {cpu_if.data_out}};
  assign mem_if_mmio.wb_in = (cpu_if.addr_out < PERIPH_START) 
    ? cpu_if.wb_out
    : 0;

  assign perif_if.data_in =  { << 8 {cpu_if.data_out}};
  assign perif_if.wr_in = (cpu_if.addr_out < PERIPH_START) 
    ? 0
    : cpu_if.wb_out;

  assign perif_if.sel_in = (cpu_if.addr_out[31:24] == 'he1);
  assign perif_if.gpioa_in = 0;

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

