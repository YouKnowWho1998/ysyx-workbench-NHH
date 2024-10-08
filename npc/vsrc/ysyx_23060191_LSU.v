/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-28 13:18:55
 * @LastEditTime : 2024-08-11 20:54:20
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_LSU.v
 * @Description  : LSU存储加载模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_LSU (
    input clk,
    input rstn,
    input [`LSU_OPT_WIDTH-1:0] i_lsu_opt_code,
    input [`CPU_WIDTH-1:0] i_addr,  //EXU->LSU 地址计算结果（读写地址都包括）
    input [`CPU_WIDTH-1:0] i_data_store,  //GPR->LSU 写入内存的数据 其值为data_Rs2

    output [`CPU_WIDTH-1:0] o_data_load  //MEM->LSU 从内存中读出的数据
);

  wire [3:0] mask, wr_mask;  //写入字节长度参数
  wire [`CPU_WIDTH-1:0] wr_addr, wr_data;  //写入地址，写入数据
  wire [`CPU_WIDTH-1:0] rd_data;  //读取数据
  wire [`CPU_WIDTH-1:0] rd_addr = i_addr;  //读取地址
  wire rd_en = i_lsu_opt_code[0];  //读取使能
 
  //读出数据
  assign o_data_load = ({$bits(o_data_load){(i_lsu_opt_code==`LSU_LW)}}  & rd_data) |
                       ({$bits(o_data_load){(i_lsu_opt_code==`LSU_LH)}}  & {{16{rd_data[15]}}, rd_data[15:0]}) |
                       ({$bits(o_data_load){(i_lsu_opt_code==`LSU_LB)}}  & {{24{rd_data[7]}}, rd_data[7:0]})   |
                       ({$bits(o_data_load){(i_lsu_opt_code==`LSU_LBU)}} & {24'b0, rd_data[7:0]})  |
                       ({$bits(o_data_load){(i_lsu_opt_code==`LSU_LHU)}} & {16'b0, rd_data[15:0]});


  //写入数据长度遮罩
  assign mask = ({$bits(mask){(i_lsu_opt_code==`LSU_SW)}} & 4'b1111) |
                ({$bits(mask){(i_lsu_opt_code==`LSU_SH)}} & 4'b0011) |
                ({$bits(mask){(i_lsu_opt_code==`LSU_SB)}} & 4'b0001);


  // Due to comb logic delay, there must use an reg!!
  // Think about this situation: if waddr and wdata is not ready, but write it to mem immediately. it's wrong! 
  // 内存写入寄存器
  RegTemplate #(2 * `CPU_WIDTH + 4, 0) reg_store (
      .clk (clk),
      .rstn(rstn),
      .din ({i_addr, i_data_store, mask}),
      .dout({wr_addr, wr_data, wr_mask}),
      .wen (1'b1)
  );

  // //DPI-C函数：内存写入
  // import "DPI-C" function void npc_pmem_write(
  //   input int wr_addr,
  //   input int wr_data,
  //   input reg [3:0] wr_mask
  // );
  // //DPI-C函数：内存读取
  // import "DPI-C" function void npc_pmem_read(
  //   input  int rd_addr,
  //   output int rd_data,
  //   input  bit rd_en
  // );

  // always @(*) begin
  //   npc_pmem_write(wr_addr, wr_data, wr_mask);
  //   npc_pmem_read(rd_addr, rd_data, rd_en);
  // end


endmodule  //ysyx_23060191_LSU
