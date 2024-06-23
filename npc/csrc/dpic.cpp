/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-05-14 20:02:03
 * @LastEditTime : 2024-06-23 22:17:05
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\sim\dpic.cpp
 * @Description  : NPC中要用到的的DPIC机制函数
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include "verilated_dpi.h"



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
