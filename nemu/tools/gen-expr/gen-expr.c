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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>

// this should be enough
static char buf[65536] = {};
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
    "#include <stdio.h>\n"
    "int main() { "
    "  unsigned result = %s; "
    "  printf(\"%%u\", result); "
    "  return 0; "
    "}";
static int len = 0;

// 随机生成数字
static void gen_num(int l)
{
  // 第一位不能是0
  buf[len++] = '0' + rand() % 9 + 1; // 1~9之间
  --l;
  for (int i = 0; i < l; i++)
  {
    buf[len++] = '0' + rand() % 10;
  }
  buf[len++] = 'u';
  buf[len++] = 'l';
  buf[len++] = 'l';
}

// 随机生成空格
static void rand_whitespace()
{
  int num = rand() % 10 + 1;
  for (int i = 0; i < num; i++)
  {
    if (rand() % 7 == 2)
    {
      buf[len++] = ' ';
    }
  }
}

// 随机生成表达式
static void gen_rand_expr(int dep)
{
  if (dep = 0)
  {
    len = 0;
  }
  if (dep > 50)
  {
    rand_whitespace();
    gen_num(rand() % 10 + 1);
    rand_whitespace();
    return;
  }
  switch (rand() % 3)
  {
  case 0:
    rand_whitespace();
    gen_num(rand() % 16 + 1);
    rand_whitespace();
    break;
  case 1:
    rand_whitespace();
    buf[len++] = '(';
    rand_whitespace();
    gen_rand_expr(dep + 1);
    rand_whitespace();
    buf[len++] = ')';
    rand_whitespace();
    break;
  case 2:
    rand_whitespace();
    gen_rand_expr(dep + 1);
    rand_whitespace();
    switch (rand() % 4)
    {
    case 0:
      buf[len++] = '+';
      break;
    case 1:
      buf[len++] = '-';
      break;
    case 2:
      buf[len++] = '*';
      break;
    case 3:
      buf[len++] = '/';
      break;
    }
    rand_whitespace();
    gen_rand_expr(dep + 1);
    rand_whitespace();
    break;
  }
  if (dep == 0)
  {
    buf[len++] = '\0';
  }
}

int main(int argc, char *argv[])
{
  int seed = time(0);
  srand(seed);
  int loop = 1;
  if (argc > 1)
  {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  for (i = 0; i < loop; i++)
  {
    gen_rand_expr();

    sprintf(code_buf, code_format, buf);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    unsigned long long result;
    ret = fscanf(fp, "%llu", &result);
    pclose(fp);

    if (ret != 1)
    {
      --i;
      continue;
    }
    for (int i = 0; buf[i] != '\0'; ++i)
    {
      if (buf[i] == 'u' || buf[i] == 'l')
      {
        buf[i] = ' ';
      }
    }
    printf("%llu %s\n", result, buf);
    fflush(stdout);
  }
  return 0;
}
