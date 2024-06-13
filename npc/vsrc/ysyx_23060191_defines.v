//处理器位宽:
`define CPU_WIDTH 32 //32位宽

//opcode：
`define TYPE_I 7'b0010011 //I型指令

//funct3:
`define FUNC3_ADDI 3'b000 //addi的func3

//固定指令
`define EBREAK 32'b000000000001_00000_000_00000_1110011

//32个GPR寄存器组:
`define X0 5'b00000 //X0 其值永远为0
`define X1 5'b00001 //X1 返回地址
`define X2 5'b00010 //X2 栈指针
`define X3 5'b00011 //X3 全局指针
`define X4 5'b00100 //X4 线程指针
`define X5 5'b00101 //X5 临时寄存器
`define X6 5'b00110 //X6 临时寄存器 
`define X7 5'b00111 //X7 临时寄存器
`define X8 5'b01000 //X8 保存寄存器，帧指针
`define X9 5'b01001 //X9 保存寄存器
`define X10 5'b01010 //X10 函数参数，返回值
`define X11 5'b01011 //X11 函数参数，返回值
`define X12 5'b01100 //X12 函数参数
`define X13 5'b01101 //X13 函数参数
`define X14 5'b01110 //X14 函数参数
`define X15 5'b01111 //X15 函数参数
`define X16 5'b10000 //X16 函数参数
`define X17 5'b10001 //X17 函数参数
`define X18 5'b10010 //X18 保存寄存器
`define X19 5'b10011 //X19 保存寄存器 
`define X20 5'b10100 //X20 保存寄存器
`define X21 5'b10101 //X21 保存寄存器
`define X22 5'b10110 //X22 保存寄存器
`define X23 5'b10111 //X23 保存寄存器
`define X24 5'b11000 //X24 保存寄存器
`define X25 5'b11001 //X25 保存寄存器
`define X26 5'b11010 //X26 保存寄存器
`define X27 5'b11011 //X27 保存寄存器
`define X28 5'b11100 //X28 临时寄存器
`define X29 5'b11101 //X29 临时寄存器
`define X30 5'b11110 //X30 临时寄存器
`define X31 5'b11111 //X31 临时寄存器


//ALU控制码
`define ALU_LUI 3'b001 //imm
`define ALU_AUIPC 3'b010 // pc+imm
`define ALU_ADD 3'b011 // rs1+rs2
`define ALU_SUB 3'b100 // rs1-rs2
`define ALU_SLL 3'b101 
`define ALU_SLT 3'b110 
