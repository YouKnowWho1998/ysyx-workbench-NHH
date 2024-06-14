/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-11 10:51:35
 * @LastEditTime : 2024-06-14 15:07:13
 * @FilePath     : \ysyx\ysyx-workbench\nemu\src\utils\iringbuf.c
 * @Description  :
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include <common.h>
#include <elf.h>
#include <device/map.h>

#define INST_NUM 32

// iringbuf
typedef struct
{
    word_t pc;
    uint32_t inst;
} InstBuf;

InstBuf iringbuf[INST_NUM];

int cur_inst = 0;
int func_num = 0;

void trace_inst(word_t pc, uint32_t inst)
{
    iringbuf[cur_inst].pc = pc;
    iringbuf[cur_inst].inst = inst;
    cur_inst = (cur_inst + 1) % INST_NUM;
}

void display_inst()
{
    /*** 注意出错的是前一条指令，当前指令可能由于出错已经无法正常译码 ***/
    int end = cur_inst;
    char buf[128];
    char *p;
    int i = cur_inst;

    if (iringbuf[i + 1].pc == 0)
        i = 0;

    do
    {
        p = buf;
        p += sprintf(buf, "[ITRACE] %s" FMT_WORD ":  %08x\t", (i + 1) % INST_NUM == end ? "-->" : "   ", iringbuf[i].pc, iringbuf[i].inst);

        void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
        disassemble(p, buf + sizeof(buf) - p, iringbuf[i].pc, (uint8_t *)&iringbuf[i].inst, 4);

        puts(buf);
        i = (i + 1) % INST_NUM;
    } while (i != end);
}
