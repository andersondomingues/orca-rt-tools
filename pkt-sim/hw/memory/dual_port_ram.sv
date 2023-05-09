module dual_port_ram #(parameter MEMORY_BUS_WIDTH, SIZE, ADDRESS)(
  input logic clock,
  input logic reset,
  interface_memory.MEM mem_if_a,
  interface_memory.MEM mem_if_b
);

function string get_image_name(int addr); 
  automatic int x = addr & 'h000F;
  automatic int y = (addr >> 8 ) & 'h000F;

  automatic string sx;
  automatic string sy;

  sx.itoa(x);
  sy.itoa(y);
  get_image_name = { "../software/ucx-os/img/build-", sx, "-", sy, "/code.txt" };
endfunction 



reg[MEMORY_BUS_WIDTH-1:0] mem[SIZE];

initial begin

  automatic string filename = get_image_name(ADDRESS); 

  for(integer j = 0; j < SIZE; j = j+1) begin
    // mem[j] = {MEMORY_BUS_WIDTH{1'b1}};
    // mem[j] = j-1;
    mem[j] = 'h0000;
  end 

  $display("filename: %s", filename);
  $readmemh(filename, mem);

end 

always @(posedge clock) begin
  if (mem_if_a.enable_in && mem_if_a.wb_in) begin
    mem[mem_if_a.addr_in % SIZE] <= mem_if_a.data_in;
  end
  if (mem_if_b.enable_in && mem_if_b.wb_in) begin
    mem[mem_if_b.addr_in % SIZE] <= mem_if_b.data_in;
  end
end

always_comb begin
  mem_if_a.data_out <= mem[mem_if_a.addr_in % SIZE];
  mem_if_b.data_out <= mem[mem_if_b.addr_in % SIZE];
end


endmodule