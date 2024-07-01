/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-20 10:59:34
 * @LastEditTime : 2024-06-30 13:47:24
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\ysyx_23060191_IFU.v
 * @Description  : IFU取指模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_IFU (
    input rstn,
    input [`CPU_WIDTH-1:0] pc,

    output [`CPU_WIDTH-1:0] inst  //取出指令  
);


  //DPIC函数：内存读取
  import "DPI-C" function void npc_pmem_read(
    input  int rd_addr,
    output int rd_data,
    input  bit rd_en
  );
  //DPIC函数：获取PC值
  import "DPI-C" function void get_dut_pc(input int npc_pc);
  
  always @(*) begin
    npc_pmem_read(pc, inst, rstn);
    get_dut_pc(pc);
  end


endmodule  //ysyx_23060191_IFU
