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

enum
{
  TK_NOTYPE = 256,
  TK_NUM = 1,
  TK_REG = 2,
  TK_HEX = 3,
  TK_EQ = 4,
  TK_NOTEQ = 5,
  TK_OR = 6,
  TK_AND = 7,
  TK_LEFT = 8,
  TK_RIGHT = 9,
  TK_LEQ = 10,
  TK_REF = 11,
  POINT,
  NEG
  /* TODO: Add more token types */

};

static struct rule
{
  const char *regex;
  int token_type;
} rules[] = {

    /* TODO: Add more rules.
     * Pay attention to the precedence level of different rules.
     */

    {" +", TK_NOTYPE}, // spaces
    {"\\+", '+'},      // plus
    {"==", TK_EQ},     // equal
    {"\\-", '-'},      // sub
    {"\\*", '*'},      // mulx
    {"\\/", '/'},      // divid
    {"\\(", TK_LEFT},  // (
    {"\\)", TK_RIGHT}, // )
    {"<=", TK_LEQ},    // left_equal
    {"!=", TK_NOTEQ},  // not_equal
    {"||", TK_OR},     // or
    {"&&", TK_AND},    // and
    {"!", '!'},        // not
    {"\\$[a-zA-Z]*[0-9]*", TK_REG},
    {"0[xX][0-9a-fA-F]+", TK_HEX},
    {"[0-9]*", TK_NUM},
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

        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */
        Token tmp_token;
        switch (rules[i].token_type)
        {
        case '+':
          tmp_token.type = '+';
          tokens[nr_token++] = tmp_token;
          break;
        case '-':
          tmp_token.type = '-';
          tokens[nr_token++] = tmp_token;
          break;
        case '*':
          tmp_token.type = '*';
          tokens[nr_token++] = tmp_token;
          break;
        case '/':
          tmp_token.type = '/';
          tokens[nr_token++] = tmp_token;
          break;
        case 256:
          break;
        case '!':
          tmp_token.type = '!';
          tokens[nr_token++] = tmp_token;
          break;
        case 9:
          tmp_token.type = ')';
          tokens[nr_token++] = tmp_token;
          break;
        case 8:
          tmp_token.type = '(';
          tokens[nr_token++] = tmp_token;
          break;
        case 1:
          tmp_token.type = 1;
          strncpy(tokens[nr_token].str, &e[position - substr_len], substr_len);
          nr_token++;
          break;
        case 2:
          tmp_token.type = 2;
          strncpy(tokens[nr_token].str, &e[position - substr_len], substr_len);
          nr_token++;
          break;
        case 3:
          tmp_token.type = 3;
          strncpy(tokens[nr_token].str, &e[position - substr_len], substr_len);
          nr_token++;
          break;
        case 4:
          tmp_token.type = 4;
          strncpy(tokens[nr_token].str, &e[position - substr_len], substr_len);
          nr_token++;
          break;
        case 5:
          tmp_token.type = 5;
          strncpy(tokens[nr_token].str, &e[position - substr_len], substr_len);
          nr_token++;
          break;
        case 6:
          tmp_token.type = 6;
          strncpy(tokens[nr_token].str, &e[position - substr_len], substr_len);
          nr_token++;
          break;
        case 7:
          tmp_token.type = 7;
          strncpy(tokens[nr_token].str, &e[position - substr_len], substr_len);
          nr_token++;
          break;
        case 10:
          tmp_token.type = 10;
          strncpy(tokens[nr_token].str, &e[position - substr_len], substr_len);
          nr_token++;
          break;
        default:
          printf("i = %d and No rules is com.\n", i);
          break;
        }
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

int max(int a, int b)
{
  return (a > b) ? a : b;
}

uint32_t eval(int p, int q)
{
  if (p > q)
  {
    /* Bad expression */
    assert(0);
    return -1;
  }
  else if (p == q)
  {
    /* Single token.
     * For now this token should be a number.
     * Return the value of the number.
     */
    return atoi(tokens[p].str);
  }
  else if (check_parentheses(p, q) == true)
  {
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */
    return eval(p + 1, q - 1);
  }
  else
  {
    int op = -1; // op = the position of 主运算符 in the token
    bool flag = false;
    for (int i = p; i <= q; i++)
    {
      if (tokens[i].type == '(')
      {
        while (tokens[i].type != ')')
        {
          i++;
        }
      }

      if (!flag && tokens[i].type == 6)
      {
        flag = true;
        op = max(op, i);
      }

      if (!flag && tokens[i].type == 7)
      {
        flag = true;
        op = max(op, i);
      }

      if (!flag && tokens[i].type == 5)
      {
        flag = true;
        op = max(op, i);
      }

      if (!flag && tokens[i].type == 4)
      {
        flag = true;
        op = max(op, i);
      }
      if (!flag && tokens[i].type == 10)
      {
        flag = true;
        op = max(op, i);
      }
      if (!flag && (tokens[i].type == '+' || tokens[i].type == '-'))
      {
        flag = true;
        op = max(op, i);
      }
      if (!flag && (tokens[i].type == '*' || tokens[i].type == '/'))
      {
        op = max(op, i);
      }
    }

    int op_type = tokens[op].type;

    // 剩余的部分
    uint32_t val1 = eval(p, op - 1);
    uint32_t val2 = eval(op + 1, q);

    switch (op_type)
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
        return 0;
      }
      return val1 / val2;

    case 4:
      return val1 == val2;

    case 5:
      return val1 != val2;

    case 6:
      return val1 || val2;

    case 7:
      return val1 && val2;

    default:
      printf("No Op type.");
      assert(0);
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

  return 0;
}
