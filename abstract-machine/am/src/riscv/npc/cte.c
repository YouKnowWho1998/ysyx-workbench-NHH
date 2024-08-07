/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-07-21 15:32:03
 * @LastEditTime : 2024-08-07 18:13:25
 * @FilePath     : /ysyx-workbench/abstract-machine/am/src/riscv/npc/cte.c
 * @Description  :
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

static Context *(*user_handler)(Event, Context *) = NULL;

Context *__am_irq_handle(Context *c)
{
  if (user_handler)
  {
    Event ev = {0};
    switch (c->mcause)
    {
    case 0:
      ev.event = EVENT_SYSCALL;
      break;
    case 11:
      ev.event = EVENT_YIELD;
      c->mepc += 4;
      break;
    default:
      ev.event = EVENT_ERROR;
      break;
    }
    c = user_handler(ev, c);
    assert(c != NULL);
  }
  return c;
}

extern void __am_asm_trap(void);

bool cte_init(Context *(*handler)(Event, Context *))
{
  // initialize exception entry
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));

  // register event handler
  user_handler = handler;

  return true;
}

Context *kcontext(Area kstack, void (*entry)(void *), void *arg)
{
  Context *cp = (Context *)(kstack.end - sizeof(Context)); // 设置cp指针指向上下文栈底位置
  cp->mepc = (uintptr_t)entry;                             // mepc跳转地址为内核线程入口
  cp->mstatus = 0x1800;                                    // 初始化difftest
  cp->gpr[10] = (uintptr_t)arg;                            // 利用a0寄存器传递参数
  return cp;
}

void yield()
{
#ifdef __riscv_e
  asm volatile("li a5, 11; ecall");
#else
  asm volatile("li a7, 11; ecall");
#endif
}

bool ienabled()
{
  return false;
}

void iset(bool enable)
{
}
