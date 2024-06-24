TOPNAME = ysyx_23060191_CPU

#build path
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

#verilator
VERILATOR = verilator
VERILATOR_FLAGS += -MMD -cc -O3 --x-assign fast --x-initial fast --noassert -j 4
VERILATOR_FLAGS += --build --trace

#cflags
WORK_PATH = $(shell pwd)
INC_PATH = $(WORK_PATH)/csrc/include
CFLAGS += -CFLAGS -I$(INC_PATH) 
CFLAGS += -CFLAGS "-D__GUEST_ISA__=riscv32"

#srcs
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

#npc_args
NPC_ARGS := --img $(IMG) --log $(BUILD_DIR)/cpu_run.txt


# color
COLOR_RED   		= \033[1;31m
COLOR_GREEN 		= \033[1;32m
COLOR_YELLOW 		= \033[33m
COLOR_NONE  		= \033[0m


$(BIN): $(VSRCS) $(CSRCS)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "$(COLOR_YELLOW)[VERILATE]$(COLOR_NONE) $(TOPNAME)"
	@rm -rf $(OBJ_DIR)
	@mkdir -p $(BUILD_DIR)
	$(VERILATOR) $(CFLAGS) $(VERILATOR_FLAGS) --top-module $(TOPNAME) --Mdir $(OBJ_DIR) --exe $^
	


run: $(BIN)
	@echo "$(COLOR_YELLOW)[CPU RUNNING FOR TEST MODULE]$(COLOR_NONE)"
	$(OBJ_DIR)/V$(TOPNAME) $(NPC_ARGS)


clean:
	rm -rf $(BUILD_DIR)

.PHONY: default  clean run
include ../Makefile
