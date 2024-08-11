/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-27 22:27:11
 * @LastEditTime : 2024-08-11 10:41:41
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_EXU.v
 * @Description  : EXU指令执行模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_EXU (
    input [`CPU_WIDTH-1:0] i_pc,
    input [`CPU_WIDTH-1:0] i_data_Rs1,
    input [`CPU_WIDTH-1:0] i_data_Rs2,
    input [`CPU_WIDTH-1:0] i_imm,
    input [`CPU_WIDTH-1:0] i_data_rd_csr,//CSR->EXU
    input [`EXU_OPT_WIDTH-1:0] i_exu_opt_code,
    input [`EXU_SEL_WIDTH-1:0] i_exu_sel_code,

    output [`CPU_WIDTH-1:0] o_exu_res,
    output [`CPU_WIDTH-1:0] o_csr_res,  //EXU->WBU
    output o_csr_res_en,  //EXU->WBU 
    output o_zero
);


  wire [`ALU_OPT_WIDTH-1:0] alu_opt_code;  //ALU操作码
  wire [`CPU_WIDTH-1:0] alu_in1, alu_in2;  //ALU输入in1和in2
  wire [`CPU_WIDTH-1:0] alu_res;  //ALU计算结果
  wire sub_u_bit;  //无符号数减法增加的最高位 
  wire less;

//-----------------------------------------------两个四选一选择器----------------------------------------
  //alu_in1 四选一选择器
  MuxDefaultTemplate #(4, `EXU_SEL_WIDTH, `CPU_WIDTH) mux_alu_in1 (
      alu_in1,
      i_exu_sel_code,
      `CPU_WIDTH'b0,
      {
        `SEL_PC_AND_4,
        i_pc,
        `SEL_PC_AND_IMM,
        i_pc,
        `SEL_RS1_AND_IMM,
        i_data_Rs1,
        `SEL_RS1_AND_RS2,
        i_data_Rs1
      }
  );
  //alu_in2 四选一选择器
  MuxDefaultTemplate #(4, `EXU_SEL_WIDTH, `CPU_WIDTH) mux_alu_in2 (
      alu_in2,
      i_exu_sel_code,
      `CPU_WIDTH'b0,
      {
        `SEL_PC_AND_4,
        `CPU_WIDTH'h4,
        `SEL_PC_AND_IMM,
        i_imm,
        `SEL_RS1_AND_IMM,
        i_imm,
        `SEL_RS1_AND_RS2,
        i_data_Rs2
      }
  );
//-------------------------------------------------------------------------------------------------------

  // 请记住：硬件中不区分有符号和无符号，全部按照补码进行运算！
  // 所以 src1 - src2 得到是补码！ 如果src1和src2是有符号数，通过输出最高位就可以判断正负！
  // 如果src1和src2是无符号数，那么就在最高位补0，拓展为有符号数再减法，通过最高位判断正负！


  //less指示位 几种特殊情况
  assign less = (alu_in2 == {1'b1,{(`CPU_WIDTH-1){1'b0}}})       ? 1'b0 :
                (alu_in1 == {1'b1,{(`CPU_WIDTH-1){1'b0}}})       ? 1'b1 :
                (~alu_in1[`CPU_WIDTH-1] & alu_in2[`CPU_WIDTH-1]) ? 1'b0 :
                (alu_in1[`CPU_WIDTH-1] & ~alu_in2[`CPU_WIDTH-1]) ? 1'b1 :
                alu_res[`CPU_WIDTH-1];
  

  //alu_opt_code ALU控制码
  assign alu_opt_code = ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_ADD)}} & `ALU_ADD) |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_SUB || i_exu_opt_code==`EXU_COMPARE || i_exu_opt_code==`EXU_BEQ || i_exu_opt_code==`EXU_BNE || i_exu_opt_code==`EXU_BGE || i_exu_opt_code==`EXU_BLT)}} & `ALU_SUB) |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_COMPARE_U || i_exu_opt_code==`EXU_BGEU || i_exu_opt_code==`EXU_BLTU)}} & `ALU_SUB_U) |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_AND)}}   & `ALU_AND)   |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_SRA_I)}} & `ALU_SRA_I) |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_SRA_R)}} & `ALU_SRA_R) |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_SLL_I)}} & `ALU_SLL_I) |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_SLL_R)}} & `ALU_SLL_R) |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_SRL_R)}} & `ALU_SRL_R) |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_SRL_I)}} & `ALU_SRL_I) |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_XOR)}}   & `ALU_XOR)   |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_OR)}}    & `ALU_OR)    |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_MUL)}}   & `ALU_MUL)   |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_REM)}}   & `ALU_REM)   |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_REMU)}}  & `ALU_REMU)  |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_DIV)}}   & `ALU_DIV)   |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_DIVU)}}  & `ALU_DIVU)  |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_MULHU)}} & `ALU_MULHU) |
                        ({$bits(alu_opt_code){(i_exu_opt_code==`EXU_MULH)}}  & `ALU_MULH)  ;


//exu_res计算结果
assign o_exu_res = ({$bits(o_exu_res){(i_exu_opt_code==`EXU_CSRRS || i_exu_opt_code==`EXU_CSRRW)}} & i_data_rd_csr) |
                  ({$bits(o_exu_res){(i_exu_opt_code==`EXU_ADD || i_exu_opt_code==`EXU_SUB || i_exu_opt_code==`EXU_AND || i_exu_opt_code==`EXU_SRA_I || i_exu_opt_code==`EXU_SRA_R || i_exu_opt_code==`EXU_SLL_I || i_exu_opt_code==`EXU_SLL_R || i_exu_opt_code==`EXU_SRL_R || i_exu_opt_code==`EXU_SRL_I || i_exu_opt_code==`EXU_XOR   || i_exu_opt_code==`EXU_OR    || i_exu_opt_code==`EXU_MUL   || i_exu_opt_code==`EXU_REM   || i_exu_opt_code==`EXU_REMU  || i_exu_opt_code==`EXU_DIV   || i_exu_opt_code==`EXU_DIVU  || i_exu_opt_code==`EXU_MULHU || i_exu_opt_code==`EXU_MULH)}} & alu_res)          |
                  ({$bits(o_exu_res){(i_exu_opt_code==`EXU_COMPARE_U)}} & {31'b0,sub_u_bit})     |
                  ({$bits(o_exu_res){(i_exu_opt_code==`EXU_COMPARE)}}   & {31'b0,less})          |
                  ({$bits(o_exu_res){(i_exu_opt_code==`EXU_BEQ)}}       & {31'b0,{~(|alu_res)}}) |
                  ({$bits(o_exu_res){(i_exu_opt_code==`EXU_BNE)}}       & {31'b0,{|alu_res}})    |
                  ({$bits(o_exu_res){(i_exu_opt_code==`EXU_BGE)}}       & {31'b0,{~less}})       |
                  ({$bits(o_exu_res){(i_exu_opt_code==`EXU_BGEU)}}      & {31'b0,{~sub_u_bit}})  |
                  ({$bits(o_exu_res){(i_exu_opt_code==`EXU_BLTU)}}      & {31'b0,{sub_u_bit}})   |
                  ({$bits(o_exu_res){(i_exu_opt_code==`EXU_BLT)}}       & {31'b0,{less}})        ;


//csr_res
assign o_csr_res = ({$bits(o_csr_res){(i_exu_opt_code==`EXU_ECALL)}} & i_pc) |
                   ({$bits(o_csr_res){(i_exu_opt_code==`EXU_CSRRS)}} & (i_data_rd_csr | i_data_Rs1)) |
                   ({$bits(o_csr_res){(i_exu_opt_code==`EXU_CSRRW)}} & (i_data_Rs1));


//csr_res_en
assign o_csr_res_en = ({$bits(o_csr_res_en){(i_exu_opt_code==`EXU_CSRRS)}} & 1'b1) |
                      ({$bits(o_csr_res_en){(i_exu_opt_code==`EXU_CSRRW)}} & 1'b1) ;

//zero
assign o_zero = ~(|o_exu_res);


//ALU
  ysyx_23060191_ALU alu (
      .i_alu_in1(alu_in1),
      .i_alu_in2(alu_in2),
      .i_alu_opt_code(alu_opt_code),

      .o_alu_res  (alu_res),
      .o_sub_u_bit(sub_u_bit)
  );


endmodule  //ysyx_23060191_EXU
