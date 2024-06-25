TOPNAME = top

#build path
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

#verilator
VERILATOR = verilator
VERILATOR_FLAGS +=  --trace --cc --build

#debug
VERILATOR_FLAGS +=  --gdbbt --debug


#srcs
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")


#npc_args
#默认加载dummy镜像
IMG ?= /mnt/ysyx/ysyx-workbench/am-kernels/tests/cpu-tests/build/dummy-riscv32e-npc.bin
NPC_ARGS := --img $(IMG) 


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
	$(VERILATOR)  $(VERILATOR_FLAGS) --top-module $(TOPNAME) --Mdir $(OBJ_DIR) --exe $^ 
	

run: $(BIN)
	@echo "$(COLOR_YELLOW)[CPU RUNNING FOR TEST MODULE]$(COLOR_NONE)"
	$(OBJ_DIR)/V$(TOPNAME) $(NPC_ARGS)

wave:
	gtkwave $(BUILD_DIR)/waves.vcd


clean:
	rm -rf $(BUILD_DIR)

.PHONY:  clean run  wave
include ../Makefile
