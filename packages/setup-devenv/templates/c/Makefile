#################################################
### Compiler flags
#################################################
CC = clang
CXX = clang++
CFLAGS = -std=c23 -ggdb3 -O0 -Wall -Wextra -Wpedantic -fno-omit-frame-pointer -fno-optimize-sibling-calls -fsanitize=undefined

#################################################
### Variables
#################################################
SRC_DIR = ./src
OBJ_DIR = ./obj
TRG_DIR = ./build

#################################################
### Files
#################################################
SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
DEPS = $(OBJS:.o=.d)



#################################################
### Targets
#################################################
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(info Compiling $@)
	mkdir -p ${OBJ_DIR}
	$(CC) -c -o $@ $< $(CFLAGS)

$(TRG_DIR)/main: $(OBJS)
	$(info Linking $@)
	mkdir -p ${TRG_DIR}
	$(CC) -o $@ $^ $(CFLAGS)

-include $(DEPS)



#################################################
### Actions
#################################################
.PHONY: clean run check format all build

build: $(TRG_DIR)/main

clean:
	rm -rf $(OBJ_DIR) $(DEPS) $(TRG_DIR)

run: build
	$(TRG_DIR)/main

test: check

debug: build
	gdb --args $(TRG_DIR)/main

check: build
	valgrind --leak-check=full --show-leak-kinds=all $(TRG_DIR)/main

format:
	find $(SRC_DIR) -name "*.c" -o -name "*.h" | xargs clang-format -i

all: clean build
