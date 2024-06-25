module Rstnreg (
    input  clk,
    input  rstn,
    
    output rstn_sync
);

  reg rstn_r1, rstn_r2;

  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      rstn_r1 <= 1'b0;
      rstn_r2 <= 1'b0;
    end else begin
      rstn_r1 <= 1'b1;
      rstn_r2 <= rstn_r1;
    end
  end

assign rstn_sync = rstn_r2;

endmodule  //Rstnreg
