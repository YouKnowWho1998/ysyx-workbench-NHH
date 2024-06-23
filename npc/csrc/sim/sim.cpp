/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-05-07 10:21:21
 * @LastEditTime : 2024-06-23 22:13:30
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\sim\sim.cpp
 * @Description  : NPC仿真testbench
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include <verilated.h>
#include "/mnt/ysyx/ysyx-workbench/npc/build/obj_dir/Vysyx_23060191_CPU.h"
#include "verilated_vcd_c.h"
#include <isa.h>
#include <common.h>

CPU_state cpu = {};

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

// #define MAX_SIM_TIME 500

// int main(int argc, char **argv)
// {
//     Verilated::commandArgs(argc, argv);
//     Vysyx_23060191_CPU *tb = new Vysyx_23060191_CPU;
//     // 启用波形追踪
//     Verilated::traceEverOn(true);
//     VerilatedVcdC *tfp = new VerilatedVcdC;
//     tb->trace(tfp, 99);
//     tfp->open("waves.vcd");
//     // 仿真输入
//     tb->clk = 0;
//     tb->rstn = 0;
//     tb->eval();
//     tfp->dump(0);

//     for (int i = 1; i < MAX_SIM_TIME; i++)
//     {
//         tb->clk ^= 1;
//         if (i > 3)
//         {
//             tb->rstn = 1;
//         }
//         tb->eval();
//         tfp->dump(i);
//     }

//     tfp->close();
//     delete tfp;
//     tb->final();
//     delete tb;
//     return 0;
// }