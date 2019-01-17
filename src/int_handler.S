#include <mips/cpu.h>
#include <mips/asm.h>
#include <mips/regdef.h>
#include <mips/hal.h>

#include "ISR_Support.h"

.set noat

.macro WRITE str
	.section .rodata
string\@: .asciiz "\str"
	.text
	dla		a0, string\@
	jal		OutString
.endm

/* General exception vector */
LEAF(_mips_general_exception_isr)
	LA		sp, xISRStackTop

	WRITE "General Exception occured\n"

	WRITE	"sr=0x"
	mfc0	a0, C0_STATUS
	ehb
	jal	OutReg32

	WRITE	",cr=0x"
	mfc0	a0, C0_CAUSE
	ehb
	jal	OutReg32

	WRITE	",epc=0x"
	mfc0	a0, C0_EPC
	ehb
	jal		OutReg32

	WRITE	"\nInfinite loop...\n"

1:	b		1b
END(_mips_general_exception_isr)

/* SW0 interrupt handler */
LEAF(_mips_isr_001)
    // Cause_DC = 0
    mfc0    a0, C0_CAUSE
    li      a1, ~(1 << 27)
    and     a0, a0, a1
    mtc0    a0, C0_CAUSE
    ehb

	ld		sp, xISRStackTop
    LA		gp, _gp

	portYIELD_SAVE_PSS

	jal		vTaskSwitchContext

	portYIELD_RESTORE_PSS

    // Count = 0
    mtc0	zero, C0_COUNT

    // Cause_DC = 1
    mfc0    a0, C0_CAUSE
    li      a1, (1 << 27)
    or      a0, a0, a1
    mtc0    a0, C0_CAUSE
    ehb

	eret
END(_mips_isr_001)

.align 8
/* Timer interrupt handler */
LEAF(_mips_isr_004)
    // Cause_DC = 0
    mfc0    a0, C0_CAUSE
    li      a1, ~(1 << 27)
    and     a0, a0, a1
    mtc0    a0, C0_CAUSE
    ehb

	ld		sp, xISRStackTop
    LA		gp, _gp

    jal		vPortIncrementTick

    // Count = 0
	mtc0	zero, C0_COUNT

    // Cause_DC = 1
    mfc0    a0, C0_CAUSE
    li      a1, (1 << 27)
    or      a0, a0, a1
    mtc0    a0, C0_CAUSE
    ehb

	eret
END(_mips_isr_004)

.align 8
/* Undefined interrupt */
LEAF(_mips_interrupt)
	LA		sp, xISRStackTop

	WRITE	"Undefined interrupt\n"

	WRITE	"Infinite loop...\n"

1:	b		1b
END(_mips_interrupt)

.align 8
LEAF(vPortStartFirstTask)
	LA    s6, uxSavedTaskStackPointer
	REG_L	k0, (s6)

	/* Restore the context. */
	REG_L	$9, CTX_HI0(k0)
	REG_L	$10, CTX_LO0(k0)
	mthi	$9
	mtlo	$10
	/* Restore the general registers.  */
	.irp num,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19, \
			20,21,22,23,24,25
		REG_L	$\num, CTX_REG(\num) (k0)
	.endr

/* 	lw		k1, CTX_STATUS(k0) */
/* 	mtc0	k1, C0_STATUS */
	REG_L	k1, CTX_EPC(k0)
	PTR_MTC0 k1, C0_EPC

	REG_L	$27, CTX_REG(27) (k0)
	REG_L	$28, CTX_REG(28) (k0)
	REG_L	$29, CTX_REG(29) (k0)
	REG_L	$30, CTX_REG(30) (k0)
	REG_L	$31, CTX_REG(31) (k0)

	/* Finally restore k0/$26.  */
 	REG_L	$26, CTX_REG(26)(k0)

	LA		sp, uxSavedTaskStackPointer
	REG_L	sp, (sp)

	ADDU	sp, sp, CTX_SIZE

	dmfc0	k0, C0_EPC
	ehb
	jr.hb	k0
END(vPortStartFirstTask)
.align 8
