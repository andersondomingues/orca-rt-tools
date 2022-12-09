module ddma_driver_tb13 #()(
  input logic clock,
  input logic reset,
  interface_router_port.ROUTER router_if,
  interface_memory.DUT mem_if,
  interface_ddma.TCD ddma_if
);


integer counter = 0;
always @(posedge clock) begin
  counter <= counter + 1;
end


initial begin

  router_if.clock_tx = clock;
  router_if.data_o = counter;
  #0;  // wait 0 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 136250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 232500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 328750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 425000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 521250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 617500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 713750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 810000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 906250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 1002500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 1098750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 1195000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 1291250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 1387500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 1483750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 1580000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 1676250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 1772500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 1868750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 1965000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 2061250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 2157500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 2253750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #8192;  // wait 4096 cycles

  // source_node:  13
  // target_node:  6
  // source_xy:    {'X': 1, 'Y': 3}
  // target_xy:    {'X': 2, 'Y': 1}
  // data_size:    8192
  // release_time: 2350000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (2 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 2048;  // 8192 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 8192;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
end

endmodule

