module manycore_pe #(parameter
  MEMORY_WIDTH = 32, 
  FLIT_WIDTH = 32,
  RAM_MSIZE = 65536,
  BOOT_MSIZE = 2048,
  ADDRESS = 0,
  INTERLEAVING_GRAIN = 3,
  NOC_DIM_X = 0,
  NOC_DIM_Y = 0
)(
  input logic clock,
  input logic reset,
  interface_pe.PE pe_if
);

  // =========================================================
  //                    memory "map"
  // =========================================================
  const int BOOT_START        = 'h00000000;
  const int BOOT_END          = 'h1fffffff;
  const int RAM_START         = 'h40000000;
  const int RAM_END           = 'h5fffffff;
  const int PERIPH_START      = 'he1000000;
  const int PERIPH_END        = 'hefffffff;
  const int PRINTCHAR_ADDR    = 'hf00000d0;
  const int INTERNAL_START    = 'hf0000000;
  const int INTERNAL_END      = 'hffffffff;
  const int DDMA_CONFIG_START = 'h20000000;
  const int DDMA_CONFIG_END   = 'h20000014;


  function string log_filename();
    automatic string sx;
    automatic string sy;
    automatic int x;
    automatic int y;

    x = ADDRESS & 'h000F;
    y = (ADDRESS >> 8 ) & 'h000F; 

    sx.itoa(x);
    sy.itoa(y);

    log_filename = {"../logs/output-", sx, "-", sy, ".txt"};
  endfunction

  int print_file = $fopen(log_filename());

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
  peripherals #(MEMORY_WIDTH) perif_mod(
    .pheripherals_if(perif_if.PERIPHERALS)
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
    .ddma_if(ddma_if.DDMA)
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
  //                    MEM / CPU / PERIPHERALS
  // =========================================================

  // IRQ_IN is 00000RSP
  // R: ddma receive process irq
  // S: ddma send process ack irq
  // P: peripherals interruptions
  assign cpu_if.extio_in = { 5'b0,
    ddma_if.irq_recv_out, ddma_if.irq_send_out, perif_if.irq };

  assign cpu_if.stall_in = 0;

  // memory output delay 
  logic[MEMORY_WIDTH-1:0] dly_address;
  always @(posedge clock) begin
    dly_address <= cpu_if.addr_out;
  end

  // print interruptions 
  always @(posedge clock) begin 
    if (cpu_if.extio_in != $past(cpu_if.extio_in)) begin
      $display("[%0d ns] Irq %b", ($time/1000), cpu_if.extio_in); 
    end 
  end

  // printchar output
  always @(posedge clock) begin 
    if (dly_address == PRINTCHAR_ADDR && print_file != 0) begin
      $fwrite(print_file, "%c", cpu_if.data_out[31:24]);
    end
  end

  // registered memory access to cpu.data_in
  always_comb begin
    // boot mem
    if (dly_address >= BOOT_START && dly_address <= BOOT_END) begin
      cpu_if.data_in = mem_if_boot.data_out;

    // ram mem
    end else if (dly_address >= RAM_START && dly_address <= RAM_END) begin
      cpu_if.data_in = mem_if_mmio.data_out;
    
    // peripherals
    end else if (dly_address >= PERIPH_START && dly_address <= PERIPH_END) begin 
      cpu_if.data_in = { 
        perif_if.data_out[7:0],
        perif_if.data_out[15:8],
        perif_if.data_out[23:16],
        perif_if.data_out[31:24]
      };

    // internals (e.g., interruption controller)
    end else if (dly_address >= INTERNAL_START && dly_address <= INTERNAL_END) begin
      cpu_if.data_in = 0; 

    // ddma config zone
    end else if (dly_address >= DDMA_CONFIG_START && dly_address <= DDMA_CONFIG_END) begin

      if ((dly_address & ~3) == 'h20000000) begin
        cpu_if.data_in = { 
          ADDRESS[7:0],
          ADDRESS[15:8],
          ADDRESS[23:16],
          ADDRESS[31:24]
        };

      end else if((dly_address & ~3) == 'h20000004) begin
        cpu_if.data_in = {
          ddma_if.dest_in[7:0],
          ddma_if.dest_in[15:8],
          ddma_if.dest_in[23:16],
          ddma_if.dest_in[31:24]
        };

      end else if((dly_address & ~3) == 'h20000008) begin
        cpu_if.data_in = {
          ddma_if.addr_in[7:0],
          ddma_if.addr_in[15:8],
          ddma_if.addr_in[23:16],
          ddma_if.addr_in[31:24]
        };

      end else if((dly_address & ~3) == 'h2000000C) begin
        cpu_if.data_in = {
          ddma_if.size_in[7:0],
          ddma_if.size_in[15:8],
          ddma_if.size_in[23:16],
          ddma_if.size_in[31:24]
        };

      end else if((dly_address & ~3) == 'h20000010) begin
        cpu_if.data_in = ddma_if.cmd_in;

      end else if((dly_address & ~3) == 'h20000014) begin

        cpu_if.data_in = { 
          // 1 bit each
          ddma_if.irq_send_out, ddma_if.irq_recv_out,
          // 3 bits each
          ddma_if.state_send_out, ddma_if.state_recv_out,
          24'h000000 
        };

      end else begin
        $display("[%0d ns] illegal read to ddma %h %h.", ($time/1000), dly_address,
          dly_address & ~3);

      end 

    // unknown addressess
    end else if ($time() != 0 && dly_address != PRINTCHAR_ADDR) begin
      $display("[%0d ns] illegal read to region %h.", ($time/1000), dly_address);
      cpu_if.data_in = 0;
    end 
  end 

  // BOOT memory mux
  always_comb begin
    mem_if_boot.enable_in = 1; 
    mem_if_boot.data_in = 0; // boot is ready only
    mem_if_boot.wb_in = 0;   // boot is ready only

    if (cpu_if.addr_out >= BOOT_START && cpu_if.addr_out <= BOOT_END) begin
      mem_if_boot.addr_in = (cpu_if.addr_out & (BOOT_MSIZE -1)) & ~3; // 4-byte alignment
    end else begin 
      mem_if_boot.addr_in = 0;
    end
  end

  // DDMA memory mux
  always_comb begin
    if (cpu_if.addr_out == 'h20000004) begin
      ddma_if.dest_in = {
        cpu_if.data_out[7:0],
        cpu_if.data_out[15:8],
        cpu_if.data_out[23:16],
        cpu_if.data_out[31:24]
      };
    end else if (cpu_if.addr_out == 'h20000008) begin
      ddma_if.addr_in = {
        cpu_if.data_out[7:0],
        cpu_if.data_out[15:8],
        cpu_if.data_out[23:16],
        cpu_if.data_out[31:24]
      };
    end else if (cpu_if.addr_out == 'h2000000C) begin
      ddma_if.size_in = {
        cpu_if.data_out[7:0],
        cpu_if.data_out[15:8],
        cpu_if.data_out[23:16],
        cpu_if.data_out[31:24]
      };
    end else if (cpu_if.addr_out == 'h20000010) begin
      ddma_if.cmd_in = {
        cpu_if.data_out[7:0],
        cpu_if.data_out[15:8],
        cpu_if.data_out[23:16],
        cpu_if.data_out[31:24]
      } > 0;
    end
  end 

  // RAM memory mux
  always_comb begin
    mem_if_mmio.enable_in = 1; 
    mem_if_mmio.data_in = cpu_if.data_out;
    
    if (cpu_if.addr_out >= RAM_START && cpu_if.addr_out <= RAM_END) begin
      mem_if_mmio.addr_in = (cpu_if.addr_out & (RAM_MSIZE - 1) & ~3); // 4-byte alignment
      mem_if_mmio.wb_in = cpu_if.wb_out;
    end else begin
      mem_if_mmio.addr_in = 0;
      mem_if_mmio.wb_in = 0;
    end 
  end
  
  // PERIPH mux
  always_comb begin
    perif_if.gpioa_in = 0;
    perif_if.data_in = { 
      cpu_if.data_out[7:0],
      cpu_if.data_out[15:8],
      cpu_if.data_out[23:16],
      cpu_if.data_out[31:24]
    };

    if (cpu_if.addr_out >= PERIPH_START && cpu_if.addr_out <= PERIPH_END) begin
      perif_if.sel_in = 1;
      perif_if.addr_in = cpu_if.addr_out & ~3; // 4-byte alignment
      perif_if.wr_in = cpu_if.wb_out;
    end else begin 
      perif_if.sel_in = 0;
      perif_if.addr_in = 0;
      perif_if.wr_in = 0;      
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
