`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060191_defines.v"
module ysyx_23060191_WBU (
    input clk,
    input rstn,
    input [`CPU_WIDTH-1:0] res_from_alu,
    input [4:0] rd_addr_from_dec,

    output reg [`CPU_WIDTH-1:0] res_to_gpr,
    output reg [4:0] rd_addr_to_gpr
);

  always @(posedge clk) begin
    if (!rstn) begin
      res_to_gpr <= 'h0;
      rd_addr_to_gpr <= 'h0;
    end else begin
      res_to_gpr <= res_from_alu;
      rd_addr_to_gpr <= rd_addr_from_dec;
    end
  end




endmodule  //ysyx_23060191_WBU
