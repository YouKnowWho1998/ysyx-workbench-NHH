TOPNAME = top

#build path
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)
INC_PATH = /home/nhh/ysyx/ysyx-workbench/npc/csrc/include

#ldflags
LDFLAGS += $(shell llvm-config --ldflags)
LIBS += $(shell llvm-config --libs) 

#verilator
VERILATOR = verilator
VERILATOR_FLAGS +=  -MMD -x-assign fast --trace --cc --build 
VERILATOR_FLAGS +=  -CFLAGS -I$(INC_PATH) 
VERILATOR_FLAGS +=  -CFLAGS -g 
VERILATOR_FLAGS +=  -LDFLAGS "$(LDFLAGS) $(LIBS)"
VERILATOR_FLAGS +=  -LDFLAGS -lreadline


#srcs
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v" -or -name "*.sv")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")


#npc_args
DIFFTEST := $(NEMU_HOME)/build/riscv32-nemu-interpreter-so
IMG ?= ../am-kernels/tests/cpu-tests/build/dummy-riscv32e-npc.bin
NPC_ARGS = --img=$(IMG) --diff=$(DIFFTEST)


$(BIN): $(VSRCS) $(CSRCS)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "[VERILATE] $(TOPNAME)"
	@rm -rf $(OBJ_DIR)
	@mkdir -p $(BUILD_DIR)
	@$(VERILATOR)  $(VERILATOR_FLAGS) --top-module $(TOPNAME) --Mdir $(OBJ_DIR) --exe $^ 
	

run: $(BIN)
	@echo "[CPU RUNNING FOR TEST MODULE]"
	$(OBJ_DIR)/V$(TOPNAME) $(NPC_ARGS)

wave:
	gtkwave $(BUILD_DIR)/waves.vcd


clean:
	rm -rf $(BUILD_DIR)

.PHONY:  clean run  wave
include ../Makefile
