APP = testBench

CC = mips-mti-elf-gcc
OBJDUMP = mips-mti-elf-objdump
OBJCOPY = mips-mti-elf-objcopy

DIR = $(shell 'pwd')
INCLUDE = -I$(DIR)/src -I$(DIR)/src/drivers -I$(DIR)/src/lib \
	-I$(DIR)/src/FreeRTOS/include -I$(DIR)/src/FreeRTOS/portable \
	-I$(DIR)/src/FreeRTOS/MemMang -I$(DIR)/src/FreeRTOS

CCFLAGS = -EL -mabi=64 $(INCLUDE) -msoft-float -O0 -g
LDSCRIPT = script.ld
LDFLAGS = -T$(LDSCRIPT) -msoft-float -nostdlib -EL -mabi=64

CSRC :=  \
	main.c \
	init_hook.c \
	eic.c \
	iolib.c \
	tasks.c \
	list.c \
	queue.c \
	timers.c \
	event_groups.c \
	croutine.c \
	heap_2.c \
	port.c
	
ASMSRC := debug.S int_handler.S

OBJS := $(ASMSRC:.S=.o) $(CSRC:.c=.o)

OBJDIR = objs
SRCDIR = src
TOBJS := $(addprefix $(OBJDIR)/, $(OBJS))

all: $(OBJDIR)/minicrt.o $(APP).bin 

$(APP).bin: $(APP).elf
	@ $(OBJCOPY) -S --output-target binary $^ $@

$(APP).elf: $(TOBJS)
	@ $(CC) $(LDFLAGS) $^ -o $@

$(OBJDIR)/%.o: $(SRCDIR)/drivers/%.c
	@ $(CC) -c $(CCFLAGS) $^ -o $@

$(OBJDIR)/%.o: $(SRCDIR)/FreeRTOS/MemMang/%.c
	@ $(CC) -c $(CCFLAGS) $^ -o $@

$(OBJDIR)/%.o: $(SRCDIR)/FreeRTOS/portable/%.c
	@ $(CC) -c $(CCFLAGS) $^ -o $@

$(OBJDIR)/%.o: $(SRCDIR)/FreeRTOS/%.c
	@ $(CC) -c $(CCFLAGS) $^ -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.S
	@ $(CC) -c $(CCFLAGS) $^ -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@ $(CC) -c $(CCFLAGS) $^ -o $@

$(OBJDIR)/%.o: $(SRCDIR)/lib/%.c
	@ $(CC) -c $(CCFLAGS) $^ -o $@

.PHONY: elfdump
elfdump: $(APP).elf
	@ $(OBJDUMP) -D -h $(APP).elf | less

.PHONY: firmware
firmware:
	@ quartus_pgm -c 1 ~/Work/Firmwares/Chain1.cdf

.PHONY: clean
clean:
	@ rm -rf $(APP).bin $(APP).elf objs/* 
