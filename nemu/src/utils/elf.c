/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-11 13:03:47
 * @LastEditTime : 2024-06-14 20:58:07
 * @FilePath     : \ysyx\ysyx-workbench\nemu\src\utils\elf.c
 * @Description  : 解析elf文件 存入符号表中
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include <elf.h>
#include <common.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <device/map.h>

typedef struct
{
    char name[64];
    Elf32_Addr addr;
    Elf32_Word size;
    unsigned char info;
} Symbol_table;

Symbol_table *symbol_table = NULL;

size_t symbol_tables_size; // 全局变量

void parse_elf(const char *elf_file)
{
    if (elf_file == NULL)
    {
        return;
    }
    // 打开elf文件
    FILE *fp = fopen(elf_file, "rb");
    Assert(fp, "Can not open '%s'", elf_file);

    // 读取ELF header
    Elf32_Ehdr elf_header;
    if (fread(&elf_header, sizeof(Elf32_Ehdr), 1, fp) <= 0)
    {
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    // 检查文件是否为ELF文件
    if (memcmp(elf_header.e_ident, ELFMAG, SELFMAG) != 0)
    {
        fprintf(stderr, "Not an ELF file\n");
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    // 移动到Section header table,寻找字符表节
    fseek(fp, elf_header.e_shoff, SEEK_SET);
    Elf32_Shdr strtab_header;
    while (1)
    {
        if (fread(&strtab_header, sizeof(Elf32_Shdr), 1, fp) <= 0)
        {
            fclose(fp);
            exit(EXIT_FAILURE);
        }
        if (strtab_header.sh_type == SHT_STRTAB)
        {
            break;
        }
    }

    // 读取字符串表内容
    char *string_table = malloc(strtab_header.sh_size);
    fseek(fp, strtab_header.sh_offset, SEEK_SET);
    if (fread(string_table, strtab_header.sh_size, 1, fp) <= 0)
    {
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    // 寻找符号表节
    Elf32_Shdr symtab_header;
    fseek(fp, elf_header.e_shoff, SEEK_SET);
    while (1)
    {
        if (fread(&symtab_header, sizeof(Elf32_Shdr), 1, fp) <= 0)
        {
            fclose(fp);
            exit(EXIT_FAILURE);
        }
        if (symtab_header.sh_type == SHT_SYMTAB)
        {
            break;
        }
    }

    /* 读取符号表中的每个符号项 */

    fseek(fp, symtab_header.sh_offset, SEEK_SET);
    Elf32_Sym symbol;
    // 确定符号表的条数
    size_t num_symbols = symtab_header.sh_size / symtab_header.sh_entsize;
    // 分配内存用于存储符号表
    symbol_table = (Symbol_table *)malloc(num_symbols * sizeof(Symbol_table));

    for (size_t i = 0; i < num_symbols; ++i)
    {
        if (fread(&symbol, sizeof(Elf32_Sym), 1, fp) <= 0)
        {
            fclose(fp);
            exit(EXIT_FAILURE);
        }

        // 判断符号是否为函数，并且函数的大小不为零
        if (ELF64_ST_TYPE(symbol.st_info) == STT_FUNC && symbol.st_size != 0)
        {
            // 从字符串表中获取符号名称
            const char *name = string_table + symbol.st_name;
            // 存储符号信息到 symbol_table 结构体数组
            strncpy(symbol_table[i].name, name, sizeof(symbol_table[i].name) - 1);
            symbol_table[i].addr = symbol.st_value;
            symbol_table[i].info = symbol.st_info;
            symbol_table[i].size = symbol.st_size;
        }
        symbol_tables_size = num_symbols;
    }

    // 关闭文件并释放内存
    fclose(fp);
    free(string_table);
}

int rec_depth = 1;

void call_trace(word_t pc, word_t func_addr)
{
    int i = 0;
    for (; i < symbol_tables_size; i++)
    {
        if (func_addr >= symbol_table[i].addr && func_addr < (symbol_table[i].addr + symbol_table[i].size))
        {
            break;
        }
    }
    printf("[FTRACE] 0x%08x:", pc);

    for (int k = 0; k < rec_depth; k++)
    {
        printf("  ");
    }

    rec_depth++;

    printf("call [%s @0x%08x]\n", symbol_table[i].name, func_addr);
}

void ret_trace(word_t pc)
{
    int i = 0;
    for (; i < symbol_tables_size; i++)
    {
        if (pc >= symbol_table[i].addr && pc < (symbol_table[i].addr + symbol_table[i].size))
        {
            break;
        }
    }

    printf("[FTRACE] 0x%08x:", pc);

    rec_depth--;

    for (int k = 0; k < rec_depth; k++)
        printf("  ");

    printf("ret  [%s]\n", symbol_table[i].name);
}