module ddma_driver_tb12 #()(
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

  // source_node:  12
  // target_node:  7
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 3, 'Y': 1}
  // data_size:    8192
  // release_time: 40000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (3 << 16) & 1;  // header flit
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

  // source_node:  12
  // target_node:  4
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 0, 'Y': 1}
  // data_size:    4096
  // release_time: 44000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (0 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 1024;  // 4096 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 4096;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #4096;  // wait 2048 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 96250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 192500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  4
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 0, 'Y': 1}
  // data_size:    4096
  // release_time: 240625
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (0 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 1024;  // 4096 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 4096;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #4096;  // wait 2048 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 288750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 385000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 481250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  4
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 0, 'Y': 1}
  // data_size:    4096
  // release_time: 521250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (0 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 1024;  // 4096 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 4096;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #4096;  // wait 2048 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 577500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 673750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  4
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 0, 'Y': 1}
  // data_size:    4096
  // release_time: 721875
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (0 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 1024;  // 4096 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 4096;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #4096;  // wait 2048 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 770000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 866250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 962500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  4
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 0, 'Y': 1}
  // data_size:    4096
  // release_time: 1002500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (0 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 1024;  // 4096 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 4096;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #4096;  // wait 2048 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 1058750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 1155000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  7
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 3, 'Y': 1}
  // data_size:    8192
  // release_time: 1203125
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (3 << 16) & 1;  // header flit
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

  // source_node:  12
  // target_node:  4
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 0, 'Y': 1}
  // data_size:    4096
  // release_time: 1207125
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (0 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 1024;  // 4096 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 4096;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #4096;  // wait 2048 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 1251250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 1347500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 1443750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  4
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 0, 'Y': 1}
  // data_size:    4096
  // release_time: 1483750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (0 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 1024;  // 4096 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 4096;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #4096;  // wait 2048 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 1540000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 1636250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  4
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 0, 'Y': 1}
  // data_size:    4096
  // release_time: 1684375
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (0 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 1024;  // 4096 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 4096;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #4096;  // wait 2048 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 1732500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 1828750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 1925000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  4
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 0, 'Y': 1}
  // data_size:    4096
  // release_time: 1965000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (0 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 1024;  // 4096 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 4096;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #4096;  // wait 2048 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 2021250
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 2117500
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  4
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 0, 'Y': 1}
  // data_size:    4096
  // release_time: 2165625
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (0 << 16) & 1;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 1024;  // 4096 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 4096;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #4096;  // wait 2048 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 2213750
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
  #153600;  // wait 76800 cycles

  // source_node:  12
  // target_node:  13
  // source_xy:    {'X': 0, 'Y': 3}
  // target_xy:    {'X': 1, 'Y': 3}
  // data_size:    153600
  // release_time: 2310000
  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = (1 << 16) & 3;  // header flit
  mem_if.addr_in = 'h0;

  #2;
  mem_if.enable_in = 1;
  mem_if.wb_in = 1;
  mem_if.data_in = 38400;  // 153600 bytes, size flit
  mem_if.addr_in = 'h0 + 'h4;

  #2;
  ddma_if.addr_in = 'h0;
  ddma_if.nbytes = 153600;
  ddma_if.cmd_in = 1;

  mem_if.wb_in = 0;  // lock memory write


  #2;
end

endmodule

