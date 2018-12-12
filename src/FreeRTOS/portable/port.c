/*-----------------------------------------------------------
 * Implementation of functions defined in portable.h for the MIPS32 port.
 *----------------------------------------------------------*/

#include <mips/hal.h>
#include <mips/m32c0.h>

/* Scheduler include files. */
#include "FreeRTOS.h"
#include "task.h"

/* Timer handling files */
// #include "port_timer.h"

/* Interrupt handler */
#include "int_handler.h"

#include "iolib.h"
#include "eic.h"

/* Let the user override the pre-loading of the initial RA with the address of
prvTaskExitError() in case is messes up unwinding of the stack in the
debugger - in which case configTASK_RETURN_ADDRESS can be defined as 0 (NULL). */
#ifdef configTASK_RETURN_ADDRESS
	#define portTASK_RETURN_ADDRESS	configTASK_RETURN_ADDRESS
#else
	#define portTASK_RETURN_ADDRESS	prvTaskExitError
#endif

/* Set configCHECK_FOR_STACK_OVERFLOW to 3 to add ISR stack checking to task
stack checking.  A problem in the ISR stack will trigger an assert, not call the
stack overflow hook function (because the stack overflow hook is specific to a
task stack, not the ISR stack). */
#if( configCHECK_FOR_STACK_OVERFLOW > 2 )

	/* Don't use 0xa5 as the stack fill bytes as that is used by the kernel for
	the task stacks, and so will legitimately appear in many positions within
	the ISR stack. */
	#define portISR_STACK_FILL_BYTE	0xee

	static const uint8_t ucExpectedStackBytes[] = {
									portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE,		\
									portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE,		\
									portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE,		\
									portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE,		\
									portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE, portISR_STACK_FILL_BYTE };	\

	#define portCHECK_ISR_STACK() configASSERT( ( memcmp( ( void * ) xISRStack, ( void * ) ucExpectedStackBytes, sizeof( ucExpectedStackBytes ) ) == 0 ) )
#else
	/* Define the function away. */
	#define portCHECK_ISR_STACK()
#endif /* configCHECK_FOR_STACK_OVERFLOW > 2 */

/*-----------------------------------------------------------*/

/*
 * Used to catch tasks that attempt to return from their implementing function.
 */
static void prvTaskExitError( void );

/*-----------------------------------------------------------*/

/* Records the interrupt nesting depth. - unused currently as no int stack */
volatile UBaseType_t uxInterruptNesting = 0x0;

/* Stores the task stack pointer when a switch is made to use the system stack. */
UBaseType_t uxSavedTaskStackPointer = 0;

/* portYIELD variable, 1 if YIELD required. */
volatile uint8_t flagYIELD = 0;

/* The stack used by interrupt service routines that cause a context switch. */
StackType_t xISRStack[ configISR_STACK_SIZE ] = { 0 };

/* The top of stack value ensures there is enough space to store 6 registers on
the callers stack, as some functions seem to want to do this. */
const StackType_t * const xISRStackTop = &( xISRStack[ configISR_STACK_SIZE - 7 ] );

/*-----------------------------------------------------------*/

/*
 * See header file for description.
 */
StackType_t *pxPortInitialiseStack( StackType_t *pxTopOfStack, TaskFunction_t pxCode, void *pvParameters )
{
// 	OutString(__func__);
// 	putsns("(0x", (reg_t)pxTopOfStack, ", ");
// 	putsns("0x", (reg_t)pxCode, ", ");
// 	putsnds("0x", (reg_t)pvParameters, 8, ") = ");

	*pxTopOfStack = (StackType_t) 0xEFACABCDDEADBEEF;
	pxTopOfStack--;

	*pxTopOfStack = (StackType_t) 0x1234567890876543;       /* Word to which the stack pointer will be left pointing after context restore. */
	pxTopOfStack--;

	/* create a space for a full context */
	pxTopOfStack -= CTX_SIZE/8;

	/* fill up some initial values for us to kick in */
	*( pxTopOfStack + CTX_CAUSE/8 ) = (StackType_t) mips_getcr();
	*( pxTopOfStack + CTX_STATUS/8 ) = (StackType_t) (mips32_get_c0(C0_STATUS) | portINITIAL_SR);
	*( pxTopOfStack + CTX_EPC/8 ) = (StackType_t) pxCode;
	*( pxTopOfStack + CTX_RA/8 ) = (StackType_t) portTASK_RETURN_ADDRESS;
	*( pxTopOfStack + CTX_A0/8 ) = (StackType_t) pvParameters; /* Parameters to pass in. */

	/* Save GP register value in the context */
	asm volatile ("sd $gp, %0" : "=m" (*( pxTopOfStack + CTX_GP/8 )));

// 	putsns("0x", (reg_t)(pxTopOfStack), "\n");

	return pxTopOfStack;
}
/*-----------------------------------------------------------*/

static void prvTaskExitError( void )
{
	/* A function that implements a task must not exit or attempt to return to
	its caller as there is nothing to return to.  If a task wants to exit it
	should instead call vTaskDelete( NULL ).

	Artificially force an assert() to be triggered if configASSERT() is
	defined, then stop here so application writers can catch the error. */

	configASSERT( uxSavedTaskStackPointer == 0UL );
	portDISABLE_INTERRUPTS();
	for( ;; );
}
/*-----------------------------------------------------------*/

void vPortEndScheduler(void)
{
	/* Not implemented in ports where there is nothing to return to.
	Artificially force an assert. */
	configASSERT( uxInterruptNesting == 1000UL );
}
/*-----------------------------------------------------------*/

BaseType_t xPortStartScheduler( void )
{
extern void vPortStartFirstTask( void );
extern void *pxCurrentTCB;
	// wwrite(__func__);wwrite("\n");
#if ( configCHECK_FOR_STACK_OVERFLOW > 2 )
{
	/* Fill the ISR stack to make it easy to asses how much is being used. */
	memset( ( void * ) xISRStack, portISR_STACK_FILL_BYTE, sizeof( xISRStack ) );
}
#endif /* configCHECK_FOR_STACK_OVERFLOW > 2 */

	mips32_bissr (SR_IE);

	/* Kick off the highest priority task that has been created so far.
	Its stack location is loaded into uxSavedTaskStackPointer. */
	uxSavedTaskStackPointer = *( UBaseType_t * ) pxCurrentTCB;

	mips_setcount(0);
	mips_eic0_setmask(0x8);

	mips_setcompare(0x5000);

	// putsnds("mask=0x", mips_eic0_getmask(), 8, "\n");
	// putsnds("sr=0x", mips_getsr(), 8, "\n");

	vPortStartFirstTask();

	/* Should never get here as the tasks will now be executing!  Call the task
	exit error function to prevent compiler warnings about a static function
	not being called in the case that the application writer overrides this
	functionality by defining configTASK_RETURN_ADDRESS. */
	prvTaskExitError();

	return pdFALSE;
}
/*-----------------------------------------------------------*/

void vPortIncrementTick( void )
{
	if( xTaskIncrementTick() != pdFALSE )
	{
		wwrite("ctx switch...\n");
		/* Pend a context switch. */
		portYIELD();
	}
}
/*-----------------------------------------------------------*/

#if configCHECK_FOR_STACK_OVERFLOW > 0
/* Assert at a stack overflow. */
void vApplicationStackOverflowHook( TaskHandle_t xTask, char *pcTaskName )
{
	configASSERT( xTask == NULL );
}
#endif

/*-----------------------------------------------------------*/
void proc1 (void)
{
// 	putsns("pxStack=0x", pxCurrentTCB->pxStack, "\n");
}
/*-----------------------------------------------------------*/

UBaseType_t uxPortSetInterruptMaskFromISR( void )
{
	UBaseType_t uxSavedEIC0MaskRegister;

	uxSavedEIC0MaskRegister = mips_eic0_getmask ();
	mips_eic0_setmask (0);

	return uxSavedEIC0MaskRegister;
}
/*-----------------------------------------------------------*/

void vPortClearInterruptMaskFromISR( UBaseType_t uxSavedEIC0MaskRegister )
{
	mips_eic0_setmask ( uxSavedEIC0MaskRegister );
}
