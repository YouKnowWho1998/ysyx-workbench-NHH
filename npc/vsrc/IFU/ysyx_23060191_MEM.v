/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-20 11:04:22
 * @LastEditTime : 2024-06-26 10:06:34
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\IFU\ysyx_23060191_MEM.v
 * @Description  : 内存模块 
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_MEM (
    input [`CPU_WIDTH-1:0] pc,
    input rd_en,  //内存读使能

    output reg [`CPU_WIDTH-1:0] inst
);

  //调用DPIC机制 读取软件模拟的内存
  import "DPI-C" function void npc_pmem_read(
    input  int raddr,
    output int rdata,
    input  bit rd_en
  );
  always @(*) begin
    npc_pmem_read(pc, inst, rd_en);
  end


endmodule  //ysyx_23060191_MEM
