/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-05-26 21:57:18
 * @LastEditTime : 2024-07-16 17:45:09
 * @FilePath     : /ysyx/ysyx-workbench/abstract-machine/klib/src/stdio.c
 * @Description  :
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

char buf[1024];
void putch(char ch);

int printf(const char *fmt, ...)
{
  va_list ap;
  va_start(ap, fmt);

  int val = vsnprintf(buf, 1024, fmt, ap);
  char *tmp = buf;
  while (*tmp != 0)
  {
    putch(*tmp);
    tmp++;
  }

  va_end(ap);
  return val;
}

int vsprintf(char *out, const char *fmt, va_list ap)
{
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...)
{
  va_list ap;
  va_start(ap, fmt);

  int val = vsnprintf(out, 1024, fmt, ap);
  va_end(ap);

  return val;
}

int snprintf(char *out, size_t n, const char *fmt, ...)
{
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap)
{
  char *start = out;
  while (n-- && *fmt != '\0')
  {
    if (*fmt == '%')
    {
      fmt++;
      if (*fmt == 's')
      {
        char *tmp_s = va_arg(ap, char *);
        while (*tmp_s != '\0')
        {
          *out++ = *tmp_s++;
        }
      }
      else if (*fmt == 'd')
      {
        int tmp_int = va_arg(ap, int);
        if (tmp_int < 0)
        {
          *out++ = '-';
          tmp_int = -1 * tmp_int;
        }
        int number = tmp_int;
        int len = 0;
        do
        {
          number /= 10;
          len++;
        } while (number);
        out = out + len - 1;
        int tmp_len = len;
        while (tmp_len--)
        {
          int tmp = tmp_int % 10;
          *out-- = tmp + 48;
          tmp_int /= 10;
        }
        out += (len + 1);
      }
      else if (*fmt == '%')
      {
        *out++ = '%';
      }
      else if (*fmt == 'c')
      {
        char tmp_char = va_arg(ap, int);
        *out++ = tmp_char;
      }
      else
      {
        return -1;
      }
    }
    else
    {
      *out++ = *fmt;
    }
    fmt++;
  }
  *out = '\0';
  return out - start;
}

#endif
