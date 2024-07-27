/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 22:06:37
 * @LastEditTime : 2024-07-27 22:29:32
 * @FilePath     : /ysyx/ysyx-workbench/npc/csrc/dpic.cpp
 * @Description  : DPIC
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include "include.h"
#include "verilated_dpi.h"

bool npc_stop = false;
static uint64_t timer = 0;

extern "C" svBit npc_finish(int inst)
{
    if (inst == 0x100073) // ebreak;
    {
        npc_stop = true;
        return 1;
    }
    else
    {
        return 0;
    }
}

extern "C" void npc_pmem_read(uint32_t rd_addr, uint32_t *rd_data, svBit rd_en)
{
#if DEVICE_ON == 1
    if (rd_addr == RTC_ADDR + 4)
    {
        difftest_skip_ref();
        timer = get_time();
        *rd_data = (uint32_t)(timer >> 32);
    }
    if (rd_addr == RTC_ADDR)
    {
        difftest_skip_ref();
        *rd_data = (uint32_t)(timer);
    }
    if (rd_addr == SERIAL_PORT_ADDR)
    {
        return;
    }
#endif

    if (rd_en && rd_addr >= PMEM_LEFT && rd_addr <= PMEM_RIGHT)
    {
        *rd_data = pmem_read(rd_addr, 4);
    }
    else
        *rd_data = 0;
}

extern "C" void npc_pmem_write(uint32_t wr_addr, uint32_t wr_data, const svBitVecVal *wr_mask)
{
// waddr = waddr & ~0x7ull;  //clear low 3bit for 8byte align.
#if DEVICE_ON == 1
    if (wr_addr == SERIAL_PORT_ADDR)
    {
        difftest_skip_ref();
        putc((char)wr_data, stderr);
        return;
    }
#endif

    switch (*wr_mask)
    {
    case 1:
        pmem_write(wr_addr, wr_data, 1);
        break; // 4'b0001, 1byte.
    case 3:
        pmem_write(wr_addr, wr_data, 2);
        break; // 4'b0011, 2byte.
    case 15:
        pmem_write(wr_addr, wr_data, 4);
        break; // 4'b1111, 4byte.
    default:
        break;
    }
}

// 获取处理器内部寄存器值,PC值,指令值
extern uint32_t *dut_reg;
extern uint32_t dut_pc;
extern uint32_t dut_inst;

extern "C" void get_dut_reg(const svOpenArrayHandle r)
{
    dut_reg = (uint32_t *)(((VerilatedDpiOpenVar *)r)->datap());
}

extern "C" void get_dut_pc(uint32_t npc_pc)
{
    dut_pc = npc_pc;
}

extern "C" void get_dut_inst(uint32_t npc_inst)
{
    dut_inst = npc_inst;
}