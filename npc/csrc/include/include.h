/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 13:22:42
 * @LastEditTime : 2024-07-25 16:40:17
 * @FilePath     : /ysyx/ysyx-workbench/npc/csrc/include/include.h
 * @Description  : NPC-头文件
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#ifndef _INCLUDE_H_
#define _INCLUDE_H_

#include "Vtop.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define PMEM_MSIZE 0x8000000
#define PMEM_START 0x80000000
#define PMEM_LEFT ((uint32_t)PMEM_START)
#define PMEM_RIGHT ((uint32_t)PMEM_START + PMEM_MSIZE - 1)

//device defines
#define DEVICE_BASE 0xa0000000
#define SERIAL_PORT_ADDR (DEVICE_BASE + 0x00003f8)
#define RTC_ADDR (DEVICE_BASE + 0x0000048)

#define DIFFTEST_ON 1
#define ITRACE_ON 0
#define DEVICE_ON 1

typedef struct
{
  uint32_t gpr[32];
  uint32_t pc;
} regfile;

uint8_t *guest_to_host(uint32_t paddr);
uint32_t host_to_guest(uint8_t *haddr);
uint32_t pmem_read(uint32_t addr, int len);
void pmem_write(uint32_t addr, uint32_t data, int len);
void npc_init(int argc, char *argv[]);
void print_regs();
bool check_regs(regfile *ref, regfile *dut);
regfile pack_dut_regfile(uint32_t *dut_reg, uint32_t pc);
uint64_t get_time();

#ifdef DIFFTEST_ON
void difftest_init(char *ref_so_file, long img_size);
bool difftest_check();
void difftest_step();
void difftest_skip_ref();
#endif

#ifdef ITRACE_ON
void store_trace_data();
void trace_inst(uint32_t pc, uint32_t inst);
void display_inst();
#endif

#endif