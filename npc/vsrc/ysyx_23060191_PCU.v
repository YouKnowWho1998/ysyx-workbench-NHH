/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-26 15:23:13
 * @LastEditTime : 2024-08-06 21:49:08
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_PCU.v
 * @Description  : PCU产生&控制模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_PCU (
    input clk,
    input rstn,
    input [`CPU_WIDTH-1:0] imm,  //立即数
    input [`CPU_WIDTH-1:0] data_Rs1,  //Rs1寄存器值
    input jal_jump_en,  //jal跳转指令使能
    input jalr_jump_en,  //jalr跳转指令使能
    input branch_en,  //branch指令使能
    input ecall_en, //IDU->PCU
    input mret_en, //IDU->PCU
    input [`CPU_WIDTH-1:0] mtvec,//CSR->PCU
    input [`CPU_WIDTH-1:0] mepc,//CSR->PCU
    input zero,    //branch非0指示 EXU->PCU 

    output [`CPU_WIDTH-1:0] pc
);

  reg [`CPU_WIDTH-1:0] pc_next;

  //跳转指令判断
  always @(*) begin
    if (ecall_en) begin
      pc_next = mtvec;
    end
    else if(mret_en) begin
      pc_next = mepc;
    end
    else if (~zero && branch_en || jal_jump_en) begin
      pc_next = pc + imm;
    end else if (jalr_jump_en) begin
      pc_next = data_Rs1 + imm;
    end else begin
      pc_next = pc + 4;
    end
  end


  RegTemplate #(`CPU_WIDTH, `CPU_WIDTH'h80000000) pc_reg (
      .clk(clk),
      .rstn(rstn),
      .din(pc_next),
      .dout(pc),
      .wen(1'b1)  //永远启用
  );

endmodule  //ysyx_23060191_PCU
