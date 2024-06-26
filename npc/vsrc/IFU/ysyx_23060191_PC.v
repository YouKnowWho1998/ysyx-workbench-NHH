/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-20 10:42:28
 * @LastEditTime : 2024-06-26 10:07:04
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\IFU\ysyx_23060191_PC.v
 * @Description  : PC寄存器
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
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
