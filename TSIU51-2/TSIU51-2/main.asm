;
; TSIU51-2.asm
;
; Created: 2019-01-29 10:36:44
; Author : Fredrik
;


; Replace with your application code

COLD:
	ldi	 r16,HIGH(RAMEND)
	out		SPH,r16
	ldi		r16,LOW(RAMEND)
	out		SPL,r16
	rcall	INIT

INIT:
	ldi		r16,$FF
	out		DDRA,r16
	ldi		r16,$40
	out		DDRB,r16
	ldi		r16,$80
	out		DDRC,r18
	ldi		r16,$00
	out		DDRD,r16
	ret



