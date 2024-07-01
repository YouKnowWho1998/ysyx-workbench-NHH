/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-15 13:00:53
 * @LastEditTime : 2024-07-01 12:02:21
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\defines.v
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


//func3:
`define FUNC3_ADDI 3'b000 //func3 addi
`define FUNC3_SW 3'b010 //func3 sw


//EXU选择器信号
`define EXU_SEL_WIDTH 2
`define SEL_PC_ADD_4 2'b00 //PC+4
`define SEL_PC_ADD_IMM 2'b01 //PC+imm
`define SEL_RS1_ADD_IMM 2'b10 //Rs1+imm
`define SEL_RS1_ADD_RS2 2'b11 //Rs1+Rs2



//EXU操作码
`define EXU_OPT_WIDTH 6
`define EXU_ADD `EXU_OPT_WIDTH'h1 //A+B


//ALU操作码
`define ALU_OPT_WIDTH 6
`define ALU_ADD `EXU_ADD




//LSU操作码
`define LSU_OPT_WIDTH 4
`define LSU_SW 4'b0101 // 010 for FUNC3_SW, 1 for store