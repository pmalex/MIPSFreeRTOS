#include <mips/regdef.h>
#include <mips/asm.h>
#include <mips/cpu.h>
#include <mips/hal.h>

/* Save the hard context to a gp_ctx pointed to by k0 from previuous
   shadow set. */
.macro _gpctx_save_pss
	.irp num,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19 \
			20,21,22,23,24,25,27,28,29,30,31
        rdpgpr  k1, $\num
		REG_S   k1, CTX_REG(\num) (k0)
	.endr

    rdpgpr  k1, k0
    nop
    nop
    REG_S   k1, CTX_REG(26) (k0)

	mfhi	k1
	REG_S	k1,  CTX_HI0(k0)
	mflo	k1
	REG_S	k1,  CTX_LO0(k0)

	/* Save CP0 registers.  */
	PTR_MFC0   k1, C0_EPC
	REG_S      k1, CTX_EPC(k0)
.endm

/* Restores a gp_ctx pointed to by k0 from previuous shadow set.
   C0_EPC ready to eret.  */
.macro _gpctx_load_pss
	REG_L      k1, CTX_HI0(k0)
	mthi       k1
    REG_L      k1, CTX_LO0(k0)
	mtlo       k1

	/* Restore the general registers.  */
	.irp num,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19, \
			20,21,22,23,24,25,27,28,29,30,31
		REG_L     k1, CTX_REG(\num) (k0)
        wrpgpr    $\num, k1
	.endr

    REG_L      k1, CTX_REG(26) (k0)
    /* Эта команда здесь почему-то приводит к зависанию, т.е.
       на данный момент мы не восстанавливаем регистр k1 */
    // wrpgpr     $26, k1

	REG_L      k1, CTX_EPC(k0)
	PTR_MTC0   k1, C0_EPC
.endm

/* Save the hard context to a gp_ctx pointed to by k1.
   Leave the value of C0_STATUS in v0/$2.
   Leave the value of k1 unchanged.  */

.macro _gpctx_save
	/* Save general registers.  */
	/* $27/k1 must be saved prior to using this macro.  */
	.irp num,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19 \
			20,21,22,23,24,25,26,28,29,30,31
		REG_S	$\num, CTX_REG(\num) (k1)
	.endr

	PTR_S   $0, CTX_LINK(k1)	/* Clear the link field.  */

	mfhi	$9
	REG_S	$9, CTX_HI0(k1)
	mflo	$10
	REG_S	$10, CTX_LO0(k1)

	/* Save CP0 registers.  */
	PTR_MFC0 $31, C0_EPC
	ehb
/* 	mfc0	$10, C0_STATUS */
/* 	ehb */
	REG_S	$31, CTX_EPC(k1)
	ehb
/* 	sw		$10, CTX_STATUS(k1) */
.endm

/* Restores a gp_ctx pointed to by k0.  Leaves interrupts disabled and
   C0_EPC ready to eret.  */

.macro _gpctx_load
	REG_L	$9, CTX_HI0(k0)
	REG_L	$10, CTX_LO0(k0)
	mthi	$9
	mtlo	$10

	/* Restore the general registers.  */
	.irp num,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19, \
			20,21,22,23,24,25
		REG_L	$\num, CTX_REG(\num) (k0)
	.endr

	/* Restore CP0 registers, kernel registers and stack with
	   interrupts disabled.  */
/*  	di */
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

.endm
