/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-28 00:28:13
 * @LastEditTime : 2024-07-12 13:07:25
 * @FilePath     : /ysyx/ysyx-workbench/npc/vsrc/ysyx_23060191_ALU.v
 * @Description  : ALU计算模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_ALU (
    input [`CPU_WIDTH-1:0] alu_in1,
    input [`CPU_WIDTH-1:0] alu_in2,
    input [`ALU_OPT_WIDTH-1:0] alu_opt_code,

    output reg [`CPU_WIDTH-1:0] alu_res,
    output reg sub_u_bit  //无符号数减法增加的最高位 根据其正负判断大小
);

  always @(*) begin  
    alu_res = 0;
    sub_u_bit = 0;
    case (alu_opt_code)
      `ALU_ADD: alu_res = alu_in1 + alu_in2;
      `ALU_SUB: alu_res = alu_in1 - alu_in2;
      `ALU_AND: alu_res = alu_in1 & alu_in2;
      `ALU_SRA_I: alu_res = {{{32{alu_in1[31]}}, alu_in1} >> alu_in2[5:0]}[31:0]; //算术右移
      `ALU_SLL_I: alu_res = alu_in1 << alu_in2[5:0];  //逻辑左移
      `ALU_SRL_I: alu_res = alu_in1 >> alu_in2[5:0];  //逻辑右移
      `ALU_SLL_R: alu_res = alu_in1 << alu_in2[4:0];
      `ALU_SRL_R: alu_res = alu_in1 >> alu_in2[4:0];
      `ALU_SRA_R: alu_res = {{{32{alu_in1[31]}}, alu_in1} >> alu_in2[4:0]}[31:0];
      `ALU_SUB_U: {sub_u_bit, alu_res} = {1'b0, alu_in1} - {1'b0, alu_in2};  //无符号数减法
      `ALU_XOR: alu_res = alu_in1 ^ alu_in2;
      `ALU_OR: alu_res = alu_in1 | alu_in2;
      `ALU_MUL: alu_res = alu_in1 * alu_in2;
      `ALU_REM: alu_res = alu_in1 % alu_in2;
      `ALU_REMU: alu_res = {{1'b0,alu_in1} % {1'b0,alu_in2}}[31:0];
      `ALU_DIV: alu_res = alu_in1 / alu_in2;
      `ALU_DIVU: alu_res = {{1'b0, alu_in1} / {1'b0, alu_in2}}[31:0];
      `ALU_MULHU: alu_res = {{{32'b0,alu_in1}*{32'b0,alu_in2}}>>32}[31:0];
      `ALU_MULH: alu_res =  {{{{32{alu_in1[31]}},alu_in1}*{{32{alu_in2[31]}},alu_in2}}>>32}[31:0];
      default : ;
    endcase
  end


endmodule  //ysyx_23060191_ALU
