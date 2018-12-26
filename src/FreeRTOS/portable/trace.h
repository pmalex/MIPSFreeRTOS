#ifndef TRACE_H
#define	TRACE_H

#ifdef	__cplusplus
extern "C"
{
#endif

#define TRACE_EVENT(x) OutString(x)
#define TRACE_VALUE(x) do{ SendByte(':'); OutReg32((reg_t)x);} while(0)

#define TRACE_PAIR(x, y)    do { TRACE_EVENT((x)); TRACE_VALUE((y)); } while(0)

// #define traceTASK_INCREMENT_TICK(x) TRACE_PAIR("trace_TICK", (x))
#define traceTASK_SWITCHED_OUT()    TRACE_PAIR("\ntrace_SWITCH_OUT", pxCurrentTCB)
#define traceTASK_SWITCHED_IN()     TRACE_PAIR("\ntrace_SWITCH_IN", pxCurrentTCB)

#ifdef	__cplusplus
}
#endif

#endif	/* TRACE_H */
