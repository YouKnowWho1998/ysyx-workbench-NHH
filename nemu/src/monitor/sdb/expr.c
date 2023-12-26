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
  TK_NUM,   // 数字（十进制）
  TK_REG,   // 寄存器
  TK_HEX,   // 十六进制
  TK_EQ,    // ==
  TK_NOTEQ, // !=
  TK_OR,    // |
  TK_AND,   // &&
  TK_REF    // 解引用(指针)
  /* TODO: Add more token types */

};

static int token_rank[512];

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
    {"==", TK_EQ},                  // equal
    {"\\-", '-'},                   // sub
    {"\\*", '*'},                   // mulx
    {"\\/", '/'},                   // divid
    {"\\(", '('},                   // (
    {"\\)", ')'},                   // )
    {"!=", TK_NOTEQ},               // not_equal
    {"||", TK_OR},                  // or
    {"&&", TK_AND},                 // and
    {"\\$[a-zA-Z]+[0-9]*", TK_REG}, // 寄存器
    {"0[xX][0-9a-fA-F]+", TK_HEX},  // 十六进制
    {"[0-9]+", TK_NUM},             // 数字
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

static Token tokens[32] __attribute__((used)) = {};
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
        position += substr_len;
        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */
        // 匹配规则
        if (rules[i].token_type == TK_NOTYPE) // 排除空格
        {
          break;
        }

        tokens[nr_token].type = rules[i].token_type;
        switch (rules[i].token_type)
        {
        case TK_NUM:
        case TK_HEX:
        case TK_REG:
          assert(substr_len <= 32); // 小于32bit
          memset(tokens[nr_token].str, 0, sizeof(tokens[nr_token].str));
          memcpy(tokens[nr_token].str, substr_start, substr_len);
          break;

        default:
          break;
        }
        nr_token++;
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

bool check_parentheses(int p, int q)
{
  if (tokens[p].type != '(' || tokens[q].type != ')')
    return false;

  int l = p, r = q;
  while (l < r)
  {
    if (tokens[l].type == '(')
    {
      if (tokens[r].type == ')')
      {
        l++, r--;
        continue;
      }
      else
        r--;
    }
    else if (tokens[l].type == ')')
      return false;
    else
      l++;
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

static uint64_t eval(int p, int q, bool *success)
{
  if (*success == false)
  {
    return 0;
  }

  // bad expression
  if (p > q)
  {
    *success = false;
    printf("Bad expression at eval(%d %d).\n", p, q);
    return 0;
  }
  else if (p == q)
  /* Single token.
   * For now this token should be a number.
   * Return the value of the number.
   */
  {
    if (tokens[p].type == TK_NUM)
      return str2int(tokens[p].str, 10u);
    if (tokens[p].type == TK_HEX)
      return str2int(tokens[p].str, 16u);
    else if (tokens[p].type == TK_REG)
    {
      uint64_t ret = isa_reg_str2val(tokens[p].str + 1, success);
      if (*success == false)
      {
        printf("No such register '%s'.\n", tokens[p].str);
        return 0;
      }
      return ret;
    }
    else
    {
      *success = false;
      printf("Token '%s' is not a number or a register.\n", tokens[p].str);
      return 0;
    }
  }
  else if (check_parentheses(p, q) == true)
  /* The expression is surrounded by a matched pair of parentheses.
   * If that is the case, just throw away the parentheses.
   */
  {
    return eval(p + 1, q - 1, success);
  }
  else
  {
    if (*success == false)
    {
      return 0;
    }
    int op = -1;
    int par = 0;
    for (int i = 0; i <= q; i++)
    {
      if (tokens[i].type == '(')
        ++par;
      if (tokens[i].type == ')')
        --par;
      if (par == 0)
      {
        if (token_rank[tokens[i].type] == 0)
          continue;
        if (op == -1 || token_rank[tokens[i].type] >= token_rank[tokens[op].type])
          op = i;
      }
    }
    // 没有发现主运算符
    if (op == -1)
    {
      *success = false;
      printf("Cannot find the main operator at eval(%d, %d).\n", p, q);
      return 0;
    }
    //指针
    if (p == op)
    {
      uint64_t res = eval(op + 1, q, success);
      if (*success == false)
        return 0;
      if (tokens[op].type == TK_REF)
        return (uint64_t)(*guest_to_host(res));
      *success = false;
      return 0;
    }
    uint64_t val1 = eval(p, op - 1, success);
    uint64_t val2 = eval(op + 1, q, success);

    if (*success == false)
    {
      return 0;
    }

    switch (tokens[op].type)
    {
    case '+':
      return val1 + val2;
    case '-':
      return val1 - val2;
    case '*':
      return val1 * val2;
    case '/':
      // The divisor cannot be zero
      if (val2 == 0)
      {
        success = false;
        printf("The divisior might be zero while calculating at eval(%d, %d).\n", p, q);
        return 0;
      }
      return val1 / val2;
    case TK_EQ:
      return val1 == val2;
    case TK_NOTEQ:
      return val1 != val2;
    case TK_AND:
      return val1 && val2;
    case TK_OR:
      return val1 || val2;
    default:
      *success = false;
      printf("Unknown token's type at %d.\n", op);
      return 0;
    }
  }
}

static void init_token_rank()
{
#define r token_rank
  r['('] = r[')'] = 1;        // 1: ( )
  r['/'] = r['*'] = 2;        // 2: / *
  r['+'] = r['-'] = 3;        // 3: + -
  r[TK_EQ] = r[TK_NOTEQ] = 4; // 4: == !=
  r[TK_AND] = 6;              // 5: &&
}

word_t expr(char *e, bool *success)
{
  if (!make_token(e))
  {
    *success = false;
    return 0;
  }
  /* TODO: Insert codes to evaluate the expression. */
  init_token_rank();

  for (int i = 0; i < nr_token; ++i)
  {
    if (i == 0 || (tokens[i - 1].type != TK_NUM && tokens[i - 1].type != TK_HEX && tokens[i - 1].type != ')' && tokens[i - 1].type != TK_REG))
    {
      // 解引用
      if (tokens[i].type == '*')
        tokens[i].type = TK_REF;
    }
  }

  uint64_t ret = eval(0, nr_token - 1, success);

  if (*success == false)
    return 0;

  return ret;
}
