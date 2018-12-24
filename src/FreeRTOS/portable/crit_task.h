/* Critical section management, and task utilities.*/
#ifndef CRIT_TASK_H
#define	CRIT_TASK_H

#ifdef	__cplusplus
extern "C"
{
#endif

#define portDISABLE_INTERRUPTS( ) asm("di")

#define portENABLE_INTERRUPTS( ) asm("ei")

extern void vTaskEnterCritical( void );
extern void vTaskExitCritical( void );
#define portCRITICAL_NESTING_IN_TCB 1
#define portENTER_CRITICAL()        vTaskEnterCritical()
#define portEXIT_CRITICAL()         vTaskExitCritical()

#ifndef configUSE_PORT_OPTIMISED_TASK_SELECTION
	#define configUSE_PORT_OPTIMISED_TASK_SELECTION 1
#endif

#if configUSE_PORT_OPTIMISED_TASK_SELECTION == 1

	/* Check the configuration. */
	#if( configMAX_PRIORITIES > 32 )
		#error configUSE_PORT_OPTIMISED_TASK_SELECTION can only be set to 1 when configMAX_PRIORITIES is less than or equal to 32.  It is very rare that a system requires more than 10 to 15 difference priorities as tasks that share a priority will time slice.
	#endif

	/* Store/clear the ready priorities in a bit map. */
	#define portRECORD_READY_PRIORITY( uxPriority, uxReadyPriorities )      \
		( uxReadyPriorities ) |= ( 1UL << ( uxPriority ) )

	#define portRESET_READY_PRIORITY( uxPriority, uxReadyPriorities )       \
		( uxReadyPriorities ) &= ~( 1UL << ( uxPriority ) )

	/*-----------------------------------------------------------*/

	#define portGET_HIGHEST_PRIORITY( uxTopPriority, uxReadyPriorities )    \
		uxTopPriority = ( 31 - mips_clz( ( uxReadyPriorities ) ) )

#endif

/* Task utilities. */

/* To yield, we fire off a software interrupt, that will be handled by the
relevant interrupt handler. */
// extern volatile uint8_t flagYIELD;
#define portYIELD() \
{ \
	mips_eic0_seticureq(1); \
}

// extern volatile UBaseType_t uxInterruptNesting;
// #define portASSERT_IF_IN_ISR()  configASSERT( uxInterruptNesting == 0 )

#define portNOP()               __asm volatile ( "nop" )
/*-----------------------------------------------------------*/

#ifdef	__cplusplus
}
#endif

#endif	/* CRIT_SECT_H */
