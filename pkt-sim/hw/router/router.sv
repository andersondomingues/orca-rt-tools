typedef logic[4:0] packed5_t;

module router #(parameter FLIT_WIDTH, ADDRESS) (
  interface_router.ROUTER router_if
);

  // router cc instance (bind to wrappers)
  routercc #(ADDRESS) router_mod(
    .clock(router_if.clock),
    .reset(router_if.reset),

    .clock_tx(router_if.clock_tx),
    .tx(router_if.tx),
    .credit_i(router_if.credit_i),
    .data_out(router_if.data_o),

    .clock_rx(router_if.clock_rx),
    .rx(router_if.rx),
    .credit_o(router_if.credit_o),
    .data_in(router_if.data_i)
  );

endmodule: router
