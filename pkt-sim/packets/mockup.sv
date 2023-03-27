`timescale 1ns/10ps

module ddma_driver_tb #(MEMORY_BUS_WIDTH, FLIT_WIDTH, ADDRESS)(
  input logic clock,
  input logic reset,
  interface_memory.DUT mem_if,
  interface_ddma.TCD ddma_if
);


integer counter = 0;
always @(posedge clock) begin
  counter <= counter + 1;
end


initial begin

  // delay to handle initialization offset
  mem_if.enable_in <= 1;
  ddma_if.addr_in <= 0;
  ddma_if.nbytes_in <= 0;
  ddma_if.cmd_in <= 0;
  // ============== PE NUM 0 ============== 
 if (ADDRESS == 0) begin

    // pkt name:     f2:0
    // source_node:  0
    // target_node:  3
    // source_xy:    {'X': 0, 'Y': 0}
    // target_xy:    {'X': 1, 'Y': 1}
    // data_size:    52
    // release_time: 0
    mem_if.wb_in <= 1;
    mem_if.data_in <=  (((0 << (FLIT_WIDTH / 4)) | 0) << FLIT_WIDTH / 2) | (((1 << (FLIT_WIDTH / 4)) | 1));
    mem_if.addr_in <= 'h0;
    #1;

    mem_if.wb_in <= 1;
    mem_if.data_in <= 14;  // 52 bytes, size flit
    mem_if.addr_in <= 'h0 + 'h1;
    #1;

    mem_if.wb_in <= 0;  // lock memory write


    #98; // skipt to 0
    ddma_if.addr_in <= 'h0;
    ddma_if.nbytes_in <= 16;
    ddma_if.cmd_in <= 1;
    #1;

    ddma_if.addr_in <= 0;
    ddma_if.nbytes_in <= 0;
    ddma_if.cmd_in <= 0; 
    #10; 
    // pkt name:     f1:0
    // source_node:  0
    // target_node:  1
    // source_xy:    {'X': 0, 'Y': 0}
    // target_xy:    {'X': 1, 'Y': 0}
    // data_size:    20
    // release_time: 36
    mem_if.wb_in <= 1;
    mem_if.data_in <=  (((0 << (FLIT_WIDTH / 4)) | 0) << FLIT_WIDTH / 2) | (((1 << (FLIT_WIDTH / 4)) | 0));
    mem_if.addr_in <= 'h0;
    #1;

    mem_if.wb_in <= 1;
    mem_if.data_in <= 6;  // 20 bytes, size flit
    mem_if.addr_in <= 'h0 + 'h1;
    #1;

    mem_if.wb_in <= 0;  // lock memory write


    #23; // skipt to 36
    ddma_if.addr_in <= 'h0;
    ddma_if.nbytes_in <= 8;
    ddma_if.cmd_in <= 1;
    #1;

    ddma_if.addr_in <= 0;
    ddma_if.nbytes_in <= 0;
    ddma_if.cmd_in <= 0; 
    #10; 

 end else 

  // ============== PE NUM 1 ============== 
 if (ADDRESS == 256) begin

    // pkt name:     f5:0
    // source_node:  1
    // target_node:  2
    // source_xy:    {'X': 1, 'Y': 0}
    // target_xy:    {'X': 0, 'Y': 1}
    // data_size:    16
    // release_time: 0
    mem_if.wb_in <= 1;
    mem_if.data_in <=  (((1 << (FLIT_WIDTH / 4)) | 0) << FLIT_WIDTH / 2) | (((0 << (FLIT_WIDTH / 4)) | 1));
    mem_if.addr_in <= 'h0;
    #1;

    mem_if.wb_in <= 1;
    mem_if.data_in <= 5;  // 16 bytes, size flit
    mem_if.addr_in <= 'h0 + 'h1;
    #1;

    mem_if.wb_in <= 0;  // lock memory write


    #98; // skipt to 0
    ddma_if.addr_in <= 'h0;
    ddma_if.nbytes_in <= 7;
    ddma_if.cmd_in <= 1;
    #1;

    ddma_if.addr_in <= 0;
    ddma_if.nbytes_in <= 0;
    ddma_if.cmd_in <= 0; 
    #10; 

 end else 

  // ============== PE NUM 2 ============== 
 if (ADDRESS == 1) begin

    // pkt name:     f4:0
    // source_node:  2
    // target_node:  1
    // source_xy:    {'X': 0, 'Y': 1}
    // target_xy:    {'X': 1, 'Y': 0}
    // data_size:    32
    // release_time: 0
    mem_if.wb_in <= 1;
    mem_if.data_in <=  (((0 << (FLIT_WIDTH / 4)) | 1) << FLIT_WIDTH / 2) | (((1 << (FLIT_WIDTH / 4)) | 0));
    mem_if.addr_in <= 'h0;
    #1;

    mem_if.wb_in <= 1;
    mem_if.data_in <= 9;  // 32 bytes, size flit
    mem_if.addr_in <= 'h0 + 'h1;
    #1;

    mem_if.wb_in <= 0;  // lock memory write


    #98; // skipt to 0
    ddma_if.addr_in <= 'h0;
    ddma_if.nbytes_in <= 11;
    ddma_if.cmd_in <= 1;
    #1;

    ddma_if.addr_in <= 0;
    ddma_if.nbytes_in <= 0;
    ddma_if.cmd_in <= 0; 
    #10; 
    // pkt name:     f3:0
    // source_node:  2
    // target_node:  3
    // source_xy:    {'X': 0, 'Y': 1}
    // target_xy:    {'X': 1, 'Y': 1}
    // data_size:    24
    // release_time: 36
    mem_if.wb_in <= 1;
    mem_if.data_in <=  (((0 << (FLIT_WIDTH / 4)) | 1) << FLIT_WIDTH / 2) | (((1 << (FLIT_WIDTH / 4)) | 1));
    mem_if.addr_in <= 'h0;
    #1;

    mem_if.wb_in <= 1;
    mem_if.data_in <= 7;  // 24 bytes, size flit
    mem_if.addr_in <= 'h0 + 'h1;
    #1;

    mem_if.wb_in <= 0;  // lock memory write


    #23; // skipt to 36
    ddma_if.addr_in <= 'h0;
    ddma_if.nbytes_in <= 9;
    ddma_if.cmd_in <= 1;
    #1;

    ddma_if.addr_in <= 0;
    ddma_if.nbytes_in <= 0;
    ddma_if.cmd_in <= 0; 
    #10; 

 end else 

  begin
    mem_if.wb_in = 0;
    mem_if.data_in = 0;
    mem_if.addr_in = 0;
    mem_if.wb_in = 0;
    ddma_if.addr_in = 0;
    ddma_if.nbytes_in = 0;
    ddma_if.cmd_in = 0;
  end


end

endmodule

