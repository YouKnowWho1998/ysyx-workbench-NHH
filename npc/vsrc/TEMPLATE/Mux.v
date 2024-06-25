/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-19 21:18:49
 * @LastEditTime : 2024-06-20 10:49:32
 * @FilePath     : \ysyx\ysyx-workbench\npc\vsrc\TEMPLATE\Mux.v
 * @Description  : ysyx的选择器模板
 * 
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved. 
 */

// 选择器模板内部实现
module MuxKeyInternal #(
    NR_KEY = 2,
    KEY_LEN = 1,
    DATA_LEN = 1,
    HAS_DEFAULT = 0
) (
    output reg [DATA_LEN-1:0] out,
    input [KEY_LEN-1:0] key,
    input [DATA_LEN-1:0] default_out,
    input [NR_KEY*(KEY_LEN + DATA_LEN)-1:0] lut
);

  localparam PAIR_LEN = KEY_LEN + DATA_LEN;
  wire [PAIR_LEN-1:0] pair_list[NR_KEY-1:0];
  wire [ KEY_LEN-1:0] key_list [NR_KEY-1:0];
  wire [DATA_LEN-1:0] data_list[NR_KEY-1:0];

  genvar n;
  generate
    for (n = 0; n < NR_KEY; n = n + 1) begin
      assign pair_list[n] = lut[PAIR_LEN*(n+1)-1 : PAIR_LEN*n];
      assign data_list[n] = pair_list[n][DATA_LEN-1:0];
      assign key_list[n]  = pair_list[n][PAIR_LEN-1:DATA_LEN];
    end
  endgenerate

  reg [DATA_LEN-1 : 0] lut_out;
  reg hit;
  integer i;
  always @(*) begin
    lut_out = 0;
    hit = 0;
    for (i = 0; i < NR_KEY; i = i + 1) begin
      lut_out = lut_out | ({DATA_LEN{key == key_list[i]}} & data_list[i]);
      hit = hit | (key == key_list[i]);
    end
    if (!HAS_DEFAULT) out = lut_out;
    else out = (hit ? lut_out : default_out);
  end
endmodule



// 不带默认值的选择器模板
// 实现了"键值选择"功能, 即在一个(键值, 数据)的列表lut中, 根据给定的键值key, 将out设置为与其匹配的数据. 若列表中不存在键值为key的数据, 则out为0.
module MuxTemplate #(
    NR_KEY   = 2,  //键值对数量
    KEY_LEN  = 1,  //键值宽度
    DATA_LEN = 1   //数据宽度
) (
    output [DATA_LEN-1:0] out, //选中的输出数据
    input [KEY_LEN-1:0] key, //输入的key
    input [NR_KEY*(KEY_LEN + DATA_LEN)-1:0] lut //（键值，数据）组成的列表
);
  MuxKeyInternal #(NR_KEY, KEY_LEN, DATA_LEN, 0) i0 (
      out,
      key,
      {DATA_LEN{1'b0}},
      lut
  );
endmodule



// 带默认值的选择器模板
// 提供一个默认值default_out, 当列表中不存在键值为key的数据, 则out为default_out
module MuxDefaultTemplate #(
    NR_KEY   = 2,
    KEY_LEN  = 1,
    DATA_LEN = 1
) (
    output [DATA_LEN-1:0] out,
    input [KEY_LEN-1:0] key,
    input [DATA_LEN-1:0] default_out,
    input [NR_KEY*(KEY_LEN + DATA_LEN)-1:0] lut
);
  MuxKeyInternal #(NR_KEY, KEY_LEN, DATA_LEN, 1) i0 (
      out,
      key,
      default_out,
      lut
  );
endmodule
