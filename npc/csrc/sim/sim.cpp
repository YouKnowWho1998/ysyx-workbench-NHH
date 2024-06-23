/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-05-07 10:21:21
 * @LastEditTime : 2024-05-23 20:46:26
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\main.cpp
 * @Description  : NPC仿真testbench
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include <verilated.h>
#include "/mnt/ysyx/ysyx-workbench/npc/build/obj_dir/Vtop.h"
#include "verilated_vcd_c.h" // 引入波形头文件
#include <iostream>

#define MAX_SIM_TIME 500

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Vtop *tb = new Vtop;
    // 启用波形追踪
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    tb->trace(tfp, 99);
    tfp->open("waves.vcd");
    // 仿真输入
    tb->clk = 0;
    tb->rstn = 0;
    tb->eval();
    tfp->dump(0);

    for (int i = 1; i < MAX_SIM_TIME; i++)
    {
        tb->clk ^= 1;
        if (i > 3)
        {
            tb->rstn = 1;
        }
        tb->eval();
        tfp->dump(i);
    }

    tfp->close();
    delete tfp;
    tb->final();
    delete tb;
    return 0;
}