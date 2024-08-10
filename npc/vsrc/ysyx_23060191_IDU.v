/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-26 10:10:46
 * @LastEditTime : 2024-08-10 11:27:35
 * @FilePath     : /ysyx-workbench/npc/vsrc/ysyx_23060191_IDU.v
 * @Description  : IDU指令译码模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"

module ysyx_23060191_IDU (
    input [`CPU_WIDTH-1:0] i_inst,

    output o_wr_en_Rd,  //Rd寄存器写使能 IDU->GPR
    output [4:0] o_addr_Rd,  //目标寄存器地址 IDU->GPR
    output [4:0] o_addr_Rs1,  //rs1寄存器地址 IDU->GPR
    output [4:0] o_addr_Rs2,  //rs2寄存器地址 IDU->GPR
    output [`CPU_WIDTH-1:0] o_imm, //所有立即数统一扩展至32位 高位填充符号位 IDU->EXU IDU->PCU
    output o_jal_jump_en,  //jal跳转指令使能 IDU->PCU
    output o_jalr_jump_en,  //jalr跳转指令使能 IDU->PCU
    output o_branch_en,  //分支指令使能 IDU->PCU
    output o_ecall_en,  //IDU->PCU
    output o_mret_en,  //IDU->PCU
    output [11:0] o_addr_rd_csr,  //IDU->CSR
    output [11:0] o_addr_wr_csr,  //IDU->CSR
    output [`EXU_OPT_WIDTH-1:0] o_exu_opt_code,  //EXU操作码 IDU->EXU
    output [`LSU_OPT_WIDTH-1:0] o_lsu_opt_code,  //LSU操作码 IDU->LSU
    output [`EXU_SEL_WIDTH-1:0] o_exu_sel_code  //EXU选择码 IDU->EXU
);

  wire [6:0] opcode = i_inst[6:0];  //opcode
  wire [2:0] func3 = i_inst[14:12];  //func3
  wire [6:0] func7 = i_inst[31:25];  //func7
  wire [11:0] func12 = i_inst[31:20];//func12 用于区分ecall和mret指令 也可以作为addr_rd_csr和addr_wr_csr地址的值

  //写地址
  wire [4:0] addr_Rd = i_inst[11:7]; //addr_Rd
  wire [4:0] addr_Rs1 = i_inst[19:15]; //addr_Rs1
  wire [4:0] addr_Rs2 = i_inst[24:20]; //addr_Rs2
  

  //立即数imm
  wire [`CPU_WIDTH-1:0] immI = {{20{i_inst[31]}}, i_inst[31:20]}; //I型立即数
  wire [`CPU_WIDTH-1:0] immU = {i_inst[31:12],12'b0}; //U型立即数 加载在寄存器高二十位
  wire [`CPU_WIDTH-1:0] immS = {{20{i_inst[31]}}, {i_inst[31:25], i_inst[11:7]}}; //S型立即数
  wire [`CPU_WIDTH-1:0] immJ = {{11{i_inst[31]}}, {i_inst[31], i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0}}; //J型立即数
  wire [`CPU_WIDTH-1:0] immB = {{20{i_inst[31]}}, i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0}; //B型立即数


  //-------------------------------------------------注意-----------------------------------------------
  
  //使用工业级verilog范式进行开发
  //data mask写法：yy = {$bits(xx){en}} & xx | ...; en是判断条件, $bits是系统函数：读取此信号位宽数值
  //拒绝在组合逻辑中使用case和if-else等抽象语法，因为会综合出带优先级电路(且不能传播不定态)，这是很不好的！
  //使用assign语句（或与写法）产生无优先级电路！

  //-----------------------------------------------指令译码---------------------------------------------

  //Rd寄存器写入使能
  assign o_wr_en_Rd = (1'b1 & {(opcode==`TYPE_U_LUI)}) |
                      (1'b1 & {(opcode==`TYPE_U_AUIPC)}) |
                      (1'b1 & {(opcode==`TYPE_J_JAL)}) |
                      (1'b1 & {(opcode==`TYPE_I_JALR)}) |
                      (1'b1 & {(opcode==`TYPE_I_LB_SERIES)}) |
                      (1'b1 & {(opcode==`TYPE_I_ADDI_SERIES)}) |
                      (1'b1 & {(opcode==`TYPE_R_SERIES)}) |
                      (1'b1 & {(opcode==`TYPE_I_ECALL_SERIES && (func3==`FUNC3_CSRRS || func3==`FUNC3_CSRRW))});


  //Rd寄存器写入地址
  assign o_addr_Rd =  ({$bits(addr_Rd){(opcode==`TYPE_U_LUI)}} & addr_Rd) |
                      ({$bits(addr_Rd){(opcode==`TYPE_U_AUIPC)}} & addr_Rd) |
                      ({$bits(addr_Rd){(opcode==`TYPE_J_JAL)}} & addr_Rd) |
                      ({$bits(addr_Rd){(opcode==`TYPE_I_JALR)}} & addr_Rd) |
                      ({$bits(addr_Rd){(opcode==`TYPE_I_LB_SERIES)}} & addr_Rd) |
                      ({$bits(addr_Rd){(opcode==`TYPE_I_ADDI_SERIES)}} & addr_Rd) |
                      ({$bits(addr_Rd){(opcode==`TYPE_R_SERIES)}} & addr_Rd) |
                      ({$bits(addr_Rd){(opcode==`TYPE_I_ECALL_SERIES && (func3==`FUNC3_CSRRS || func3==`FUNC3_CSRRW))}} & addr_Rd);


//Rs1寄存器写入地址
assign o_addr_Rs1 = ({$bits(addr_Rs1){(opcode==`TYPE_I_JALR)}} & addr_Rs1) |
                    ({$bits(addr_Rs1){(opcode==`TYPE_I_LB_SERIES)}} & addr_Rs1) |
                    ({$bits(addr_Rs1){(opcode==`TYPE_I_ADDI_SERIES)}} & addr_Rs1) |
                    ({$bits(addr_Rs1){(opcode==`TYPE_S_SERIES)}} & addr_Rs1) |                    
                    ({$bits(addr_Rs1){(opcode==`TYPE_R_SERIES)}} & addr_Rs1) |                    
                    ({$bits(addr_Rs1){(opcode==`TYPE_B_SERIES)}} & addr_Rs1) |  
                     //定向读取a5寄存器的值至mcause寄存器中                 
                    ({$bits(addr_Rs1){(opcode==`TYPE_I_ECALL_SERIES && func3==`FUNC3_ECALL_AND_MRET && func12==`ECALL)}} & 5'd15) |                    
                    ({$bits(addr_Rs1){(opcode==`TYPE_I_ECALL_SERIES && (func3==`FUNC3_CSRRS || func3==`FUNC3_CSRRW))}} & addr_Rs1);    


//Rs2寄存器写入地址
assign o_addr_Rs2 = ({$bits(addr_Rs2){(opcode==`TYPE_S_SERIES)}} & addr_Rs2) |
                    ({$bits(addr_Rs2){(opcode==`TYPE_B_SERIES)}} & addr_Rs2) |
                    ({$bits(addr_Rs2){(opcode==`TYPE_R_SERIES)}} & addr_Rs2);


//imm立即数
assign o_imm = ({$bits(immU){(opcode==`TYPE_U_LUI || opcode==`TYPE_U_AUIPC)}} & immU) |
                ({$bits(immJ){(opcode==`TYPE_J_JAL)}} & immJ) |
                ({$bits(immI){(opcode==`TYPE_I_JALR || opcode==`TYPE_I_ADDI_SERIES || opcode==`TYPE_I_LB_SERIES)}} & immI) |
                ({$bits(immS){(opcode==`TYPE_S_SERIES)}} & immS) |
                ({$bits(immB){(opcode==`TYPE_B_SERIES)}} & immB);


//jal_jump_en使能
assign o_jal_jump_en = {(opcode==`TYPE_J_JAL)} & 1'b1;

//jalr_jump_en使能
assign o_jalr_jump_en = {(opcode==`TYPE_I_JALR)} & 1'b1;

//branch_en使能
assign o_branch_en = {(opcode==`TYPE_B_SERIES)} & 1'b1;

//ecall_en使能
assign o_ecall_en = {(opcode==`TYPE_I_ECALL_SERIES && func3==`FUNC3_ECALL_AND_MRET && func12==`ECALL)} & 1'b1;

//mret_en使能
assign o_mret_en = {(opcode==`TYPE_I_ECALL_SERIES && func3==`FUNC3_ECALL_AND_MRET && func12==`MRET)} & 1'b1;

//addr_rd_csr CSR寄存器读地址 
assign o_addr_rd_csr =  {$bits(func12){(opcode==`TYPE_I_ECALL_SERIES && (func3==`FUNC3_CSRRS || func3==`FUNC3_CSRRW))}} & func12; 

//addr_wr_csr CSR寄存器写地址 
assign o_addr_wr_csr =  {$bits(func12){(opcode==`TYPE_I_ECALL_SERIES && (func3==`FUNC3_CSRRS || func3==`FUNC3_CSRRW))}} & func12; 

//exu_opt_code EXU操作码
assign o_exu_opt_code = ({$bits(o_exu_opt_code){(opcode==`TYPE_I_ECALL_SERIES && func3==`FUNC3_ECALL_AND_MRET && func12==`ECALL)}} & `EXU_ECALL) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_I_ECALL_SERIES && func3 ==`FUNC3_CSRRS)}} & `EXU_CSRRS) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_I_ECALL_SERIES && func3==`FUNC3_CSRRW)}} & `EXU_CSRRW) |
                        ({$bits(o_exu_opt_code){((opcode==`TYPE_I_ADDI_SERIES && func3 ==`FUNC3_SLTIU) || (opcode==`TYPE_R_SERIES && func3==`FUNC3_SLTU_SERIES &&func7==`FUNC7_SLTU))}} & `EXU_COMPARE_U) |
                        ({$bits(o_exu_opt_code){((opcode==`TYPE_I_ADDI_SERIES && func3 ==`FUNC3_SLTI) || (opcode==`TYPE_R_SERIES && func3==`FUNC3_SLT))}} & `EXU_COMPARE) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_I_ADDI_SERIES && func3 ==`FUNC3_SLLI)}} & `EXU_SLL_I) |
                        ({$bits(o_exu_opt_code){((opcode==`TYPE_I_ADDI_SERIES && func3 ==`FUNC3_XORI) || (opcode==`TYPE_R_SERIES && func3==`FUNC3_DIV_SERIES &&func7==`FUNC7_XOR))}} & `EXU_XOR) |
                        ({$bits(o_exu_opt_code){((opcode==`TYPE_I_ADDI_SERIES && func3 ==`FUNC3_ORI) || (opcode==`TYPE_R_SERIES && func3==`FUNC3_REM_SERIES &&func7==`FUNC7_OR))}} & `EXU_OR) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_I_ADDI_SERIES && func3 ==`FUNC3_SRI_SERIES && func7==`FUNC7_SRAI)}} & `EXU_SRA_I) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_I_ADDI_SERIES && func3 ==`FUNC3_SRI_SERIES && func7==`FUNC7_SRLI)}} & `EXU_SRL_I) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_B_SERIES && func3==`FUNC3_BEQ)}}  & `EXU_BEQ) | 
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_B_SERIES && func3==`FUNC3_BNE)}}  & `EXU_BNE) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_B_SERIES && func3==`FUNC3_BGE)}}  & `EXU_BGE) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_B_SERIES && func3==`FUNC3_BGEU)}} & `EXU_BGEU) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_B_SERIES && func3==`FUNC3_BLTU)}} & `EXU_BLTU) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_B_SERIES && func3==`FUNC3_BLT)}}  & `EXU_BLT) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_R_SERIES && func3==`FUNC3_ADD_SERIES  && func7==`FUNC7_SUB)}}   & `EXU_SUB) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_R_SERIES && func3==`FUNC3_ADD_SERIES  && func7==`FUNC7_MUL)}}   & `EXU_MUL) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_R_SERIES && func3==`FUNC3_REM_SERIES  && func7==`FUNC7_REM)}}   & `EXU_REM) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_R_SERIES && func3==`FUNC3_DIV_SERIES  && func7==`FUNC7_DIV)}}   & `EXU_DIV) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_R_SERIES && func3==`FUNC3_SLTU_SERIES && func7==`FUNC7_MULHU)}} & `EXU_MULHU) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_R_SERIES && func3==`FUNC3_REMU_SERIES && func7==`FUNC7_REMU)}}  & `EXU_REMU) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_R_SERIES && func3==`FUNC3_DIVU_SERIES && func7==`FUNC7_DIVU)}}  & `EXU_DIVU) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_R_SERIES && func3==`FUNC3_DIVU_SERIES && func7==`FUNC7_SRA)}}   & `EXU_SRA_R) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_R_SERIES && func3==`FUNC3_DIVU_SERIES && func7==`FUNC7_SRL)}}   & `EXU_SRL_R) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_R_SERIES && func3==`FUNC3_SLL_SERIES  && func7==`FUNC7_SLL)}}   & `EXU_SLL_R) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_R_SERIES && func3==`FUNC3_SLL_SERIES  && func7==`FUNC7_MULH)}}  & `EXU_MULH) |
                        ({$bits(o_exu_opt_code){((opcode==`TYPE_I_ADDI_SERIES && func3==`FUNC3_ANDI) || (opcode==`TYPE_R_SERIES && func3==`FUNC3_REMU_SERIES &&     func7==`FUNC7_AND))}} & `EXU_AND) |
                        ({$bits(o_exu_opt_code){(opcode==`TYPE_U_LUI || opcode==`TYPE_U_AUIPC || opcode==`TYPE_J_JAL || opcode==`TYPE_I_JALR || (opcode==`TYPE_I_ADDI_SERIES && func3==`FUNC3_ADDI) || opcode==`TYPE_I_LB_SERIES || opcode==`TYPE_S_SERIES || (opcode==`TYPE_R_SERIES && func3==`FUNC3_ADD_SERIES && func7==`FUNC7_ADD))}} & `EXU_ADD);


//lsu_opt_code LSU操作码
assign o_lsu_opt_code = {$bits(o_lsu_opt_code){(opcode==`TYPE_I_LB_SERIES && func3==`FUNC3_LW)}} & `LSU_LW |
                        {$bits(o_lsu_opt_code){(opcode==`TYPE_I_LB_SERIES && func3==`FUNC3_LH)}} & `LSU_LH |
                        {$bits(o_lsu_opt_code){(opcode==`TYPE_I_LB_SERIES && func3==`FUNC3_LB)}} & `LSU_LB |
                        {$bits(o_lsu_opt_code){(opcode==`TYPE_I_LB_SERIES && func3==`FUNC3_LBU)}} & `LSU_LBU |
                        {$bits(o_lsu_opt_code){(opcode==`TYPE_I_LB_SERIES && func3==`FUNC3_LHU)}} & `LSU_LHU |
                        {$bits(o_lsu_opt_code){(opcode==`TYPE_S_SERIES && func3==`FUNC3_SW)}} & `LSU_SW |
                        {$bits(o_lsu_opt_code){(opcode==`TYPE_S_SERIES && func3==`FUNC3_SB)}} & `LSU_SB |
                        {$bits(o_lsu_opt_code){(opcode==`TYPE_S_SERIES && func3==`FUNC3_SH)}} & `LSU_SH ;


//exu_sel_code EXU选择码（控制内部两个选择器）
assign o_exu_sel_code = {$bits(o_exu_sel_code){(opcode==`TYPE_J_JAL || opcode==`TYPE_I_JALR)}} & `SEL_PC_AND_4 |
                        {$bits(o_exu_sel_code){(opcode==`TYPE_U_AUIPC)}} & `SEL_PC_AND_IMM |
                        {$bits(o_exu_sel_code){(opcode==`TYPE_U_LUI || opcode==`TYPE_I_ADDI_SERIES || opcode==`TYPE_I_LB_SERIES || opcode==`TYPE_S_SERIES)}} & `SEL_RS1_AND_IMM |
                        {$bits(o_exu_sel_code){(opcode==`TYPE_B_SERIES || opcode==`TYPE_R_SERIES)}} & `SEL_RS1_AND_RS2 ;

endmodule  //ysyx_23060191_IDU
