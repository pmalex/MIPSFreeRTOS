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

LEAF(_mips_tlb_refill_isr)
	di
    ld		sp, xISRStackTop

    WRITE   "\nTLB Refill\n"

    jal     OutGPRfromPSS

    jal     OutCP0Reg

    dmfc0   a0, C0_EPC
    addiu   a0, 4
    dmtc0   a0, C0_EPC
    ehb

1:  b 1b

    eret
END(_mips_tlb_refill_isr)

LEAF(_mips_xtlb_refill_isr)
	ld		sp, xISRStackTop

	WRITE   "\nXTLB Refill\n"

	jal     OutGPRfromPSS

	jal     OutCP0Reg

	dmfc0   a0, C0_EPC
	addiu   a0, 4
	dmtc0   a0, C0_EPC
	ehb

	1:  b 1b

	eret
END(_mips_xtlb_refill_isr)

LEAF(_mips_cache_error_isr)
    ld		sp, xISRStackTop

    WRITE   "\nCache Error: "

	jal     OutGPRfromPSS

    jal     OutCP0Reg

1:	b		1b
END(_mips_cache_error_isr)

/* General exception vector */
LEAF(_mips_general_exception_isr)
	di
	ld		sp, xISRStackTop

	WRITE "\nGeneral Exception occured\n"

    jal     OutGPRfromPSS

    jal     OutCP0Reg

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

	// di
	// ehb

	ld		sp, xISRStackTop
    // LA      sp, __stack
    LA		gp, _gp

	portYIELD_SAVE_PSS

	jal		vTaskSwitchContext

	portYIELD_RESTORE_PSS

    // Count = 0
    mtc0	zero, C0_COUNT
    ehb

    mfc0    a0, C0_EPC
    ehb
    addiu   a0, 4
    mtc0    a0, C0_EPC
    ehb

    // Cause_DC = 1
    mfc0    a0, C0_CAUSE
    li      a1, (1 << 27)
    or      a0, a0, a1
    mtc0    a0, C0_CAUSE
    ehb

	// ei
	// ehb

	eret
END(_mips_isr_001)

LEAF(_mips_isr_002)
    ld		sp, xISRStackTop

    rdpgpr a0, v1
    jal OutReg32
    jal OutCRLF

    mfc0 a0, C0_EPC
    ehb
    jal OutReg32
    jal OutCRLF

    mfc0    a0, C0_EPC
    ehb
    addiu   a0, 4
    mtc0    a0, C0_EPC
    ehb

    eret
END(_mips_isr_002)

.align 8
/* Timer interrupt handler */
LEAF(_mips_isr_004)
    // Cause_DC = 0
    mfc0    a0, C0_CAUSE
    li      a1, ~(1 << 27)
    and     a0, a0, a1
    mtc0    a0, C0_CAUSE
    ehb

	// di
	// ehb

	ld		sp, xISRStackTop
    // LA      sp, __stack

    LA		gp, _gp

    jal		vPortIncrementTick

    // Count = 0
	mtc0	zero, C0_COUNT
    ehb

    mfc0    a0, C0_EPC
    ehb
    addiu   a0, 4
	mtc0    a0, C0_EPC
    ehb

    // Cause_DC = 1
    mfc0    a0, C0_CAUSE
    li      a1, (1 << 27)
    or      a0, a0, a1
    mtc0    a0, C0_CAUSE
    ehb

	// ei
	// ehb

	eret
END(_mips_isr_004)

.align 8
/* Undefined interrupt */
LEAF(_mips_interrupt)
	di

	ld		sp, xISRStackTop

	WRITE	"\nUndefined interrupt, code: 0x"
    move    a0, k1
    jal     OutReg32

	jal     OutGPRfromPSS

    jal     OutCP0Reg

	WRITE	"\nSYSTEM FAILURE!\n"

	1:	b 1b
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

 	lw		k1, CTX_STATUS(k0)
    mtc0	k1, C0_STATUS
	REG_L	k1, CTX_EPC(k0)
	PTR_MTC0 k1, C0_EPC

	REG_L	$27, CTX_REG(27) (k0)
	REG_L	$28, CTX_REG(28) (k0)
	REG_L	$29, CTX_REG(29) (k0)
	REG_L	$30, CTX_REG(30) (k0)
	REG_L	$31, CTX_REG(31) (k0)

	/* Finally restore k0/$26.  */
 	REG_L	$26, CTX_REG(26)(k0)

	LA		k0, uxSavedTaskStackPointer
	REG_L	sp, (k0)

	ADDU	sp, sp, CTX_SIZE

	dmfc0	k0, C0_EPC
	ehb
	jr.hb	k0
END(vPortStartFirstTask)
.align 8
