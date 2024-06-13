`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060191_defines.v"

module top (
    input clk,
    input rstn
);

  ysyx_23060191_cpu CPU (
      .clk (clk),
      .rstn(rstn)
  );


endmodule  //top
