/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 20:13:08
 * @LastEditTime : 2024-07-26 08:25:36
 * @FilePath     : /ysyx/ysyx-workbench/npc/csrc/main.cpp
 * @Description  :
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include "include.h"
#include "Vtop__Dpi.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

static VerilatedVcdC *tfp = NULL;
static VerilatedContext *contextp = NULL;
static Vtop *top = NULL;

void init_wave()
{
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    top = new Vtop;
    contextp->traceEverOn(true);
    top->trace(tfp, 0);
    tfp->open("build/waves.vcd");
}

void dump_wave()
{
    contextp->timeInc(1);
    tfp->dump(contextp->time());
}

void single_cycle()
{
    top->clk = 0;
    top->rstn = 1;
    top->eval();
    dump_wave();
    top->clk = 1;
    top->eval();
    dump_wave();
}

void cpu_exec(uint32_t n)
{
    while (n > 0)
    {
        single_cycle();
        difftest_step();
        if (!difftest_check())
        {
            print_regs();
            break;
        }
        n--;
    }
}

void close_wave()
{
    tfp->close();
    delete tfp;
    delete top;
    delete contextp;
}

int main(int argc, char *argv[])
{
    init_wave();
    single_cycle();
    single_cycle();
    npc_init(argc, argv);
    cpu_exec(1000);
    close_wave();
    return 0;
}