#ifndef TRACE_H
#define	TRACE_H

#ifdef	__cplusplus
extern "C"
{
#endif

#if !defined(__ASSEMBLER__)
enum _traceEvents {
	trace_TICK = 0,
	trace_SWITCH_OUT,
	trace_SWITCH_IN,
};
#endif

#define TRACE_EVENT(x)      _m32c0_mtc0(23, 3, (x))
#define TRACE_VALUE(x)      _m32c0_mtc0(24, 3, (x))
#define TRACE_PAIR(x, y)    do { TRACE_EVENT((x)); TRACE_VALUE((y)); } while(0)

#define traceTASK_INCREMENT_TICK(x) TRACE_PAIR(trace_TICK, (x))
#define traceTASK_SWITCHED_OUT()    TRACE_PAIR(trace_SWITCH_OUT, pxCurrentTCB)
#define traceTASK_SWITCHED_IN()     TRACE_PAIR(trace_SWITCH_IN, pxCurrentTCB)

#ifdef	__cplusplus
}
#endif

#endif	/* TRACE_H */

