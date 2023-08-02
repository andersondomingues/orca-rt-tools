module single_port_ram #(parameter 
  MEMORY_BUS_WIDTH = 32, 
  SIZE = 2048, 
  ADDRESS = 0
)(
  input logic clock,
  input logic reset,
  input logic enable,
  interface_memory.MEM mem_if_a
);

reg[31:0] mem[SIZE];

// -- --
initial begin
  automatic string filename = { "../software/hfrisc-software/boot.txt" };
  $display("boot_img: %s (%0d bytes)", filename, SIZE * 4);
  $readmemh(filename, mem);
end

always @(posedge clock) begin
  if (enable) begin

    if(mem_if_a.wb_in[3]) begin
      mem[mem_if_a.addr_in][31:24] <= mem_if_a.data_in[31:24];
    end
    if(mem_if_a.wb_in[2]) begin
      mem[mem_if_a.addr_in][23:16] <= mem_if_a.data_in[23:16];
    end
    if(mem_if_a.wb_in[1]) begin
      mem[mem_if_a.addr_in][15:8] <= mem_if_a.data_in[15:8];
    end
    if(mem_if_a.wb_in[0]) begin
      mem[mem_if_a.addr_in][7:0] <= mem_if_a.data_in[7:0];
    end

    mem_if_a.data_out <= mem[mem_if_a.addr_in];
  end
end


endmodule