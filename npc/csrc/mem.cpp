/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 20:48:02
 * @LastEditTime : 2024-06-25 15:13:23
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\mem.cpp
 * @Description  :
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */

#include "include/include.h"
#include <string.h>

static const uint32_t img[] = {
    0b00000000110000000000001011101111, // jal   x5 12         0x80000000
    0b00000000000000000001001000110111, // lui   x4 1          0x80000004
    0b00000000000000000001000110010111, // auipc x3 1          0x80000008
    0b00000000010100000000000010010011, // addi  x1 x0 5       0x8000000c
    0b00000000010100000000000010010011, // addi  x1 x0 5       0x80000010
    0b00000000000100000000000100010011, // addi  x2 x0 1       0x80000014
    0b00000000001000000000000100010011, // addi  x2 x0 2       0x80000018
    0b00000000000001010000010100010011, // addi x10 x10 0      0x8000001c mv a0,a0;
    0b00110000010100010001001001110011, // csrrw x4 mstatus x2 0x80000020 mstatus=0b010 x2=0b010 x4=0b000
    0b00110000010100001010001011110011, // csrrs x5 mstatus x1 0x80000024 mstatus=0b111 x1=0b101 x5=0b010
    0b00000000000100000000000001110011  // ebreak              0x80000028
};
static uint8_t *pmem = NULL;

uint8_t *guest_to_host(uint32_t paddr) { return pmem + paddr - PMEM_START; }
uint32_t host_to_guest(uint8_t *haddr) { return haddr - pmem + PMEM_START; }


void init_mem(size_t size)
{
    pmem = (uint8_t *)malloc(size * sizeof(uint8_t));
    memcpy(pmem, img, sizeof(img));
    if (pmem == NULL)
    {
        exit(0);
    }
    printf("the memory is [%hhn]", pmem);
    printf("npc physical memory area [%#x, %#lx]", PMEM_START, PMEM_START + size * sizeof(uint8_t));
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