/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 22:20:25
 * @LastEditTime : 2024-06-28 00:30:08
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\top.v
 * @Description  : Verilator仿真顶层模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
module top (
    input clk,
    input rstn
);

  ysyx_23060191_CPU cpu (
      .clk (clk),
      .rstn(rstn)
  );

endmodule  //top


