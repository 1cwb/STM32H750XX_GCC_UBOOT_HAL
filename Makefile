# for sub directory
export SRC_AMSFILES :=
export SRC_C_FILES :=
export SRC_INCFILES :=
export SRC_CXX_FILES :=
export SRC_INCDIR :=
export LINK_FILES :=


######################################SUB_MK###################################################
SUBDIRS := $(shell find $(CURRENT_DIR) -maxdepth 4 -type d)
SUBMK += $(foreach dir, $(SUBDIRS), $(wildcard $(dir)/*.mk))
#$(info "$(SUBMK)")
include $(SUBMK)

################################################################################################
TARGET           	?= STM32H7_uboot
OUTPUTDIR := $(CURDIR)/output
###################################################COMPILE######################################
CROSS_COMPILE    	?= arm-none-eabi-

CC               	:= $(CROSS_COMPILE)gcc
CXX              	:= $(CROSS_COMPILE)g++
LD               	:= $(CROSS_COMPILE)ld
OBJCOPY          	:= $(CROSS_COMPILE)objcopy
OBJDUMP          	:= $(CROSS_COMPILE)objdump
SIZEINFO            := $(CROSS_COMPILE)size

#############################################################ARM################################
#softvfp 软浮点
#fpv5-d16 or fpv5-sp-d16 cortex-M7 单精度硬件浮点
#fpv4-d16 or fpv4-sp-d16 cortex-M4 单精度硬件浮点
#fpv5-dp-d16 cortex-M7 双精度硬件浮点

CPU           		:= -mcpu=cortex-m7
FPU        			:= -mfpu=fpv5-sp-d16
FLOAT_ABT 			:= -mfloat-abi=hard
ARM_INSTRUCTION 	:= -mthumb
MCU_FLAGS       	:= $(CPU) $(ARM_INSTRUCTION) $(FPU) $(FLOAT_ABT)

##################################################COMPILE_FLAGS#################################
C_COMPILE_FLAGS 	:= -lc -lm -lnosys -std=c11 -Wall -fdata-sections -ffunction-sections -g0 -gdwarf-2 -O1

CXX_COMPILE_FLAGS 	:= -lc -lm -lnosys -fno-rtti -std=c++11 -fno-exceptions -fno-builtin -Wall \
						-fdata-sections -ffunction-sections -g0 -gdwarf-2 -O1 -Wl,-gc-section

ASM_COMPILE_FLAGS 	:= -x assembler-with-cpp -Wa,-mimplicit-it=thumb
#################################################################################################
EXTRA_LINK_FLAGS	:= -g -gdwarf-2 -lc -lm -lnosys -T$(LINK_FILES) \
						-Wl,-Map=$(OUTPUTDIR)/$(TARGET).map,--cref,--no-warn-mismatch \
						-specs=nano.specs -specs=nosys.specs

#################################################################################################
DEFINE    :=-DSTM32H750xx \
			-DUSE_HAL_DRIVER \
			-DUSE_FULL_LL_DRIVER \
			-DHSE_VALUE=25000000
###############################################################
CFLAGS 				+= $(MCU_FLAGS) $(C_COMPILE_FLAGS) $(DEFINE)
CXXFLAGS 			+= $(MCU_FLAGS) $(CXX_COMPILE_FLAGS) $(DEFINE)
ASMFLAGS			+= $(MCU_FLAGS) $(ASM_COMPILE_FLAGS) $(DEFINE)

LFLAGS += $(MCU_FLAGS)  $(EXTRA_LINK_FLAGS)

INCLUDE 		 := $(patsubst %, -I %, $(SRC_INCDIR))
SFILES			 := $(SRC_AMSFILES)
CFILES			 := $(SRC_C_FILES)
CXXFILES         := $(SRC_CXX_FILES)

SFILENAME  		 := $(notdir $(SFILES))
CFILENAME 		 := $(notdir $(CFILES))
CXXFILENAME		 := $(notdir $(CXXFILES))

SOBJS		 	 := $(patsubst %, $(OUTPUTDIR)/%, $(SFILENAME:.s=.o))
COBJS		 	 := $(patsubst %, $(OUTPUTDIR)/%, $(CFILENAME:.c=.o))
CXXOBJS          := $(patsubst %, $(OUTPUTDIR)/%, $(CXXFILENAME:.cpp=.o))
OBJS			 := $(SOBJS) $(COBJS) $(CXXOBJS)

SRCDIRS          := $(dir $(SFILES)) $(dir $(CFILES)) $(dir $(CXXFILES))
VPATH			 := $(SRCDIRS)

.PHONY: clean


#$(info "SFILES = $(SFILES) ")
#$(info "CFILES = $(CFILES) ")

$(OUTPUTDIR)/$(TARGET).elf:$(OBJS)
	$(CC) -o $(OUTPUTDIR)/$(TARGET).elf $^ $(LFLAGS)
	$(OBJCOPY) -O binary -S $(OUTPUTDIR)/$(TARGET).elf $(OUTPUTDIR)/$(TARGET).bin
	$(OBJDUMP) -D -m arm $(OUTPUTDIR)/$(TARGET).elf > $(OUTPUTDIR)/$(TARGET).dis
	$(SIZEINFO) $@
	cp output/$(TARGET).bin /mnt/d/STM32/
	sync

$(SOBJS) : $(OUTPUTDIR)/%.o : %.s
	$(CC) -c $(ASMFLAGS) -o $@ $<

$(COBJS) : $(OUTPUTDIR)/%.o : %.c
	$(CC) -c $(CFLAGS) $(INCLUDE) -o $@ $<

$(CXXOBJS) : $(OUTPUTDIR)/%.o : %.cpp
	$(CXX) -c $(CXXFLAGS) $(INCLUDE) -o $@ $<

clean:
	rm -rf $(OUTPUTDIR)/*
