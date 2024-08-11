/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-27 14:50:08
 * @LastEditTime : 2024-08-11 16:51:37
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_GPR.v
 * @Description  : GPR寄存器组
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_GPR (
    input clk,
    input i_wr_en_Rd,  //Rd寄存器写使能
    input [4:0] i_addr_Rd,  //Rd寄存器写地址 
    input [`CPU_WIDTH-1:0] i_data_Rd,  //Rd寄存器写入数据 
    input [4:0] i_addr_Rs1,  //Rs1寄存器读地址 IDU->GPR  
    input [4:0] i_addr_Rs2,  //Rs2寄存器读地址 IDU->GPR

    output [`CPU_WIDTH-1:0] o_data_Rs1,  //Rs1寄存器读出数据 GPR->EXU
    output [`CPU_WIDTH-1:0] o_data_Rs2   //Rs2寄存器读出数据 GPR->EXU GPR->LSU
);

  reg [`CPU_WIDTH-1:0] gpr[`CPU_WIDTH-1:0];  //32个寄存器组

  always @(posedge clk) begin
    if (i_wr_en_Rd) begin
      if (i_addr_Rd == 5'b0) begin
        gpr[i_addr_Rd] <= `CPU_WIDTH'b0;  //X0寄存器永远接0
      end else begin
        gpr[i_addr_Rd] <= i_data_Rd;
      end
    end
  end

  assign o_data_Rs1 = gpr[i_addr_Rs1];
  assign o_data_Rs2 = gpr[i_addr_Rs2];

// //DPI-C函数：获取NPC寄存器值
// import "DPI-C" function void get_dut_reg(input reg [31:0] r[]);

// initial get_dut_reg(gpr);

endmodule  //ysyx_23060191_GPR
