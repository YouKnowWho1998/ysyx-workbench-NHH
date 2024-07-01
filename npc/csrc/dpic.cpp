/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 22:06:37
 * @LastEditTime : 2024-07-01 23:06:11
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\dpic.cpp
 * @Description  : DPIC
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include "include.h"
#include "verilated_dpi.h"

extern bool rstn_sync;
extern "C" void check_rstn(svBit rstn_flag)
{
    if (rstn_flag)
    {
        rstn_sync = true;
    }
    else
    {
        rstn_sync = false;
    }
}

extern "C" svBit check_finish(int inst)
{
    if (inst == 0x100073) // ebreak;
        return 1;
    else
        return 0;
}

extern "C" void npc_pmem_read(uint32_t rd_addr, uint32_t *rd_data, svBit rd_en)
{
    if (rd_en && rd_addr >= PMEM_LEFT && rd_addr <= PMEM_RIGHT)
    {
        *rd_data = pmem_read(rd_addr, 4);
    }
    else
        *rd_data = 0;
}

extern "C" void npc_pmem_write(uint32_t wr_addr, uint32_t wr_data, const svBitVecVal *wr_mask)
{
    // printf("wr_addr = 0x%x,wr_data = 0x%x,wr_mask = 0x%x\n",wr_addr,wr_data,*wr_mask);
    // waddr = waddr & ~0x7ull;  //clear low 3bit for 8byte align.
    switch (*wr_mask)
    {
    case 1:
        pmem_write(wr_addr, wr_data, 1);
        break; // 4'b0001, 1byte.
    case 3:
        pmem_write(wr_addr, wr_data, 2);
        break; // 4'b0011, 2byte.
    case 15:
        pmem_write(wr_addr, wr_data, 4);
        break; // 4'b1111, 4byte.
    default:
        break;
    }
}

//获取处理器内部寄存器值,PC值,指令值
extern uint32_t *dut_reg;
extern uint32_t dut_pc;
extern uint32_t dut_inst;

extern "C" void get_dut_reg(const svOpenArrayHandle r){
    dut_reg = (uint32_t *)(((VerilatedDpiOpenVar *)r)->datap());
}

extern "C" void get_dut_pc(uint32_t npc_pc){
    dut_pc = npc_pc;
}

extern "C" void get_dut_inst(uint32_t npc_inst){
    dut_inst = npc_inst;
}