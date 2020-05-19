! inicijalizacija simulacije
dc x.1, x.9996
dc x.0, x.9998
onkp false, x.1, x.1
onkp false, x.1, x.1
onkp true, x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
kpreg 1.1, r0, x.1
kpreg 1.1, r1, x.2
kpreg 1.1, r2, x.3
kpreg 1.1, r3, x.4
kpreg 1.1, r4, x.5
kpreg 1.1, r5, x.6
kpreg 1.1, r6, x.7
kpreg 1.1, r7, x.8
kpreg 2.1, r0, x.9
kpreg 2.1, r1, x.a
kpreg 2.1, r2, x.b
kpreg 2.1, r3, x.c
kpreg 2.1, r4, x.d
kpreg 2.1, r5, x.e
kpreg 2.1, r6, x.f
kpreg 2.1, r7, x.10
reg pc, x.4000
reg ivtp, x.4000
reg sp, x.9000
! kraj inicijalizacije

! ----------------------- Glavni program-------------------------------------
org x.4000
intd
ldimm x.300, r1
mvrir r1, ivtp
! INCIJALIZACIJA IVTP
ldimm x.2000, r1
stmem x.300, r1

ldimm x.1500, r1
stmem x.301, r1


ldimm x.2500, r1
stmem x.302, r1

ldimm x.500, r1
stmem x.303, r1

ldimm x.1000, r1
stmem x.304, r1


ldimm x.3000, r1
stmem x.305, r1

inte

! Pokretanje KP1.1-------
ldimm x.3, r1
stmem x.f102, r1
ldimm x.5000, r2 ! niz A
ldimm x.9, r3 ! broj elemenata niza A
ldimm x.f, r4 ! 1111b zbog startovanja KP1.1
clr ra ! flag da li je gotovo (rA = 0)
stmem x.f100, r4 ! startovanje KP 1.1


! Pokretanje KP2.1-------
ldimm x.1, r5
stmem x.f202, r5
ldimm x.6000, r6
ldimm x.9, r7
ldimm x.f, r8
clr rb
stmem x.f200, r8

! Cekanje da se obavi ucitavanje nizova -------------------
ldimm x.1, rc
loopWait1:
	and ra, ra, rc
	beql loopWait1
loopWait2:
	and rb, rb, rc
	beql loopWait2


! Poziv potprograma sumAll -----------------
ldimm x.5000, r0
push r0
ldimm x.6000, r0
push r0
ldimm x.8, r0
push r0
jsr sumAll
pop r0
stmem x.9999, r0 ! Ucitavanje zbira nizova A i B u lokaciju 9999h


! Kopiranje niza B pomocu DMA1.4 u memoriju pocevsi od lokacije 6100h

! Pokretanje DMA1.4
ldimm x.5, r1 ! broj ulaza
stmem x.f0c2, r1
ldimm x.8, r1 ! Count (8 clanova niza)
stmem x.f0c4, r1
ldimm x.6000, r1 ! Lokacija niza B (AR1)
stmem x.f0c5, r1
ldimm x.6100, r1 ! Odrediste kopiranja niza B (AR2)
stmem x.f0c6, r1

clr rf ! flag(semafor) za DMA1.4
ldimm x.b6, r1 ! vrednost za startovanje DMA1.4 

stmem x.f0c0, r1
ldimm x.f, r1
waitDMA14: and rf, rf, r1
	 bneq waitDMA14


! slanje niza A kontroleru DMA1.1


! Pokretanje DMA1.1
clr r1 ! broj ulaza
stmem x.f002, r1
ldimm x.8, r1 ! Count (8 clanova niza)
stmem x.f004, r1
ldimm x.5000, r1 ! Lokacija niza A (AR1)
stmem x.f005, r1
clr rf ! flag(semafor) za DMA1.4
ldimm x.e, r1 ! vrednost za startovanje DMA1.4 
stmem x.f000, r1
ldimm x.f, r1
waitDMA11: and rf, rf, r1
	 bneq waitDMA11

! Slanje sadrzaja lokacije 9999h kontroleru DMA1.2

! Pokretanje DMA1.2
ldimm x.2, r1 ! broj ulaza
stmem x.f042, r1
ldimm x.1, r1 ! Count (8 clanova niza)
stmem x.f044, r1
ldimm x.9999, r1 ! Lokacija 9999h
stmem x.f045, r1
clr rf ! flag(semafor) za DMA1.4
ldimm x.86, r1 ! vrednost za startovanje DMA1.4 
stmem x.f040, r1
ldimm x.f, r1
waitDMA12: and rf, rf, r1
	 bneq waitDMA12


halt
! ----------------------- Kraj glavnog programa-------------------------------



! Potprogram sumAll -------------------------------
sumAll: 
	pop r4 ! r1 <= PC
	pop r3 ! broj elemenata niza (n)
	pop r2 ! lokacija pocetka niza arr2
	pop r1 ! lokacija pocetka niza arr1
	clr r0
	clr ra
	clr rb
	loopSumAll:	
			ldrid [r1]x.0, ra ! ra <= MEM[r1 + x.0]
			ldrid [r2]x.0, rb ! rb <= MEM[r2 + x.0]
			add r0, r0, ra
			add r0, r0, rb
			inc r1
			inc r2
			dec r3
			bneq loopSumAll
	push r0
	push r4
	rts



! Prekidna rutina KP1.1-------
org x.500 ! IVT[3]
dec r3
bneq loopKP1
clr r4
stmem x.f100, r4
ldimm x.1, ra
jmp endKP1



loopKP1: 
	ldmem x.f103, rf
	stri [r2], rf
	inc r2
	
endKP1 : rti


! Prekidna rutina KP2.1---------
org x.1500 ! IVT[1]
dec r7
bneq loopKP2
clr r8
stmem x.f200, r8
ldimm x.1, rb
jmp endKP2


loopKP2: 
	ldmem x.f203, re
	stri [r6], re
	inc r6

endKP2: rti

! prekidna rutina DMA 1.4
org x.3000
push r0
ldimm x.1, rf
clr r0
stmem x.f0c0, r0
pop r0
rti

! prekidna rutina DMA 1.1
org x.2000
push r0
ldimm x.1, rf
clr r0
stmem x.f000, r0
pop r0
rti



! prekidna rutina DMA 1.2
org x.2500
push r0
ldimm x.1, rf
clr r0
stmem x.f040, r0
pop r0
rti