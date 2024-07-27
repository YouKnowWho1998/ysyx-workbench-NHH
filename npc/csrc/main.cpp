/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 20:13:08
 * @LastEditTime : 2024-07-27 17:58:29
 * @FilePath     : /ysyx/ysyx-workbench/npc/csrc/main.cpp
 * @Description  : main函数 修复difftest逻辑
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
extern bool npc_stop;

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

void close_wave()
{
    tfp->close();
    delete tfp;
    delete top;
    delete contextp;
}

void cpu_exec(uint32_t n)
{
    while (n > 0)
    {
        single_cycle();
#if ITRACE_ON == 1
        if (!npc_stop)
        {
            store_trace_data();
            display_inst();
        }
#endif
#if DIFFTEST_ON == 1
        difftest_step();
        if (!difftest_check())
        {
            print_regs();
            break;
        }
#endif
        n--;
    }
}

int main(int argc, char *argv[])
{
    init_wave();
    single_cycle();
    single_cycle(); // 推进两个周期校准至开始位置 因为复位信号打了两拍
    npc_init(argc, argv);
    cpu_exec(1000);
    close_wave();
    return 0;
}