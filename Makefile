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
C_COMPILE_FLAGS 	:= -lc -lm -lnosys -std=c11 -Wall -fdata-sections -ffunction-sections -g0 -gdwarf-2 -Os

CXX_COMPILE_FLAGS 	:= -lc -lm -lnosys -fno-rtti -std=c++11 -fno-exceptions -fno-builtin -Wall \
						-fdata-sections -ffunction-sections -g0 -gdwarf-2 -Os -Wl,-gc-section

ASM_COMPILE_FLAGS 	:= -x assembler-with-cpp -Wa,-mimplicit-it=thumb
#################################################################################################
EXTRA_LINK_FLAGS	:= -g -gdwarf-2 -lc -lm -lnosys -T$(LINK_FILES) \
						-Wl,-Map=$(OUTPUTDIR)/$(TARGET).map,--cref,--no-warn-mismatch \
						-specs=nano.specs -specs=nosys.specs

#################################################################################################
#ifdef HSE8M
#DEFINE    :=-DSTM32H750xx \
#			-DHSE_VALUE=8000000 \
#			-DCSI_VALUE=4000000 \
#			-DHSI_VALUE=64000000 \
#			-DPLLM_VALUE=2 \
#			-DPLLN_VALUE=240 \
#			-DPLLP_VALUE=2 \
#			-DPLLQ_VALUE=4 \
#			-DPLLR_VALUE=2
#else ifdef HSE25M
DEFINE    :=-DSTM32H750xx \
			-DHSE_VALUE=25000000 \
			-DCSI_VALUE=4000000 \
			-DHSI_VALUE=64000000 \
			-DPLLM_VALUE=5 \
			-DPLLN_VALUE=192 \
			-DPLLP_VALUE=2 \
			-DPLLQ_VALUE=4 \
			-DPLLR_VALUE=2
#else
#DEFINE    :=-DSTM32H750xx \
#			-DHSE_VALUE=16000000 \
#			-DCSI_VALUE=4000000 \
#			-DHSI_VALUE=64000000 \
#			-DPLLM_VALUE=4 \
#			-DPLLN_VALUE=240 \
#			-DPLLP_VALUE=2 \
#			-DPLLQ_VALUE=4 \
#			-DPLLR_VALUE=2
#endif
DEFINE    +=-DTHREAD_TICK_PER_SECOND=1000
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

define ensure_dir
    @if [ ! -d "$(1)" ]; then \
        echo "创建目录: $(1)"; \
        mkdir -p $(1); \
    else \
        echo "目录已存在: $(1)"; \
    fi
endef

.PHONY: clean


#$(info "SFILES = $(SFILES) ")
#$(info "CFILES = $(CFILES) ")

$(OUTPUTDIR)/$(TARGET).elf:$(OBJS)
	$(CC) -o $(OUTPUTDIR)/$(TARGET).elf $^ $(LFLAGS)
	$(OBJCOPY) -O binary -S $(OUTPUTDIR)/$(TARGET).elf $(OUTPUTDIR)/$(TARGET).bin
	$(OBJDUMP) -D -m arm $(OUTPUTDIR)/$(TARGET).elf > $(OUTPUTDIR)/$(TARGET).dis
	$(SIZEINFO) $@
	cp output/$(TARGET).bin /mnt/e/STM32/
	sync

$(SOBJS) : $(OUTPUTDIR)/%.o : %.s
	$(call ensure_dir,$(OUTPUTDIR))
	$(CC) -c $(ASMFLAGS) -o $@ $<

$(COBJS) : $(OUTPUTDIR)/%.o : %.c
	$(CC) -c $(CFLAGS) $(INCLUDE) -o $@ $<

$(CXXOBJS) : $(OUTPUTDIR)/%.o : %.cpp
	$(CXX) -c $(CXXFLAGS) $(INCLUDE) -o $@ $<

clean:
	rm -rf $(OUTPUTDIR)
