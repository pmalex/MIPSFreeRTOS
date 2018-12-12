#ifndef INT_HANDLER_H
#define	INT_HANDLER_H

#ifdef	__cplusplus
extern "C"
{
#endif

#include "portmacro.h"
#include "eic.h"

/* Nicer names for the interrupt bits */
#define SW0                 0x00
#define SW1                 0x01
#define HW0                 0x02
#define HW1                 0x03
#define HW2                 0x04
#define HW3                 0x05
#define HW4                 0x06
#define HW5                 0x07

/* Where timer irq is wired as reported by hw */
#define TIMER_IRQ			4
#define SR_TIMER_IRQ	(SR_IM0 << TIMER_IRQ)

/*
 * The software interrupt handler that performs the yield.
 */
extern void vPortYieldISR( void );

extern UBaseType_t uxPortSetInterruptMaskFromISR( void );
extern void vPortClearInterruptMaskFromISR( UBaseType_t );

#define SR_DSP  0

#define portINITIAL_SR      ( SR_IE )
#define portCLEAR_PENDING_INTERRUPTS()      mips_eic0_setmask (0)

#define portSET_INTERRUPT_MASK_FROM_ISR()   uxPortSetInterruptMaskFromISR()
#define portCLEAR_INTERRUPT_MASK_FROM_ISR( uxSavedStatusRegister ) \
	vPortClearInterruptMaskFromISR( uxSavedStatusRegister )


#ifdef	__cplusplus
}
#endif

#endif	/* INT_HANDLER_H */

