; main.asm

	processor 16f84A
	include <p16F84A.inc>
	__config _RC_OSC & _WDT_OFF & _PWRTE_ON

; some handy macro definitions

IFEQ macro fr,lit,label
	movlw lit
	xorwf fr,W
	btfss STATUS,Z ; (fr == lit) then execute code following macro
	goto label ; else goto label
	 endm

MOVLF macro lit,fr
	movlw lit
	movwf fr
	  endm

MOVFF macro from,to
	movf from,W
	movwf to
  	  endm

; file register variables
nextS equ 0x0C
octr equ 0x0D
ictr equ 0x0E

; state definitions for Port A
OK equ B'00000'
L1 equ B'00001'
L2 equ B'00010'
L3 equ B'00100'
L4 equ B'01000'
ER equ B'10000'

; input bits on Port B
G4 equ 3
G3 equ 2
G2 equ 1
G1 equ 0

; Important initialization
	org 0x00	; reset at address 0
reset:	goto	init	; skip reserved program addresses
	org	0x08 	; beginning of user code
init:
	bsf	STATUS,RP0
	MOVLF B'11100000',TRISA
	bcf	STATUS,RP0

MOVLF	L1,nextS

mloop:
	MOVFF	nextS, PORTA
	call delay

	IFEQ	PORTA, L1, s2 ; if (state == L1)

		IFEQ	PORTB, OK, yesInput ; if (G1' G2' G3' G4') ; no input
			MOVLF	L2, nextS
			goto mloop

	s2: IFEQ	PORTA, L2, s3  ; else if (state == L2)
		IFEQ	PORTB, OK, yesInput
			MOVLF	L3, nextS
			goto mloop

	s3: IFEQ	PORTA, L3, s4  ; else if (state == L3)
		IFEQ	PORTB, OK, yesInput
			MOVLF	L4, nextS
			goto mloop

	s4: IFEQ	PORTA, L4, ok  ; else if (state == L4)
		IFEQ	PORTB, OK, yesInput
			MOVLF	L1, nextS
			goto mloop

	ok: IFEQ	PORTA, OK, er ; else if (state == OK)
		IFEQ	PORTB, OK, sok
			MOVLF	L1, nextS
			goto mloop

	er: IFEQ	PORTA, ER, err  ; else if (state == ER)
		IFEQ	PORTB, OK, err
			MOVLF	L1, nextS
			goto mloop

err:MOVLF	ER,nextS ; goToError
	goto mloop
sok:MOVLF	OK,nextS ; goToSOK
	goto mloop
yesInput: IFEQ	PORTA, PORTB, err
	goto sok


; Delay helper method
; 25khz
delay: ; create a delay of about 0.5 seconds
	MOVLF	d'32',octr ; initialize outer loop counter to 16
d1:	clrf	ictr	; initialize inner loop counter to 256
d2: decfsz	ictr,F	; if (--ictr != 0) loop to d2
	goto 	d2
	decfsz	octr,F	; if (--octr != 0) loop to d1
	goto	d1
  return
endloop: ; end of main loop
	goto	mloop

	end		; end of program code
