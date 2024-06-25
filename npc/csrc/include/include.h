/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 20:47:25
 * @LastEditTime : 2024-06-25 13:37:36
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\include\include.h
 * @Description  :
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */

#ifndef _INCLUDE_H_
#define _INCLUDE_H_

#include "Vtop.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define INST_START 0x80000000
#define PMEM_START 0x80000000
#define PMEM_END 0x87ffffff
#define PMEM_MSIZE 0x8000000


// #define DIFFTEST_ON 0

// typedef struct
// {
//   uint32_t x[32];
//   uint32_t pc;
// } regfile;

uint8_t *guest_to_host(uint32_t paddr);
uint32_t host_to_guest(uint8_t *haddr);
uint32_t pmem_read(uint32_t addr, int len);
void pmem_write(uint32_t addr, uint32_t data, int len);
void init_mem(size_t size);
void npc_init(int argc, char *argv[]);
// void print_regs();
// bool checkregs(regfile *ref, regfile *dut);
// regfile pack_dut_regfile(uint32_t *dut_reg, uint32_t pc);

// #ifdef DIFFTEST_ON
// void difftest_init(char *ref_so_file, long img_size);
// bool difftest_check();
// void difftest_step();
// #endif

#endif