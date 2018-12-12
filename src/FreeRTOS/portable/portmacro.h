#ifndef PORTMACRO_H
#define	PORTMACRO_H

/* Include system headers */
#include <mips/cpu.h>

#ifdef	__cplusplus
extern "C"
{
#endif

/*-----------------------------------------------------------
 * Port specific definitions.
 *
 * The settings in this file configure FreeRTOS correctly for the
 * given hardware and compiler.
 *
 * These settings should not be altered.
 *-----------------------------------------------------------
 */

/* Type definitions. */
#define portCHAR                char
#define portFLOAT               float
#define portDOUBLE              double
#define portLONG                long
#define portSHORT               short
#define portSTACK_TYPE          uint64_t
#define portBASE_TYPE           long

typedef portSTACK_TYPE StackType_t;
typedef long BaseType_t;
typedef unsigned long UBaseType_t;

/* We'll use 32-bit ticks for efficiency */
typedef uint32_t TickType_t;
#define portMAX_DELAY           ( TickType_t ) 0xffffffffUL
#define portTICK_PERIOD_MS   ( ( TickType_t ) 1000 / configTICK_RATE_HZ )
/*-----------------------------------------------------------*/

/* Hardware specifics. */
#define portBYTE_ALIGNMENT		8
#define portSTACK_GROWTH		-1
/*-----------------------------------------------------------*/

/* Critical section management is done in the crit_sect.h file for the
interrupt mechanism being used; similarly, interrupt enable and disable are
also defined in that file. The directory for the interrupt mechanism MUST be
on the include path, things will not compile. */
#include "crit_task.h"
#include "int_handler.h"

/* Task function macros as described on the FreeRTOS.org WEB site. */
#define portTASK_FUNCTION_PROTO( vFunction, pvParameters )  \
			void vFunction( void *pvParameters ) __attribute__((noreturn))
#define portTASK_FUNCTION( vFunction, pvParameters )        \
			void vFunction( void *pvParameters )
/*-----------------------------------------------------------*/

#define portEND_SWITCHING_ISR( xSwitchRequired )	\
if( xSwitchRequired )								\
{                                                   \
	portYIELD();                                    \
}
#define portYIELD_FROM_ISR( x ) portEND_SWITCHING_ISR( x )
/* Required by the kernel aware debugger. */
#ifdef __DEBUG
	#define portREMOVE_STATIC_QUALIFIER
#endif

#ifdef	__cplusplus
}
#endif

#endif	/* PORTMACRO_H */

