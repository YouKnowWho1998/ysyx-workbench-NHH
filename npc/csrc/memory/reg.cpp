/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-30 11:53:03
 * @LastEditTime : 2024-07-29 21:56:08
 * @FilePath     : /ysyx-workbench/npc/csrc/memory/reg.cpp
 * @Description  : regs
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include "include.h"

uint32_t *dut_reg = NULL;
uint32_t dut_pc;
uint32_t dut_inst;

const char *regs[] = {
    "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
    "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
    "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
    "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"};

bool check_regs(regfile *ref, regfile *dut)
{
    if (ref->pc != dut->pc)
    {
        printf("\033[1;36mdifftest error:\033[0m\n");
        printf("\033[1;36mthe next pc is different: ref = 0x%x, dut = 0x%x\033[0m\n", ref->pc, dut->pc);
        return false;
    }
    for (int i = 0; i < 32; i++)
    {
        if (ref->gpr[i] != dut->gpr[i])
        {
            printf("\033[1;36mdifftest error at next pc = 0x%x,\033[0m", dut->pc);
            printf("\033[1;36mreg %s is different: ref = 0x%x, dut = 0x%x\033[0m\n", regs[i], ref->gpr[i], dut->gpr[i]);
            return false;
        }
    }
    return true;
}

void print_regs()
{
    printf("\033[1;36mdut pc = 0x%x\033[0m\n", dut_pc);
    for (int i = 0; i < 32; i++)
    {
        printf("\033[1;36mdut reg %3s = 0x%x\033[0m\n", regs[i], dut_reg[i]);
    }
}

regfile pack_dut_regfile(uint32_t *dut_reg, uint32_t pc)
{
    regfile dut;
    for (int i = 0; i < 32; i++)
    {
        dut.gpr[i] = dut_reg[i];
    }
    dut.pc = pc;
    return dut;
}

void store_trace_data()
{
    trace_inst(dut_pc, dut_inst);
}
