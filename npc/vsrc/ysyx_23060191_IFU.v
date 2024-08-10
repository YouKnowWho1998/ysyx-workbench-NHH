/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-20 10:59:34
 * @LastEditTime : 2024-08-08 20:07:14
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_IFU.v
 * @Description  : IFU取指模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_IFU (
    input rstn,
    input [`CPU_WIDTH-1:0] i_pc,

    output [`CPU_WIDTH-1:0] o_inst  //取出指令  
);


  //DPIC函数：内存读取
  import "DPI-C" function void npc_pmem_read(
    input  int rd_addr,
    output int rd_data,
    input  bit rd_en
  );
  //DPIC函数：获取PC值
  import "DPI-C" function void get_dut_pc(input int npc_pc);
  //DPIC函数：获取inst值
  import "DPI-C" function void get_dut_inst(input int npc_inst);
  
  always @(*) begin
    npc_pmem_read(i_pc, o_inst, rstn);
    get_dut_pc(i_pc);
    get_dut_inst(o_inst);
  end


endmodule  //ysyx_23060191_IFU
