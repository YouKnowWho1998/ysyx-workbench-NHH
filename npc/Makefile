TOPNAME = ysyx_23060191_TOP

#build path
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
LOG_DIR = ./log

#verilator
VERILATOR = verilator
VERILATOR_FLAGS += -MMD -cc -O3 --x-assign fast --x-initial fast --noassert -j 4
# VERILATOR_FLAGS += --Wno-CASEINCOMPLETE --Wno-WIDTHEXPAND
VERILATOR_FLAGS += --cc --exe --build --trace

#cflags
WORK_PATH = $(shell pwd)
INC_PATH = $(WORK_PATH)/csrc/include
CFLAGS += -CFLAGS -I$(INC_PATH) 
CFLAGS += -CFLAGS "-D__GUEST_ISA__=riscv32"

#npc_args
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
NPC_ARGS := --img $(IMG) --log $(LOG_DIR)/cpu_run.log


# color
COLOR_RED   		= \033[1;31m
COLOR_GREEN 		= \033[1;32m
COLOR_YELLOW 		= \033[33m
COLOR_NONE  		= \033[0m


build: $(CSRC) $(VSRC)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "$(COLOR_YELLOW)[VERILATE]$(COLOR_NONE) $(TOPNAME)"
	@rm -rf $(OBJ_DIR)
	@mkdir -p $(BUILD_DIR)
	$(VERILATOR) $(CFLAGS) $(VERILATOR_FLAGS) \
	--top-module $(TOPNAME) $^ \
	--Mdir $(OBJ_DIR) -o $(BUILD_DIR)/$(TOPNAME)



run: build
	@echo "$(COLOR_YELLOW)[CPU RUNNING FOR TEST MODULE]$(COLOR_NONE)"
	$(OBJ_DIR)/V$(TOPNAME) $(NPC_ARGS)


clean:
	rm -rf $(BUILD_DIR)

.PHONY: default  clean run
include ../Makefile
