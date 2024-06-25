/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 20:48:02
 * @LastEditTime : 2024-06-25 12:52:42
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\mem.cpp
 * @Description  :
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */

#include "include/include.h"

static uint8_t *pmem = NULL;

uint8_t *guest_to_host(uint32_t paddr) { return pmem + paddr - PMEM_START; }
uint32_t host_to_guest(uint8_t *haddr) { return haddr - pmem + PMEM_START; }

void init_mem(size_t size){
    pmem = (uint8_t *)malloc(size * sizeof(uint8_t));
    if(pmem == NULL){exit(0);}
}


void pmem_write(uint32_t addr, uint32_t data, int len)
{
    uint8_t *paddr = guest_to_host(addr);
    switch (len)
    {
    case 1:
        *(uint8_t *)paddr = data;
        return;
    case 2:
        *(uint16_t *)paddr = data;
        return;
    case 4:
        *(uint32_t *)paddr = data;
        return;
    }
}

uint32_t pmem_read(uint32_t addr, int len)
{
    uint8_t *paddr = (uint8_t *)guest_to_host(addr);
    switch (len)
    {
    case 1:
        return *(uint8_t *)paddr;
    case 2:
        return *(uint16_t *)paddr;
    case 4:
        return *(uint32_t *)paddr;
    }
    assert(0);
}