module dual_port_ram #(parameter MEMORY_BUS_WIDTH = 32, SIZE = 65536, ADDRESS = 0)(
  input logic clock,
  input logic reset,
  input logic enable,
  interface_memory.MEM mem_if_a,
  interface_memory.MEM mem_if_b
);

// Please find below some information on the simulation
// of memories using bit and reg datatypes. 
// - bit: only zeroes and ones; your memory will be initialized
//        with zeroes in all positions at the startup. However,
//        modelsim will not infer memory cores from your code. It
//        would also be difficult to debug Xs and Zs (as they both
//        will be replaced by zeroes).
// - reg: quad-state values (0, 1, X and Z). memory cores will
//        be inferred, which makes the simulation fast. However,
//        your memory will be filled with Xs at the startup, and 
//        you may find some problems when reading/writing half-words,
//        e.g. Xs being pushed into the ALU.
reg[31:0] mem[SIZE];

// -- --
initial begin
  automatic string filename = { "../software/ucx-os/build/target/code.txt" };
  $display("ram_img: %s (%0d bytes)", filename, SIZE * 4);
  $readmemh(filename, mem);
end


// function void dump(integer addr);
//   for(int i = addr; i < addr + 16; i++) begin
//     $display("0x%h       %h", i, mem[i]);
//   end 
// endfunction

//  function void dump(integer addr);
//    for(int i = 0; i < SIZE; i++) begin
//      $display("%h ", mem[i]);
//    end 
//  endfunction

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

    // if(mem_if_b.addr_in == ('h3044 >> 2) && !(mem_if_b.wb_in)) begin
    //   dump(mem_if_b.addr_in);
    // end

  end
end


endmodule