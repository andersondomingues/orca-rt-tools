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
  //const int BOOT_END = BOOT_START + BOOT_MSIZE -1;
  const int BOOT_END = 'h1fffffff;
  const int RAM_START  = 'h40000000;
  // const int RAM_END = RAM_START + RAM_MSIZE -1;
  const int RAM_END = 'h5fffffff;
  const int PERIPH_START = 'he1000000;
  const int PERIPH_END = 'he1ffffff;
  // const int PERIPH_END = 'hffffffff;

  const int PRINTCHAR_ADDR = 'hF00000D0;

  initial begin
    if (ADDRESS == 0) begin
      $display("BOOT_START %h", BOOT_START);
      $display("BOOT_MSIZE %h", BOOT_MSIZE);
      $display("BOOT_END %h", BOOT_END);
      $display("RAM_START %h", RAM_START);
      $display("RAM_END %h", RAM_END);
      $display("RAM_MSIZE %h", RAM_MSIZE);
      $display("RAM_START %h", RAM_START);
      $display("PERIPH_START %h", PERIPH_START);
      $display("PERIPH_END %h", PERIPH_END);
      $display("PRINTCHAR_ADDR %h", PRINTCHAR_ADDR);
    end 
  end 

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
  //                    MEME / CPU / PERIPHERALS
  // =========================================================

  assign cpu_if.extio_in[7:2] = 'b000000;
  assign cpu_if.extio_in[1] = ddma_if.irq_out[0];
  assign cpu_if.extio_in[0] = perif_if.irq;
  assign cpu_if.stall_in = 0;

  // memory output delay 
  logic[MEMORY_WIDTH-1:0] dly_address;
  always @(posedge clock) begin
    dly_address <= cpu_if.addr_out;
  end

  // printchar output
  always @(posedge clock) begin 
    if (dly_address == PRINTCHAR_ADDR) begin 
      $display("[%0d ns] printchar %c", ($time/1000), cpu_if.data_out[31:24]);
    end
  end 

  // registered memory access 
  always_comb begin
    if (dly_address >= BOOT_START && dly_address <= BOOT_END) begin
      cpu_if.data_in = { << 8 {mem_if_boot.data_out}};

    end else if (dly_address >= RAM_START && dly_address <= RAM_END) begin
      cpu_if.data_in = { << 8 {mem_if_mmio.data_out}};
    
    end else if (dly_address >= PERIPH_START && dly_address <= PERIPH_END) begin 
      cpu_if.data_in = { << 8 {perif_if.data_out}};
    
    // avoid XXXX at the begining of the simulation
    end else if($time != 0 && dly_address != PRINTCHAR_ADDR) begin
      $display("[%0d ns] Illegal access to region %h", ($time/1000), dly_address); 
    end 
  end 

  // BOOT memory mux
  always_comb begin
    mem_if_boot.enable_in = 1; 
    mem_if_boot.data_in = 0; // boot is ready only
    mem_if_boot.wb_in = 0;   // boot is ready only

    if (cpu_if.addr_out >= BOOT_START && cpu_if.addr_out <= BOOT_END) begin
      mem_if_boot.addr_in = cpu_if.addr_out & 'h000007FF;
    end else begin 
      mem_if_boot.addr_in = 0;
    end
  end

  // RAM memory mux
  always_comb begin
    mem_if_mmio.enable_in = 1; 
    mem_if_mmio.data_in = { << 8 {cpu_if.data_out}};

    if (cpu_if.addr_out >= RAM_START && cpu_if.addr_out <= RAM_END) begin
      mem_if_mmio.addr_in = (cpu_if.addr_out & 'h0000FFFF);  // addresses to 64k RAM  
      mem_if_mmio.wb_in = cpu_if.wb_out;
    end else begin
      mem_if_mmio.addr_in = 0;
      mem_if_mmio.wb_in = 0;
    end 
  end
  
  // PERIPH mux
  always_comb begin
    perif_if.data_in =  { << 8 {cpu_if.data_out}};
    perif_if.sel_in = (cpu_if.addr_out[31:24] == 'he1);
    perif_if.gpioa_in = 0;

    if (cpu_if.addr_out >= PERIPH_START && cpu_if.addr_out <= PERIPH_END) begin
      perif_if.wr_in = cpu_if.wb_out;
      perif_if.addr_in = cpu_if.addr_out;
    end else begin 
      perif_if.wr_in = 0;
      perif_if.addr_in = 0;
    end 
  end 

  always @(posedge clock) begin 
    if (cpu_if.extio_in != $past(cpu_if.extio_in)) begin
      $display("[%0d ns] Irq %8h", ($time/1000), cpu_if.extio_in); 
    end 
  end

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

