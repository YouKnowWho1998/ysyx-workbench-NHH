/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-28 15:46:00
 * @LastEditTime : 2024-08-06 21:02:34
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_WBU.v
 * @Description  : WBU回写模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_WBU (
    input  [`CPU_WIDTH-1:0] exu_res,//EXU计算结果(需要回写)
    input  [`CPU_WIDTH-1:0] lsu_res,
    input  [`CPU_WIDTH-1:0] csr_res,
    input  csr_res_en, 
    input  load_en, 

    output wr_en_csr,
    output [`CPU_WIDTH-1:0] data_wr_csr,
    output [`CPU_WIDTH-1:0] data_wr_Rd  
);

assign wr_en_csr = csr_res_en;

assign data_wr_csr = csr_res;

assign data_wr_Rd = load_en ? lsu_res : exu_res;

endmodule //ysyx_23060191_WBU