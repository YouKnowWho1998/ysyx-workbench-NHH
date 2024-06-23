`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060171_CPU (
    input clk,
    input rstn
);

wire [`CPU_WIDTH-1:0] inst;


//IFU模块
ysyx_23060191_IFU IFU(
    .clk(clk),
    .rstn(rstn),
    .jump_addr_from_EXU(32'b0),//JAL(R)跳转指令跳转地址
    .jump_en_from_IDU(1'b0),//JAL(R)跳转指令使能信号

    .inst(inst) //取出指令  
);


//出现ebreak指令终止仿真
import "DPI-C" function bit ebreak(input int inst);
always @(*) begin
    if (ebreak(inst)) begin
        $display("--EBREAK--");
        $display("CPU STOP RUNNING");
        $finish;
    end
end



endmodule  //ysyx_23060191_CPU
