module single_port_ram #(parameter MEMORY_BUS_WIDTH, SIZE, ADDRESS)(
  input logic clock,
  input logic reset,
  interface_memory.MEM mem_if
);

reg[7:0] mem[SIZE];

initial begin

  automatic string filename = { "../software/ucx-os/img/boot.txt" };

  automatic reg[31:0] mem_aux[SIZE/4];
  automatic integer i;
  automatic integer j;

  j = 0;
  for(; j < SIZE / 4; j = j+1) begin
    mem_aux[j] = 'h0000;
  end 

  $display("boot: %s", filename);
  $readmemh(filename, mem_aux);

  // copy read contents into the 8-bit addressed memory
  j = 0;
  i = 0;
  while (i < SIZE) begin
    mem[i] = mem_aux[j][31:24];
    mem[i + 1] = mem_aux[j][23:16];
    mem[i + 2] = mem_aux[j][15:8];
    mem[i + 3] = mem_aux[j][7:0];
    i = i + 4;
    j = j + 1;
  end

end 

always @(posedge clock) begin
  if (mem_if.enable_in) begin
    if(mem_if.wb_in[3]) begin
      mem[mem_if.addr_in] <= mem_if.data_in[31:24];
    end
    if(mem_if.wb_in[2]) begin
      mem[mem_if.addr_in + 1] <= mem_if.data_in[23:16];
    end
    if(mem_if.wb_in[1]) begin
      mem[mem_if.addr_in + 2] <= mem_if.data_in[15:8];
    end
    if(mem_if.wb_in[0]) begin
      mem[mem_if.addr_in + 3] <= mem_if.data_in[7:0];
    end
  end
end


always_comb begin
  mem_if.data_out <= {
    mem[mem_if.addr_in + 3],
    mem[mem_if.addr_in + 2],
    mem[mem_if.addr_in + 1],
    mem[mem_if.addr_in]
  };
end


endmodule