/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-28 15:46:00
 * @LastEditTime : 2024-06-28 16:40:06
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\ysyx_23060191_WBU.v
 * @Description  : WBU回写模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_WBU (
    input  [`CPU_WIDTH-1:0] exu_res,//EXU计算结果(需要回写)
    input  [`CPU_WIDTH-1:0] lsu_res,
    input  load_en, 

    output [`CPU_WIDTH-1:0] data_wr_Rd  
);

assign data_wr_Rd = load_en ? lsu_res : exu_res;

endmodule //ysyx_23060191_WBU