#ifndef TRACE_H
#define	TRACE_H

#ifdef	__cplusplus
extern "C"
{
#endif

#define TRACE_OUT_STRING(x) OutString(x)
#define TRACE_OUT_VALUE(x) OutReg32((reg_t)x)
#define TRACE_PROMPT() TRACE_OUT_STRING("\ntrace: ")
#define TRACE_PAIR(x,y) do{ TRACE_PROMPT(); TRACE_OUT_STRING(x); \
    SendByte(' '); TRACE_OUT_STRING(y);} while(0)

#define traceTASK_INCREMENT_TICK(xTickCount)  SendByte('~');
#define traceTASK_SWITCHED_OUT()              TRACE_PAIR("SWITCH_OUT", pxCurrentTCB -> pcTaskName)
#define traceTASK_SWITCHED_IN()               TRACE_PAIR("SWITCH_IN", pxCurrentTCB -> pcTaskName)
#define traceTASK_CREATE(pxNewTCB)            TRACE_PAIR("TASK_CREATE", pxNewTCB -> pcTaskName)
#define traceTASK_DELETE(pxTaskToDelete)      TRACE_PAIR("TASK_DELETE", pxTaskToDelete -> pcTaskName)
#define traceTASK_RESUME(pxTaskToResume)      TRACE_PAIR("TASK_RESUME", pxTaskToResume -> pcTaskName)
#define traceTASK_SUSPEND(pxTaskToSuspend)    TRACE_PAIR("TASK_SUSPEND", pxTaskToSuspend -> pcTaskName)
#define traceTASK_DELAY()                     TRACE_PAIR("TASK_DELAY", "")

#define traceMALLOC(pvAddress, uiSize) do { \
            TRACE_PROMPT(); \
            TRACE_OUT_STRING("MALLOC("); TRACE_OUT_VALUE(pvAddress); \
            SendByte(','); \
            TRACE_OUT_VALUE(uiSize); TRACE_OUT_STRING(")"); \
        } while(0)

#define traceFREE(pvAddress, uiSize) do { \
            TRACE_PROMPT(); \
            TRACE_OUT_STRING("FREE("); TRACE_OUT_VALUE(pvAddress); \
            SendByte(','); TRACE_OUT_VALUE(uiSize); SendByte(')'); \
        } while(0)

#ifdef	__cplusplus
}
#endif

#endif	/* TRACE_H */
