/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-15 13:00:53
 * @LastEditTime : 2024-08-10 11:05:12
 * @FilePath     : /ysyx-workbench/npc/vsrc/defines.v
 * @Description  : CPU设计参数宏定义
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */

//处理器位宽:
`define CPU_WIDTH 32 //32位宽


//opcode：
`define TYPE_U_LUI   7'b0110111 //U型 lui
`define TYPE_U_AUIPC 7'b0010111 //U型 auipc
`define TYPE_J_JAL   7'b1101111 //J型 jal
//I型指令有五种不同的opcode码
`define TYPE_I_JALR         7'b1100111 //I型 jalr
`define TYPE_I_LB_SERIES    7'b0000011 //I型 lb lh lw lbu lhu
`define TYPE_I_ADDI_SERIES  7'b0010011 //I型 addi slti sltiu xori ori andi slli srli srai
`define TYPE_I_FENCE_SERIES 7'b0001111 //I型 fence fence.i
`define TYPE_I_ECALL_SERIES 7'b1110011 //I型 ecall ebreak csrrw csrrs csrrc csrrwi csrrsi csrrci
`define TYPE_S_SERIES 7'b0100011 //S型 sb sh sw
`define TYPE_R_SERIES 7'b0110011 //R型 add sub sll slt sltu xor srl sra or and
`define TYPE_B_SERIES 7'b1100011 //B型 beq bne bge bgeu bltu blt

//ecall & mret
`define ECALL 12'b000000000000 
`define MRET  12'b001100000010 

//func3:
`define FUNC3_ADDI 3'b000 //func3 addi
`define FUNC3_ANDI 3'b111 //func3 andi
`define FUNC3_SLLI 3'b001 //func3 slli
`define FUNC3_SLTIU 3'b011 //func3 sltiu
`define FUNC3_SLTI 3'b010 //func3 slti
`define FUNC3_SW 3'b010 //func3 sw
`define FUNC3_SB 3'b000 //func3 sb
`define FUNC3_SH 3'b001 //func3 sh
`define FUNC3_LW 3'b010 //func3 lw
`define FUNC3_LH 3'b001 //func3 lh
`define FUNC3_LBU 3'b100 //func3 lbu
`define FUNC3_XORI 3'b100 //func3 xori
`define FUNC3_ORI 3'b110 //func3 ori
`define FUNC3_LHU 3'b101 //func3 lhu
`define FUNC3_LB 3'b000 //func3 lb
`define FUNC3_SLT 3'b010 //func3 slt
`define FUNC3_SLTU 3'b011 //func3 sltu
`define FUNC3_XOR 3'b100 //func3 xor
`define FUNC3_OR 3'b110 //func3 or
`define FUNC3_AND 3'b111 //func3 and
`define FUNC3_SLL_SERIES 3'b001 //func3 sll
`define FUNC3_ADD_SERIES 3'b000 //func3 add sub
`define FUNC3_SRI_SERIES 3'b101 //func3 srli srai 
`define FUNC3_SR_SERIES 3'b101 //func3 srl sra
`define FUNC3_REM_SERIES 3'b110 //func3 rem or
`define FUNC3_DIV_SERIES 3'b100 //func3 div xor
`define FUNC3_SLTU_SERIES 3'b011 //func3 sltu mulhu
`define FUNC3_REMU_SERIES 3'b111 //func3 remu and
`define FUNC3_DIVU_SERIES 3'b101 //func3 divu sra srl
`define FUNC3_BEQ 3'b000 //func3 beq
`define FUNC3_BNE 3'b001 //func3 bne
`define FUNC3_BGE 3'b101 //func3 bge
`define FUNC3_BGEU 3'b111 //func3 bgeu
`define FUNC3_BLTU 3'b110 //func3 bltu
`define FUNC3_BLT 3'b100 //func3 blt
`define FUNC3_CSRRW 3'b001 //func3 csrrw
`define FUNC3_CSRRS 3'b010 //func3 csrrs
`define FUNC3_ECALL_AND_MRET 3'b000 //func3 ecall & mret

//func7:
`define FUNC7_SRLI 7'b0
`define FUNC7_SRAI 7'b0100000
`define FUNC7_ADD 7'b0
`define FUNC7_SUB 7'b0100000
`define FUNC7_SRL 7'b0
`define FUNC7_SRA 7'b0100000
`define FUNC7_MUL 7'b0000001
`define FUNC7_REM 7'b0000001
`define FUNC7_OR 7'b0
`define FUNC7_DIV 7'b0000001
`define FUNC7_XOR 7'b0
`define FUNC7_SLTU 7'b0
`define FUNC7_MULHU 7'b0000001
`define FUNC7_REMU 7'b0000001
`define FUNC7_AND 7'b0
`define FUNC7_DIVU 7'b0000001
`define FUNC7_DIVU 7'b0000001
`define FUNC7_SLL 7'b0
`define FUNC7_MULH 7'b0000001

//EXU选择器信号
`define EXU_SEL_WIDTH 2
`define SEL_PC_AND_4 2'b00 //PC 4
`define SEL_PC_AND_IMM 2'b01 //PC imm
`define SEL_RS1_AND_IMM 2'b10 //Rs1 imm
`define SEL_RS1_AND_RS2 2'b11 //Rs1 Rs2

//EXU操作码
`define EXU_OPT_WIDTH 6
`define EXU_ADD `EXU_OPT_WIDTH'h1 //A + B
`define EXU_SUB `EXU_OPT_WIDTH'h2 //A - B
`define EXU_COMPARE_U `EXU_OPT_WIDTH'h3 //无符号数判断大小
`define EXU_AND `EXU_OPT_WIDTH'h4 //A & B
`define EXU_SRA_I `EXU_OPT_WIDTH'h5 //A >> B[5:0]算术 (立即数)
`define EXU_SLL_I `EXU_OPT_WIDTH'h6 //A << B[5:0]逻辑 (立即数)
`define EXU_SRL_I `EXU_OPT_WIDTH'h7 //A >> B[5:0]逻辑 (立即数)
`define EXU_XOR `EXU_OPT_WIDTH'h8 //A ^ B
`define EXU_COMPARE `EXU_OPT_WIDTH'h9 //有符号数判断大小
`define EXU_OR `EXU_OPT_WIDTH'h10 //A | B
`define EXU_SLL_R `EXU_OPT_WIDTH'h11 //A << B[4:0]逻辑 （寄存器）
`define EXU_SRL_R `EXU_OPT_WIDTH'h12 //A >> B[4:0]逻辑 （寄存器）
`define EXU_MUL `EXU_OPT_WIDTH'h13// A * B
`define EXU_REM `EXU_OPT_WIDTH'h14// A % B
`define EXU_DIV `EXU_OPT_WIDTH'h15// A / B
`define EXU_MULHU `EXU_OPT_WIDTH'h16
`define EXU_MULH `EXU_OPT_WIDTH'h17
`define EXU_REMU `EXU_OPT_WIDTH'h18
`define EXU_DIVU `EXU_OPT_WIDTH'h19
`define EXU_SRA_R `EXU_OPT_WIDTH'h20 //A >> B[4:0]算术 （寄存器）
`define EXU_BEQ `EXU_OPT_WIDTH'h21
`define EXU_BNE `EXU_OPT_WIDTH'h22
`define EXU_BGE `EXU_OPT_WIDTH'h23
`define EXU_BGEU `EXU_OPT_WIDTH'h24
`define EXU_BLTU `EXU_OPT_WIDTH'h25
`define EXU_BLT `EXU_OPT_WIDTH'h26
`define EXU_ECALL `EXU_OPT_WIDTH'h27
`define EXU_CSRRS `EXU_OPT_WIDTH'h28
`define EXU_CSRRW `EXU_OPT_WIDTH'h29

//ALU操作码
`define ALU_OPT_WIDTH 6
`define ALU_ADD `ALU_OPT_WIDTH'h1
`define ALU_SUB `ALU_OPT_WIDTH'h2 
`define ALU_SUB_U `ALU_OPT_WIDTH'h3 //无符号数减法
`define ALU_AND `ALU_OPT_WIDTH'h4
`define ALU_SRA_I `ALU_OPT_WIDTH'h5
`define ALU_SLL_I `ALU_OPT_WIDTH'h6
`define ALU_SRL_I `ALU_OPT_WIDTH'h7
`define ALU_XOR `ALU_OPT_WIDTH'h8
`define ALU_OR `ALU_OPT_WIDTH'h9
`define ALU_SLL_R `ALU_OPT_WIDTH'h10
`define ALU_SRL_R `ALU_OPT_WIDTH'h11
`define ALU_MUL `ALU_OPT_WIDTH'h12
`define ALU_REM `ALU_OPT_WIDTH'h13
`define ALU_DIV `ALU_OPT_WIDTH'h14
`define ALU_MULHU `ALU_OPT_WIDTH'h15
`define ALU_MULH `ALU_OPT_WIDTH'h16
`define ALU_REMU `ALU_OPT_WIDTH'h17
`define ALU_DIVU `ALU_OPT_WIDTH'h18
`define ALU_SRA_R `ALU_OPT_WIDTH'h19


//LSU操作码
`define LSU_OPT_WIDTH 4
`define LSU_SW  `LSU_OPT_WIDTH'b0010 // 0 for store
`define LSU_SB  `LSU_OPT_WIDTH'b0110 // 0 for store
`define LSU_SH  `LSU_OPT_WIDTH'b0100 // 0 for store

`define LSU_LW  `LSU_OPT_WIDTH'b0001 // 1 for load
`define LSU_LH  `LSU_OPT_WIDTH'b0011 // 1 for load
`define LSU_LB  `LSU_OPT_WIDTH'b0111 // 1 for load
`define LSU_LBU `LSU_OPT_WIDTH'b0101 // 1 for load
`define LSU_LHU `LSU_OPT_WIDTH'b1101 // 1 for load

//CSR寄存器
`define MSTATUS 12'h300
`define MTVEC   12'h305
`define MCAUSE  12'h342
`define MEPC    12'h341