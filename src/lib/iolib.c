#include <mips/cpu.h>
#include <stdint.h>

#define UART_BASE			0xffffffffb8210400

void SendByte (const uint8_t x)
{
	while(!(*((volatile uint8_t* const)UART_BASE + 0x08) & 0x08));
	*((volatile uint8_t* const)UART_BASE + 0x20) = x;
}

int write (int file, const char *ptr, int len)
{
	for(int i = 0; i < len; i++)
		SendByte (*ptr++);

	return len;
}

int wwrite (const char *ptr)
{
	while(*ptr)
		SendByte(*ptr++);
}

void putsnds (const char *pre, reg_t value, int digits, const char *post)
{
	char buf[digits];
	int shift;
	int idx = 0;

	if (pre != NULL)
		wwrite (pre);

	for (shift = ((digits - 1) * 4) ; shift >= 0 ; shift -= 4)
		buf[idx++] = "0123456789abcdef"[(value >> shift) & 0xf];
	write (1, buf, digits);

	if (post != NULL)
		wwrite (post);
}

void putsns (const char *pre, reg_t value, const char *post)
{
	putsnds (pre, value, sizeof (reg_t) * 2, post);
}

void* memset(void* memptr, int val, size_t num)
{
	while(num--)
		*((uint8_t*)memptr + num) = (uint8_t)val;
	
	return memptr;
}

void* memcpy(void * destptr, const void* srcptr, size_t num)
{
	while(num--)
		*((uint8_t*)destptr + num) = *((uint8_t*)srcptr + num);
	
	return destptr;
}

