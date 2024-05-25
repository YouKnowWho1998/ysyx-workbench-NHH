`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060191_defines.v"
module ysyx_23060191_cpu (
    input clk,
    input rstn
);

  wire [`CPU_WIDTH-1:0] pc;
  wire [`CPU_WIDTH-1:0] inst;
  wire [11:0] imm_to_alu;
  wire [4:0] rd_addr_to_wbu;
  wire [4:0] rs1_addr_to_gpr;
  wire [2:0] ctr_to_alu;
  wire [`CPU_WIDTH-1:0] rs1_to_alu;
  wire [`CPU_WIDTH-1:0] rs1_from_gpr;
  wire [`CPU_WIDTH-1:0] res_to_wbu;
  wire [`CPU_WIDTH-1:0] res_to_gpr;
  wire [4:0] rd_addr_to_gpr;




  //取指
  ysyx_23060191_IFU IFU (
      .clk (clk),
      .rstn(rstn),

      .pc(pc)  //输出pc值
  );

  //内存
  ysyx_23060191_MEM MEM (
      .addr(pc),  //地址(PC)

      .data(inst)  //输出指令
  );

  //译码
  ysyx_23060191_DEC DEC (
      .inst(inst),
      .rs1_from_gpr(rs1_from_gpr),

      .imm_to_alu(imm_to_alu),  //12位立即数
      .rs1_addr_to_gpr(rs1_addr_to_gpr),  //5位rs1源寄存器地址
      //.rs2_addr, //5位rs2源寄存器地址
      .rd_addr_to_wbu(rd_addr_to_wbu),  //5位目标寄存器地址
      .ctr_to_alu(ctr_to_alu),  //ALU计算控制码 
      .rs1_to_alu(rs1_to_alu)
  );

  ysyx_23060191_GPR GPR (
      .waddr(rd_addr_to_gpr),  //写入地址
      .raddr(rs1_addr_to_gpr),  //读取地址
      .din(res_to_gpr),  //写入数据

      .dout(rs1_from_gpr)  //读取数据 
  );

  ysyx_23060191_ALU ALU (
      // input [`CPU_WIDTH-1:0] pc,
      .op1(imm_to_alu),
      .op2(rs1_to_alu),
      .ctr(ctr_to_alu),

      .result(res_to_wbu)
  );

  ysyx_23060191_WBU WBU (
      .clk(clk),
      .rstn(rstn),
      .res_from_alu(res_to_wbu),
      .rd_addr_from_dec(rd_addr_to_wbu),

      .res_to_gpr(res_to_gpr),
      .rd_addr_to_gpr(rd_addr_to_gpr)
  );

import "DPI-C" function bit ebreak(input int inst_in);
always @(*) begin
    if (ebreak(inst)) begin
        $display("---ebreak---");
        $finish;
    end
end



endmodule  //ysyx_23060191_npc
