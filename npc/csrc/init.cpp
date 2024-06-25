/*
 * @Author       : 中北大学-聂怀昊
 * @Date         : 2024-06-24 20:49:24
 * @LastEditTime : 2024-06-25 13:21:54
 * @FilePath     : \ysyx\ysyx-workbench\npc\csrc\init.cpp
 * @Description  : 修改自NEMU
 *
 * Copyright (c) 2024 by 873040830@qq.com, All Rights Reserved.
 */
#include "include/include.h"
#include <getopt.h>

static char *img_file = NULL;
static char *diff_so_file = NULL;

static int parse_args(int argc, char *argv[])
{
    const struct option table[] = {
        {"img", required_argument, NULL, 'i'},
        {"diff", required_argument, NULL, 'd'},
        {0, 0, NULL, 0},
    };
    int o;
    while ((o = getopt_long(argc, argv, "-d:i:", table, NULL)) != -1)
    {
        switch (o)
        {
        case 'i':
            img_file = optarg;
            break;
        case 'd':
            diff_so_file = optarg;
            break;
        }
    }
    return 0;
}


static long load_img(char *img_file)
{
    if (img_file == NULL)
    {
        printf("No image is given. Use the default build-in image.\n");
        return 4096; // built-in image size
    }

    FILE *fp = fopen(img_file, "rb");
    if (fp == NULL)
    {
        printf("Can not open '%s'\n", img_file);
        assert(0);
    }

    fseek(fp, 0, SEEK_END); // move cur to end.
    long size = ftell(fp);

    fseek(fp, 0, SEEK_SET);
    int ret = fread(guest_to_host(PMEM_START), size, 1, fp);
    assert(ret == 1);

    fclose(fp);
    return size;
}

void npc_init(int argc, char *argv[])
{
    /* Perform some global initialization. */

    /* Parse arguments. */
    parse_args(argc, argv);

    init_mem(PMEM_MSIZE);

    /* Load the image to memory. This will overwrite the built-in image. */
    long img_size = load_img(img_file);

    // #ifdef DIFFTEST_ON
    //     /* Initialize differential testing. */
    //     difftest_init(diff_so_file, img_size);
    // #endif
}
