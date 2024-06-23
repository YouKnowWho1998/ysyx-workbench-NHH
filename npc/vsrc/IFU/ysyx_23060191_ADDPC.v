`include "/mnt/ysyx/ysyx-workbench/npc/vsrc/defines.v"
module ysyx_23060191_ADDPC (
    input [`CPU_WIDTH-1:0] pc_in_add_before,

    output [`CPU_WIDTH-1:0] pc_out_add_after
);

  assign pc_out_add_after = pc_in_add_before + 4;

endmodule  //ysyx_23060191_ADDPC
