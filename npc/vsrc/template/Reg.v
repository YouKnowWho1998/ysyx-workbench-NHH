/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-19 21:13:34
 * @LastEditTime : 2024-08-11 15:09:11
 * @FilePath     : /ysyx-workbench/npc/vsrc/template/Reg.v
 * @Description  : ysyx的触发器模板
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
module RegTemplate #(
    WIDTH = 1,
    RESET_VAL = 0
) (
    input clk,
    input rstn,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout,
    input wen
);
  always @(posedge clk) begin
    if (!rstn) dout <= RESET_VAL;
    else if (wen) dout <= din;
  end
endmodule
