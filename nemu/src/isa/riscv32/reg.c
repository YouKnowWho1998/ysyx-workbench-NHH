/***************************************************************************************
 * Copyright (c) 2014-2022 Zihao Yu, Nanjing University
 *
 * NEMU is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan PSL v2.
 * You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 *
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 * MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 *
 * See the Mulan PSL v2 for more details.
 ***************************************************************************************/

#include <isa.h>
#include "local-include/reg.h"

const char *regs[] = {
    "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
    "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
    "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
    "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"};

void isa_reg_display()
{
  // 寄存器总个数
  int l = sizeof(regs) / sizeof(regs[0]);
  for (int i = 0; i < l; i++)
  {
    printf("reg(%s) -> %d\n", regs[i], cpu.gpr[i]); // gpr就是对应的寄存器的值
  }
}

word_t isa_reg_str2val(const char *s, bool *success)
{
  if (strlen(s) != 2)
  {
    *success = false;
    return 0;
  }

  // 32个寄存器
  for (int i = 0; i < 32; ++i)
  {
    if (s[0] == regs[i][0] && s[1] == regs[i][1])
    {
      return gpr(i);
    }
  }

  // 如果是PC寄存器
  if (s[0] == 'p' && s[1] == 'c')
  {
    return cpu.pc;
  }

  *success = false;
  return 0;
}
