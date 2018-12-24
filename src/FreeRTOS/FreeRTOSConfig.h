#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

/*-----------------------------------------------------------
 * Application specific definitions.
 *
 * These definitions should be adjusted for your particular hardware and
 * application requirements.
 *
 * THESE PARAMETERS ARE DESCRIBED WITHIN THE 'CONFIGURATION' SECTION OF THE
 * FreeRTOS API DOCUMENTATION AVAILABLE ON THE FreeRTOS.org WEB SITE.
 *
 * See http://www.freertos.org/a00110.html.
 *----------------------------------------------------------*/

#define configUSE_PREEMPTION                        1
#define configUSE_PORT_OPTIMISED_TASK_SELECTION     1
#define configCPU_CLOCK_HZ                          20000000
#define configTIMER_RATE_HZ                         ( ( TickType_t ) 10000000 )
#define configTICK_RATE_HZ                          1000
#define configUSE_16_BIT_TICKS                      0
#define configMAX_PRIORITIES                        5
#define configMINIMAL_STACK_SIZE                    ( 2000 )
#define configISR_STACK_SIZE                        ( 1000 )
#define configTOTAL_HEAP_SIZE						( ( size_t ) (32*4096) )
#define configMAX_TASK_NAME_LEN                     ( 16 )

/* Hook functions */
#define configUSE_IDLE_HOOK                         0
#define configUSE_TICK_HOOK                         0

/* Co routines */
#define configUSE_CO_ROUTINES                       0

/* The interrupt priority of the RTOS kernel */
#define configKERNEL_INTERRUPT_PRIORITY             0x01

/* The maximum priority from which API functions can be called */
#define configMAX_API_CALL_INTERRUPT_PRIORITY       0x03

/* Prevent assert code from being used in assembly files */
#ifndef __ASSEMBLER__
	void vAssertCalled( const char *pcFileName, unsigned long ulLine );
	#define configASSERT( x )						\
		do {										\
			if( ( x ) == 0 )						\
				vAssertCalled( __FILE__, __LINE__ );\
		} while (0)
#endif

/* Optional functions */
#define INCLUDE_vTaskPrioritySet					0
#define INCLUDE_uxTaskPriorityGet					0
#define INCLUDE_vTaskDelayUntil						1
#define INCLUDE_vTaskDelay							1
#define INCLUDE_vTaskDelete							1
#define INCLUDE_vTaskSuspend						0

// #define ENABLE_TRACE

#if defined(ENABLE_TRACE)
#include "trace.h"
#endif

#endif	/* FREERTOSCONFIG_H */
