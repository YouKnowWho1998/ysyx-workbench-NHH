/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 20:13:08
 * @LastEditTime : 2024-06-24 22:58:31
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\main.cpp
 * @Description  :
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include "include/include.h"
#include "Vtop__Dpi.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

void step_and_dump_wave(VerilatedContext *contextp, VerilatedVcdC *tfp, Vtop *top)
{
    top->eval();
    contextp->timeInc(1);
    tfp->dump(contextp->time());
}

int main(int argc, char *argv[])
{
    VerilatedContext *contextp = new VerilatedContext;
    VerilatedVcdC *tfp = new VerilatedVcdC;
    Vtop *top = new Vtop;
    contextp->traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("build/waves.vcd");

    top->rstn = !0;
    top->clk = 0;
    step_and_dump_wave(contextp, tfp, top);

    npc_init(argc, argv);

    while (!contextp->gotFinish())
    {
        top->clk = !top->clk;
        step_and_dump_wave(contextp, tfp, top);
    }

    step_and_dump_wave(contextp, tfp, top);
    tfp->close();
    delete tfp;
    delete top;
    delete contextp;

    return 0;
}