/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-28 15:46:00
 * @LastEditTime : 2024-08-10 18:25:09
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_WBU.v
 * @Description  : WBU回写模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_WBU (
    input  [`CPU_WIDTH-1:0] i_exu_res,//EXU计算结果(需要回写)
    input  [`CPU_WIDTH-1:0] i_lsu_res,
    input  [`CPU_WIDTH-1:0] i_csr_res,
    input  i_csr_res_en, 
    input  i_load_en, 

    output o_wr_en_csr,
    output [`CPU_WIDTH-1:0] o_data_wr_csr,
    output [`CPU_WIDTH-1:0] o_data_wr_Rd  
);

assign o_wr_en_csr = i_csr_res_en;

assign o_data_wr_csr = i_csr_res;

assign o_data_wr_Rd = i_load_en ? i_lsu_res : i_exu_res;

endmodule //ysyx_23060191_WBU