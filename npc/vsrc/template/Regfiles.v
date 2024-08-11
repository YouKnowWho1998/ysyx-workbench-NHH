module Regfiles #(
    parameter REG_NUM = 256 //实例化寄存器的数量 默认实例256个32bit寄存器 1kb容量
) (
    input  clk,
    input  i_wr_en, 
    input  [$clog2(REG_NUM)-1:0] i_addr_rd,   
    input  [$clog2(REG_NUM)-1:0] i_addr_wr,   
    input  [31:0] i_data_wr,

    output [31:0] o_data_rd    
);
    
reg [31:0] reg_files [REG_NUM-1:0];


always @(posedge clk) begin
    if (i_wr_en) begin
        reg_files[i_addr_wr] <= i_data_wr;
    end
end

assign o_data_rd = reg_files[i_addr_rd];

endmodule