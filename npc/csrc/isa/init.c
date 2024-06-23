/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-21 14:20:59
 * @LastEditTime : 2024-06-23 21:52:12
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\isa\init.c
 * @Description  : 修改自NEMU
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include <isa.h>
#include <paddr.h>

// 内建镜像
static const uint32_t img[] = {
    0x800002b7, // lui t0,0x80000
    0x0002a023, // sw  zero,0(t0)
    0x0002a503, // lw  a0,0(t0)
    0x00100073, // ebreak (used as nemu_trap)
};

static void restart()
{
  /* Set the initial program counter. */
  cpu.pc = RESET_VECTOR;

  /* The zero register is always 0. */
  cpu.gpr[0] = 0;
}

void init_isa()
{
  /* Load built-in image. */
  memcpy(guest_to_host(RESET_VECTOR), img, sizeof(img));

  /* Initialize this virtual computer system. */
  restart();
}
