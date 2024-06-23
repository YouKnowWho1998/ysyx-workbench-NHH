`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"

module  ysyx_23060191_TOP(
    input clk,
    input rstn
);

  ysyx_23060191_CPU cpu (
      .clk (clk),
      .rstn(rstn)
  );


endmodule  //top
