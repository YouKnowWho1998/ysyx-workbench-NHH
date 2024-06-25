/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 22:06:37
 * @LastEditTime : 2024-06-25 09:40:17
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\dpic.cpp
 * @Description  : DPIC
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include "include/include.h"
#include "verilated_dpi.h"

extern "C" svBit check_finish(int inst)
{
    if (inst == 0x100073) // ebreak;
        return 1;
    else
        return 0;
}

extern "C" void npc_pmem_read(uint32_t raddr,uint32_t *rdata,svBit rd_en)
{
    if (rd_en && raddr >= PMEM_START && raddr <= PMEM_END)
    {
        *rdata = pmem_read(raddr, 4);
    }
    else 
        *rdata = 0;
}