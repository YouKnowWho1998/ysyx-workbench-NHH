/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-08-01 10:46:22
 * @LastEditTime : 2024-08-11 20:19:32
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_CSR.v
 * @Description  : CSR寄存器组
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_CSR (
    input clk,
    input i_ecall_en,  //中断使能
    input [`CPU_WIDTH-1:0] i_ecall_NO,  //中断事件编号(a5寄存器)
    input i_wr_en_csr,  //csr寄存器写使能
    input [`CPU_WIDTH-1:0] i_data_wr_csr,  //csr寄存器写数据
    input [11:0] i_addr_wr_csr,  //csr寄存器写地址 
    input [11:0] i_addr_rd_csr,  //csr寄存器读地址

    output [`CPU_WIDTH-1:0] o_data_rd_csr,  //csr寄存器读数据
    output [`CPU_WIDTH-1:0] o_mtvec,  //mtvec寄存器数据
    output [`CPU_WIDTH-1:0] o_mepc  //mepc寄存器数据
);
  wire [1:0] waddr;
  wire [1:0] raddr;
  reg [`CPU_WIDTH-1:0] csr[3:0]; //4个csr寄存器 csr[0]=mtvec csr[1]=mepc csr[2]=mstatus csr[3]=mcause

  //写地址转换器 外部输入地址转换成两位地址
  MuxTemplate #(4, 12, 2) wr_addr_converter (
      waddr,
      i_addr_wr_csr,
      {`MTVEC, 2'b00, `MEPC, 2'b01, `MSTATUS, 2'b10, `MCAUSE, 2'b11}
  );

  //读地址转换器 外部输入地址转换成两位地址
  MuxTemplate #(4, 12, 2) rd_addr_converter (
      raddr,
      i_addr_rd_csr,
      {`MTVEC, 2'b00, `MEPC, 2'b01, `MSTATUS, 2'b10, `MCAUSE, 2'b11}
  );


  //写数据
  always @(posedge clk) begin
    if (i_wr_en_csr) begin
      csr[waddr] <= i_data_wr_csr;
    end
    //ecall
    if (i_ecall_en) begin
      csr[3] <= i_ecall_NO;  //mcause寄存器写入事件编号
      csr[1] <= i_data_wr_csr;  //mepc寄存器写入当前PC值
    end
  end

  //读数据
  assign o_data_rd_csr = csr[raddr];

  always @(*) begin
    csr[2] = 32'h1800;  //初始化mstatus为0x1800
  end
  
  assign o_mtvec = csr[0];
  assign o_mepc  = csr[1];

endmodule  //ysyx_23060191_CSR
