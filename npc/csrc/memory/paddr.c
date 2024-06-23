/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-21 11:39:22
 * @LastEditTime : 2024-06-23 22:45:48
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\memory\paddr.c
 * @Description  : 修改自NEMU
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include <host.h>
#include <paddr.h>
#include <macro.h>
#include <common.h>

#if defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem = NULL;
#else // CONFIG_PMEM_GARRAY
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};
#endif


uint8_t *guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }


paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }



static word_t pmem_read(paddr_t addr, int len)
{
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}



static void pmem_write(paddr_t addr, int len, word_t data)
{
  host_write(guest_to_host(addr), len, data);
}



void init_mem()
{
#if defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_MSIZE);
  assert(pmem);
#endif
#ifdef CONFIG_MEM_RANDOM
  uint32_t *p = (uint32_t *)pmem;
  int i;
  for (i = 0; i < (int)(CONFIG_MSIZE / sizeof(p[0])); i++)
  {
    p[i] = rand();
  }
#endif
  Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
}



word_t paddr_read(paddr_t addr, int len)
{
  if (likely(in_pmem(addr)))
    return pmem_read(addr, len);
  return 0;
}



void paddr_write(paddr_t addr, int len, word_t data)
{
  if (likely(in_pmem(addr)))
  {
    pmem_write(addr, len, data);
    return;
  }
}
