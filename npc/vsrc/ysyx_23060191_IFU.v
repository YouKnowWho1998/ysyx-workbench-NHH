`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060191_defines.v"
module ysyx_23060191_IFU (
    input clk,
    input rstn,

    output [`CPU_WIDTH-1:0] inst  //输出从内存中取出的指令
);

  reg [`CPU_WIDTH-1:0] pc;  //PC计数器


  always @(posedge clk) begin
    if (!rstn) begin
      pc <= 'h8000_0000;  //pc初始值为h'8000_0000
    end else begin
      pc <= pc + 'h4;
    end
  end


  //连接存储器 内部储存了写好的addi指令 
  ysyx_23060191_mem mem_inst (
      .addr(pc),  //地址(PC)

      .data(inst)  //输出指令
  );


endmodule  //ysyx_23060191_IFU
