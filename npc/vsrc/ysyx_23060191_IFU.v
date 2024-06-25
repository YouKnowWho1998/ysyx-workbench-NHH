`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_IFU (
    input  clk,
    input  rstn,
    input  [`CPU_WIDTH-1:0] jump_addr_from_EXU,//JAL(R)跳转指令跳转地址
    input  jump_en_from_IDU,//JAL(R)跳转指令使能信号

    output [`CPU_WIDTH-1:0] inst //取出指令  
);

wire [`CPU_WIDTH-1:0] chosen_pc;
wire [`CPU_WIDTH-1:0] pc;
wire [`CPU_WIDTH-1:0] pc_add_after;



//IFU里的二选一选择器，负责选通跳转指令和正常顺序指令
MuxTemplate #(2,1,`CPU_WIDTH) mux1(chosen_pc,jump_en_from_IDU,{
    1'b1,jump_addr_from_EXU,
    1'b0,pc_add_after
});

//PC寄存器
ysyx_23060191_PC pc_reg(
    .clk(clk),
    .rstn(rstn),
    .pc_origin(chosen_pc),

    .pc(pc)
);

//加法器 负责PC顺序加4 
ysyx_23060191_ADDPC addPC(
    .pc_in_add_before(pc),

    .pc_out_add_after(pc_add_after)
);

//内存读取指令
ysyx_23060191_MEM mem(
    .pc(pc),
    .rd_en(1'b1),  //内存读使能
    
    .inst(inst)
);

endmodule //ysyx_23060191_IFU