;
; TSIU51-1.asm
;
; Created: 2019-01-29 10:41:18
; Author : Jensg
;

COLD:
	ldi	 r16,HIGH(RAMEND)
	out		SPH,r16
	ldi		r16,LOW(RAMEND)
	out		SPL,r16
	rcall	INIT

	ldi		r16,$FF
	out		DDRA,r16
	ldi		r16,$B7
	out		DDRB,r16
	ldi		r16,$80
	out		DDRC,r18
	ldi		r16,$00
	out		DDRD,r16
	ret



