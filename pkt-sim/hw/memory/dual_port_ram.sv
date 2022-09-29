module dual_port_ram #(parameter MEMORY_BUS_WIDTH, SIZE)(
  input logic clock,
  input logic reset,
  interface_memory.MEM mem_if_a,
  interface_memory.MEM mem_if_b
);

logic mem [SIZE * MEMORY_BUS_WIDTH-3:0];

always @ (posedge clock) begin
  if (mem_if_a.enable_in) begin
    if(mem_if_a.wb_in) begin
      mem[mem_if_a.addr_in] <= mem_if_a.data_in;
    end
  end
end

always @ (posedge clock) begin
  if (mem_if_b.enable_in) begin
    if(mem_if_b.wb_in) begin
      mem[mem_if_b.addr_in] <= mem_if_b.data_in;
    end
  end
end

assign mem_if_a.data_out = mem[mem_if_a.addr_in];
assign mem_if_b.data_out = mem[mem_if_b.addr_in];


endmodule