/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-05-14 20:02:03
 * @LastEditTime : 2024-05-14 21:19:59
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\dpic.cpp
 * @Description  :  dpic.cpp
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include "verilated_dpi.h"

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
