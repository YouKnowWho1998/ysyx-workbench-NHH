/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-30 09:28:12
 * @LastEditTime : 2024-07-25 22:11:50
 * @FilePath     : /ysyx/ysyx-workbench/npc/csrc/difftest/difftest.c
 * @Description  : difftest模块
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include "include.h"
#include <dlfcn.h>

#ifdef DIFFTEST_ON

extern uint32_t *dut_reg;
extern uint32_t dut_pc;
bool is_skip_ref = false;

enum
{
    DIFFTEST_TO_DUT,
    DIFFTEST_TO_REF
};
void (*ref_difftest_memcpy)(uint32_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint32_t n) = NULL;
// void (*ref_difftest_raise_intr)(uint32_t NO) = NULL;

void difftest_skip_ref()
{
    is_skip_ref = true;
}

void difftest_init(char *ref_so_file, long img_size)
{
    assert(ref_so_file != NULL);

    void *handle;
    handle = dlopen(ref_so_file, RTLD_LAZY);
    assert(handle);

    ref_difftest_memcpy = (void (*)(uint32_t addr, void *buf, size_t n, bool direction))dlsym(handle, "difftest_memcpy");
    assert(ref_difftest_memcpy);

    ref_difftest_regcpy = (void (*)(void *dut, bool direction))dlsym(handle, "difftest_regcpy");
    assert(ref_difftest_regcpy);

    ref_difftest_exec = (void (*)(uint32_t n))dlsym(handle, "difftest_exec");
    assert(ref_difftest_exec);

    // ref_difftest_raise_intr = (void (*)(uint32_t NO))dlsym(handle, "difftest_raise_intr");
    // assert(ref_difftest_raise_intr);

    void (*ref_difftest_init)() = (void (*)())dlsym(handle, "difftest_init");
    assert(ref_difftest_init);

    ref_difftest_init();
    ref_difftest_memcpy(PMEM_LEFT, guest_to_host(PMEM_LEFT), img_size, DIFFTEST_TO_REF);

    regfile dut = pack_dut_regfile(dut_reg, PMEM_LEFT);
    ref_difftest_regcpy(&dut, DIFFTEST_TO_REF);
}

bool difftest_check()
{
    regfile ref, dut;
    ref_difftest_regcpy(&ref, DIFFTEST_TO_DUT);
    dut = pack_dut_regfile(dut_reg, dut_pc);
    return check_regs(&ref, &dut);
}

void difftest_step()
{
    if (is_skip_ref)
    {
        regfile dut = pack_dut_regfile(dut_reg, dut_pc);
        ref_difftest_regcpy(&dut, DIFFTEST_TO_REF);
        is_skip_ref = false;
        return;
    }
    ref_difftest_exec(1);
}

#endif