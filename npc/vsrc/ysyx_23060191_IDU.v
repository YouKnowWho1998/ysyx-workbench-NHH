/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-26 10:10:46
 * @LastEditTime : 2024-06-28 13:54:12
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\ysyx_23060191_IDU.v
 * @Description  : IDU指令译码模块
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */
`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"

module ysyx_23060191_IDU (
    input [`CPU_WIDTH-1:0] inst,

    output reg wr_en_Rd,  //Rd寄存器写使能 IDU->GPR
    output reg [4:0] addr_Rd,  //目标寄存器地址 IDU->GPR
    output reg [4:0] addr_Rs1,  //rs1寄存器地址 IDU->GPR
    output reg [4:0] addr_Rs2,  //rs2寄存器地址 IDU->GPR
    output reg [`CPU_WIDTH-1:0] imm, //所有立即数统一扩展至32位 高位填充符号位 IDU->EXU IDU->PCU
    output reg jal_jump_en,  //jal跳转指令使能 IDU->PCU
    output reg jalr_jump_en,  //jalr跳转指令使能 IDU->PCU
    output reg [`EXU_OPT_WIDTH-1:0] exu_opt_code,  //EXU操作码 IDU->EXU
    output reg [`LSU_OPT_WIDTH-1:0] lsu_opt_code,  //LSU操作码 IDU->LSU
    output reg [`EXU_SEL_WIDTH-1:0] exu_sel_code  //EXU选择码 IDU->EXU
);

  wire [6:0] opcode = inst[6:0];  //opcode
  wire [2:0] fun3 = inst[14:12];  //fun3

  //指令解码 分离出立即数和寄存器地址
  always @(*) begin
    imm = 0;
    addr_Rd = 0;
    addr_Rs1 = 0;
    jal_jump_en = 0;
    jalr_jump_en = 0;
    wr_en_Rd = 0;
    exu_opt_code = 0;
    lsu_opt_code = 0;
    exu_sel_code = `EXU_SEL_WIDTH'b0;
    case (opcode)
      `TYPE_U_LUI: begin  //lui指令:R(rd) = imm
        imm = {inst[31:12], 12'b0};  //U型立即数 加载在寄存器高20位
        addr_Rd = inst[11:7];
        wr_en_Rd = 1;
      end
      `TYPE_U_AUIPC: begin  //auipc指令:R(rd) = pc + imm
        imm = {inst[31:12], 12'b0};  //U型立即数 加载在寄存器高20位
        addr_Rd = inst[11:7];
        wr_en_Rd = 1;
        exu_opt_code = `EXU_ADD;
        exu_sel_code = `SEL_PC_ADD_IMM;
      end
      `TYPE_J_JAL: begin  //jal指令:R(rd) = pc + 4; pc = pc + imm
        imm = {
          {11{inst[31]}}, {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}
        };  //J型立即数 左移一位后高位补符号位
        addr_Rd = inst[11:7];
        jal_jump_en = 1;
        wr_en_Rd = 1;
        exu_opt_code = `EXU_ADD;
        exu_sel_code = `SEL_PC_ADD_4;
      end
      `TYPE_I_JALR: begin  //jalr指令:R(rd) = pc + 4; pc = src1 + imm
        imm = {
          {20{inst[31]}}, inst[31:20]
        };  //I型立即数  加载在寄存器低12位 高位填充符号位
        addr_Rd = inst[11:7];
        addr_Rs1 = inst[19:15];
        jalr_jump_en = 1;
        wr_en_Rd = 1;
        exu_opt_code = `EXU_ADD;
        exu_sel_code = `SEL_PC_ADD_4;
      end
      `TYPE_I_ADDI_SERIES: begin
        case (fun3)
          `FUNC3_ADDI: begin  //addi指令:R(rd) = src1 + imm
            imm = {
              {20{inst[31]}}, inst[31:20]
            };  //I型立即数  加载在寄存器低12位 高位填充符号位
            addr_Rs1 = inst[19:15];
            addr_Rd = inst[11:7];
            wr_en_Rd = 1;
            exu_opt_code = `EXU_ADD;
            exu_sel_code = `SEL_RS1_ADD_IMM;
          end
        endcase
        `TYPE_S_SERIES : begin
          `FUNC3_SW : begin  //sw指令:Mw(src1 + imm, 4, src2)) src1+imm是内存写入地址 src2是写入值
            imm = {{20{inst[31]}}, {inst[31:25], inst[11:7]}};
            addr_Rs1 = inst[19:15];
            addr_Rs2 = inst[24:20];
            exu_opt_code = `EXU_ADD;
            exu_sel_code = `SEL_RS1_ADD_IMM;
            lsu_opt_code = `LSU_SW;
          end
        end
      end
    endcase
  end








endmodule  //ysyx_23060191_DECS
