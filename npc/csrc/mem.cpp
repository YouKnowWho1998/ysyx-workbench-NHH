/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-25 16:08:33
 * @LastEditTime : 2024-06-25 22:44:35
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\mem.cpp
 * @Description  : mem
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include "include/include.h"

uint8_t pmem[PMEM_MSIZE]  = {};

// 内建镜像
static const uint32_t img[] = {
    0x800002b7, // lui t0,0x80000
    0x0002a023, // sw  zero,0(t0)
    0x0002a503, // lw  a0,0(t0)
    0x00100073, // ebreak
};

uint8_t *guest_to_host(uint32_t paddr) { return pmem + paddr - PMEM_START; }

uint32_t host_to_guest(uint8_t *haddr) { return haddr - pmem + PMEM_START; }

// 内存初始化
void init_mem()
{
    memcpy(guest_to_host(PMEM_LEFT), img, sizeof(img));
    printf("内存完成初始化\n");
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