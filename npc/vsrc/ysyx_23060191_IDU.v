/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-26 10:10:46
 * @LastEditTime : 2024-07-06 11:49:25
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\ysyx_23060191_IDU.v
 * @Description  : IDU指令译码模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/home/nhh/ysyx/ysyx-workbench/npc/vsrc/defines.v"

module ysyx_23060191_IDU (
    input [`CPU_WIDTH-1:0] inst,

    output reg wr_en_Rd,  //Rd寄存器写使能 IDU->GPR
    output reg [4:0] addr_Rd,  //目标寄存器地址 IDU->GPR
    output reg [4:0] addr_Rs1,  //rs1寄存器地址 IDU->GPR
    output reg [4:0] addr_Rs2,  //rs2寄存器地址 IDU->GPR
    output reg [`CPU_WIDTH-1:0] imm, //所有立即数统一扩展至32位 高位填充符号位 IDU->EXU IDU->PCU
    output reg jal_jump_en,  //jal跳转指令使能 IDU->PCU
    output reg jalr_jump_en,  //jalr跳转指令使能 IDU->PCU
    output reg branch_en,  //分支指令使能 IDU->PCU
    output reg [`EXU_OPT_WIDTH-1:0] exu_opt_code,  //EXU操作码 IDU->EXU
    output reg [`LSU_OPT_WIDTH-1:0] lsu_opt_code,  //LSU操作码 IDU->LSU
    output reg [`EXU_SEL_WIDTH-1:0] exu_sel_code  //EXU选择码 IDU->EXU
);

  wire [6:0] opcode = inst[6:0];  //opcode
  wire [2:0] func3 = inst[14:12];  //func3
  wire [6:0] func7 = inst[31:25];  //func7

  //指令解码 分离出立即数和寄存器地址
  /* verilator lint_off CASEINCOMPLETE */
  always @(*) begin
    imm = 0;
    addr_Rd = 0;
    addr_Rs1 = 0;
    jal_jump_en = 0;
    jalr_jump_en = 0;
    branch_en = 0;
    wr_en_Rd = 0;
    exu_opt_code = 0;
    lsu_opt_code = `LSU_NOP;
    exu_sel_code = 0;
    case (opcode)
      `TYPE_U_LUI: begin  //lui指令:R(rd) = X0 + imm
        imm = {inst[31:12], 12'b0};  //U型立即数 加载在寄存器高20位
        addr_Rd = inst[11:7];
        addr_Rs1 = 0;  //X0寄存器
        wr_en_Rd = 1;
        exu_opt_code = `EXU_ADD;
        exu_sel_code = `SEL_RS1_AND_IMM;
      end
      `TYPE_U_AUIPC: begin  //auipc指令:R(rd) = pc + imm
        imm = {inst[31:12], 12'b0};  //U型立即数 加载在寄存器高20位
        addr_Rd = inst[11:7];
        wr_en_Rd = 1;
        exu_opt_code = `EXU_ADD;
        exu_sel_code = `SEL_PC_AND_IMM;
      end
      `TYPE_J_JAL: begin  //jal指令:R(rd) = pc + 4; pc = pc + imm
        imm = {{11{inst[31]}}, {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}};
        addr_Rd = inst[11:7];
        jal_jump_en = 1;
        wr_en_Rd = 1;
        exu_opt_code = `EXU_ADD;
        exu_sel_code = `SEL_PC_AND_4;
      end
      `TYPE_I_JALR: begin  //jalr指令:R(rd) = pc + 4; pc = src1 + imm
        imm = {{20{inst[31]}}, inst[31:20]};
        addr_Rd = inst[11:7];
        addr_Rs1 = inst[19:15];
        jalr_jump_en = 1;
        wr_en_Rd = 1;
        exu_opt_code = `EXU_ADD;
        exu_sel_code = `SEL_PC_AND_4;
      end
      `TYPE_I_ADDI_SERIES: begin
        case (func3)
          `FUNC3_ADDI: begin  //addi指令:R(rd) = src1 + imm
            imm = {{20{inst[31]}}, inst[31:20]};
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_ADD;
            exu_sel_code = `SEL_RS1_AND_IMM;
          end
          `FUNC3_SLTIU: begin  //sltiu指令：R(rd) = src1 < imm 无符号数判断大小
            imm = {{20{inst[31]}}, inst[31:20]};
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_COMPARE_U;
            exu_sel_code = `SEL_RS1_AND_IMM;
          end
          `FUNC3_SLTI: begin  //slti指令：R(rd) = src1 < imm 有符号数判断大小
            imm = {{20{inst[31]}}, inst[31:20]};
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_COMPARE;
            exu_sel_code = `SEL_RS1_AND_IMM;
          end
          `FUNC3_ANDI: begin  //andi指令：R(rd) = src1 & imm
            imm = {{20{inst[31]}}, inst[31:20]};
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_AND;
            exu_sel_code = `SEL_RS1_AND_IMM;
          end
          `FUNC3_SLLI: begin  //slli指令：R(rd) = src1 << BITS(imm, 5, 0) 逻辑左移（补0）
            imm = {27'b0, inst[24:20]};
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_SLL_I;
            exu_sel_code = `SEL_RS1_AND_IMM;
          end
          `FUNC3_XORI: begin  //xori指令：R(rd) = src1 ^ imm
            imm = {{20{inst[31]}}, inst[31:20]};
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_XOR;
            exu_sel_code = `SEL_RS1_AND_IMM;
          end
          `FUNC3_ORI: begin  //ori指令：R(rd) = src1 | imm
            imm = {{20{inst[31]}}, inst[31:20]};
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_OR;
            exu_sel_code = `SEL_RS1_AND_IMM;
          end
          `FUNC3_SRI_SERIES:
          case (func7)
            `FUNC7_SRAI: begin//srai指令：R(rd) = src1 >> BITS(imm, 5, 0) 算数右移（补符号位）
              imm = {27'b0, inst[24:20]};
              addr_Rs1 = inst[19:15];
              addr_Rd = inst[11:7];
              wr_en_Rd = 1;
              exu_opt_code = `EXU_SRA_I;
              exu_sel_code = `SEL_RS1_AND_IMM;
            end
            `FUNC7_SRLI: begin  //srli指令：R(rd) = src1 >> BITS(imm, 5, 0) 逻辑右移（补0）
              imm = {27'b0, inst[24:20]};
              addr_Rs1 = inst[19:15];
              addr_Rd = inst[11:7];
              wr_en_Rd = 1;
              exu_opt_code = `EXU_SRL_I;
              exu_sel_code = `SEL_RS1_AND_IMM;
            end
          endcase
        endcase
      end
      `TYPE_I_LB_SERIES: begin
        case (func3)
          `FUNC3_LW: begin  //lw指令:R(rd) = Mr(src1 + imm, 4) src1+imm是内存读取地址
            imm = {{20{inst[31]}}, inst[31:20]};
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_ADD;
            exu_sel_code = `SEL_RS1_AND_IMM;
            lsu_opt_code = `LSU_LW;
          end
          `FUNC3_LH: begin  //lw指令:R(rd) = Mr(src1 + imm, 16) src1+imm是内存读取地址
            imm = {{20{inst[31]}}, inst[31:20]};
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_ADD;
            exu_sel_code = `SEL_RS1_AND_IMM;
            lsu_opt_code = `LSU_LH;
          end
          `FUNC3_LB: begin  //lb指令:R(rd) = Mr(src1 + imm, 1) 单字节有符号数
            imm = {{20{inst[31]}}, inst[31:20]};
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_ADD;
            exu_sel_code = `SEL_RS1_AND_IMM;
            lsu_opt_code = `LSU_LB;
          end
          `FUNC3_LBU: begin  //lbu指令:R(rd) = Mr(src1 + imm, 1) 单字节无符号数
            imm = {{20{inst[31]}}, inst[31:20]};
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_ADD;
            exu_sel_code = `SEL_RS1_AND_IMM;
            lsu_opt_code = `LSU_LBU;
          end
          `FUNC3_LHU: begin  //lhu指令：R(rd) = SEXT(Mr(src1 + imm, 2), 16) 双字节无符号数
            imm = {{20{inst[31]}}, inst[31:20]};
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_ADD;
            exu_sel_code = `SEL_RS1_AND_IMM;
            lsu_opt_code = `LSU_LHU;
          end
        endcase
      end
      `TYPE_S_SERIES: begin
        case (func3)
          `FUNC3_SW : begin  //sw指令:Mw(src1 + imm, 4, src2)) src1+imm是内存写入地址 src2是写入值
            imm = {{20{inst[31]}}, {inst[31:25], inst[11:7]}};
            addr_Rs1 = inst[19:15];
            addr_Rs2 = inst[24:20];
            exu_opt_code = `EXU_ADD;
            exu_sel_code = `SEL_RS1_AND_IMM;
            lsu_opt_code = `LSU_SW;
          end
          `FUNC3_SB : begin  //sb指令:Mw(src1 + imm, 1, BITS(src2, 7, 0)) src1+imm是内存写入地址 src2是写入值 单字节
            imm = {{20{inst[31]}}, {inst[31:25], inst[11:7]}};
            addr_Rs1 = inst[19:15];
            addr_Rs2 = inst[24:20];
            exu_opt_code = `EXU_ADD;
            exu_sel_code = `SEL_RS1_AND_IMM;
            lsu_opt_code = `LSU_SB;
          end
          `FUNC3_SH : begin  //sb指令:Mw(src1 + imm, 1, BITS(src2, 15, 0)) src1+imm是内存写入地址 src2是写入值 双字节
            imm = {{20{inst[31]}}, {inst[31:25], inst[11:7]}};
            addr_Rs1 = inst[19:15];
            addr_Rs2 = inst[24:20];
            exu_opt_code = `EXU_ADD;
            exu_sel_code = `SEL_RS1_AND_IMM;
            lsu_opt_code = `LSU_SH;
          end
        endcase
      end
      `TYPE_B_SERIES: begin
        case (func3)
          `FUNC3_BEQ: begin
            branch_en = 1;
            imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            addr_Rs1 = inst[19:15];
            addr_Rs2 = inst[24:20];
            exu_opt_code = `EXU_BEQ;
            exu_sel_code = `SEL_RS1_AND_RS2;
          end
          `FUNC3_BNE: begin
            branch_en = 1;
            imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            addr_Rs1 = inst[19:15];
            addr_Rs2 = inst[24:20];
            exu_opt_code = `EXU_BNE;
            exu_sel_code = `SEL_RS1_AND_RS2;
          end
          `FUNC3_BGE: begin
            branch_en = 1;
            imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            addr_Rs1 = inst[19:15];
            addr_Rs2 = inst[24:20];
            exu_opt_code = `EXU_BGE;
            exu_sel_code = `SEL_RS1_AND_RS2;
          end
          `FUNC3_BGEU: begin
            branch_en = 1;
            imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            addr_Rs1 = inst[19:15];
            addr_Rs2 = inst[24:20];
            exu_opt_code = `EXU_BGEU;
            exu_sel_code = `SEL_RS1_AND_RS2;
          end
          `FUNC3_BLTU: begin
            branch_en = 1;
            imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            addr_Rs1 = inst[19:15];
            addr_Rs2 = inst[24:20];
            exu_opt_code = `EXU_BLTU;
            exu_sel_code = `SEL_RS1_AND_RS2;
          end
          `FUNC3_BLT: begin
            branch_en = 1;
            imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            addr_Rs1 = inst[19:15];
            addr_Rs2 = inst[24:20];
            exu_opt_code = `EXU_BLT;
            exu_sel_code = `SEL_RS1_AND_RS2;
          end
        endcase
      end
      `TYPE_R_SERIES: begin
        case (func3)
          `FUNC3_ADD_SERIES: begin
            case (func7)
              `FUNC7_ADD: begin  //add指令：R(rd) = src1 + src2
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_ADD;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
              `FUNC7_SUB: begin  //sub指令：R(rd) = src1 - src2
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_SUB;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
              `FUNC7_MUL: begin  //mul指令：R(rd) = src1 * src2
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_MUL;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
            endcase
          end
          `FUNC3_REM_SERIES: begin
            case (func7)
              `FUNC7_REM: begin  //rem指令：R(rd) = src1 % src2
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_REM;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
              `FUNC7_OR: begin  //or指令：R(rd) = src1 | src2
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_OR;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
            endcase
          end
          `FUNC3_DIV_SERIES: begin
            case (func7)
              `FUNC7_DIV: begin
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_DIV;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
              `FUNC7_XOR: begin
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_XOR;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
            endcase
          end
          `FUNC3_SLTU_SERIES: begin
            case (func7)
              `FUNC7_SLTU: begin
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_COMPARE_U;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
              `FUNC7_MULHU: begin
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_MULHU;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
            endcase
          end
          `FUNC3_REMU_SERIES: begin
            case (func7)
              `FUNC7_REMU: begin
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_REMU;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
              `FUNC7_AND: begin
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_AND;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
            endcase
          end
          `FUNC3_DIVU_SERIES: begin
            case (func7)
              `FUNC7_DIVU: begin
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_DIVU;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
              `FUNC7_SRA: begin
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_SRA_R;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
              `FUNC7_SRL: begin
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_SRL_R;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
            endcase
          end
          `FUNC3_SLL_SERIES: begin
            case (func7)
              `FUNC7_SLL: begin  //R(rd) = src1 << BITS(src2, 4, 0) 逻辑左移
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_SLL_R;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
              `FUNC7_MULH: begin
                addr_Rd = inst[11:7];
                wr_en_Rd = 1;
                addr_Rs1 = inst[19:15];
                addr_Rs2 = inst[24:20];
                exu_opt_code = `EXU_MULH;
                exu_sel_code = `SEL_RS1_AND_RS2;
              end
            endcase
          end
          `FUNC3_SLT: begin
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            addr_Rs1 = inst[19:15];
            addr_Rs2 = inst[24:20];
            exu_opt_code = `EXU_COMPARE;
            exu_sel_code = `SEL_RS1_AND_RS2;
          end
        endcase
      end
      default: ;
    endcase
  end



endmodule  //ysyx_23060191_IDU
