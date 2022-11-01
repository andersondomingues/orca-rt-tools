module dual_port_ram #(parameter MEMORY_BUS_WIDTH, SIZE)(
  input logic clock,
  input logic reset,
  interface_memory.MEM mem_if_a,
  interface_memory.MEM mem_if_b
);

reg[SIZE][MEMORY_BUS_WIDTH-1:0] mem;

initial begin
  for(integer j = 0; j < SIZE; j = j+1) begin
    // mem[j] = {MEMORY_BUS_WIDTH{1'b1}};
    mem[j] = j;
  end 
end 

always @(posedge clock) begin
  if (mem_if_a.enable_in && mem_if_a.wb_in) begin
    mem[mem_if_a.addr_in] <= mem_if_a.data_in;
  end
  if (mem_if_b.enable_in && mem_if_b.wb_in) begin
    mem[mem_if_b.addr_in] <= mem_if_b.data_in;
  end
end

always @(posedge clock) begin
  mem_if_a.data_out <= mem[mem_if_a.addr_in];
  mem_if_b.data_out <= mem[mem_if_b.addr_in];
end


endmodule