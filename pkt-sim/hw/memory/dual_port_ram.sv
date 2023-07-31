module dual_port_ram #(parameter MEMORY_BUS_WIDTH = 32, SIZE = 65536, ADDRESS = 0)(
  input logic clock,
  input logic reset,
  input logic enable,
  interface_memory.MEM mem_if_a,
  interface_memory.MEM mem_if_b
);

bit[31:0] mem[SIZE];

// -- --
initial begin
  automatic string filename = { "../software/ucx-os/build/target/code.txt" };
  $display("ram_img: %s (%0d B)", filename, SIZE);
  $readmemh(filename, mem);
end

always @(posedge clock) begin
  if($past(mem_if_b.addr_in) == 'h2fa4) begin
    $display("read addr %h -> %h", $past(mem_if_b.addr_in), mem_if_b.data_out);
  end
end 

always @(posedge clock) begin
  if (enable) begin

    // PORT A
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

    if(mem_if_b.wb_in[3]) begin
      mem[mem_if_b.addr_in][31:24] <= mem_if_b.data_in[31:24];
    end
    if(mem_if_b.wb_in[2]) begin
      mem[mem_if_b.addr_in][23:16] <= mem_if_b.data_in[23:16];
    end
    if(mem_if_b.wb_in[1]) begin
      mem[mem_if_b.addr_in][15:8] <= mem_if_b.data_in[15:8];
    end
    if(mem_if_b.wb_in[0]) begin
      mem[mem_if_b.addr_in][7:0] <= mem_if_b.data_in[7:0];
    end

    mem_if_a.data_out <= mem[mem_if_a.addr_in];
    mem_if_b.data_out <= mem[mem_if_b.addr_in];
  end
end


endmodule