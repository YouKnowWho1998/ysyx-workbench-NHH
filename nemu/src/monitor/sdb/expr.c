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

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>
#include <memory/paddr.h>

enum
{
  TK_NOTYPE = 256,
  TK_EQ,    // ==
  TK_NOTEQ, // !=
  TK_OR,    // ||
  TK_AND,   // &&
  TK_REG,   // 寄存器
  TK_HEX,   // 十六进制
  TK_NUM,   // 数字（十进制）
  // TK_REF    // 解引用(指针)
  /* TODO: Add more token types */
};

// 运算优先级指示符
enum
{
  top4,
  top3,
  top2,
  top1,
  top0,
};


static struct rule
{
  const char *regex;
  int token_type;
} rules[] = {
    /* TODO: Add more rules.
     * Pay attention to the precedence level of different rules.
     */
    {" +", TK_NOTYPE},              // spaces
    {"\\+", '+'},                   // plus
    {"\\=\\=", TK_EQ},              // equal
    {"\\-", '-'},                   // sub
    {"\\*", '*'},                   // mulx
    {"\\/", '/'},                   // divid
    {"\\(", '('},                   // (
    {"\\)", ')'},                   // )
    {"\\!\\=", TK_NOTEQ},           // not_equal
    {"\\|\\|", TK_OR},              // or
    {"\\&\\&", TK_AND},             // and
    {"\\$[a-zA-Z]+[0-9]*", TK_REG}, // 寄存器
    {"0[xX][0-9a-fA-F]+", TK_HEX},  // 十六进制
    {"[0-9]+", TK_NUM}              // 数字
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex()
{
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i++)
  {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0)
    {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token
{
  int type;
  char str[32];
} Token;

static Token tokens[1024] __attribute__((used)) = {};
static int nr_token __attribute__((used)) = 0;

static bool make_token(char *e)
{
  int position = 0;
  int i;
  regmatch_t pmatch;
  nr_token = 0;

  while (e[position] != '\0')
  {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i++)
    {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0)
      {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */

        switch (rules[i].token_type)
        {
        case TK_NOTYPE:
          break;
        case '+':
          tokens[nr_token].type = rules[i].token_type;
          break;
        case TK_EQ:
          tokens[nr_token].type = rules[i].token_type;
          break;
        case '-':
          tokens[nr_token].type = rules[i].token_type;
          break;
        case '*':
          tokens[nr_token].type = rules[i].token_type;
          break;
        case '/':
          tokens[nr_token].type = rules[i].token_type;
          break;
        case '(':
          tokens[nr_token].type = rules[i].token_type;
          break;
        case ')':
          tokens[nr_token].type = rules[i].token_type;
          break;
        case TK_NOTEQ:
          tokens[nr_token].type = rules[i].token_type;
          strcpy(tokens[nr_token].str, "!=");
          break;
        case TK_OR:
          tokens[nr_token].type = rules[i].token_type;
          strcpy(tokens[nr_token].str, "||");
          break;
        case TK_AND:
          tokens[nr_token].type = rules[i].token_type;
          strcpy(tokens[nr_token].str, "&&");
          break;
        case TK_HEX:
        case TK_NUM:
        case TK_REG:
          tokens[nr_token].type = rules[i].token_type;
          strncpy(tokens[nr_token].str, &e[position - substr_len], substr_len);
          break;
        default:
          printf("i = %d and No rules is com.\n", i);
          break;
        }
        ++nr_token;
        break;
      }
    }

    if (i == NR_REGEX)
    {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }
  return true;
}

static bool check_parentheses(int p, int q)
{
  // 没有括号包围
  if (tokens[p].type != '(' || tokens[q].type != ')')
    return false;
  // 括号不匹配
  int pare = 1;
  for (int i = p + 1; i < q; ++i)
  {
    if (tokens[i].type == '(')
      ++pare;
    if (tokens[i].type == ')')
      --pare;
    if (pare == 0)
      return false;
    if (pare < 0)
    {
      printf("Unclosed parentheses before %d.\n", i);
      return false;
    }
  }
  return true;
}

static uint64_t str2int(char *s, unsigned base)
{
  int len = strlen(s);
  uint64_t ret = 0;
  for (int i = 0; i < len; ++i)
  {
    ret = ret * base + s[i] - '0';
  }
  return ret;
}

static uint32_t get_main_op(int p, int q, bool *success)
{
  if (*success == false)
  {
    return 0;
  }

  int op = -1;
  int cnt = 0;
  int top_prior = top0;
  int prior = top0;
  for (int i = p; i < q; i++)
  {
    // 主运算符不能在括号中间
    if (tokens[i].type == '(')
    {
      cnt++;
    }
    else if (tokens[i].type == ')')
    {
      cnt--;
    }
    if (cnt != 0)
    {
      continue;
    }

    // 根据优先级判断主运算符
    if (tokens[i].type == TK_AND || tokens[i].type == TK_OR)
    {
      prior = top4;
    }
    else if (tokens[i].type == TK_EQ || tokens[i].type == TK_NOTEQ)
    {
      prior = top3;
    }
    else if (tokens[i].type == '+' || tokens[i].type == '-')
    {
      prior = top2;
    }
    else if (tokens[i].type == '*' || tokens[i].type == '/')
    {
      prior = top1;
    }
    else
    {
      prior = top0;
    }

    if (prior < top_prior)
    {
      top_prior = prior;
      op = i;
    }
    else if (prior == top_prior)
    {
      // 单运算符从右向左
      op = (top_prior == top0) ? op : i;
    }
  }

  if (top_prior == top0)
  {
    *success = false;
    return 0;
  }
  *success = true;
  return op;
}

static uint32_t eval(int p, int q, bool *success)
{
  if (p > q)
  {
    /* Bad expression */
    *success = false;
    printf("表达式有误，位置在(%d %d).\n", p, q);
    return 0;
  }
  else if (p == q)
  {
    /* Single token.
     * For now this token should be a number.
     * Return the value of the number.
     */
    switch (tokens[p].type)
    {
    case TK_HEX:
      return str2int(tokens[p].str, 16u);
    case TK_NUM:
      return str2int(tokens[p].str, 10u);
    case TK_REG:
      return (uint32_t)isa_reg_str2val(tokens[p].str + 1, success);
    default:
      printf("Wrong expression.\n");
      return 0;
    }
  }
  else if (check_parentheses(p, q) == true)
  {
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */
    return eval(p + 1, q - 1, success);
  }
  else
  {
    /* We should do more things here. */

    // 获得主运算符
    uint32_t op = get_main_op(p, q, success);
    // 递归处理剩余的部分
    uint32_t val1 = eval(p, op - 1, success);
    uint32_t val2 = eval(op + 1, q, success);

    // 计算
    switch (tokens[op].type)
    {
    case '+':
      return val1 + val2;
    case '-':
      return val1 - val2;
    case '*':
      return val1 * val2;
    case '/':
      if (val2 == 0)
      {
        printf("the divisior can not be 0.\n");
        return 0;
      }
      return val1 / val2;
    case TK_EQ:
      return val1 == val2;
    case TK_NOTEQ:
      return val1 != val2;
    case TK_OR:
      return val1 || val2;
    case TK_AND:
      return val1 && val2;
    default:
      printf("there is unknown token type at %d.\n", op);
      return 0;
    }
  }
}

word_t expr(char *e, bool *success)
{
  if (!make_token(e))
  {
    *success = false;
    return 0;
  }
  /* TODO: Insert codes to evaluate the expression. */
  return eval(0, nr_token - 1, success);
}
