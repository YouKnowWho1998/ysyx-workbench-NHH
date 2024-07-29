/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-15 13:00:53
 * @LastEditTime : 2024-07-29 21:52:20
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_CPU.v
 * @Description  : CPU顶层模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_CPU (
    input clk,
    input rstn
);

  wire rstn_sync;
  wire jal_jump_en;  //jal跳转使能
  wire jalr_jump_en;  //jalr跳转使能
  wire wr_en_Rd;  //Rd寄存器写使能
  wire branch_en;
  wire zero;
  wire [`CPU_WIDTH-1:0] imm;  //立即数
  wire [`CPU_WIDTH-1:0] data_Rs1;  //Rs1寄存器值
  wire [`CPU_WIDTH-1:0] pc;  //pc值
  wire [`CPU_WIDTH-1:0] inst;  //指令
  wire [4:0] addr_Rd;
  wire [4:0] addr_Rs1;
  wire [4:0] addr_Rs2;
  wire [`CPU_WIDTH-1:0] data_Rd;
  wire [`CPU_WIDTH-1:0] data_Rs1;
  wire [`CPU_WIDTH-1:0] data_Rs2;
  wire [`CPU_WIDTH-1:0] exu_res;
  wire [`CPU_WIDTH-1:0] lsu_res;
  wire [`EXU_OPT_WIDTH-1:0] exu_opt_code;
  wire [`LSU_OPT_WIDTH-1:0] lsu_opt_code;
  wire [`EXU_SEL_WIDTH-1:0] exu_sel_code;

  //复位信号置0打一拍
  Rstnreg rstn_reg (
      .clk (clk),
      .rstn(rstn),

      .rstn_sync(rstn_sync)
  );

  //PCU 
  ysyx_23060191_PCU pcu (
      .clk(clk),
      .rstn(rstn_sync),
      .imm(imm),  //立即数
      .data_Rs1(data_Rs1),  //Rs1寄存器值
      .jal_jump_en(jal_jump_en),  //jal跳转指令使能
      .jalr_jump_en(jalr_jump_en),  //jalr跳转指令使能
      .branch_en(branch_en),
      .zero(zero),

      .pc(pc)
  );

  //IFU
  ysyx_23060191_IFU ifu (
      .rstn(rstn_sync),
      .pc  (pc),

      .inst(inst)  //取出指令  
  );

  //IDU
  ysyx_23060191_IDU idu (
      .inst(inst),

      .wr_en_Rd(wr_en_Rd),  //Rd寄存器写使能 IDU->GPR
      .addr_Rd(addr_Rd),  //目标寄存器地址 IDU->GPR
      .addr_Rs1(addr_Rs1),  //rs1寄存器地址 IDU->GPR
      .addr_Rs2(addr_Rs2),  //rs2寄存器地址 IDU->GPR
      .imm(imm),  //所有立即数统一扩展至32位 高位填充符号位 IDU->EXU IDU->PCU
      .jal_jump_en(jal_jump_en),  //jal跳转指令使能 IDU->PCU
      .jalr_jump_en(jalr_jump_en),  //jalr跳转指令使能 IDU->PCU
      .branch_en(branch_en),
      .exu_opt_code(exu_opt_code),  //EXU操作码 IDU->EXU
      .lsu_opt_code(lsu_opt_code),  //LSU操作码 IDU->LSU
      .exu_sel_code(exu_sel_code)  //EXU选择码 IDU->EXU
  );

  //GPR
  ysyx_23060191_GPR gpr (
      .clk(clk),
      .wr_en_Rd(wr_en_Rd),  //Rd寄存器写使能
      .addr_Rd(addr_Rd),  //Rd寄存器写地址 
      .data_Rd(data_Rd),  //Rd寄存器写入数据 
      .addr_Rs1(addr_Rs1),  //Rs1寄存器读地址 IDU->GPR  
      .addr_Rs2(addr_Rs2),  //Rs2寄存器读地址 IDU->GPR

      .data_Rs1(data_Rs1),  //Rs1寄存器读出数据 GPR->EXU
      .data_Rs2(data_Rs2)   //Rs2寄存器读出数据 GPR->EXU GPR->LSU
  );

  //EXU
  ysyx_23060191_EXU exu (
      .pc(pc),
      .data_Rs1(data_Rs1),
      .data_Rs2(data_Rs2),
      .imm(imm),
      .exu_opt_code(exu_opt_code),
      .exu_sel_code(exu_sel_code),

      .exu_res(exu_res),  //EXU->LSU EXU->WBU
      .zero(zero)
  );

  //LSU
  ysyx_23060191_LSU lsu (
      .clk(clk),
      .rstn(rstn_sync),
      .lsu_opt_code(lsu_opt_code),
      .addr(exu_res),  //EXU->LSU 地址计算结果（读写地址都包括）
      .data_store(data_Rs2),  //GPR->LSU 写入内存的数据 其值为data_Rs2

      .data_load(lsu_res) //MEM->LSU 从内存中读出的数据
  );

  //WBU
  ysyx_23060191_WBU wbu (
      .exu_res(exu_res),  //EXU计算结果(需要回写)
      .lsu_res(lsu_res),
      .load_en(~lsu_opt_code[0]),

      .data_wr_Rd(data_Rd)
  );

  //DPI-C函数：Ebreak指令停止仿真
  import "DPI-C" function bit npc_finish(input int inst);

  always @(*) begin
    if (npc_finish(inst)) begin
      $display("\033[1;35m[EBREAK]  CPU STOP RUNNING\033[0m");
      $finish;
    end
  end

endmodule  //ysyx_23060191_CPU
