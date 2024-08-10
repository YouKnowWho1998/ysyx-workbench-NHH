/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-28 00:28:13
 * @LastEditTime : 2024-08-10 18:11:18
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

//alu_res计算结果
assign o_alu_res = ({$bits(o_alu_res){(i_alu_opt_code==`ALU_ADD)}}   & (i_alu_in1 + i_alu_in2)) |
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SUB)}}   & (i_alu_in1 - i_alu_in2)) |
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_AND)}}   & (i_alu_in1 & i_alu_in2)) |
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SRA_I)}} & ({{{32{i_alu_in1[31]}}, i_alu_in1} >> i_alu_in2[5:0]}[31:0])) |
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SLL_I)}} & (i_alu_in1 << i_alu_in2[5:0])) | //逻辑左移
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SRL_I)}} & (i_alu_in1 >> i_alu_in2[5:0])) | //逻辑右移
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SLL_R)}} & (i_alu_in1 << i_alu_in2[4:0])) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SRL_R)}} & (i_alu_in1 >> i_alu_in2[4:0])) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SRA_R)}} & ({{{32{i_alu_in1[31]}}, i_alu_in1} >> i_alu_in2[4:0]}[31:0])) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_SUB_U)}} & ({({1'b0, i_alu_in1} - {1'b0, i_alu_in2})}[31:0])) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_XOR)}}   & (i_alu_in1 ^ i_alu_in2)) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_OR)}}    & (i_alu_in1 | i_alu_in2)) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_MUL)}}   & (i_alu_in1 * i_alu_in2)) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_REM)}}   & (i_alu_in1 % i_alu_in2)) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_DIV)}}   & (i_alu_in1 / i_alu_in2)) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_REMU)}}  & ({{1'b0,i_alu_in1} % {1'b0,i_alu_in2}}[31:0])) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_DIVU)}}  & ({{1'b0,i_alu_in1} / {1'b0,i_alu_in2}}[31:0])) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_MULHU)}} & ({{{32'b0,i_alu_in1} * {32'b0,i_alu_in2}} >> 32}[31:0])) | 
                   ({$bits(o_alu_res){(i_alu_opt_code==`ALU_MULH)}}  & ({{{{32{i_alu_in1[31]}},i_alu_in1} * {{32{i_alu_in2[31]}},i_alu_in2}} >> 32}[31:0])); 


assign o_sub_u_bit = ({$bits(o_sub_u_bit){(i_alu_opt_code==`ALU_SUB_U)}} & ({({1'b0, i_alu_in1} - {1'b0, i_alu_in2})}[32]));


endmodule  //ysyx_23060191_ALU
