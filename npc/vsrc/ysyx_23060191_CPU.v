/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-15 13:00:53
 * @LastEditTime : 2024-08-10 18:12:27
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
  wire ecall_en;
  wire mret_en;
  wire [`CPU_WIDTH-1:0] mtvec;
  wire [`CPU_WIDTH-1:0] mepc;
  wire [11:0] addr_wr_csr;
  wire [11:0] addr_rd_csr;
  wire [`CPU_WIDTH-1:0] data_rd_csr; 
  wire [`CPU_WIDTH-1:0] data_wr_csr; 
  wire [`CPU_WIDTH-1:0] csr_res;
  wire csr_res_en;
  wire wr_en_csr; 

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
      .i_imm(imm),  //立即数
      .i_data_Rs1(data_Rs1),  //Rs1寄存器值
      .i_jal_jump_en(jal_jump_en),  //jal跳转指令使能
      .i_jalr_jump_en(jalr_jump_en),  //jalr跳转指令使能
      .i_branch_en(branch_en),
      .i_ecall_en(ecall_en),//IDU->PCU
      .i_mret_en(mret_en),//IDU->PCU
      .i_mtvec(mtvec), //CSR->PCU
      .i_mepc(mepc),//CSR->PCU
      .i_zero(zero),

      .o_pc(pc)
  );

  //IFU
  ysyx_23060191_IFU ifu (
      .rstn(rstn_sync),
      .i_pc  (pc),

      .o_inst(inst)  //取出指令  
  );

  //IDU
  ysyx_23060191_IDU idu (
      .i_inst(inst),

      .o_wr_en_Rd(wr_en_Rd),  //Rd寄存器写使能 IDU->GPR
      .o_addr_Rd(addr_Rd),  //目标寄存器地址 IDU->GPR
      .o_addr_Rs1(addr_Rs1),  //rs1寄存器地址 IDU->GPR
      .o_addr_Rs2(addr_Rs2),  //rs2寄存器地址 IDU->GPR
      .o_imm(imm),  //所有立即数统一扩展至32位 高位填充符号位 IDU->EXU IDU->PCU
      .o_jal_jump_en(jal_jump_en),  //jal跳转指令使能 IDU->PCU
      .o_jalr_jump_en(jalr_jump_en),  //jalr跳转指令使能 IDU->PCU
      .o_branch_en(branch_en),
      .o_ecall_en(ecall_en),//IDU->CSR IDU->PCU
      .o_mret_en(mret_en), //IDU->PCU
      .o_addr_rd_csr(addr_rd_csr),//IDU->CSR
      .o_addr_wr_csr(addr_wr_csr),//IDU->CSR
      .o_exu_opt_code(exu_opt_code),  //EXU操作码 IDU->EXU
      .o_lsu_opt_code(lsu_opt_code),  //LSU操作码 IDU->LSU
      .o_exu_sel_code(exu_sel_code)  //EXU选择码 IDU->EXU
  );

  //GPR
  ysyx_23060191_GPR gpr (
      .clk(clk),
      .i_wr_en_Rd(wr_en_Rd),  //Rd寄存器写使能
      .i_addr_Rd(addr_Rd),  //Rd寄存器写地址 
      .i_data_Rd(data_Rd),  //Rd寄存器写入数据 
      .i_addr_Rs1(addr_Rs1),  //Rs1寄存器读地址 IDU->GPR  
      .i_addr_Rs2(addr_Rs2),  //Rs2寄存器读地址 IDU->GPR

      .o_data_Rs1(data_Rs1),  //Rs1寄存器读出数据 GPR->EXU
      .o_data_Rs2(data_Rs2)   //Rs2寄存器读出数据 GPR->EXU GPR->LSU
  );

ysyx_23060191_CSR csr(
    .clk(clk),
    .i_ecall_en(ecall_en),  //中断使能
    .i_ecall_NO(data_Rs1),  //中断事件编号
    .i_wr_en_csr(wr_en_csr),  //csr寄存器写使能
    .i_data_wr_csr(data_wr_csr),  //csr寄存器写数据
    .i_addr_wr_csr(addr_wr_csr),  //csr寄存器写地址 
    .i_addr_rd_csr(addr_rd_csr),  //csr寄存器读地址

    .o_data_rd_csr(data_rd_csr),  //csr寄存器读数据 CSR->EXU
    .o_mtvec(mtvec),  //mtvec寄存器数据
    .o_mepc(mepc)  //mepc寄存器数据
);

  //EXU
  ysyx_23060191_EXU exu (
      .i_pc(pc),
      .i_data_Rs1(data_Rs1),
      .i_data_Rs2(data_Rs2),
      .i_imm(imm),
      .i_exu_opt_code(exu_opt_code),
      .i_exu_sel_code(exu_sel_code),
      .i_data_rd_csr(data_rd_csr),

      .o_exu_res(exu_res),  //EXU->LSU EXU->WBU
      .o_csr_res(csr_res),
      .o_csr_res_en(csr_res_en),//EXU->WBU
      .o_zero(zero)
  );

  //LSU
  ysyx_23060191_LSU lsu (
      .clk(clk),
      .rstn(rstn_sync),
      .i_lsu_opt_code(lsu_opt_code),
      .i_addr(exu_res),  //EXU->LSU 地址计算结果（读写地址都包括）
      .i_data_store(data_Rs2),  //GPR->LSU 写入内存的数据 其值为data_Rs2

      .o_data_load(lsu_res) //MEM->LSU 从内存中读出的数据
  );

  //WBU
  ysyx_23060191_WBU wbu (
      .i_exu_res(exu_res),  //EXU计算结果(需要回写)
      .i_lsu_res(lsu_res),
      .i_load_en(lsu_opt_code[0]),
      .i_csr_res(csr_res),
      .i_csr_res_en(csr_res_en),

      .o_data_wr_Rd(data_Rd),
      .o_data_wr_csr(data_wr_csr),
      .o_wr_en_csr(wr_en_csr)
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
