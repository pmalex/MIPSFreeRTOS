#ifndef ISR_SUPPORT_H
#define	ISR_SUPPORT_H

/* This file is only used by the port_asm.S file, and so is pretty much a
no-op if (accidentally) included within any other non-assembly files */
#if defined(__ASSEMBLER__)

#include <mips/hal.h>

#include "FreeRTOSConfig.h"
#include "ctx.S"

/* Save this processor context. This will happen when a timer tick happens.
As we are using Count/Compare as our timer, this fires on Status(HW5). */
.macro  portSAVE_CONTEXT
	/* Make room for the context. First save the current status so it can be
	manipulated, and the cause and EPC registers so their original values are
	captured. */
   ADDU        sp, sp, -CTX_SIZE
	REG_S       k1, CTX_K1(sp)

	/* k1 is used as the frame pointer. */
	ADDU        k1, zero, sp

	/* Save the context into the space just created. */
	_gpctx_save

	/* Save the stack pointer. */
	LA          s6, uxSavedTaskStackPointer
	REG_S       k1, (s6)
	REG_L       k1, CTX_K1(sp)

.endm

/******************************************************************/

/* Restore the processor context. */
.macro  portRESTORE_CONTEXT

	LA          s6, uxSavedTaskStackPointer
	REG_L       k0, (s6)

	/* Restore the context. */
	_gpctx_load

	LA          sp, uxSavedTaskStackPointer
	REG_L       sp, (sp)

	ADDU        sp, sp, CTX_SIZE
.endm

/******************************************************************/

/* Yield context save from GPR */
.macro portYIELD_SAVE

	/* Make room for the context. First save the current status so it can be
	manipulated. */
	daddiu      sp, sp, -CTX_SIZE
	REG_S       k1, CTX_K1(sp)

	/* k0cd is used as the frame pointer. */
	move        k1, sp

	/* Save the context into the space just created. */
	_gpctx_save

	/* Save the stack pointer to the task. */
	LA			s7, pxCurrentTCB
	REG_L		s7, (s7)
	REG_S		k1, (s7)

.endm

/******************************************************************/

/* Yield context save from previuous shadow set */
.macro portYIELD_SAVE_PSS
    /* Read sp from GRP in k0 */
    rdpgpr     k0, sp

	/* Make room for the context. */
    daddiu     k0, k0, -CTX_SIZE

	/* Next k0 is will be used as the frame pointer.
	   Save the context into the space just created. */
	_gpctx_save_pss

	/* Save the stack pointer to the task. */
	LA         s0, pxCurrentTCB
	REG_L	   s1, (s0)
	REG_S      k0, (s1)
.endm

/******************************************************************/

/* Yield context restore from previuous shadow set */
.macro portYIELD_RESTORE_PSS
	/* Set the context restore register from the TCB. */
	LA			s0, pxCurrentTCB
	REG_L		s1, (s0)
    REG_L		k0, (s1)

    /* Restore GRR context from previuous shadow set */
	_gpctx_load_pss

	/* Restore the stack pointer from the TCB. */
	LA			s0, pxCurrentTCB
	REG_L		s1, (s0)
	REG_L		sp, (s1)

	/* Remove stack frame. */
	daddiu		sp, sp, CTX_SIZE
    wrpgpr      sp

.endm

/******************************************************************/

.macro portYIELD_RESTORE

	/* Set the context restore register from the TCB. */
	LA			s0, pxCurrentTCB
	REG_L		s0, (s0)
	REG_L		k0, (s0)

	/*
	 * The _gpctx_load restore code just wholesale copies the
	 * status register from the context back to the register loosing
	 * any changes that may have occured, 'status' is really global state
	 * You dont enable interrupts on one thread and not another...
	 * So we just copy the current status value into the saved value
	 * so nothing changes on the restore
	 */

// 	mfc0	k1, C0_STATUS
// 	sw		k1, CTX_STATUS(k0)

	_gpctx_load

	/* Restore the stack pointer from the TCB. */
	LA			sp, pxCurrentTCB
	REG_L		sp, (sp)
	REG_L		sp, (sp)

	/* Remove stack frame. */
	daddiu		sp, sp, CTX_SIZE

.endm

#endif /* #if defined(__ASSEMBLER__) */

#endif	/* ISR_SUPPORT_H */
