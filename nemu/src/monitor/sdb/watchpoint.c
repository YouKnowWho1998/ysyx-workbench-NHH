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

#include "sdb.h"

#define NR_WP 32

typedef struct watchpoint
{
  int NO;
  struct watchpoint *next;
  char expr[32];
  uint32_t value;
  /* TODO: Add more members if necessary */

} WP;

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL; // 两个链表

void init_wp_pool()
{
  int i;
  for (i = 0; i < NR_WP; i++)
  {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = NULL;
  free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */
WP *new_wp()
{
  assert(free_ != NULL); // 如果free_不是NULL则说明空闲链表已经用完
  WP *new = free_;       // 声明结构体指针new指向free_链表第一个元素
  free_ = free_->next;   // free_指针指向free_链表第二个元素
  new->next = head;      // free_链表第一个元素的指针域指向head链表第一个元素（head）
  head = new;            // 将new指针指向的free_链表第一个元素作为head链表的第一个元素（头节点）
  return new;
}

void free_wp(WP *wp)
{
  // 如果是头节点
  if (head == wp)
  {
    WP *p = head;
    head = head->next;
    p->next = free_;
    free_ = p;
  }
  else
  {
    WP *p = head;

    // 如果p没有指向wp位置则不断遍历
    while (p != NULL && p->next != wp)
    {
      p = p->next;
    }

    // 如果没有找到wp位置
    if (p == NULL)
    {
      printf("No watchpoinnts number %d.\n", wp->NO);
      return;
    }

    WP *q = p->next;
    p->next = q->next;
    q->next = free_;
    memset(q->expr, 0, sizeof(q->expr)); // 填充0归还到free_空闲链表中
    free_ = q;
  }
}

void wp_add(char *e)
{
  bool success = true;
  int val = expr(e, &success); // 表达式计算后的值

  if (success)
  {
    WP *p = new_wp();
    memcpy(p->expr, e, strlen(e)); // 存储表达式
    p->value = val;                // 存储表达式的值
  }
  else
  {
    printf("%s:expr error.\n", e);
  }
}

void wp_delete(int n)
{
  WP *p = head;
  while (p != NULL)
  {
    if (p->NO != n)
    {
      p = p->next;
    }
    else
    {
      free_wp(p);
      return;
    }
  }
  printf("No watchpoints NO.%d.\n", n);
}

bool check_watchpoint()
{
  WP *p = head;
  bool changed = false;

  while (p != NULL)
  {
    bool success = true;
    uint32_t val = expr(p->expr, &success);
    assert(success);

    //如果与实际值不符
    if (val != p->value)
    {
      changed = true;
      printf("Watchpoint %d: %s\n\n", p->NO, p->expr);
      printf("The Old Value = %x\n", p->value);
      printf("The New Value = %x\n\n", val);
      p->value = val;
    }
    p = p->next;
  }

  return changed;
}


void watchpoint_display()
{
  WP *p = head;

  if (p == NULL)
  {
    printf("No watchpoints.\n");
  }
  else
  {
    printf("watchpoints list.\n");
    while (p != NULL)
    {
      printf("No.%d:%s.\n", p->NO, p->expr);
      p = p->next; // 遍历链表
    }
  }
}