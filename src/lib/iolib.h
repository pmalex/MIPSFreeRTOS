#include <mips/cpu.h>
#include <stdint.h>

uint8_t mips_getrand(void);

void SendByte (const uint8_t);
// int write (int, const char*, int);
// int wwrite (const char*);
// void putsnds (const char*, reg_t, int, const char*);
// void putsns (const char*, reg_t, const char*);
//
// void* memset(void*, int, size_t);
// void* memcpy(void*, const void*, size_t);
//
void OutString(const char*);
void OutReg32(reg_t);
void OutReg64(reg_t);
// void OutCRLF(void);
void delay(uint32_t);
