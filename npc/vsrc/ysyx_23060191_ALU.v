`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060191_defines.v"
module ysyx_23060191_ALU (
    // input [`CPU_WIDTH-1:0] pc,
    input [`CPU_WIDTH-1:0] op1,
    input [`CPU_WIDTH-1:0] op2,
    input [2:0] ctr,

    output reg [`CPU_WIDTH-1:0] result
);


  always @(*) begin
    case (ctr)
      `ALU_LUI: begin
        result = op2;  // R(rd) = imm
      end
      // `ALU_AUIPC: begin
      //   result = pc + op2;  // R(rd) = s->pc + imm
      // end
      `ALU_ADD: begin
        result = op1 + op2;  // R(rd) = src1 + src2
      end
      `ALU_SUB: begin
        result = op1 - op2;  // R(rd) = src1 - src2
      end
      `ALU_SLL: begin
        result = op1 << op2;  // R(rd) = U64(src1) << BITS(src2, 4, 0)
      end
      `ALU_SLT: begin
        result = (op1 > op2 ? 1 : 0);  // R(rd) = (S64(src1) < S64(src2)) ? 1 : 0
      end
      default result = 'h0;

    endcase
  end





endmodule
