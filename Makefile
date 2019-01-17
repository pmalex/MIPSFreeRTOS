APP = mipsFreeRTOS

CC = mips-mti-elf-gcc
OBJDUMP = mips-mti-elf-objdump
OBJCOPY = mips-mti-elf-objcopy

INCLUDE = -Isrc -Isrc/drivers -Isrc/lib \
	-Isrc/FreeRTOS/include -Isrc/FreeRTOS/portable \
	-Isrc/FreeRTOS/MemMang -Isrc/FreeRTOS

CCFLAGS = -EL -mabi=64 $(INCLUDE) -mclib=tiny -msoft-float -O0 -g
LDSCRIPT = script.ld
LDFLAGS = -T$(LDSCRIPT) -msoft-float -EL -mabi=64

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
	heap_4.c \
	port.c

ASMSRC := debug.S int_handler.S

OBJS := $(ASMSRC:.S=.o) $(CSRC:.c=.o)

OBJDIR = objs
SRCDIR = src
TOBJS := $(addprefix $(OBJDIR)/, $(OBJS))

all: $(OBJDIR)/minicrt.o $(APP).bin

$(APP).bin: $(APP).elf
	@ $(OBJCOPY) -I elf64-tradlittlemips -O binary $^ $@

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
	@ $(OBJDUMP) -D -EL -mmips:isa64r2 -h $(APP).elf | less

.PHONY: bindump
bindump: $(APP).bin
	@ $(OBJDUMP) -EL -mmips:isa64r2 -z -D $(APP).bin -b binary | less

.PHONY: listing
listing: $(APP).elf
	@ $(OBJDUMP) -EL -Mgpr-names=numeric,cp0-names=numeric,no-aliases -mmips:isa64r2 -SD $(APP).elf | less

.PHONY: firmware
firmware:
	@ quartus_pgm -c 1 ~/Work/Firmwares/Chain1.cdf

.PHONY: clean
clean:
	@ rm -rf $(APP).bin $(APP).elf objs/*
