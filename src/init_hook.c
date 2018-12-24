#include <mips/cpu.h>
#include "eic.h"

/* Start program address, defined in ld script */
extern volatile uint64_t __entry[];

void hardware_init_hook(void)
{
	mips32_setebase(__entry);

	/* Setup Vectored Interrupts */
	mips_biscr( CR_IV );
	mips32_setintctl( ( mips32_getintctl() & ~INTCTL_VS ) | INTCTL_VS_64 );

	/* Start Counting */
	mips_biscr(CR_DC);

	/* Enable Interrupts */
	mips_setsr(1);

	// Разрешение работы EIC
	mips_eic0_setctrl(1);

	/* Настроим соответствие прерываний и теневых множеств. Нумерация
       прерываний с нуля, теневых множеств - с единицы. */
	for(int i = 1;i < 8; i++){
		mips_eic0_setintnum (i-1);
		mips_eic0_setssm (i);
	}

	/* Устанавливаем теневой набор для исключений */
	mips32_setsrsctl (6 << SRSCTL_ESS_SHIFT);

	/* Задержка, связанная с багом в наших скриптах загрузки */
	for(int i = 0; i < 300000;i++);
}
