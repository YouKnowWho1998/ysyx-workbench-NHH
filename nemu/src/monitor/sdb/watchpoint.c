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
  int value;
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
  wp->next = free_;
  free_ = wp;
}

void wp_add(char *e)
{
  WP *wp = NULL;
  bool success;
  int val = expr(e, &success); // 表达式计算后的值

  if (success == false)
  {
    return;
  }

  strcpy(wp->expr, e); // 表达式赋值给节点
  wp->value = val;     // 表达式计算后的值赋值给节点
}

void wp_delete(int n)
{
  WP *wp = NULL;
  WP *p = NULL;

  for (wp = head; wp != NULL; wp = wp->next) // 遍历链表
  {
    if (wp->NO == n) // 要删除的节点
    {
      break;
    }
    p = wp;
  }

  if (wp == NULL)
  {
    return;
  }

  if (p == NULL)
  {
    head = wp->next;
  }
  else
  {
    p->next = wp->next;
  }
}

int check_watchpoint()
{
  WP *wp = NULL;
  int cnt = 0;
  for (wp = head; wp != NULL; wp = wp->next)
  {
    bool success;
    int val = expr(wp->expr, &success);

    // 如果表达式计算的值与结构体中的原值不符
    if (val != wp->value)
    {
      printf("this NO.%d watchpoint is %s.\n", wp->NO, wp->expr);
      printf("the old value is 0x%x.\n", wp->value);
      wp->value = val; // 重新赋值
      printf("the new value is 0x%x.\n", wp->value);
      cnt++;
    }
  }

  if (cnt == 0)
  {
    return 0;
  }

  return 1;
}

void watchpoint_display()
{
  WP *wp = NULL;

  if (head == NULL)
  {
    printf("No watchpoints.\n");
  }
  else
  {
    for (wp = head; wp != NULL; wp = wp->next)
    {
      printf("NUM = %d.\t expr = %s.\n", wp->NO, wp->expr);
    }
  }
}