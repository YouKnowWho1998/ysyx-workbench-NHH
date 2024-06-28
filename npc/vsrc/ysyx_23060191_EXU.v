/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-27 22:27:11
 * @LastEditTime : 2024-06-28 17:05:33
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\ysyx_23060191_EXU.v
 * @Description  : EXU指令执行模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_EXU (
    input [`CPU_WIDTH-1:0] pc,
    input [`CPU_WIDTH-1:0] data_Rs1,
    input [`CPU_WIDTH-1:0] data_Rs2,
    input [`CPU_WIDTH-1:0] imm,
    input [`EXU_OPT_WIDTH-1:0] exu_opt_code,
    input [`EXU_SEL_WIDTH-1:0] exu_sel_code,

    output reg [`CPU_WIDTH-1:0] exu_res
);

wire [`ALU_OPT_WIDTH-1:0] alu_opt_code;//ALU操作码
wire [`CPU_WIDTH-1:0] alu_in1,alu_in2;//ALU输入in1和in2
wire [`CPU_WIDTH-1:0] alu_res;//ALU计算结果

//alu_in1 四选一选择器
MuxDefaultTemplate #(4,`EXU_SEL_WIDTH,`CPU_WIDTH) mux_alu_in1(alu_in1,exu_sel_code,`CPU_WIDTH'b0,{
    `SEL_PC_ADD_4, `CPU_WIDTH'h4,
    `SEL_PC_ADD_IMM, imm,
    `SEL_RS1_ADD_IMM, imm,
    `SEL_RS1_ADD_RS2, data_Rs2
});

//alu_in2 四选一选择器
MuxDefaultTemplate #(4,`EXU_SEL_WIDTH,`CPU_WIDTH) mux_alu_in2(alu_in2,exu_sel_code,`CPU_WIDTH'b0,{
    `SEL_PC_ADD_4, pc,
    `SEL_PC_ADD_IMM, pc,
    `SEL_RS1_ADD_IMM, data_Rs1,
    `SEL_RS1_ADD_RS2, data_Rs1
});

//分析EXU操作码
always @(*) begin
    case (exu_opt_code)
        `EXU_ADD:begin
            alu_opt_code = `ALU_ADD;
            exu_res = alu_res;
        end
        default:begin 
            exu_res = 0;
        end
    endcase
end

//ALU
ysyx_23060191_ALU alu(
    .alu_in1(alu_in1),
    .alu_in2(alu_in2),
    .alu_opt_code(alu_opt_code),

    .alu_res(alu_res)
);


endmodule  //ysyx_23060191_EXU
