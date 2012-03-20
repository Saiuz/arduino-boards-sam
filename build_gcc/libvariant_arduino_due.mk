#
#  Copyright (c) 2011 Arduino.  All right reserved.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
#  See the GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

# Makefile for compiling libArduino
.SUFFIXES: .o .a .c .s

CHIP=__SAM3U4E__
VARIANT=arduino_due
LIBNAME=libvariant_$(VARIANT)
TOOLCHAIN=gcc

#-------------------------------------------------------------------------------
# Path
#-------------------------------------------------------------------------------

# Output directories
OUTPUT_BIN = ../../../cores/sam

# Libraries
PROJECT_BASE_PATH = ..
SYSTEM_PATH = ../../../system
CMSIS_PATH = $(SYSTEM_PATH)/CMSIS/Include
ARDUINO_PATH = ../../../cores/sam
VARIANT_BASE_PATH = ../../../variants
VARIANT_PATH = ../../../variants/$(VARIANT)
VARIANT_COMMON_PATH = ../../common

#-------------------------------------------------------------------------------
# Files
#-------------------------------------------------------------------------------

vpath %.h $(PROJECT_BASE_PATH) $(SYSTEM_PATH) $(VARIANT_PATH) $(VARIANT_COMMON_PATH)
#vpath %.c $(PROJECT_BASE_PATH) $(VARIANT_PATH)
vpath %.cpp $(PROJECT_BASE_PATH) $(PROJECT_BASE_PATH) $(VARIANT_COMMON_PATH)

VPATH+=$(PROJECT_BASE_PATH)

INCLUDES = 
#INCLUDES += -I$(PROJECT_BASE_PATH)
INCLUDES += -I$(ARDUINO_PATH)
INCLUDES += -I$(SYSTEM_PATH)
INCLUDES += -I$(SYSTEM_PATH)/libsam
INCLUDES += -I$(VARIANT_BASE_PATH)
INCLUDES += -I$(VARIANT_PATH)
INCLUDES += -I$(CMSIS_PATH)

#-------------------------------------------------------------------------------
ifdef DEBUG
include debug.mk
else
include release.mk
endif

#-------------------------------------------------------------------------------
# Tools
#-------------------------------------------------------------------------------

include $(TOOLCHAIN).mk

#-------------------------------------------------------------------------------
ifdef DEBUG
OUTPUT_OBJ=debug
OUTPUT_LIB_POSTFIX=dbg
else
OUTPUT_OBJ=release
OUTPUT_LIB_POSTFIX=rel
endif

OUTPUT_LIB=$(LIBNAME)_$(TOOLCHAIN)_$(OUTPUT_LIB_POSTFIX).a
OUTPUT_PATH=$(OUTPUT_OBJ)_$(VARIANT)

#-------------------------------------------------------------------------------
# C source files and objects
#-------------------------------------------------------------------------------
C_SRC=$(wildcard $(PROJECT_BASE_PATH)/*.c)

C_OBJ_TEMP = $(patsubst %.c, %.o, $(notdir $(C_SRC)))

# during development, remove some files
C_OBJ_FILTER=

C_OBJ=$(filter-out $(C_OBJ_FILTER), $(C_OBJ_TEMP))

#-------------------------------------------------------------------------------
# CPP source files and objects
#-------------------------------------------------------------------------------
CPP_SRC=$(wildcard $(PROJECT_BASE_PATH)/*.cpp)
CPP_SRC+=$(wildcard $(VARIANT_COMMON_PATH)/*.cpp)

CPP_OBJ_TEMP = $(patsubst %.cpp, %.o, $(notdir $(CPP_SRC)))

# during development, remove some files
CPP_OBJ_FILTER=

CPP_OBJ=$(filter-out $(CPP_OBJ_FILTER), $(CPP_OBJ_TEMP))

#-------------------------------------------------------------------------------
# Assembler source files and objects
#-------------------------------------------------------------------------------
A_SRC=$(wildcard $(PROJECT_BASE_PATH)/*.s)

A_OBJ_TEMP=$(patsubst %.s, %.o, $(notdir $(A_SRC)))

# during development, remove some files
A_OBJ_FILTER=

A_OBJ=$(filter-out $(A_OBJ_FILTER), $(A_OBJ_TEMP))

#-------------------------------------------------------------------------------
# Rules
#-------------------------------------------------------------------------------
all: $(VARIANT)

$(VARIANT): create_output $(OUTPUT_LIB)

.PHONY: create_output
create_output:
	@echo --- Preparing $(VARIANT) files in $(OUTPUT_PATH) $(OUTPUT_BIN) 
	@echo -------------------------
	@echo *$(INCLUDES)
	@echo -------------------------
	@echo *$(C_SRC)
	@echo -------------------------
	@echo *$(C_OBJ)
	@echo -------------------------
	@echo *$(addprefix $(OUTPUT_PATH)/, $(C_OBJ))
	@echo -------------------------
	@echo *$(CPP_SRC)
	@echo -------------------------
	@echo *$(CPP_OBJ)
	@echo -------------------------
	@echo *$(addprefix $(OUTPUT_PATH)/, $(CPP_OBJ))
	@echo -------------------------
	@echo *$(A_SRC)
	@echo -------------------------

	-@mkdir $(OUTPUT_PATH) 1>NUL 2>&1

$(addprefix $(OUTPUT_PATH)/,$(C_OBJ)): $(OUTPUT_PATH)/%.o: %.c
#	@$(CC) -v -c $(CFLAGS) $< -o $@
	@$(CC) -c $(CFLAGS) $< -o $@

$(addprefix $(OUTPUT_PATH)/,$(CPP_OBJ)): $(OUTPUT_PATH)/%.o: %.cpp
#	@$(CC) -c $(CPPFLAGS) $< -o $@
	@$(CC) -xc++ -c $(CPPFLAGS) $< -o $@

$(addprefix $(OUTPUT_PATH)/,$(A_OBJ)): $(OUTPUT_PATH)/%.o: %.s
	@$(AS) -c $(ASFLAGS) $< -o $@

$(OUTPUT_LIB): $(addprefix $(OUTPUT_PATH)/, $(C_OBJ)) $(addprefix $(OUTPUT_PATH)/, $(CPP_OBJ)) $(addprefix $(OUTPUT_PATH)/, $(A_OBJ))
	@$(AR) -v -r "$(OUTPUT_BIN)/$@" $^
	@$(NM) "$(OUTPUT_BIN)/$@" > "$(OUTPUT_BIN)/$@.txt"


.PHONY: clean
clean:
	@echo --- Cleaning $(VARIANT) files [$(OUTPUT_PATH)$(SEP)*.o]
	-@$(RM) $(OUTPUT_PATH) 1>NUL 2>&1
	-@$(RM) $(OUTPUT_BIN)/$(OUTPUT_LIB) 1>NUL 2>&1
