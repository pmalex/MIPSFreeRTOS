#include <mips/cpu.h>

#include "eic.h"

void hardware_init_hook(void)
{
	mips32_setebase(0xa0000000);
	
	/* Setup Vectored Interrupts */
	mips_biscr( CR_IV );
	mips32_setintctl( ( mips32_getintctl() & ~INTCTL_VS ) | INTCTL_VS_64 );
	
	/* Start Counting */
	mips_biscr(CR_DC);
	
	/* Enable Interrupts */
	mips_setsr(1);
	
	// Разрешение работы EIC
	mips_eic0_setctrl(1);
	
	// Настроим соответствие прерываний и теневых множеств
	for(int i = 1;i < 8; i++){
		mips_eic0_setintnum (i);
		mips_eic0_setssm (i);
	}
		
	// Устанавливаем теневой набор для исключений
	mips32_setsrsctl (6 << SRSCTL_ESS_SHIFT);
	
	// Задержка
	for(int i = 0; i < 300000;i++);
}
