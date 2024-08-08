/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-26 15:23:13
 * @LastEditTime : 2024-08-08 20:02:27
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_PCU.v
 * @Description  : PCU产生&控制模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_PCU (
    input clk,
    input rstn,
    input [`CPU_WIDTH-1:0] i_imm,  //立即数
    input [`CPU_WIDTH-1:0] i_data_Rs1,  //Rs1寄存器值
    input i_jal_jump_en,  //jal跳转指令使能
    input i_jalr_jump_en,  //jalr跳转指令使能
    input i_branch_en,  //branch指令使能
    input i_ecall_en,  //IDU->PCU
    input i_mret_en,  //IDU->PCU
    input [`CPU_WIDTH-1:0] i_mtvec,  //CSR->PCU
    input [`CPU_WIDTH-1:0] i_mepc,  //CSR->PCU
    input i_zero,  //branch非0指示 EXU->PCU 

    output [`CPU_WIDTH-1:0] o_pc
);

  reg [`CPU_WIDTH-1:0] pc_next;



  //data mask写法：yy = {$bits(xx){en}} & xx; en是判断条件
  //拒绝在组合逻辑中使用case和if-else等抽象语法，因为会综合出带优先级电路(且不能传播不定态)，这是很不好的！
  //使用assign语句（或与写法）产生无优先级电路！
  //当然，是否产生优先级电路取决于你的设计，这里要设计出带优先级电路
  assign pc_next = i_ecall_en ? i_mtvec :
                    i_mret_en ? i_mepc :
                    (~i_zero && i_branch_en || i_jal_jump_en) ? o_pc + i_imm :
                    i_jalr_jump_en ? i_data_Rs1 + i_imm : 
                    o_pc + 4 ;


  RegTemplate #(`CPU_WIDTH, `CPU_WIDTH'h80000000) pc_reg (
      .clk(clk),
      .rstn(rstn),
      .din(pc_next),
      .dout(o_pc),
      .wen(1'b1)  //永远启用
  );

endmodule  //ysyx_23060191_PCU
