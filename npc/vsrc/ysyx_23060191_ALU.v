/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-28 00:28:13
 * @LastEditTime : 2024-06-28 13:14:27
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\ysyx_23060191_ALU.v
 * @Description  : ALU计算模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_ALU (
    input [`CPU_WIDTH-1:0] alu_in1,
    input [`CPU_WIDTH-1:0] alu_in2,
    input [`ALU_OPT_WIDTH-1:0] alu_opt_code,

    output reg [`CPU_WIDTH-1:0] alu_res
);

  always @(*) begin
    case (alu_opt_code)
      `ALU_ADD: alu_res = alu_in1 + alu_in2;
      default:  alu_res = 0;
    endcase
  end


endmodule  //ysyx_23060191_ALU
