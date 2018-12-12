#include <mips/cpu.h>
#include <mips/asm.h>
#include <mips/regdef.h>

#include <mips/hal.h>

.set noat

.macro WRITE str
	.section .rodata
string\@: .asciiz "\str"
	.text
	dla		a0, string\@
	jal		wwrite
.endm

/* General exception vector */
LEAF(_mips_isr_000)
	WRITE	"Exception occured\n"
	
	WRITE	"sr=0x"
	mfc0	a0, C0_STATUS
	ehb
	jal		OutReg32
	
	WRITE	",cr=0x"
	mfc0	a0, C0_CAUSE
	ehb
	jal		OutReg32
	
	WRITE	",epc=0x"
	mfc0	a0, C0_EPC
	ehb
	jal		OutReg32
	
	WRITE	"\nInfinite loop...\n"
	
1:	b		1b
END(_mips_isr_000)

/* SW0 interrupt handler */
LEAF(_mips_isr_001)
/* 	portYIELD_SAVE */
	
	li		a0, 'Y'
	jal		SendByte
	
	jal		vTaskSwitchContext
	
/* 	portYIELD_RESTORE */
	
	/* Сбросим Status */
	li		k0, 1
	mtc0	k0, C0_STATUS
	ehb
	
	mfc0	k0, C0_EPC
	jr.hb	k0
END(_mips_isr_001)

.align 8
/* SW1 interrupt handler */
LEAF(_mips_isr_002)
	rdpgpr	sp
	WRITE	"SW1 interrupt\n"
	
	/* Сбросим бит Cause_IP1 */
	mfc0	k0, C0_CAUSE
	ins		k0, zero, CR_IP_SHIFT + 1, 1
	mtc0	k0, C0_CAUSE
	
	eret
END(_mips_isr_002)

.align 8
/* Timer interrupt */
LEAF(_mips_isr_004)
	LA			sp, xISRStackTop
	REG_L		sp, (sp)
	rdpgpr		gp
	
	li			a0, '{'
	jal			SendByte
	
	/* If yield needed, then branch */
	LA			k0, flagYIELD
	lb			k0, 0 (k0)
	bnez		k0, 2f
	
	/* Need yield? */
	jal			xTaskIncrementTick
	beqz		v0, 1f
2:
	li			a0, 'y'
	jal 		SendByte
	
	/* Reset flagYIELD */
	LA			k0, flagYIELD
	sb			zero, 0 (k0)
	
	/* k0 is used as the frame pointer. */
	rdpgpr		k0, sp
	daddiu		k0, k0, -CTX_SIZE
	
	.irp reg,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19 \
			20,21,22,23,24,25,26,27,28,29,30,31
		rdpgpr		k1, $\reg
		REG_S		k1, CTX_REG(\reg) (k0)
	.endr
	
	PTR_S		$0, CTX_LINK(k0)	/* Clear the link field.  */

	mfhi		$9
	REG_S		$9, CTX_HI0(k0)
	mflo		$10
	REG_S		$10, CTX_LO0(k0)
	
	PTR_MFC0	$31, C0_EPC
	ehb
	REG_S		$31, CTX_EPC(k0)
	
	/* Save the stack pointer to the task. */
	LA			s7, pxCurrentTCB
	REG_L		s7, (s7)
/*	move a0, s7
	jal OutReg64*/
	REG_S		k0, (s7)
	
	jal			vTaskSwitchContext
	
	/* Set the context restore register from the TCB. */
	LA			s0, pxCurrentTCB
	REG_L		s0, (s0)
/*	move a0, s0
	jal OutReg64*/
	REG_L		k0, (s0)
	
	REG_L		$9, CTX_HI0(k0)
	REG_L		$10, CTX_LO0(k0)
	mthi		$9
	mtlo		$10
	
	/* Это баг! bug10.mi */
	REG_L		$11, CTX_REG(26) (k0)
/* 	wrpgpr		$26, $11 */
	
	.irp reg,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19 \
			20,21,22,23,24,25,27,28,29,30,31
		REG_L		k1, CTX_REG(\reg) (k0)
		wrpgpr		$\reg, k1
	.endr
	
	REG_L		k1, CTX_EPC(k0)
	PTR_MTC0	k1, C0_EPC
	
	/* Restore the stack pointer from the TCB. */
	LA			k0, pxCurrentTCB
	REG_L		k0, (k0)
	REG_L		k0, (k0)
	
	/* Remove stack frame. */
	daddiu		k0, k0, CTX_SIZE
	
	wrpgpr		sp, k0
	
1:
/*	dmfc0	a0, C0_EPC
	ehb
	jal OutReg32*/
	
	li			a0, '}'
	jal			SendByte
	
	mtc0		zero, C0_COUNT
	
	eret
END(_mips_isr_004)

.align 8
/* Undefined interrupt */
LEAF(_mips_interrupt)
	LA		sp, __stack
	
	WRITE	"Undefined interrupt\n"
	
	WRITE	"Infinite loop...\n"
	
1:	b		1b
END(_mips_interrupt)

.align 8
LEAF(vPortStartFirstTask)
	LA          s6, uxSavedTaskStackPointer
	REG_L       k0, (s6)
	
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
/* 	REG_L	$26, CTX_REG(26)(k0) */
	
	LA          sp, uxSavedTaskStackPointer
	REG_L       sp, (sp)

	ADDU        sp, sp, CTX_SIZE
	
	dmfc0		k0, C0_EPC
	jr.hb		k0
END(vPortStartFirstTask)
.align 8
