/*
 * External Interrupt Controller user API
 */

#include <stdint.h>

#define EIC0_BASE		0xFFFFFFFFB8210600

#define EIC0CTRL		(0x0000 + EIC0_BASE)
#define EIC0MASK		(0x0008 + EIC0_BASE)
#define EIC0STAT		(0x0010 + EIC0_BASE)
#define EIC0SSM_REG		(0x0018 + EIC0_BASE)
#define EIC0INTNUM		(0x0020 + EIC0_BASE)
#define EIC0ICUPRI		(0x0028 + EIC0_BASE)
#define EIC0ICUREQ		(0x0030 + EIC0_BASE)

#define EIC0_TIMER_IRQ			1 << 3

void mips_eic0_setctrl (const uint32_t val);
void mips_eic0_setmask (const uint32_t val);
uint32_t mips_eic0_getmask (void);
void mips_eic0_setssm (const uint32_t val);
void mips_eic0_setintnum (const uint32_t val);
void mips_eic0_seticupri (const uint32_t val);
void mips_eic0_seticureq (const uint32_t val);
uint32_t mips_eic0_geticureq (void);
