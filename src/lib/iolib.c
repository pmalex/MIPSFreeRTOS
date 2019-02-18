#include "iolib.h"

#include "crit_task.h"

uint8_t mips_getrand(void)
{
    mips_tlbr();
    return mips32_get_c0(C0_RANDOM);
}

#define UART_BASE			0xffffffffb8210400

void SendByte (const uint8_t x)
{
    // portENTER_CRITICAL();
	while(!(*((volatile uint8_t* const)(UART_BASE + 0x08)) & 0x08));
	*((volatile uint8_t* const)(UART_BASE + 0x20)) = x;
    // portEXIT_CRITICAL();
}

inline void delay(uint32_t v)
{
    for(int i = 0;i < v; i++);
}

void OutString(const char *str)
{
    while(*str)
        SendByte(*str++);
}

// int write (int file, const char *ptr, int len)
// {
// 	for(int i = 0; i < len; i++)
// 		SendByte (*ptr++);
//
// 	return len;
// }

// int wwrite (const char *ptr)
// {
// 	while(*ptr)
// 		SendByte(*ptr++);
// }

// void putsnds (const char *pre, reg_t value, int digits, const char *post)
// {
// 	char buf[digits];
// 	int shift;
// 	int idx = 0;
//
// 	if (pre != NULL)
// 		OutString (pre);
//
// 	for (shift = ((digits - 1) * 4) ; shift >= 0 ; shift -= 4)
// 		buf[idx++] = "0123456789abcdef"[(value >> shift) & 0xf];
// 	write (1, buf, digits);
//
// 	if (post != NULL)
// 		OutString (post);
// }

// void putsns (const char *pre, reg_t value, const char *post)
// {
// 	putsnds (pre, value, sizeof (reg_t) * 2, post);
// }
