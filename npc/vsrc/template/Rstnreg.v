/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-25 23:35:27
 * @LastEditTime : 2024-06-28 00:28:56
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\TEMPLATE\Rstnreg.v
 * @Description  : rstn复位信号置零与打拍寄存器
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
module Rstnreg (
    input clk,
    input rstn,

    output rstn_sync
);

  reg rstn_r1, rstn_r2;

  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      rstn_r1 <= 1'b0;
      rstn_r2 <= 1'b0;
    end else begin
      rstn_r1 <= 1'b1;
      rstn_r2 <= rstn_r1;
    end
  end

  assign rstn_sync = rstn_r2;

endmodule  //Rstnreg
