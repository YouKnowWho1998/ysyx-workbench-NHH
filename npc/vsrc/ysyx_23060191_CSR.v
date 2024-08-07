/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-08-01 10:46:22
 * @LastEditTime : 2024-08-07 15:45:13
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_CSR.v
 * @Description  : CSR寄存器组
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_CSR (
    input clk,
    input ecall_en,  //中断使能
    input [7:0] ecall_NO,  //中断事件编号(a7寄存器)
    input wr_en_csr,  //csr寄存器写使能
    input [`CPU_WIDTH-1:0] data_wr_csr,  //csr寄存器写数据
    input [11:0] addr_wr_csr,  //csr寄存器写地址 
    input [11:0] addr_rd_csr,  //csr寄存器读地址

    output [`CPU_WIDTH-1:0] data_rd_csr,  //csr寄存器读数据
    output [`CPU_WIDTH-1:0] mtvec,  //mtvec寄存器数据
    output [`CPU_WIDTH-1:0] mepc  //mepc寄存器数据
);
  wire [1:0] waddr;
  wire [1:0] raddr;
  reg [`CPU_WIDTH-1:0] csr[3:0]; //4个csr寄存器 csr[0]=mtvec csr[1]=mepc csr[2]=mstatus csr[3]=mcause

  //写地址转换器 外部输入地址转换成两位地址
  MuxTemplate #(4, 12, 2) wr_addr_converter (
      waddr,
      addr_wr_csr,
      {`MTVEC, 2'b00, `MEPC, 2'b01, `MSTATUS, 2'b10, `MCAUSE, 2'b11}
  );

  //读地址转换器 外部输入地址转换成两位地址
  MuxTemplate #(4, 12, 2) rd_addr_converter (
      raddr,
      addr_rd_csr,
      {`MTVEC, 2'b00, `MEPC, 2'b01, `MSTATUS, 2'b10, `MCAUSE, 2'b11}
  );


  //写数据
  always @(posedge clk) begin
    if (wr_en_csr) begin
      csr[waddr] <= data_wr_csr;
    end
    //ecall
    if (ecall_en) begin
      csr[3] <= {{24'b0}, ecall_NO};  //mcause寄存器写入事件编号
      csr[1] <= data_wr_csr;  //mepc寄存器写入当前PC值
    end
  end

  //读数据
  assign data_rd_csr = csr[raddr];

  assign csr[2]      = 32'h1800;  //初始化mstatus为0x1800
  assign mtvec       = csr[0];
  assign mepc        = csr[1];

endmodule  //ysyx_23060191_CSR
