#include "eic.h"

void mips_eic0_setctrl (const uint32_t val)
{
	*(volatile uint32_t* const)(EIC0CTRL) = val;
}

void mips_eic0_setmask (const uint32_t val)
{
	*(volatile uint32_t* const)(EIC0MASK) = val;
}

uint32_t mips_eic0_getmask (void)
{
	return *(volatile uint32_t* const)(EIC0MASK);
}

void mips_eic0_setssm (const uint32_t val)
{
	*(volatile uint32_t* const)(EIC0SSM_REG) = val;
}

void mips_eic0_setintnum (const uint32_t val)
{
	*(volatile uint32_t* const)(EIC0INTNUM) = val;
}

void mips_eic0_seticupri (const uint32_t val)
{
	*(volatile uint32_t* const)(EIC0ICUPRI) = val;
}

void mips_eic0_seticureq (const uint32_t val)
{
	*(volatile uint32_t* const)(EIC0ICUREQ) = val;
}

uint32_t mips_eic0_geticureq (void)
{
	return *(volatile uint32_t* const)(EIC0ICUREQ);
}
