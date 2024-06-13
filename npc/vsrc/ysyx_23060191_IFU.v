`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060191_defines.v"
module ysyx_23060191_IFU (
    input clk,
    input rstn,

    output reg [`CPU_WIDTH-1:0] pc  //输出pc值
);


  always @(posedge clk) begin
    if (!rstn) begin
      pc <= 'h8000_0000;  //pc初始值为h'8000_0000
    end else begin
      pc <= pc + 'h4;
    end
  end



endmodule  //ysyx_23060191_IFU
