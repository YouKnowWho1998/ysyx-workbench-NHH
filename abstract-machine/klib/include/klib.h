/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-05-26 21:57:18
 * @LastEditTime : 2024-06-13 20:20:32
 * @FilePath     : \ysyx\ysyx-workbench\abstract-machine\klib\include\klib.h
 * @Description  :
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#ifndef KLIB_H__
#define KLIB_H__

#include <am.h>
#include <stddef.h>
#include <stdarg.h>

#ifdef __cplusplus
extern "C"
{
#endif

#define __NATIVE_USE_KLIB__

  // string.h
  void *memset(void *s, int c, size_t n);
  void *memcpy(void *dst, const void *src, size_t n);
  void *memmove(void *dst, const void *src, size_t n);
  int memcmp(const void *s1, const void *s2, size_t n);
  size_t strlen(const char *s);
  char *strcat(char *dst, const char *src);
  char *strcpy(char *dst, const char *src);
  char *strncpy(char *dst, const char *src, size_t n);
  int strcmp(const char *s1, const char *s2);
  int strncmp(const char *s1, const char *s2, size_t n);

  // stdlib.h
  void srand(unsigned int seed);
  int rand(void);
  void *malloc(size_t size);
  void free(void *ptr);
  int abs(int x);
  int atoi(const char *nptr);

  // stdio.h
  int printf(const char *format, ...);
  int sprintf(char *str, const char *format, ...);
  int snprintf(char *str, size_t size, const char *format, ...);
  int vsprintf(char *str, const char *format, va_list ap);
  int vsnprintf(char *str, size_t size, const char *format, va_list ap);

// assert.h
#ifdef NDEBUG
#define assert(ignore) ((void)0)
#else
#define assert(cond)                                           \
  do                                                           \
  {                                                            \
    if (!(cond))                                               \
    {                                                          \
      printf("Assertion fail at %s:%d\n", __FILE__, __LINE__); \
      halt(1);                                                 \
    }                                                          \
  } while (0)
#endif

#ifdef __cplusplus
}
#endif

#endif
