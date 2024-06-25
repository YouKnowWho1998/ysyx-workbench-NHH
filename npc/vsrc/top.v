module top (
    input clk,
    input rstn
);

  ysyx_23060191_CPU cpu (
      .clk (clk),
      .rstn(rstn)
  );

endmodule  //top


