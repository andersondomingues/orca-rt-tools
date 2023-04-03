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
  integer TCD_CONFIG_ADDR = 32'hFF;

  logic[31:0] ddma_status;

  logic cpu_irq;
  logic[2:0] cpu_data_mode_out;
  logic[7:0] cpu_extio_in;
  logic[7:0] cpu_extio_out;


  interface_router #(FLIT_WIDTH) router_if(clock, reset); // router and pe
  interface_router_port #(FLIT_WIDTH) router_port_if(clock, reset); // router and ddma
  interface_ddma   #(MEMORY_WIDTH, FLIT_WIDTH, INTERLEAVING_GRAIN, ADDRESS) ddma_if(clock, reset); //tcd and ddma

  interface_memory #(MEMORY_WIDTH) mem_if_dma(clock, reset); // mem and ddma
  interface_memory #(MEMORY_WIDTH) mem_if_mmio(clock, reset); // mem and mmio

  interface_core_rv32e #(MEMORY_WIDTH) cpu_if(clock, reset); // cpu to mmio
  
  interface_tcd #(MEMORY_WIDTH) tcd_if(clock, reset);
  // modport TCD (
  //   input clock, reset, data_in, input_in, 
  //   output status_out);

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

  // mmio wiring
  assign mem_if_mmio.addr_in = (cpu_if.addr_out < TCD_CONFIG_ADDR) ? cpu_if.addr_out : 0;
  assign mem_if_mmio.wb_in = (cpu_if.addr_out < TCD_CONFIG_ADDR) ? cpu_if.wb_out : 0;
  assign mem_if_mmio.data_in = cpu_if.data_out;
  assign cpu_if.data_in = (cpu_if.addr_out < TCD_CONFIG_ADDR) ? mem_if_mmio.data_out : ddma_if.status_out; 

  // temporary bings for unused cpu wiring
  always_comb begin
    cpu_if.stall_in <= 0;
    cpu_data_mode_out <= cpu_if.data_mode_out;
    cpu_if.extio_in <= cpu_extio_in;
    cpu_extio_out <= cpu_if.extio_out;
  end

  // connect router inout to the pe (only SNWE ports)
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

  // connect router local port to the ddma
  always_comb begin
    router_port_if.clock_tx <= router_if.clock_tx[4];
    router_port_if.tx <= router_if.tx[4];
    router_port_if.data_o <= router_if.data_o[4];
    router_port_if.credit_o <= router_if.credit_o[4];

    router_if.clock_rx[4] <= router_port_if.clock_rx;
    router_if.rx[4] <= router_port_if.rx;
    router_if.data_i[4] <= router_port_if.data_i;
    router_if.credit_i[4] <= router_port_if.credit_i;
  end


endmodule: manycore_pe

