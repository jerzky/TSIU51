;
; TestStepper.asm
;
; Created: 2019-02-06 13:06:57
; Author : Jensg
;


; Replace with your application code



STEP_DATA: .db $01, $09, $08, $0A, $02, $06, $04, $05, $00
STEP_DATA_REVERSE: .db $05, $04, $06, $02, $0A, $08, $09, $01, $00

		.def	reverse_bit = r20

		ldi		r16, HIGH(RAMEND)
		out		SPH, r16
		ldi		r16, LOW(RAMEND)
		out		SPL, r16

		ldi		r16, $FF
		out		DDRA, r16
		out		DDRC, r16

		ldi		reverse_bit, $00

		rjmp	START
NORMAL:
		cbi		PORTC, 7
		ldi		ZH, HIGH(STEP_DATA*2)
		ldi		ZL, LOW(STEP_DATA*2)
		rjmp	LOOP
REVERSE:
		sbi		PORTC, 7
		ldi		ZH, HIGH(STEP_DATA_REVERSE*2)
		ldi		ZL, LOW(STEP_DATA_REVERSE*2)
		rjmp	LOOP
START:
		inc		r18	
		brne	START_NORMAL
		com		reverse_bit
START_NORMAL:
		cpi		reverse_bit, $FF
		brne	NORMAL
		rjmp	REVERSE	
LOOP:
		lpm		r16, Z+
		cpi		r16, $00
		breq	START
OUTPUT:
		swap	r16
		out		PORTA, r16
		rcall	DELAY
		rjmp	LOOP


DELAY:
		ldi		r17, $00
DELAY_OUTER:	
		ldi		r16, $05
DELAY_INNER:
		dec		r16
		brne	DELAY_INNER
		dec		r17
		brne	DELAY_OUTER
		ret