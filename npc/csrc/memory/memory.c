#include <memory.h>
#include <common.h>
#include <debug.h>

static uint8_t *pmem = NULL;

// 内建镜像程序
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

void init_mem(size_t size)
{
    pmem = (uint8_t *)malloc(size * sizeof(uint8_t));
    memcpy(pmem, img, sizeof(img));
    if (pmem == NULL)
    {
        exit(0);
    }
    Log("npc physical memory area [%#x, %#lx]", RESET_VECTOR, RESET_VECTOR + size * sizeof(uint8_t));
}

uint8_t *guest_to_host(uint32_t paddr) { return pmem + (paddr - RESET_VECTOR); }

extern "C" uint32_t pmem_read(uint32_t paddr)
{
    if (!(paddr >= 0x80000000 && paddr <= 0x87ffffff))
    {
        return 0;
    }
    uint32_t *inst_paddr = (uint32_t *)guest_to_host(paddr);
    return *inst_paddr;
}

extern "C" void pmem_write(int waddr, int wdata, char wmask)
{
    if (!(waddr >= 0x80000000 && waddr <= 0x87ffffff))
    {
        return;
    }

    uint8_t *vaddr = guest_to_host(waddr);
    uint8_t *iaddr;
    int i;
    int j;
    for (i = 0, j = 0; i < 4; i++)
    {
        if (wmask & (1 << i))
        {
            iaddr = vaddr + i;
            *iaddr = (wdata >> (j * 8)) & 0xFF;
            j++;
        }
    }
}
