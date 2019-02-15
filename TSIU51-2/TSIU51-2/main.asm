;
; TSIU51-2.asm
;
; Created: 2019-01-29 10:36:44
; Author : Fredrik
;
; Replace with your application code

	.org 0000
	jmp INIT
	.include "tables.inc"

	.equ	 ADDR = ALPHA_Y*2
INIT:
		
			ldi		r16, HIGH(RAMEND)
			out		SPH, r16
			ldi		r16, LOW(RAMEND)
			out		SPL, r16
			ldi		r16, $FF
			out		DDRA, r16
			ldi		r16, $80
			out		DDRC, r16
START:
			rcall	TEST_ALL
			//rcall	TEST_DRAW
END:
			jmp	end


TEST_ALL:
			ldi		ZH, HIGH(ALPHA_ALL*2)
			ldi		ZL, LOW(ALPHA_ALL*2)
TEST_ALL_LOOP:
			lpm		r16, Z+
			cpi		r16, $FF
			breq	TEST_ALL_DONE
			lpm		r17, Z+
			push	ZL
			push	ZH
			lsl		r17
			lsl		r16
			brcc	NO_CARRY
			subi	r17, -1
NO_CARRY:
			mov		ZH, r17
			mov		ZL, r16
			rcall	DRAW_FUNC
			pop		ZH
			pop		ZL			
			ldi		r16, $02
			ldi		r25, $00
			ldi		r24, $0A
			rcall	MOVE_FUNC
			rjmp	TEST_ALL_LOOP
TEST_ALL_DONE:
			ret


DRAW_FUNC:		
			lpm		r16, Z+
			cpi		r16, $FF
			breq	DRAW_FUNC_DONE
			sbrc	r16, 7
			rcall	LOWER_PEN
			sbrs	r16, 7
			rcall	RAISE_PEN
			andi	r16, $7F
			lpm		r25, Z+
			lpm		r24, Z+
			rcall	MOVE_FUNC
			rjmp	DRAW_FUNC					
DRAW_FUNC_DONE:
			rcall	RAISE_PEN
			ret		

TEST_DRAW:
			ldi		ZH, HIGH(ADDR)
			ldi		ZL, LOW(ADDR)	
TEST_DRAW_LOOP:			
			lpm		r16, Z+
			cpi		r16, $FF
			breq	TEST_DRAW_DONE
			sbrc	r16, 7
			rcall	LOWER_PEN
			sbrs	r16, 7
			rcall	RAISE_PEN
			andi	r16, $7F
			lpm		r25, Z+
			lpm		r24, Z+
			rcall	MOVE_FUNC
			rjmp	TEST_DRAW_LOOP						
TEST_DRAW_DONE:
			rcall	RAISE_PEN
			ret		


;------ DRIVER FOR PLOTTER
;------ r16 direction, use consts NORTH, SOUTH .. etc
;------ r24-r25 how far to move (max 65 535)
MOVE_FUNC:
		push	ZH
		push	ZL
		mov		r19, r16
MOVE_FUNC_SEQUENCE:
		mov		r16, r19
		ldi		r17, 8
		ldi		ZH, HIGH(FIRST_PULSE*2)
		ldi		ZL, LOW(FIRST_PULSE*2)
		add		ZL, r16
MOVE_FUNC_LOOP:		
		lpm		r16, Z
		out		PORTA, r16
		call	PULSE_DELAY
		subi	ZL, -8
		dec		r17
		brne	MOVE_FUNC_LOOP
		sbiw	r25:r24,1
		brne	MOVE_FUNC_SEQUENCE
		pop		ZL
		pop		ZH
		ret



LOWER_PEN:
		sbic	PORTC,7
		rjmp	LOWER_PEN_EXIT
		sbi		PORTC, 7
		rcall	PEN_DELAY
LOWER_PEN_EXIT:
		ret


RAISE_PEN:
		sbis	PORTC, 7
		rjmp	RAISE_PEN_EXIT
		cbi		PORTC, 7
		rcall	PEN_DELAY
RAISE_PEN_EXIT:
		ret
		


PEN_DELAY:
		push	r16
		push	r17
		ldi		r17, $FF
PEN_DELAY_OUTER:
		ldi		r16, $FF
PEN_DELAY_INNER:
		dec		r16
		brne	PEN_DELAY_INNER
		dec		r17
		brne	PEN_DELAY_OUTER
		pop		r17
		pop		r16
		ret

PULSE_DELAY:
		push	r16
		push	r17
		ldi		r17, $10
PULSE_DELAY_OUTER:
		ldi		r16, $FF
PULSE_DELAY_INNER:
		dec		r16
		brne	PULSE_DELAY_INNER
		dec		r17
		brne	PULSE_DELAY_OUTER
		pop		r17
		pop		r16
		ret



