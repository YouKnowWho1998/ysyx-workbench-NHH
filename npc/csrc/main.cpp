/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-05-07 10:21:21
 * @LastEditTime : 2024-06-23 23:54:21
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\main.cpp
 * @Description  : NPC仿真testbench
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include <verilated.h>
#include "/mnt/ysyx/ysyx-workbench/npc/build/obj_dir/Vysyx_23060191_CPU.h"
#include "verilated_vcd_c.h"
#include <common.h>

void init_monitor(int, char *[]);

void dump_waves(VerilatedContext *contextp, VerilatedVcdC *tfp, Vysyx_23060191_CPU *top)
{
    top->eval();
    tfp->dump(contextp->time());
    contextp->timeInc(1);
}

int main(int argc, char **argv)
{
    VerilatedContext *contextp;
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    Vysyx_23060191_CPU *top = new Vysyx_23060191_CPU{contextp};
    top->trace(tfp, 99);
    tfp->open("waves.vcd");

    top->clk = 0;
    top->rstn = !0;
    dump_waves(contextp, tfp, top);
    init_monitor(argc, argv);
    
    while (!contextp->gotFinish())
    {
        top->clk = !top->clk;
        dump_waves(contextp, tfp, top);
    }

    dump_waves(contextp, tfp, top);

    top->final();
    tfp->close();
    delete tfp;
    delete top;
    delete contextp;
    return 0;
}
