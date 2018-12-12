#include <mips/asm.h>
#include <regdef.h>

/****************************************************/
.equ STACK_INC, 8

.irp num,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	.equ		CTX\num, STACK_INC*\num
.endr

.macro push reg
	PTR_ADDU	sp, sp, -STACK_INC
	PTR_S		\reg, 0 (sp)
.endm

.macro pop reg
	PTR_L		\reg, 0 (sp)
	PTR_ADDU	sp, sp, STACK_INC
.endm

.macro WRITE str
	.section .rodata
string\@: .asciiz "\str"
	.text
	LA		a0, string\@
	jal		wwrite
.endm
/****************************************************/
LEAF(debug_proc)
	li		a0, 'D'
	jal		SendByte
	
1:	b	1b
END(debug_proc)
/****************************************************/
LEAF(OutString)
	push	ra
	push	a0
	push	t8
	
	move	t8, a0
1:	lb		a0, 0(t8)
	beqz	a0, 2f
	jal		SendByte
	addiu	t8, t8, 1
	b		1b
	
2:	pop		t8
	pop		a0
	pop		ra
	jr	ra
END(OutString)

LEAF(OutReg64)
	.set push
	.set mips64r2
	push	ra
	push	t8
	
	move	t8, a0
	
	dext	a0, t8, 56, 8
	jal		OutByteHexF
	dext	a0, t8, 48, 8
	jal		OutByteHexF
	dext	a0, t8, 40, 8
	jal		OutByteHexF
	dext	a0, t8, 32, 8
	jal		OutByteHexF
	dext	a0, t8, 24, 8
	jal		OutByteHexF
	dext	a0, t8, 16, 8
	jal		OutByteHexF
	dext	a0, t8, 8, 8
	jal		OutByteHexF
	dext	a0, t8, 0, 8
	jal		OutByteHexF
	
	move	a0, t8
	
	pop		t8
	pop		ra
	jr	ra
	.set pop
END(OutReg64)

LEAF(OutReg32)
	push	ra
	push	t8
	
	move	t8, a0
	
	ext		a0, t8, 24, 8
	jal		OutByteHexF
	ext		a0, t8, 16, 8
	jal		OutByteHexF
	ext		a0, t8, 8, 8
	jal		OutByteHexF
	ext		a0, t8, 0, 8
	jal		OutByteHexF
	
	move	a0, t8
	
	pop		t8
	pop		ra
	jr	ra
END(OutReg32)

LEAF(OutByteHexF)
	push	ra
	push	a0
	push	t8
	
	move	t8, a0
	srl		a0, a0, 4
	jal		OutFirstDigitHexF
	andi	a0, t8, 0xf
	jal		OutFirstDigitHexF
	
	pop		t8
	pop		a0
	pop		ra
	jr	ra
END(OutByteHexF)

LEAF(OutFirstDigitHexF)
	push	ra
	push	a0
	push	t8
	
	andi	a0, a0, 0xf # в a0 оставляем только последний hex разряд
	slti	t8, a0, 0xa # a0 < 10 ?
	bgtz	t8, 1f
	addiu	a0, a0, 97-10
	b		2f
	
1:	addiu	a0, a0, 48
2:	jal		SendByte
	
	pop		t8
	pop		a0
	pop		ra
	jr	ra
END(OutFirstDigitHexF)

LEAF(OutCRLF)
	push	ra
	
	li		a0, '\r'
	jal		SendByte
	li		a0, '\n'
	jal		SendByte
	
	pop		ra
	jr	ra
END(OutCRLF)
/****************************************************/
	.section .rodata
hi_str:				.asciiz "	HI=0x"
lo_str:				.asciiz "	LO=0x"
status_str:			.asciiz " CP0	Status    0x"
cause_str:			.asciiz " Cause         0x"
intctl_str:			.asciiz " 	IntCtl    0x"
epc_str:			.asciiz " EPC       0x"
conf0_str:			.asciiz "	Config0   0x"
conf1_str:			.asciiz " Config1       0x"
conf2_str:			.asciiz "	Config2   0x"
conf3_str:			.asciiz " Config3       0x"
conf4_str:			.asciiz "	Config4   0x"
conf5_str:			.asciiz " Config5       0x"
conf6_str:			.asciiz "	Config6   0x"
conf7_str:			.asciiz " Config7       0x"
lladdr_str:			.asciiz " LLAddr    0x"
count_str:			.asciiz " Count         0x"
nestedepc_str:		.asciiz " NestedEPC 0x"
prid_str:			.asciiz "	PRId	  0x"
ebase_str:			.asciiz " EBase         0x"
cdmmbase_str:		.asciiz " CDMMBase  0x"
badinstr_str:		.asciiz "	BadInstr  0x"
badinstrp_str:		.asciiz " BadInstrP     0x"
errorepc_str:		.asciiz " ErrorEPC  0x"
random_str:			.asciiz "	Random    0x"
srsctl_str:			.asciiz " SRSCtl        0x"
badvaddr_str:		.asciiz " BadVAddr  0x"
index_str:			.asciiz "	Index     0x"
entryhi_str:		.asciiz " EntryHi   0x"
entrylo1_str:		.asciiz " EntryLo1      0x"
entrylo0_str:		.asciiz " EntryLo0  0x"
pagemask_str:		.asciiz " PageMask  0x"
pagegrain_str:		.asciiz "	PageGrain 0x"
wired_str:			.asciiz " Wired         0x"
pwctl_str:			.asciiz "	PWCtl     0x"
compare_str:		.asciiz " Compare       0x"
srsmap_str:			.asciiz "	SRSMap    0x"
context_str:		.asciiz " Context   0x"
contextconfig_str:	.asciiz " ContextConfig 0x"
depc_str:			.asciiz " DEPC      0x"
debug_str:			.asciiz " Debug     0x"
	.text
/****************************************************/
.set mips64r2
LEAF(OutCP0Reg)
	push	ra
	push	a0
	
	LA		a0,status_str
	jal		wwrite
	mfc0	a0,$12,0
	ehb
	jal		OutReg32
	
	LA		a0,cause_str
	jal		wwrite
	mfc0	a0,$13,0
	ehb
	jal		OutReg32
	
	LA		a0,epc_str
	jal		wwrite
	dmfc0	a0,$14,0
	ehb
	jal		OutReg64
	
	jal		OutCRLF
	
	LA		a0,conf0_str
	jal		wwrite
	mfc0	a0,$16,0
	ehb
	jal		OutReg32
	
	LA		a0,conf1_str
	jal		wwrite
	mfc0	a0,$16,1
	ehb
	jal		OutReg32
	
	LA		a0,lladdr_str
	jal		wwrite
	dmfc0	a0,$17,0
	ehb
	jal		OutReg64
	
	jal		OutCRLF
	
	LA		a0,conf2_str
	jal		wwrite
	mfc0	a0,$16,2
	ehb
	jal		OutReg32
	
	LA		a0,conf3_str
	jal		wwrite
	mfc0	a0,$16,3
	ehb
	jal		OutReg32
	
	LA		a0,cdmmbase_str
	jal		wwrite
	dmfc0	a0,$15,2
	ehb
	jal		OutReg64
	
	jal		OutCRLF
	
	LA		a0,conf4_str
	jal		wwrite
	mfc0	a0,$16,4
	ehb
	jal		OutReg32
	
	LA		a0,conf5_str
	jal		wwrite
	mfc0	a0,$16,5
	ehb
	jal		OutReg32
	
	LA		a0,errorepc_str
	jal		wwrite
	dmfc0	a0,$30,0
	ehb
	jal		OutReg64
	
	jal		OutCRLF
	
	LA		a0,conf6_str
	jal		wwrite
	mfc0	a0,$16,6
	ehb
	jal		OutReg32
	
	LA		a0,conf7_str
	jal		wwrite
	mfc0	a0,$16,7
	ehb
	jal		OutReg32
	
	LA		a0,depc_str
	jal		wwrite
	dmfc0	a0, $24, 0
	ehb
	jal		OutReg64
	
	jal		OutCRLF
	
	LA		a0,intctl_str
	jal		wwrite
	mfc0	a0,$12,1
	ehb
	jal		OutReg32
	
	LA		a0,count_str
	jal		wwrite
	mfc0	a0,$9,0
	ehb
	jal		OutReg32
	
	LA		a0,nestedepc_str
	jal		wwrite
	dmfc0	a0,$14,2
	ehb
	jal		OutReg64
	
	jal		OutCRLF
	
	LA		a0,prid_str
	jal		wwrite
	mfc0	a0,$15,0
	ehb
	jal		OutReg32
	
	LA		a0,ebase_str
	jal		wwrite
	mfc0	a0,$15,1
	ehb
	jal		OutReg32
	
	LA		a0,pagemask_str
	jal		wwrite
	dmfc0	a0,$5,0
	ehb
	jal		OutReg64
	
	jal		OutCRLF
	
	LA		a0,badinstr_str
	jal		wwrite
	mfc0	a0,$8,1
	ehb
	jal		OutReg32
	
	LA		a0,badinstrp_str
	jal		wwrite
	mfc0	a0,$8,2
	ehb
	jal		OutReg32
	
	LA		a0,badvaddr_str
	jal		wwrite
	dmfc0	a0,$8,0
	ehb
	jal		OutReg64
	
	jal		OutCRLF
	
	LA		a0,random_str
	jal		wwrite
	mfc0	a0,$1,0
	ehb
	jal		OutReg32
	
	LA		a0,srsctl_str
	jal		wwrite
	mfc0	a0,$12,2
	ehb
	jal		OutReg32
	
	LA		a0,entrylo0_str
	jal		wwrite
	dmfc0	a0,$2,0
	ehb
	jal		OutReg64
	
	jal		OutCRLF
	
	LA		a0,index_str
	jal		wwrite
	mfc0	a0,$0,0
	ehb
	jal		OutReg32
	
	LA		a0,entrylo1_str
	jal		wwrite
	mfc0	a0,$3,0
	ehb
	jal		OutReg32
	
	LA		a0,entryhi_str
	jal		wwrite
	dmfc0	a0,$10,0
	ehb
	jal		OutReg64
	
	jal		OutCRLF
	
	LA		a0,pagegrain_str
	jal		wwrite
	mfc0	a0,$5,1
	ehb
	jal		OutReg32
	
	LA		a0,wired_str
	jal		wwrite
	mfc0	a0,$6,0
	ehb
	jal		OutReg32
	
	LA		a0,context_str
	jal		wwrite
	dmfc0	a0,$4,0
	ehb
	jal		OutReg64
	
	jal		OutCRLF
	
	LA		a0,pwctl_str
	jal		wwrite
	mfc0	a0,$6,6
	ehb
	jal		OutReg32
	
	LA		a0,compare_str
	jal		wwrite
	mfc0	a0,$11,0
	ehb
	jal		OutReg32
	
	LA		a0, debug_str
	jal		wwrite
	dmfc0	a0, $23, 0
	ehb
	jal		OutReg64
	
	jal		OutCRLF
	
	LA		a0,srsmap_str
	jal		wwrite
	mfc0	a0,$12,3
	ehb
	jal		OutReg32
	
	LA		a0,contextconfig_str
	jal		wwrite
	mfc0	a0,$4,1
	ehb
	jal		OutReg32
	
	jal		OutCRLF
	
	pop		a0
	pop		ra
	jr	ra
	
END(OutCP0Reg)
	
/****************************************************/
LEAF(OutGPR)
	addiu	sp, -32*STACK_INC
	
	.set noat
	.irp reg,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,30,31
		sd		$\reg, \reg*STACK_INC(sp)
	.endr
	.set at
	
	move	a0, sp
	addiu	a0, 32*STACK_INC
	sd		a0, 29*STACK_INC(sp)
	
	WRITE	"	HI=0x"
	mfhi	a0
	jal		OutReg64
	
	WRITE	" LO=0x"
	mflo	a0
	jal		OutReg64
	
	WRITE	" EPC=0x"
	dmfc0	a0, $14, 0
	jal		OutReg64
	
	jal		OutCRLF
	
	WRITE	" GPR00:"
	
	WRITE	" r0 "
	move	a0, zero
	jal		OutReg64
	
	WRITE	" at "
	ld		a0, CTX1(sp)
	jal		OutReg64
	
	WRITE	" v0 "
	ld		a0, CTX2(sp)
	jal		OutReg64
	
	WRITE	" v1 "
	ld		a0, CTX3(sp)
	jal		OutReg64
	
	jal		OutCRLF
	
	WRITE	" GPR04:"
	
	WRITE	" a0 "
	ld		a0, CTX4(sp)
	jal		OutReg64

	WRITE	" a1 "
	ld		a0, CTX5(sp)
	jal		OutReg64
	
	WRITE	" a2 "
	ld		a0, CTX6(sp)
	jal		OutReg64
	
	WRITE	" a3 "
	ld		a0, CTX7(sp)
	jal		OutReg64
	
	jal		OutCRLF
	
	WRITE	" GPR08:"
	
	WRITE	" t0 "
	ld		a0, CTX8(sp)
	jal		OutReg64
	
	WRITE	" t1 "
	ld		a0, CTX9(sp)
	jal		OutReg64
	
	WRITE	" t2 "
	ld		a0, CTX10(sp)
	jal		OutReg64
	
	WRITE	" t3 "
	ld		a0, CTX11(sp)
	jal		OutReg64
	
	jal		OutCRLF
	
	WRITE	" GPR12:"
	
	WRITE	" t4 "
	ld		a0, CTX12(sp)
	jal		OutReg64
	
	WRITE	" t5 "
	ld		a0, CTX13(sp)
	jal		OutReg64
	
	WRITE	" t6 "
	ld		a0, CTX14(sp)
	jal		OutReg64
	
	WRITE	" t7 "
	ld		a0, CTX15(sp)
	jal		OutReg64
	
	jal		OutCRLF
	
	WRITE	" GPR16:"
	
	WRITE	" s0 "
	ld		a0, CTX16(sp)
	jal		OutReg64
	
	WRITE	" s1 "
	ld		a0, CTX17(sp)
	jal		OutReg64
	
	WRITE	" s2 "
	ld		a0, CTX18(sp)
	jal		OutReg64
	
	WRITE	" s3 "
	ld		a0, CTX19(sp)
	jal		OutReg64
	
	jal		OutCRLF
	
	WRITE	" GPR20:"
	
	WRITE	" s4 "
	ld		a0, CTX20(sp)
	jal		OutReg64
	
	WRITE	" s5 "
	ld		a0, CTX21(sp)
	jal		OutReg64
	
	WRITE	" s6 "
	ld		a0, CTX22(sp)
	jal		OutReg64
	
	WRITE	" s7 "
	ld		a0, CTX23(sp)
	jal		OutReg64
	
	jal		OutCRLF
	
	WRITE	" GPR24:"
	
	WRITE	" t8 "
	ld		a0, CTX24(sp)
	jal		OutReg64
	
	WRITE	" t9 "
	ld		a0, CTX25(sp)
	jal		OutReg64
	
	WRITE	" k0 "
	ld		a0, CTX26(sp)
	jal		OutReg64
	
	WRITE	" k1 "
	ld		a0, CTX27(sp)
	jal		OutReg64
	
	jal		OutCRLF
	
	WRITE	" GPR28:"
	
	WRITE	" gp "
	ld		a0, CTX28(sp)
	jal		OutReg64
	
	WRITE	" sp "
	ld		a0, CTX29(sp)
	jal		OutReg64
	
	WRITE	" s8 "
	ld		a0, CTX30(sp)
	jal		OutReg64
	
	WRITE	" ra "
	ld		a0, CTX31(sp)
	jal		OutReg64
	
	jal		OutCRLF
	
	.set noat
	.irp reg,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,30,31
		ld		$\reg, \reg*STACK_INC(sp)
	.endr
	.set at
	
	addiu	sp, 32*STACK_INC
	
	jr	ra
END(OutGPR)
/****************************************************/
