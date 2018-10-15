#### DIRS ####
INC_DIR := include
SRC_DIR := src
OUT_DIR := out
LCOV_DIR := ../lcov-1.13

#--- object file dir ---
OBJ_DIR:= $(OUT_DIR)/obj

#--- disassembly file dir ---
ASM_DIR:= $(OUT_DIR)/asm

#---  dir ---
BIN_DIR:= $(OUT_DIR)/bin

#### TOOLCHAIN ####
CC := gcc
LL := gcc
LCOV    := $(LCOV_DIR)/bin/lcov
GENHTML := $(LCOV_DIR)/bin/genhtml
GENDESC := $(LCOV_DIR)/bin/gendesc
GENPNG  := $(LCOV_DIR)/bin/genpng
DESCRIPTIONS  := $(LCOV_DIR)/bin/genpng

# Depending on the presence of the GD.pm perl module, we can use the
# special option '--frames' for genhtml
USE_GENPNG := $(shell $(GENPNG) --help >/dev/null 2>/dev/null; echo $$?)

ifeq ($(USE_GENPNG),0)
  FRAMES := --frames
else
  FRAMES :=
endif

#--- OS DEPENDENDT ---
# -p Create Parent Directories as needed
MK_DIR:= mkdir -p


#### FLAGS ###
COMMON_FLAGS := -fprofile-arcs \
                -ftest-coverage

# Compiler Specific Flags
CFLAGS := -Wall

# Linker Specific Flags
LFLAGS := -lgcov

#### INPUT_FILES ####
SRC_FILES := $(SRC_DIR)/main.c

#### OUTPUT_FILES ####
OUT_BIN_NAME := $(BIN_DIR)/run_this.out


###OBJECT DEFINITION###
OBJ = $(OBJ_DIR)/$(notdir $(SRC_FILES:%.c=%.o))


#### RULES ####
# ---rule to build object files
$(OBJ) : $(SRC_FILES) $(OBJ_DIR)
	$(CC) -I$(INC_DIR) $(COMMON_FLAGS) $(CFLAGS) -c $< -o $@

# ---rule to link files
$(OUT_BIN_NAME) : $(OBJ)
	$(LL) -I$(INC_DIR) $(COMMON_FLAGS) $(LFLAGS) $< -o $@



$(OBJ_DIR):
	$(MK_DIR) $@

$(ASM_DIR):
	$(MK_DIR) $@

$(BIN_DIR):
	$(MK_DIR) $@

default:all

#----Phoney Targets ----

.PHONY: all clean lcov

all: $(OBJ_DIR) $(ASM_DIR) $(BIN_DIR) $(OBJ) $(OUT_BIN_NAME)

lcov:
	$(LCOV) --zerocounters --directory .
	./$(OUT_BIN_NAME)
	$(LCOV) --capture --directory . --output-file $(BIN_DIR)/trace_noargs.info --test-name test_noargs --no-external
	$(GENHTML) $(BIN_DIR)/trace_noargs.info \
		   --output-directory $(BIN_DIR)/lcov_html --title "Basic example" \
		   --show-details \
		   --legend

#remove the output dir
clean:
	rm -rf $(OUT_DIR)
	
	
	