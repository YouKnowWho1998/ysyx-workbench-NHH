/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-28 13:18:55
 * @LastEditTime : 2024-07-05 12:43:43
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\ysyx_23060191_LSU.v
 * @Description  : LSU存储加载模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_LSU (
    input clk,
    input rstn,
    input [`LSU_OPT_WIDTH-1:0] lsu_opt_code,
    input [`CPU_WIDTH-1:0] addr,  //EXU->LSU 地址计算结果（读写地址都包括）
    input [`CPU_WIDTH-1:0] data_store,  //GPR->LSU 写入内存的数据 其值为data_Rs2

    output reg [`CPU_WIDTH-1:0] data_load  //MEM->LSU 从内存中读出的数据
);

  reg [3:0] mask, wr_mask;  //写入字节长度参数
  wire [`CPU_WIDTH-1:0] wr_addr, wr_data;  //写入地址，写入数据
  wire [`CPU_WIDTH-1:0] rd_data;  //读取数据
  wire [`CPU_WIDTH-1:0] rd_addr = addr;  //读取地址
  wire rd_en = ~lsu_opt_code[0];  //读取使能

  //读出数据长度遮罩
  always @(*) begin
    case (lsu_opt_code)
      `LSU_LW:  data_load = rd_data;
      `LSU_LH:  data_load = {{16{rd_data[15]}}, rd_data[15:0]};
      `LSU_LB:  data_load = {{24{rd_data[7]}}, rd_data[7:0]};
      `LSU_LBU: data_load = {24'b0, rd_data[7:0]};  //无符号数
      `LSU_LHU: data_load = {16'b0, rd_data[15:0]};  //无符号数
      default:  data_load = 0;
    endcase
  end


  //写入数据长度遮罩
  always @(*) begin
    case (lsu_opt_code)
      `LSU_SW: mask = 4'b1111;  //4字节
      `LSU_SH: mask = 4'b0011;  //2字节
      `LSU_SB: mask = 4'b0001;  //1字节
      default: mask = 0;
    endcase
  end

  // Due to comb logic delay, there must use an reg!!
  // Think about this situation: if waddr and wdata is not ready, but write it to mem immediately. it's wrong! 
  // 内存写入寄存器
  RegTemplate #(2 * `CPU_WIDTH + 4, 0) reg_store (
      .clk (clk),
      .rstn(rstn),
      .din ({addr, data_store, mask}),
      .dout({wr_addr, wr_data, wr_mask}),
      .wen (1'b1)
  );

  //DPI-C函数：内存写入
  import "DPI-C" function void npc_pmem_write(
    input int wr_addr,
    input int wr_data,
    input reg [3:0] wr_mask
  );
  //DPI-C函数：内存读取
  import "DPI-C" function void npc_pmem_read(
    input  int rd_addr,
    output int rd_data,
    input  bit rd_en
  );

  always @(*) begin
    npc_pmem_write(wr_addr, wr_data, wr_mask);
    npc_pmem_read(rd_addr, rd_data, rd_en);
  end

endmodule  //ysyx_23060191_LSU
