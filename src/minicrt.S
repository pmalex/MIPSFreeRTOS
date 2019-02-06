#include <mips/asm.h>
#include <mips/regdef.h>

.set noat

// j _start
.org 0x000
_mips_tlb_refill:
		.weak _mips_tlb_refill_isr
		LA		k0, _mips_tlb_refill_isr
		beqz	k0, _mips_tlb_refill
		jr		k0

.org 0x080
_mips_xtlb_refill:
		.weak _mips_xtlb_refill_isr
		LA		k0, _mips_xtlb_refill_isr
		beqz	k0, _mips_xtlb_refill
		jr		k0

.org 0x100
_mips_cache_error:
		.weak _mips_cache_error_isr
		LA		k0, _mips_cache_error_isr
		beqz	k0, _mips_cache_error
		jr		k0

.org 0x180
_mips_general_exception:
		.weak _mips_general_exception_isr
		LA		k0, _mips_general_exception_isr
		beqz	k0, _mips_general_exception
		jr		k0

.org 0x200
LEAF(__isr_vec)
	/* EIC interrupt vectors */
	.irp num,00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19 \
				20,21,22,23,24,25,26,27,28,29,30,31
		.align 6 # equal to VEC_SPACE = 64
		AENT(__isr_vec_0\num)
		.weak   _mips_isr_0\num
			LA		k0, _mips_isr_0\num
            li      k1, 0x\num
			beqz	k0, __isr_vec_fallback
			jr		k0
	.endr

	AENT(__isr_vec_fallback)
	.weak _mips_interrupt
	1:	LA		k0, _mips_interrupt
		beqz	k0, 1b
		jr		k0
END(__isr_vec)

.org 0xb00
LEAF(_start)
	/* Set up global pointer for small data access */
	LA     gp, _gp

    /*
     * zero out the bss section.
     */
    LA     t0, _fbss
	LA     t1, _end
	beq    t0, t1, 1f
2:
	PTR_ADDU   t0, t0, 4
	sw     zero, -4(t0)
	bne    t0, t1, 2b
1:

	/* Set up stack pointer */
	LA     sp, __stack

	jal    hardware_init_hook

    // jal     _init

	/* Jump to C code */
	jal    main

    // jal     _fini

	/* Call the exit handler */
	jal    __exit

	.weak __exit
AENT(__exit)
	li     ra, 0xbfc00000
	jr     ra
END(_start)
