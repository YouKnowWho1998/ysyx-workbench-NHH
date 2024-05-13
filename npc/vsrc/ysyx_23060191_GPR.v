`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060191_defines.v"

module ysyx_23060191_GPR (
    input [4:0] waddr,  //写入地址
    input [4:0] raddr,  //读取地址
    input [`CPU_WIDTH-1:0] din,  //写入数据

    output reg [`CPU_WIDTH-1:0] dout  //读取数据 
);

  reg [`CPU_WIDTH-1:0] gpr[0:31];

  //初值为0
  integer i;
  always @(*) begin
    for (i = 0; i < 32; i = i + 1) begin
      gpr[i] = 'h0;
    end
  end

  //写入
  always @(*) begin
    case (waddr)
      `X0:  gpr[`X0] = 'h0;
      `X1:  gpr[`X1] = din;
      `X2:  gpr[`X2] = din;
      `X3:  gpr[`X3] = din;
      `X4:  gpr[`X4] = din;
      `X5:  gpr[`X5] = din;
      `X6:  gpr[`X6] = din;
      `X7:  gpr[`X7] = din;
      `X8:  gpr[`X8] = din;
      `X9:  gpr[`X9] = din;
      `X10: gpr[`X10] = din;
      `X11: gpr[`X11] = din;
      `X12: gpr[`X12] = din;
      `X13: gpr[`X13] = din;
      `X14: gpr[`X14] = din;
      `X15: gpr[`X15] = din;
      `X16: gpr[`X16] = din;
      `X17: gpr[`X17] = din;
      `X18: gpr[`X18] = din;
      `X19: gpr[`X19] = din;
      `X20: gpr[`X20] = din;
      `X21: gpr[`X21] = din;
      `X22: gpr[`X22] = din;
      `X23: gpr[`X23] = din;
      `X24: gpr[`X24] = din;
      `X25: gpr[`X25] = din;
      `X26: gpr[`X26] = din;
      `X27: gpr[`X27] = din;
      `X28: gpr[`X28] = din;
      `X29: gpr[`X29] = din;
      `X30: gpr[`X30] = din;
      `X31: gpr[`X31] = din;
    endcase
  end

  //读取
  always @(*) begin
    case (raddr)
      `X0:  dout = gpr[`X0];
      `X1:  dout = gpr[`X1];
      `X2:  dout = gpr[`X2];
      `X3:  dout = gpr[`X3];
      `X4:  dout = gpr[`X4];
      `X5:  dout = gpr[`X5];
      `X6:  dout = gpr[`X6];
      `X7:  dout = gpr[`X7];
      `X8:  dout = gpr[`X8];
      `X9:  dout = gpr[`X9];
      `X10: dout = gpr[`X10];
      `X11: dout = gpr[`X11];
      `X12: dout = gpr[`X12];
      `X13: dout = gpr[`X13];
      `X14: dout = gpr[`X14];
      `X15: dout = gpr[`X15];
      `X16: dout = gpr[`X16];
      `X17: dout = gpr[`X17];
      `X18: dout = gpr[`X18];
      `X19: dout = gpr[`X19];
      `X20: dout = gpr[`X20];
      `X21: dout = gpr[`X21];
      `X22: dout = gpr[`X22];
      `X23: dout = gpr[`X23];
      `X24: dout = gpr[`X24];
      `X25: dout = gpr[`X25];
      `X26: dout = gpr[`X26];
      `X27: dout = gpr[`X27];
      `X28: dout = gpr[`X28];
      `X29: dout = gpr[`X29];
      `X30: dout = gpr[`X30];
      `X31: dout = gpr[`X31];
    endcase
  end


endmodule  //ysyx_23060191_gpr
