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

// #include <isa.h>

// /* We use the POSIX regex functions to process regular expressions.
//  * Type 'man regex' for more information about POSIX regex functions.
//  */
// #include <regex.h>
// #include <memory/paddr.h>

// enum
// {
//   TK_NOTYPE = 256,
//   TK_EQ,     // ==
//   TK_NOTEQ,  // !=
//   TK_OR,     // ||
//   TK_AND,    // &&
//   TK_REG,    // 寄存器
//   TK_HEX,    // 十六进制
//   TK_NUM,    // 数字（十进制）
//   TK_NEG,    // 负数
//   TK_POINTER // 解引用(指针)
//   /* TODO: Add more token types */
// };

// // 运算优先级指示符
// enum
// {
//   top5,
//   top4,
//   top3,
//   top2,
//   top1,
//   top0,
// };

// static struct rule
// {
//   const char *regex;
//   int token_type;
// } rules[] = {
//     /* TODO: Add more rules.
//      * Pay attention to the precedence level of different rules.
//      */
//     {" +", TK_NOTYPE},              // spaces
//     {"\\+", '+'},                   // plus
//     {"\\=\\=", TK_EQ},              // equal
//     {"\\-", '-'},                   // sub
//     {"\\*", '*'},                   // mulx
//     {"\\/", '/'},                   // divid
//     {"\\(", '('},                   // (
//     {"\\)", ')'},                   // )
//     {"\\!\\=", TK_NOTEQ},           // not_equal
//     {"\\|\\|", TK_OR},              // or
//     {"\\&\\&", TK_AND},             // and
//     {"\\$[a-zA-Z]+[0-9]*", TK_REG}, // 寄存器
//     {"0[xX][0-9a-fA-F]+", TK_HEX},  // 十六进制
//     {"[0-9]+", TK_NUM}              // 数字
// };

// #define NR_REGEX ARRLEN(rules)

// static regex_t re[NR_REGEX] = {};

// /* Rules are used for many times.
//  * Therefore we compile them only once before any usage.
//  */
// void init_regex()
// {
//   int i;
//   char error_msg[128];
//   int ret;

//   for (i = 0; i < NR_REGEX; i++)
//   {
//     ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
//     if (ret != 0)
//     {
//       regerror(ret, &re[i], error_msg, 128);
//       panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
//     }
//   }
// }

// typedef struct token
// {
//   int type;
//   char str[32];
// } Token;

// static Token tokens[1024] __attribute__((used)) = {};
// static int nr_token __attribute__((used)) = 0;

// static bool make_token(char *e)
// {
//   int position = 0;
//   int i;
//   regmatch_t pmatch;
//   nr_token = 0;

//   while (e[position] != '\0')
//   {
//     /* Try all rules one by one. */
//     for (i = 0; i < NR_REGEX; i++)
//     {
//       if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0)
//       {
//         char *substr_start = e + position;
//         int substr_len = pmatch.rm_eo;

//         Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
//             i, rules[i].regex, position, substr_len, substr_len, substr_start);

//         position += substr_len;

//         /* TODO: Now a new token is recognized with rules[i]. Add codes
//          * to record the token in the array `tokens'. For certain types
//          * of tokens, some extra actions should be performed.
//          */

//         switch (rules[i].token_type)
//         {
//         case TK_NOTYPE:
//           break;
//         case '+':
//           tokens[nr_token].type = rules[i].token_type;
//           break;
//         case TK_EQ:
//           tokens[nr_token].type = rules[i].token_type;
//           break;
//         case '-':
//           tokens[nr_token].type = rules[i].token_type;
//           break;
//         case '*':
//           tokens[nr_token].type = rules[i].token_type;
//           break;
//         case '/':
//           tokens[nr_token].type = rules[i].token_type;
//           break;
//         case '(':
//           tokens[nr_token].type = rules[i].token_type;
//           break;
//         case ')':
//           tokens[nr_token].type = rules[i].token_type;
//           break;
//         case TK_NOTEQ:
//           tokens[nr_token].type = rules[i].token_type;
//           strcpy(tokens[nr_token].str, "!=");
//           break;
//         case TK_OR:
//           tokens[nr_token].type = rules[i].token_type;
//           strcpy(tokens[nr_token].str, "||");
//           break;
//         case TK_AND:
//           tokens[nr_token].type = rules[i].token_type;
//           strcpy(tokens[nr_token].str, "&&");
//           break;
//         case TK_HEX:
//         case TK_NUM:
//         case TK_REG:
//           tokens[nr_token].type = rules[i].token_type;
//           strncpy(tokens[nr_token].str, &e[position - substr_len], substr_len);
//           break;
//         default:
//           printf("i = %d and No rules is com.\n", i);
//           break;
//         }
//         ++nr_token;
//         break;
//       }
//     }

//     if (i == NR_REGEX)
//     {
//       printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
//       return false;
//     }
//   }
//   return true;
// }

// static bool check_parentheses(int p, int q)
// {
//   // 没有括号包围
//   if (tokens[p].type != '(' || tokens[q].type != ')')
//     return false;
//   // 括号不匹配
//   int pare = 1;
//   for (int i = p + 1; i < q; ++i)
//   {
//     if (tokens[i].type == '(')
//       ++pare;
//     if (tokens[i].type == ')')
//       --pare;
//     if (pare == 0)
//       return false;
//     if (pare < 0)
//     {
//       printf("Unclosed parentheses before %d.\n", i);
//       return false;
//     }
//   }
//   return true;
// }

// static uint64_t str2int(char *s, unsigned base)
// {
//   int len = strlen(s);
//   uint64_t ret = 0;
//   for (int i = 0; i < len; ++i)
//   {
//     ret = ret * base + s[i] - '0';
//   }
//   return ret;
// }

// static uint32_t get_main_op(int p, int q, bool *success)
// {
//   if (*success == false)
//   {
//     return 0;
//   }

//   int op = -1;
//   int cnt = 0;
//   int top_prior = top0;
//   int prior = top0;
//   for (int i = p; i < q; i++)
//   {
//     // 主运算符不能在括号中间
//     if (tokens[i].type == '(')
//     {
//       cnt++;
//     }
//     else if (tokens[i].type == ')')
//     {
//       cnt--;
//     }
//     if (cnt != 0)
//     {
//       continue;
//     }

//     // 根据优先级判断主运算符
//     if (tokens[i].type == TK_AND || tokens[i].type == TK_OR)
//     {
//       prior = top5;
//     }
//     else if (tokens[i].type == TK_EQ || tokens[i].type == TK_NOTEQ)
//     {
//       prior = top4;
//     }
//     else if (tokens[i].type == '+' || tokens[i].type == '-')
//     {
//       prior = top3;
//     }
//     else if (tokens[i].type == '*' || tokens[i].type == '/')
//     {
//       prior = top2;
//     }
//     else if(tokens[i].type == TK_POINTER || tokens[i].type == TK_NEG)
//     {
//       prior = top1;
//     }
//     else
//     {
//       prior = top0;
//     }

//     if (prior < top_prior)
//     {
//       top_prior = prior;
//       op = i;
//     }
//     else if (prior == top_prior)
//     {
//       // 单运算符从右向左
//       op = (top_prior == top0) ? op : i;
//     }
//   }

//   if (top_prior == top0)
//   {
//     *success = false;
//     return 0;
//   }
//   *success = true;
//   return op;
// }

// static uint32_t eval(int p, int q, bool *success)
// {
//   if (p > q)
//   {
//     /* Bad expression */
//     *success = false;
//     printf("表达式有误，位置在(%d %d).\n", p, q);
//     return 0;
//   }
//   else if (p == q)
//   {
//     /* Single token.
//      * For now this token should be a number.
//      * Return the value of the number.
//      */
//     switch (tokens[p].type)
//     {
//     case TK_HEX:
//       return str2int(tokens[p].str, 16u);
//     case TK_NUM:
//       return str2int(tokens[p].str, 10u);
//     case TK_REG:
//       return (uint32_t)isa_reg_str2val(tokens[p].str + 1, success); // 返回寄存器的值
//     default:
//       printf("Wrong expression.\n");
//       *success = false;
//       return 0;
//     }
//   }
//   else if (check_parentheses(p, q) == true)
//   {
//     /* The expression is surrounded by a matched pair of parentheses.
//      * If that is the case, just throw away the parentheses.
//      */
//     return eval(p + 1, q - 1, success);
//   }
//   else
//   {
//     /* We should do more things here. */

//     // 获得主运算符
//     uint32_t op = get_main_op(p, q, success);
//     // 递归处理剩余的部分
//     uint32_t val1 = eval(p, op - 1, success);
//     uint32_t val2 = eval(op + 1, q, success);

//     // 计算
//     switch (tokens[op].type)
//     {
//     case '+':
//       return val1 + val2;
//     case '-':
//       return val1 - val2;
//     case '*':
//       return val1 * val2;
//     case '/':
//       if (val2 == 0)
//       {
//         printf("the divisior can not be 0.\n");
//         return 0;
//       }
//       return val1 / val2;
//     case TK_EQ:
//       return val1 == val2;
//     case TK_NOTEQ:
//       return val1 != val2;
//     case TK_OR:
//       return val1 || val2;
//     case TK_AND:
//       return val1 && val2;
//     case TK_NEG:
//       return -val2;
//     case TK_POINTER:
//       return paddr_read(val2, 4);
//     default:
//       printf("there is unknown token type at %d.\n", op);
//       *success = false;
//       return 0;
//     }
//   }
// }

// // 对应负数和指针解引用情况的综合
// #define ALL tokens[i - 1].type == (TK_NOTYPE || tokens[i - 1].type == '+' || 
//                                    tokens[i - 1].type == '-' ||              
//                                    tokens[i - 1].type == '*' ||              
//                                    tokens[i - 1].type == '/' ||              
//                                    tokens[i - 1].type == '(' ||              
//                                    tokens[i - 1].type == ')' ||              
//                                    tokens[i - 1].type == TK_AND ||           
//                                    tokens[i - 1].type == TK_OR ||            
//                                    tokens[i - 1].type == TK_NEG ||           
//                                    tokens[i - 1].type == TK_POINTER)

// // 执行函数
// word_t expr(char *e, bool *success)
// {
//   if (!make_token(e))
//   {
//     *success = false;
//     return 0;
//   }
//   /* TODO: Insert codes to evaluate the expression. */
//   for (int i = 0; i < nr_token; i++)
//   {
//     // 指针解引用识别
//     if (tokens[i].type == '*' && (i == 0 || ALL))
//     {
//       tokens[i].type = TK_POINTER;
//     }

//     // 负数识别
//     if (tokens[i].type == '-' && (i == 0 || ALL))
//     {
//       tokens[i].type = TK_NEG;
//     }
//   }
//   *success = true;

//   return eval(0, nr_token - 1, success);
// }

#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>
#include <memory/vaddr.h>

enum
{
  TK_NOTYPE = 256,
  TK_EQ,
  TK_NEQ,
  TK_AND,
  TK_OR,
  TK_HEX,
  TK_DEC,
  TK_REG,
  TK_MINUS,
  TK_DEREF,
};

enum
{
  PR_0,
  PR_1,
  PR_2,
  PR_3,
  PR_4,
  PR_MAX,
};

static char reg_rule[] = "\\$\\$0|"
                         "\\$ra|"
                         "\\$sp|"
                         "\\$gp|"
                         "\\$tp|"
                         "\\$t[0-6]|"
                         "\\$s[0-9]|"
                         "\\$s1[0-1]|"
                         "\\$a[0-7]|"
                         "\\$pc";

static struct rule
{
  const char *regex;
  int token_type;
} rules[] = {

    /* TODO: Add more rules.
     * Pay attention to the precedence level of different rules.
     */

    {" +", TK_NOTYPE},             // spaces
    {"==", TK_EQ},                 // equal
    {"!=", TK_NEQ},                // not equal
    {"\\+", '+'},                  // plus
    {"-", '-'},                    // minus
    {"\\*", '*'},                  // mul
    {"/", '/'},                    // div
    {"\\(", '('},                  // left
    {"\\)", ')'},                  // right
    {"&&", TK_AND},                // and
    {"\\|\\|", TK_OR},             // or
    {"0[xX][0-9a-fA-F]+", TK_HEX}, // hex number
    {"[0-9]+", TK_DEC},            // dec number
    {reg_rule, TK_REG},            // regs
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

        if (substr_len >= 32)
        {
          printf("Substring is too long.\n");
          return false;
        }

        switch (rules[i].token_type)
        {
        case TK_NOTYPE:
          break;
        default:
          tokens[nr_token].type = rules[i].token_type;
          memcpy(tokens[nr_token].str, substr_start, substr_len);
          tokens[nr_token].str[substr_len] = '\0';
          nr_token++;
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

bool check_parentheses(int p, int q, bool *success)
{
  if (*success == false)
  {
    return false;
  }

  int left_count = 0;
  int right_count = 0;

  for (int i = p; i < q; i++)
  {
    if (tokens[i].type == '(')
    {
      left_count++;
    }
    else if (tokens[i].type == ')')
    {
      right_count++;
    }

    if (right_count > left_count)
    {
      *success = false;
      return false;
    }
  }

  *success = true;
  if (tokens[p].type == '(' && tokens[q].type == ')')
  {
    return true;
  }
  else
  {
    return false;
  }
}

word_t find_main_op(int p, int q, bool *success)
{
  // printf("find: p=%d, q=%d\n",p,q);
  if (*success == false)
  {
    return 0;
  }

  int prior = PR_MAX;
  int position = 0;
  int cnt = 0;
  int cur_prior = PR_MAX;
  for (int i = p; i < q; i++)
  {
    /* main operator is not between () */
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

    /* determain main operator according to priority */
    if (tokens[i].type == TK_AND || tokens[i].type == TK_OR)
    {
      cur_prior = PR_0;
    }
    else if (tokens[i].type == TK_EQ || tokens[i].type == TK_NEQ)
    {
      cur_prior = PR_1;
    }
    else if (tokens[i].type == '+' || tokens[i].type == '-')
    {
      cur_prior = PR_2;
    }
    else if (tokens[i].type == '*' || tokens[i].type == '/')
    {
      cur_prior = PR_3;
    }
    else if (tokens[i].type == TK_MINUS || tokens[i].type == TK_DEREF)
    {
      cur_prior = PR_4;
    }
    else
    {
      cur_prior = PR_MAX;
    }

    if (cur_prior < prior)
    {
      prior = cur_prior;
      position = i;
      // printf("1, pos:%d, pri=%d\n", position, prior);
    }
    else if (cur_prior == prior)
    {
      // unary operators is right to left
      position = prior == PR_4 ? position : i;
      // printf("2, pos:%d, pri=%d\n", position, prior);
    }
  }

  if (prior == PR_MAX)
  {
    *success = false;
    return 0;
  }

  *success = true;
  // printf("find: position=%d prior=%d\n", position, prior);
  return position;
}

word_t eval(int p, int q, bool *success)
{
  if (*success == false)
  {
    return 0;
  }

  if (p > q)
  {
    /* Bad expression */
    // printf("p:%d q:%d\n", p, q);
    printf("Wrong expression1.\n");
    *success = false;
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
      return (word_t)strtol(tokens[p].str, NULL, 16);
    case TK_DEC:
      return (word_t)strtol(tokens[p].str, NULL, 10);
    case TK_REG:
      return isa_reg_str2val(tokens[p].str + 1, success);
    default:
      printf("Wrong expression2.\n");
      *success = false;
      return 0;
    }
  }
  else if (check_parentheses(p, q, success) == true)
  {
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */
    return eval(p + 1, q - 1, success);
  }
  else
  {
    // printf("p=%d, q=%d\n", p, q);
    // printf("ptoken=%d, qtoken=%d\n",tokens[p].type, tokens[q].type);
    word_t op = find_main_op(p, q, success);
    // printf("op=%d token=%d\n",op, tokens[op].type);
    word_t val1 = 0;
    word_t val2 = 0;
    if (op >= p + 1)
    {
      val1 = eval(p, op - 1, success);
    }
    if (q >= op + 1)
    {
      val2 = eval(op + 1, q, success);
    }

    switch (tokens[op].type)
    {
    case TK_AND:
      return val1 && val2;
    case TK_OR:
      return val1 || val2;
    case TK_EQ:
      return val1 == val2;
    case TK_NEQ:
      return val1 != val2;
    case '+':
      return val1 + val2;
    case '-':
      return val1 - val2;
    case '*':
      return val1 * val2;
    case '/':
      if (val2 != 0)
      {
        return val1 / val2;
      }
      else
      {
        printf("Cannot divide zero.\n");
        *success = false;
        return 0;
      }
    case TK_MINUS:
      return -val2;
    case TK_DEREF:
      return vaddr_read(val2, 4);
    default:
      // printf("op=%d token=%d\n",op, tokens[op].type);
      printf("Wrong expression3.\n");
      *success = false;
      return 0;
    }
  }
}

#define CER_TYPE tokens[i - 1].type == TK_EQ ||        \
                     tokens[i - 1].type == TK_NEQ ||   \
                     tokens[i - 1].type == '+' ||      \
                     tokens[i - 1].type == '-' ||      \
                     tokens[i - 1].type == '*' ||      \
                     tokens[i - 1].type == '/' ||      \
                     tokens[i - 1].type == '(' ||      \
                     tokens[i - 1].type == TK_AND ||   \
                     tokens[i - 1].type == TK_OR ||    \
                     tokens[i - 1].type == TK_MINUS || \
                     tokens[i - 1].type == TK_DEREF

word_t expr(char *e, bool *success)
{
  if (!make_token(e))
  {
    *success = false;
    return 0;
  }

  for (int i = 0; i < nr_token; i++)
  {
    if (tokens[i].type == '*' && (i == 0 || CER_TYPE))
    {
      tokens[i].type = TK_DEREF;
    }
    else if (tokens[i].type == '-' && (i == 0 || CER_TYPE))
    {
      tokens[i].type = TK_MINUS;
    }
  }

  *success = true;
  return eval(0, nr_token - 1, success);
}