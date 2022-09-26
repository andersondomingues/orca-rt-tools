// reference: https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/RAM-Inference-True-Dual-Port-Structure-SystemVerilog

module dual_port_ram #(parameter MEMORY_BUS_WIDTH)(
  input logic clock,
  input logic write_a_in,
  input logic write_b_in,
  input logic enable_a_in,
  input logic enable_b_in,
  input [MEMORY_BUS_WIDTH-3:0] address_a_in, //aligned to 8 bits
  input [MEMORY_BUS_WIDTH-3:0] address_b_in,
  input [MEMORY_BUS_WIDTH-1:0] data_a_in,
  input [MEMORY_BUS_WIDTH-1:0] data_b_in,
  input [MEMORY_BUS_WIDTH-1:0] data_a_out,
  input [MEMORY_BUS_WIDTH-1:0] data_b_out,
);

logic mem [2**MEMORY_BUS_WIDTH-3:0];

always @ (posedge clock) begin
  if (enable_a_in) begin
    data_a_out <= mem[address_a_in];
    if(write_a_in) begin
      mem[address_a_in] <= data_a_in;
    end
  end
end

always @ (posedge clock) begin
  if (enable_b_in) begin
    data_b_out <= mem[address_b_in];
    if(write_b_in) begin
      mem[address_b_in] <= data_b_in;
    end
  end
end

 

endmodule