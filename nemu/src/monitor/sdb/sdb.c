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
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <memory/paddr.h>
#include <memory/vaddr.h>
#include "sdb.h"

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char *rl_gets()
{
  static char *line_read = NULL;

  if (line_read)
  {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");

  if (line_read && *line_read)
  {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args)
{
  cpu_exec(-1);
  return 0;
}

static int cmd_q(char *args)
{
  nemu_state.state = NEMU_QUIT;
  return -1;
}

// 单步执行
__attribute__((used)) static int cmd_si(char *args)
{
  int step = 0;
  if (args == NULL)
  {
    step = 1;
  }
  else
  {
    // 固定字符输入源 args -> step 格式为%d
    sscanf(args, "%d", &step);
  }
  cpu_exec(step);
  return 0;
}

// 打印寄存器的值
__attribute__((used)) static int cmd_info(char *args)
{
  if (args == NULL)
  {
    printf("No commands\n");
    return 0;
  }
  // 当输入字符是r时表示读取 strcmp是字符串比较函数 相同时输出0
  if (strcmp(args, "r") == 0)
  {
    isa_reg_display();
  }
  return 0;
}

// 扫描内存
__attribute__((used)) static int cmd_x(char *args)
{
  if (args == NULL)
  {
    return 0;
  }

  char *first_str = strtok(args, " "); // 分割的第一个字符串
  char *after_str = strtok(NULL, " "); // 输入NULL是因为 用分割完第一个字符串的args继续分割
  int length = 0;
  paddr_t addr = 0;
  sscanf(first_str, "%d", &length);
  sscanf(after_str, "%x", &addr);
  for (int i = 0; i < length; i++)
  {
    printf("%x\n", paddr_read(addr, 4)); // 打印出结果
    addr = addr + 4;                     //+4是因为32位指令集 四个字节(PC)
  }
  return 0;
}

// 表达式求值
__attribute__((used)) static int cmd_p(char *args)
{
  if (args == NULL)
  {
    printf("No args\n");
    return 0;
  }

  bool success = true;
  uint64_t ret = expr(args, &success);

  if (success)
  {
    printf("%s = %lx(%lu)\n", args, ret, ret);
  }
  else
  {
    printf("%s: Syntax Error.\n", args);
  }
  return 0;
}

static int cmd_help(char *args);

static struct
{
  const char *name;
  const char *description;
  int (*handler)(char *);
} cmd_table[] = {
    {"help", "Display information about all supported commands", cmd_help},
    {"c", "Continue the execution of the program", cmd_c},
    {"q", "Exit NEMU", cmd_q},
    {"si", "单步打印", cmd_si},
    {"info", "打印寄存器", cmd_info},
    {"x", "扫描内存", cmd_x},
    {"p", "表达式求值", cmd_p},

    /* TODO: Add more commands */

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args)
{
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL)
  {
    /* no argument given */
    for (i = 0; i < NR_CMD; i++)
    {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else
  {
    for (i = 0; i < NR_CMD; i++)
    {
      if (strcmp(arg, cmd_table[i].name) == 0)
      {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

void sdb_set_batch_mode()
{
  is_batch_mode = true;
}

void sdb_mainloop()
{
  if (is_batch_mode)
  {
    cmd_c(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL;)
  {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL)
    {
      continue;
    }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end)
    {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i++)
    {
      if (strcmp(cmd, cmd_table[i].name) == 0)
      {
        if (cmd_table[i].handler(args) < 0)
        {
          return;
        }
        break;
      }
    }

    if (i == NR_CMD)
    {
      printf("Unknown command '%s'\n", cmd);
    }
  }
}

void init_sdb()
{
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}