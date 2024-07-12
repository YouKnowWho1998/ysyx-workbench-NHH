/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-27 22:27:11
 * @LastEditTime : 2024-07-12 13:07:36
 * @FilePath     : /ysyx/ysyx-workbench/npc/vsrc/ysyx_23060191_EXU.v
 * @Description  : EXU指令执行模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_EXU (
    input [`CPU_WIDTH-1:0] pc,
    input [`CPU_WIDTH-1:0] data_Rs1,
    input [`CPU_WIDTH-1:0] data_Rs2,
    input [`CPU_WIDTH-1:0] imm,
    input [`EXU_OPT_WIDTH-1:0] exu_opt_code,
    input [`EXU_SEL_WIDTH-1:0] exu_sel_code,

    output reg [`CPU_WIDTH-1:0] exu_res,
    output zero
);

reg [`ALU_OPT_WIDTH-1:0] alu_opt_code;//ALU操作码
wire [`CPU_WIDTH-1:0] alu_in1,alu_in2;//ALU输入in1和in2
wire [`CPU_WIDTH-1:0] alu_res;//ALU计算结果
wire sub_u_bit; //无符号数减法增加的最高位 
reg less;

//alu_in1 四选一选择器
MuxDefaultTemplate #(4,`EXU_SEL_WIDTH,`CPU_WIDTH) mux_alu_in1(alu_in1,exu_sel_code,`CPU_WIDTH'b0,{
    `SEL_PC_AND_4, pc,
    `SEL_PC_AND_IMM, pc,
    `SEL_RS1_AND_IMM, data_Rs1,
    `SEL_RS1_AND_RS2, data_Rs1
});
//alu_in2 四选一选择器
MuxDefaultTemplate #(4,`EXU_SEL_WIDTH,`CPU_WIDTH) mux_alu_in2(alu_in2,exu_sel_code,`CPU_WIDTH'b0,{
    `SEL_PC_AND_4, `CPU_WIDTH'h4,
    `SEL_PC_AND_IMM, imm,
    `SEL_RS1_AND_IMM, imm,
    `SEL_RS1_AND_RS2, data_Rs2
});


  // 请记住：硬件中不区分有符号和无符号，全部按照补码进行运算！
  // 所以 src1 - src2 得到是补码！ 如果src1和src2是有符号数，通过输出最高位就可以判断正负！
  // 如果src1和src2是无符号数，那么就在最高位补0，拓展为有符号数再减法，通过最高位判断正负！

//less指示位 几种特殊情况
always @(*) begin
    if (alu_in2 == {1'b1, {(`CPU_WIDTH-1){1'b0}}}) begin
        less = 0;
    end
    else if(alu_in1 == {1'b1, {(`CPU_WIDTH-1){1'b0}}}) begin
        less = 1;
    end
    else if(~alu_in1[`CPU_WIDTH-1] & alu_in2[`CPU_WIDTH-1]) begin
        less = 0;
    end
    else if(alu_in1[`CPU_WIDTH-1] & ~alu_in2[`CPU_WIDTH-1]) begin
        less = 1;
    end
    else begin
        less = alu_res[`CPU_WIDTH-1];
    end
end

//解析EXU操作码
always @(*) begin
    case (exu_opt_code)
        `EXU_ADD:begin
            alu_opt_code = `ALU_ADD;
            exu_res = alu_res;
        end
        `EXU_SUB:begin
            alu_opt_code = `ALU_SUB;
            exu_res = alu_res;
        end
        `EXU_COMPARE_U:begin
            alu_opt_code = `ALU_SUB_U;
            exu_res = {31'b0, sub_u_bit};
        end
        `EXU_COMPARE:begin
            alu_opt_code = `ALU_SUB;
            exu_res = {31'b0, less};
        end
        `EXU_AND:begin
            alu_opt_code = `ALU_AND;
            exu_res = alu_res;
        end
        `EXU_SRA_I:begin
            alu_opt_code = `ALU_SRA_I;
            exu_res = alu_res;
        end
        `EXU_SRA_R:begin
            alu_opt_code = `ALU_SRA_R;
            exu_res = alu_res;
        end
        `EXU_SLL_I:begin
            alu_opt_code = `ALU_SLL_I;
            exu_res = alu_res;           
        end
        `EXU_SLL_R:begin
            alu_opt_code = `ALU_SLL_R;
            exu_res = alu_res;           
        end
        `EXU_SRL_R:begin
            alu_opt_code = `ALU_SRL_R;
            exu_res = alu_res;           
        end        
        `EXU_SRL_I:begin
            alu_opt_code = `ALU_SRL_I;
            exu_res = alu_res;
        end
        `EXU_XOR:begin
            alu_opt_code = `ALU_XOR;
            exu_res = alu_res;
        end
        `EXU_OR:begin
            alu_opt_code = `ALU_OR;
            exu_res = alu_res;
        end
        `EXU_MUL:begin
            alu_opt_code = `ALU_MUL;
            exu_res = alu_res;            
        end
        `EXU_REM:begin
            alu_opt_code = `ALU_REM;
            exu_res = alu_res;            
        end
        `EXU_REMU:begin
            alu_opt_code = `ALU_REMU;
            exu_res = alu_res;            
        end
        `EXU_DIV:begin
            alu_opt_code = `ALU_DIV;
            exu_res = alu_res;            
        end
        `EXU_DIVU:begin
            alu_opt_code = `ALU_DIVU;
            exu_res = alu_res;            
        end
        `EXU_MULHU:begin
            alu_opt_code = `ALU_MULHU;
            exu_res = alu_res;            
        end
        `EXU_MULH:begin
            alu_opt_code = `ALU_MULH;
            exu_res = alu_res;            
        end
        `EXU_BEQ:begin
            alu_opt_code = `ALU_SUB;
            exu_res[`CPU_WIDTH-1:1] = 31'b0;
            exu_res[0] = ~(|alu_res);
        end 
        `EXU_BNE:begin
            alu_opt_code = `ALU_SUB;
            exu_res[`CPU_WIDTH-1:1] = 31'b0;
            exu_res[0] = (|alu_res);
        end
        `EXU_BGE:begin
            alu_opt_code = `ALU_SUB;
            exu_res[`CPU_WIDTH-1:1] = 31'b0;
            exu_res[0] = ~less;
        end
        `EXU_BGEU:begin
            alu_opt_code = `ALU_SUB_U;
            exu_res[`CPU_WIDTH-1:1] = 31'b0;
            exu_res[0] = ~sub_u_bit;
        end
        `EXU_BLTU:begin
            alu_opt_code = `ALU_SUB_U;
            exu_res[`CPU_WIDTH-1:1] = 31'b0;
            exu_res[0] = sub_u_bit;
        end        
        `EXU_BLT:begin
            alu_opt_code = `ALU_SUB;
            exu_res[`CPU_WIDTH-1:1] = 31'b0;
            exu_res[0] = less;
        end        
        default: begin 
            alu_opt_code = 0;
            exu_res = 0;
        end
    endcase
end

assign zero = ~(|exu_res);

//ALU
ysyx_23060191_ALU alu(
    .alu_in1(alu_in1),
    .alu_in2(alu_in2),
    .alu_opt_code(alu_opt_code),

    .alu_res(alu_res),
    .sub_u_bit(sub_u_bit)
);


endmodule  //ysyx_23060191_EXU
