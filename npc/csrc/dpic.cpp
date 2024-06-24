/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-05-14 20:02:03
 * @LastEditTime : 2024-06-24 12:11:36
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\dpic.cpp
 * @Description  : NPC中要用到的的DPIC机制函数
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include "verilated_dpi.h"
#include <memory/paddr.h>

//ebreak指令终止仿真
 extern "C" svBit ebreak(int inst)
{
    if (inst == 0x100073)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

extern "C" int npc_pmem_read(int raddr)
{
    int inst = 0;
    if (raddr >= PMEM_LEFT && raddr <= PMEM_RIGHT)
    {
        inst = paddr_read(raddr, 4);
    }
}
