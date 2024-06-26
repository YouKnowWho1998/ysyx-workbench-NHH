/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-20 10:54:15
 * @LastEditTime : 2024-06-26 10:06:05
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\IFU\ysyx_23060191_ADDPC.v
 * @Description  : PC加法器 顺序+4
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_ADDPC (
    input [`CPU_WIDTH-1:0] pc_in_add_before,

    output [`CPU_WIDTH-1:0] pc_out_add_after
);

  assign pc_out_add_after = pc_in_add_before + 4;

endmodule  //ysyx_23060191_ADDPC
