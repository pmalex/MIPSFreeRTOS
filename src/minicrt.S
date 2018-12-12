#include <mips/asm.h>
#include <mips/regdef.h>

.org 0x200
LEAF(__isr_vec)
	.set noat
	/* EIC interrupt vectors */
	.irp num,00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19 \
				20,21,22,23,24,25,26,27,28,29,30,31
		.align 6 # equal to VEC_SPACE = 64
		AENT(__isr_vec_0\num)
		.weak   _mips_isr_0\num
			LA		k0, _mips_isr_0\num
			beqz	k0, __isr_vec_fallback
			jr		k0
	.endr
	
	AENT(__isr_vec_fallback)
	.weak _mips_interrupt
	1:	LA		k0, _mips_interrupt
		beqz	k0, 1b
		jr		k0
END(__isr_vec)

/*	.org 0x300
	j		_mips_isr_004*/

.org 0xb00
LEAF(_start)
	/* Set up global pointer for small data access */
	LA		gp, _gp
	/* Set up stack pointer */
	LA		sp, __stack
	
	jal		hardware_init_hook
2:
	/* Jump to C code */
	jal		main
	
	/* Call the exit handler */
	jal		__exit
	
	.weak __exit
AENT(__exit)
	li		ra, 0xbfc00000
	jr		ra
END(_start)
