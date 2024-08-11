/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-28 00:28:13
 * @LastEditTime : 2024-08-11 16:44:50
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_ALU.v
 * @Description  : ALU计算模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_ALU (
    input [`CPU_WIDTH-1:0] i_alu_in1,
    input [`CPU_WIDTH-1:0] i_alu_in2,
    input [`ALU_OPT_WIDTH-1:0] i_alu_opt_code,

    output [`CPU_WIDTH-1:0] o_alu_res,
    output o_sub_u_bit  //无符号数减法增加的最高位 根据其正负判断大小
);

wire [63:0] data_alu_sra_i = {{{32{i_alu_in1[31]}}, i_alu_in1} >> i_alu_in2[5:0]};
wire [63:0] data_alu_sra_r = {{{32{i_alu_in1[31]}}, i_alu_in1} >> i_alu_in2[4:0]};
wire [32:0] data_alu_sub_u = {({1'b0, i_alu_in1} - {1'b0, i_alu_in2})};
wire [32:0] data_alu_remu  = {{1'b0,i_alu_in1} % {1'b0,i_alu_in2}};
wire [32:0] data_alu_divu  = {{1'b0,i_alu_in1} / {1'b0,i_alu_in2}};
wire [63:0] data_alu_mulhu = {{{32'b0,i_alu_in1} * {32'b0,i_alu_in2}} >> 32};
wire [63:0] data_alu_mulh  = {{{{32{i_alu_in1[31]}},i_alu_in1} * {{32{i_alu_in2[31]}},i_alu_in2}} >> 32};

//alu_res计算结果
assign o_alu_res = ({$bits(o_alu_res){(i_alu_opt_code==`ALU_ADD)}}   & (i_alu_in1 + i_alu_in2))       |
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SUB)}}   & (i_alu_in1 - i_alu_in2))       |
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_AND)}}   & (i_alu_in1 & i_alu_in2))       |
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SRA_I)}} & (data_alu_sra_i[31:0]))        |
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SLL_I)}} & (i_alu_in1 << i_alu_in2[5:0])) | //逻辑左移
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SRL_I)}} & (i_alu_in1 >> i_alu_in2[5:0])) | //逻辑右移
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SLL_R)}} & (i_alu_in1 << i_alu_in2[4:0])) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SRL_R)}} & (i_alu_in1 >> i_alu_in2[4:0])) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SRA_R)}} & (data_alu_sra_r[31:0]))        | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SUB_U)}} & (data_alu_sub_u[31:0]))        | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_XOR)}}   & (i_alu_in1 ^ i_alu_in2))       | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_OR)}}    & (i_alu_in1 | i_alu_in2))       | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_MUL)}}   & (i_alu_in1 * i_alu_in2))       | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_REM)}}   & (i_alu_in1 % i_alu_in2))       | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_DIV)}}   & (i_alu_in1 / i_alu_in2))       | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_REMU)}}  & (data_alu_remu[31:0]))         | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_DIVU)}}  & (data_alu_divu[31:0]))         | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_MULHU)}} & (data_alu_mulhu[31:0]))        | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_MULH)}}  & (data_alu_mulh[31:0]))         ; 


assign o_sub_u_bit = ({$bits(o_sub_u_bit){(i_alu_opt_code==`ALU_SUB_U)}} & (data_alu_sub_u[32]));


endmodule  //ysyx_23060191_ALU
