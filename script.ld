ENTRY(_start)
OUTPUT_FORMAT("elf64-tradlittlemips")
SEARCH_DIR(objs)
__DYNAMIC  =  0;
GROUP(-lc)
STARTUP(minicrt.o)

/*
 * Allocate the stack to be at the top of memory, since the stack
 * grows down
 */

/* PROVIDE (__global = 0); */

/*
 * Initalize some symbols to be zero so we can reference them in the
 * crt0 without core dumping. These functions are all optional, but
 * we do this so we can have our crt0 always use them if they exist.
 * This is so BSPs work better when using the crt0 installed with gcc.
 * We have to initalize them twice, so we multiple object file
 * formats, as some prepend an underscore.
 */
PROVIDE (hardware_exit_hook = 0);
PROVIDE (hardware_hazard_hook = 0);
PROVIDE (hardware_init_hook = 0);
PROVIDE (software_init_hook = 0);

SECTIONS
{
	. = 0xffffffffa0000000;
    /* . = 0xffffffffbfc00000; */

    /* Выделяем 1 мегабайт памяти */
    PROVIDE (__stack = . + 0x100000);

    PROVIDE(__entry = .);

	.text : {
		_ftext = . ;
		PROVIDE (eprol  =  .);
		*(.text)
		*(.text.*)
		*(.gnu.linkonce.t.*)
		*(.mips16.fn.*)
		*(.mips16.call.*)
	}
	.init : {
		KEEP (*(.init))
	}
	.fini : {
		KEEP (*(.fini))
	}
	.rel.sdata : {
		PROVIDE (__runtime_reloc_start = .);
		*(.rel.sdata)
		PROVIDE (__runtime_reloc_stop = .);
	}
	PROVIDE (etext  =  .);
	_etext  =  .;

	.eh_frame_hdr : { *(.eh_frame_hdr) *(.eh_frame_entry .eh_frame_entry.*) }
	.eh_frame : { KEEP (*(.eh_frame)) }
	.gcc_except_table : { *(.gcc_except_table .gcc_except_table.*) }
	.gnu_extab   : { *(.gnu_extab .gnu_extab.*) }
	.jcr : { KEEP (*(.jcr)) }
	.init_array     :
	{
		PROVIDE_HIDDEN (__init_array_start = .);
		KEEP (*(SORT(.init_array.*)))
		KEEP (*(.init_array))
		PROVIDE_HIDDEN (__init_array_end = .);
	}
	.fini_array     :
	{
		PROVIDE_HIDDEN (__fini_array_start = .);
		KEEP (*(SORT(.fini_array.*)))
		KEEP (*(.fini_array))
		PROVIDE_HIDDEN (__fini_array_end = .);
	}
	.ctors    :
	{
		/* gcc uses crtbegin.o to find the start of
		the constructors, so we make sure it is
		first.  Because this is a wildcard, it
		doesn't matter if the user does not
		actually link against crtbegin.o; the
		linker won't look for a file to match a
		wildcard.  The wildcard also means that it
		doesn't matter which directory crtbegin.o
		is in.  */

		KEEP (*crtbegin.o(.ctors))

		/* We don't want to include the .ctor section from
		from the crtend.o file until after the sorted ctors.
		The .ctor section from the crtend file contains the
		end of ctors marker and it must be last */

		KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
		KEEP (*(SORT(.ctors.*)))
		KEEP (*(.ctors))
	}

	.dtors    :
	{
		KEEP (*crtbegin.o(.dtors))
		KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
		KEEP (*(SORT(.dtors.*)))
		KEEP (*(.dtors))
	}

	. = .;
	.MIPS.abiflags : {
		__MIPS_abiflags_start = .;
		*(.MIPS.abiflags)
		__MIPS_abiflags_end = .;
	}
	.rodata : {
		*(.rdata)
		*(.rodata)
		*(.rodata.*)
		*(.gnu.linkonce.r.*)
	}
	. = ALIGN(16);
	_fdata = .;
	.data : {
		*(.data)
		*(.data.*)
		*(.gnu.linkonce.d.*)
	}
	. = ALIGN(8);
	_gp = . + 0x8000;
	__global = _gp;
	.lit8 : {
		*(.lit8)
	}
	.lit4 : {
		*(.lit4)
	}
	.sdata : {
		*(.sdata)
		*(.sdata.*)
		*(.gnu.linkonce.s.*)
	}
	. = ALIGN(4);
	PROVIDE (edata  =  .);
	_edata  =  .;
	_fbss = .;
	.sbss : {
		*(.sbss)
		*(.sbss.*)
		*(.gnu.linkonce.sb.*)
		*(.scommon)
	}
	.bss : {
		_bss_start = . ;
		*(.bss)
		*(.bss.*)
		*(.gnu.linkonce.b.*)
		*(COMMON)
	}

    /DISCARD/ :
	{
		*.o (.MIPS.options)
		*.o (.MIPS.abiflags)
		*.o (.gnu.attributes)
        /* *.o (.debug*) */
        /* *.o (.comment) */
	}

	. = ALIGN(4);
	PROVIDE (end = .);
	_end = .;
}
