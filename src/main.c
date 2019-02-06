/* Kernel includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"

#include "iolib.h"

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
static void CheckTask( void *pvParameters );
static void FillTask( void *pvParameters );
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

uint32_t data[16];

/*-----------------------------------------------------------*/
int main(void)
{
    OutString("######################################################\n");
	OutString("Welcome to MIPS FreeRTOS 0.0.1\n");

	// xQueue = xQueueCreate( mainQUEUE_LENGTH, sizeof( unsigned long ) );
    //
	// if( xQueue != NULL )
	// {
		// xTaskCreate( CheckTask, ( signed char * ) "CheckTask",
		// 	configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY + 2 , NULL );
		// xTaskCreate( FillTask, ( signed char * ) "FillTask",
		// 	configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY + 1 , NULL );
        //
		xTaskCreate( taskA, ( signed char * ) "taskA", configMINIMAL_STACK_SIZE,
			NULL, tskIDLE_PRIORITY + 1, NULL );
		xTaskCreate( taskB, ( signed char * ) "taskB", configMINIMAL_STACK_SIZE,
			NULL, tskIDLE_PRIORITY + 1, NULL );

		/* Start the tasks running. */
		vTaskStartScheduler();
	// }

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
        // mips_getrand();
        SendByte('.');
        // SendByte('0' + mips_getrand() % 10);
    }
}

// void vApplicationTickHook( void )
// {
//     for( ;; ){
//         asm("nop");
//     }
// }

uint64_t fib(int n)
{
    if(n == 0)return 0;
    else return fib(n - 1) + fib(n - 2);
}

static void taskA( void *pvParameters )
{
    for(;;){
        OutString("12345\n");
        vTaskDelete(NULL);
    }
}

static void taskB( void *pvParameters )
{
    for(;;){
        OutString("ABCDEF\n");
        vTaskDelete(NULL);
    }
}
/*-----------------------------------------------------------*/

static void FillTask( void *pvParameters )
{
portTickType xNextWakeTime;
const unsigned long ulValueToSend = 8;

    for(int i = 0; i < 16; i++)
        data[i] = i + 5;

	/* Initialise xNextWakeTime - this only needs to be done once. */
	xNextWakeTime = xTaskGetTickCount();

	vTaskDelayUntil( &xNextWakeTime, mainQUEUE_SEND_FREQUENCY_MS );

	/* Send to the queue - causing the queue receive task to unblock and
	print out a message.  0 is used as the block time so the sending
	operation will not block - it shouldn't need to block as the queue
	should always be empty at this point in the code. */
	xQueueSend( xQueue, &ulValueToSend, 0 );

	vTaskDelete(NULL);
}
/*-----------------------------------------------------------*/

static void CheckTask( void *pvParameters )
{
unsigned long ulReceivedValue;

	/* Wait until something arrives in the queue - this task will block
	indefinitely provided INCLUDE_vTaskSuspend is set to 1 in
	FreeRTOSConfig.h. */
	xQueueReceive( xQueue, &ulReceivedValue, portMAX_DELAY );

    for(;;){
	/*  To get here something must have been received from the queue, but
	is it the expected value?  If it is, print out a pass message, if no,
	print out a fail message. */
    	if( ulReceivedValue == 8 )
    	{
            OutString("Test #1: ");
            for(int i = 0;i < 16;i++)
                if(data[i] != i + 5){
                    OutString("FAILED\n");
                    vTaskDelete(NULL);
                }
            // asm("pause");
    		OutString("PASSED\n");
            vTaskDelete(NULL);
    	}
    }
}
/*-----------------------------------------------------------*/
void vAssertCalled( const char *pcFileName, unsigned long ulLine )
{
    asm("di");
	OutString("\nGuru meditation in ");
	OutString(pcFileName);
    OutString(": 0x"); OutReg32((reg_t)ulLine); SendByte('\n');
	for (;;);
}
