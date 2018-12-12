/* Kernel includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"

#include "iolib.h"

/* Priorities at which the tasks are created. */
#define mainQUEUE_RECEIVE_TASK_PRIORITY		( tskIDLE_PRIORITY + 2 )
#define	mainQUEUE_SEND_TASK_PRIORITY		( tskIDLE_PRIORITY + 1 )

/* The rate at which data is sent to the queue, specified in milliseconds. */
#define mainQUEUE_SEND_FREQUENCY_MS			( 10 )

/* The number of items the queue can hold.  This is 1 as the receive task
will remove items as they are added, meaning the send task should always find
the queue empty. */
#define mainQUEUE_LENGTH					( 1 )

/*-----------------------------------------------------------*/

/*
 * The tasks as described in the accompanying PDF application note.
 */
static void prvQueueReceiveTask( void *pvParameters );
static void prvQueueSendTask( void *pvParameters );
static void taskA( void* );
static void taskB( void* );

/*-----------------------------------------------------------*/

/* The queue used by both tasks. */
static xQueueHandle xQueue = NULL;

/* One array position is used for each task created by this demo.  The
variables in this array are set and cleared by the trace macros within
FreeRTOS, and displayed on the logic analyzer window within the Keil IDE -
the result of which being that the logic analyzer shows which task is
running when. */
unsigned long ulTaskNumber[ 3 ];

/*-----------------------------------------------------------*/
int main(void)
{
	wwrite("Starting...\n");
	/* Create the queue. */
	xQueue = xQueueCreate( mainQUEUE_LENGTH, sizeof( unsigned long ) );

	if( xQueue != NULL )
	{
		/* Start the two tasks as described in the accompanying application
		note. */
		xTaskCreate( prvQueueReceiveTask, ( signed char * ) "Rx",
			configMINIMAL_STACK_SIZE, NULL, mainQUEUE_RECEIVE_TASK_PRIORITY, NULL );
		xTaskCreate( prvQueueSendTask, ( signed char * ) "TX",
			configMINIMAL_STACK_SIZE, NULL, mainQUEUE_SEND_TASK_PRIORITY, NULL );
		xTaskCreate( taskA, ( signed char * ) "taskA", configMINIMAL_STACK_SIZE,
			NULL, tskIDLE_PRIORITY + 1, NULL );
		xTaskCreate( taskB, ( signed char * ) "taskB", configMINIMAL_STACK_SIZE,
			NULL, tskIDLE_PRIORITY + 1, NULL );

		asm("nop\n"
				"nop\n"
				"nop\n"
		);

		/* Start the tasks running. */
		vTaskStartScheduler();
	}

	OutString("WARNING! This point in main must not be reached!\n");
	/* If all is well we will never reach here as the scheduler will now be
	running.  If we do reach here then it is likely that there was insufficient
	heap available for the idle task to be created. */
	for( ;; );
}
/*-----------------------------------------------------------*/
void vApplicationIdleHook( void )
{
	for( ;; ){
		for(int i = 0;i < 10000;i++);
		OutString("IdleHook\n");
	}
}

static void taskA( void *pvParameters )
{
	for( ;; ){
// 		for(int i = 0;i < 10000;i++);
		wwrite("taskA\n");
	}
}

static void taskB( void *pvParameters )
{
	for( ;; ){
// 		for(int i = 0;i < 10000;i++);
		wwrite("taskB\n");
	}
}
/*-----------------------------------------------------------*/

static void prvQueueSendTask( void *pvParameters )
{
portTickType xNextWakeTime;
const unsigned long ulValueToSend = 100UL;

	putsnds(__func__, 0, 0, " call...\n");

	/* Initialise xNextWakeTime - this only needs to be done once. */
	xNextWakeTime = xTaskGetTickCount();

	for( ;; )
	{
		/* Place this task in the blocked state until it is time to run again.
		The block time is specified in ticks, the constant used converts ticks
		to ms.  While in the Blocked state this task will not consume any CPU
		time. */
		vTaskDelayUntil( &xNextWakeTime, mainQUEUE_SEND_FREQUENCY_MS );

		/* Send to the queue - causing the queue receive task to unblock and
		print out a message.  0 is used as the block time so the sending
		operation will not block - it shouldn't need to block as the queue
		should always be empty at this point in the code. */
		xQueueSend( xQueue, &ulValueToSend, 0 );

// 		printf("%s message sent\n", __func__);
		putsnds(__func__, 0, 0, " message sent\n");
		vTaskDelete(NULL);
	}
}
/*-----------------------------------------------------------*/

static unsigned long ulRcv;

static void prvQueueReceiveTask( void *pvParameters )
{
unsigned long ulReceivedValue;
// 	printf("%s call...\n", __func__);
	putsnds(__func__, 0, 0, " call\n");

	for( ;; )
	{
		/* Wait until something arrives in the queue - this task will block
		indefinitely provided INCLUDE_vTaskSuspend is set to 1 in
		FreeRTOSConfig.h. */
		xQueueReceive( xQueue, &ulReceivedValue, portMAX_DELAY );

		putsnds(__func__, 0, 0, " message received\n");

		/*  To get here something must have been received from the queue, but
		is it the expected value?  If it is, print out a pass message, if no,
		print out a fail message. */
		if( ulReceivedValue == 100UL )
		{
			ulRcv++;
			OutString("ok\n");
			vTaskDelete(NULL);
		}
		else
		{
			OutString("no\n");
			ulRcv = 0;
		}
	}
}
/*-----------------------------------------------------------*/
void vAssertCalled( const char *pcFileName, unsigned long ulLine )
{
	OutString("Guru meditation in ");
	OutString(pcFileName);
	putsns(": 0x", ulLine, "\n");
	for (;;);
}
// asm(".align 10");
