module router #(parameter ADDRESS = 0) (
  input logic clock,
  input logic reset,
  interface_router.ROUTER router_if
);
  // bind routercc (vhdl) to router_if
  routercc #(ADDRESS) router_mod(
    .clock(clock), 
    .reset(reset),

    .clock_rx(router_if.clock_rx),
    .rx(router_if.rx),
    .data_in(router_if.data_i),
    .credit_o(router_if.credit_o),

    .clock_tx(router_if.clock_tx),
    .tx(router_if.tx),
    .data_out((router_if.data_o)),
    .credit_i(router_if.credit_i)
  );

  initial begin
    $display("ADDRESS: ", ADDRESS);
  end

endmodule: router
