`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060191_defines.v"
module ysyx_23060191_DEC (
    input [`CPU_WIDTH-1:0] inst,
    input [`CPU_WIDTH-1:0] rs1_from_gpr,

    output reg [11:0] imm_to_alu,  //12位立即数
    output reg [4:0] rs1_addr_to_gpr,  //5位rs1源寄存器地址
    //output reg [4:0] rs2_addr, //5位rs2源寄存器地址
    output reg [4:0] rd_addr_to_wbu,  //5位目标寄存器地址
    output reg [2:0] ctr_to_alu,  //ALU计算控制码 
    output [`CPU_WIDTH-1:0] rs1_to_alu
);


  //判断opcode类型
  always @(*) begin
    case (inst[6:0])
      `TYPE_I:
      if (inst[14:12] == `FUNC3_ADDI) begin
        imm_to_alu = inst[31:20];
        rs1_addr_to_gpr = inst[19:15];
        rd_addr_to_wbu = inst[11:7];
        ctr_to_alu = `ALU_ADD;
      end
    endcase
  end

  assign rs1_to_alu = rs1_from_gpr;


endmodule  //ysyx_23060191_DEC
