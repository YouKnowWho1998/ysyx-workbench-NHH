/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 22:06:37
 * @LastEditTime : 2024-06-28 15:35:07
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

extern "C" void npc_pmem_read(uint32_t rd_addr, uint32_t *rd_data, svBit rd_en)
{
    if (rd_en && rd_addr >= PMEM_LEFT && rd_addr <= PMEM_RIGHT)
    {
        *rd_data = pmem_read(rd_addr, 4);
    }
    else
        *rd_data = 0;
}

extern "C" void npc_pmem_write(uint32_t wr_addr, uint32_t wr_data, const svBitVecVal *wr_mask)
{
    // printf("wr_addr = 0x%x,wr_data = 0x%x,wr_mask = 0x%x\n",wr_addr,wr_data,*wr_mask);
    // waddr = waddr & ~0x7ull;  //clear low 3bit for 8byte align.
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