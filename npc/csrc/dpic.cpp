#include "include/include.h"
#include "verilated_dpi.h"

extern "C" svBit check_finish(int inst)
{
    if (inst == 0x100073 || inst == 0x00006f) // ebreak;
        return 1;
    else
        return 0;
}

extern "C" int npc_pmem_read(uint32_t raddr)
{
    int inst = 0;
    if (raddr >= PMEM_START && raddr <= PMEM_END)
    {
        inst = pmem_read(raddr, 4);
    }
    return inst;
}