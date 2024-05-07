`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060191_defines.v"
module top (
    input clk,
    input rstn,

    output [`CPU_WIDTH-1:0] inst
);

  ysyx_23060191_IFU IFU_inst (
      .clk (clk),
      .rstn(rstn),

      .inst(inst)  //输出从内存中取出的指令
  );


endmodule  //top
