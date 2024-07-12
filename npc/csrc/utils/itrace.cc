/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-07-01 22:24:50
 * @LastEditTime : 2024-07-05 12:15:05
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\utils\itrace.cc
 * @Description  : itrace iringbuf缓冲区
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <inttypes.h>
#include "include.h"

#define FMT_WORD "0x%08" PRIx32

extern "C" void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);

// iringbuf
typedef struct iringbuf
{
    uint32_t pcs[20];
    uint32_t insts[20];
    uint32_t iring_rf;
    uint32_t iring_wf;
} iringbuf;

iringbuf irb;

void trace_inst(uint32_t pc, uint32_t inst)
{
    irb.pcs[irb.iring_wf] = pc;
    irb.insts[irb.iring_wf] = inst;
    irb.iring_wf = (irb.iring_wf + 1) % 20;
    if (irb.iring_wf == irb.iring_rf)
    {
        irb.iring_rf = (irb.iring_rf + 1) % 20;
    }
}

void display_inst()
{
    char logbuf[64];
    while (irb.iring_rf != irb.iring_wf)
    {
        // 存储pc和指令内容到缓冲区
        char *p = logbuf;
        // if (irb.iring_rf + 1 == irb.iring_wf)
        // {
        //     p += snprintf(p, 20, "[ITRACE]  ");
        // }
        // else
        // {
        //     memset(p, ' ', 4);
        //     p += 4;
        // }
        p += snprintf(p, 20, "[ITRACE]  ");
        p += snprintf(p, sizeof(logbuf), FMT_WORD " :", irb.pcs[irb.iring_rf]);
        uint8_t *inst = (uint8_t *)&irb.insts[irb.iring_rf];
        for (int j = 3; j >= 0; j--)
        {
            p += snprintf(p, 4, " %02x", inst[j]);
        }
        memset(p, ' ', 4);
        p += 4;

        // 解析指令对应的汇编语句
        disassemble(p, logbuf + sizeof(logbuf) - p,
                    irb.pcs[irb.iring_rf], (uint8_t *)&irb.insts[irb.iring_rf], 4);
        irb.iring_rf = (irb.iring_rf + 1) % 20;
    }
    puts(logbuf);
}