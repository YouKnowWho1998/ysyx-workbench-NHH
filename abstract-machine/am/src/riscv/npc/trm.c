/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-07-21 15:32:03
 * @LastEditTime : 2024-07-23 20:24:21
 * @FilePath     : /ysyx/ysyx-workbench/abstract-machine/am/src/riscv/npc/trm.c
 * @Description  :
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */

#include <am.h>
#include <klib-macros.h>
#include "npc.h"

extern char _heap_start;
int main(const char *args);

extern char _pmem_start;
#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END ((uintptr_t) & _pmem_start + PMEM_SIZE)

Area heap = RANGE(&_heap_start, PMEM_END);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

void putch(char ch)
{
  outb(SERIAL_PORT_ADDR, ch);
}

void halt(int code)
{
  asm volatile("mv a0, %0; ebreak" : : "r"(code));
  while (1)
    ;
}

void _trm_init()
{
  int ret = main(mainargs);
  halt(ret);
}
