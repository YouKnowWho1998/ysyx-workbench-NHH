`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060191_defines.v"
module ysyx_23060191_MEM (
    input [`CPU_WIDTH-1:0] addr,  //地址(PC)

    output reg [`CPU_WIDTH-1:0] data  //输出指令
);

  reg [`CPU_WIDTH-1:0] mem [0:4] = {//addi指令格式：12位立即数+5位rs1源寄存器地址+3位Func3码+5位目标寄存器地址+7位opcode识别码
    {12'b0000_0000_0001, `X0, `FUNC3_ADDI, `X18, `TYPE_I},  //0+1= 1(X18)
    {12'b0000_0000_0010, `X0, `FUNC3_ADDI, `X19, `TYPE_I},  //2+0= 2(X19)
    {12'b0000_0000_0100, `X0, `FUNC3_ADDI, `X20, `TYPE_I},  //4+0= 4(X20)
    {12'b0000_0000_1000, `X0, `FUNC3_ADDI, `X21, `TYPE_I},  //8+0= 8(X21)
    `EBREAK
  };

  always @(*) begin
    case (addr)
      'h8000_0000: data = 'h0;
      'h8000_0004: data = mem[0];
      'h8000_0008: data = mem[1];
      'h8000_000c: data = mem[2];
      'h8000_0010: data = mem[3];
      'h8000_0014: data = mem[4];
    endcase
  end

endmodule  //ysyx_23060191_mem
