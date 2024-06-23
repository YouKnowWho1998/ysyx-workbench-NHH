`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_PC (
    input clk,
    input rstn,
    input [`CPU_WIDTH-1:0] pc_origin,

    output [`CPU_WIDTH-1:0] pc
);

  RegTemplate #(`CPU_WIDTH, 32'h80000000) PC (  //32位PC寄存器，复位值是32'h80000000
      .clk(clk),
      .rstn(rstn),
      .din(pc_origin),
      .dout(pc),
      .wen(1'b1)  //永远启用
  );


endmodule  //PC
