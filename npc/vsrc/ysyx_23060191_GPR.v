/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-27 14:50:08
 * @LastEditTime : 2024-06-28 21:33:46
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\ysyx_23060191_GPR.v
 * @Description  : GPR寄存器组
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_GPR (
    input clk,
    input wr_en_Rd,  //Rd寄存器写使能
    input [4:0] addr_Rd,  //Rd寄存器写地址 
    input [`CPU_WIDTH-1:0] data_Rd,  //Rd寄存器写入数据 
    input [4:0] addr_Rs1,  //Rs1寄存器读地址 IDU->GPR  
    input [4:0] addr_Rs2,  //Rs2寄存器读地址 IDU->GPR

    output [`CPU_WIDTH-1:0] data_Rs1,  //Rs1寄存器读出数据 GPR->EXU
    output [`CPU_WIDTH-1:0] data_Rs2   //Rs2寄存器读出数据 GPR->EXU GPR->LSU
);

  reg [`CPU_WIDTH-1:0] regfile[`CPU_WIDTH-1:0];  //32个寄存器组

  always @(posedge clk) begin
    if (wr_en_Rd) begin
      if (addr_Rd == 5'b0) begin
        regfile[addr_Rd] <= `CPU_WIDTH'b0;  //X0寄存器永远接0
      end else begin
        regfile[addr_Rd] <= data_Rd;
      end
    end
  end

  assign data_Rs1 = regfile[addr_Rs1];
  assign data_Rs2 = regfile[addr_Rs2];



endmodule  //ysyx_23060191_GPR
