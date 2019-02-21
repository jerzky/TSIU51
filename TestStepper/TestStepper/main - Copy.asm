;
; TestStepper.asm
;
; Created: 2019-02-06 13:06:57
; Author : Jensg
;


; Replace with your application code

		jmp		COLD
		.org	INT0addr
		jmp		INTERRUPT_0



STEP_DATA: .db $01, $09, $08, $0A, $02, $06, $04, $05, $00
STEP_DATA_REVERSE: .db $05, $04, $06, $02, $0A, $08, $09, $01, $00
COLD:		
		ldi		r16,(0 << ISC01)| ( 0 << ISC00)
		out		MCUCR,r16
		ldi		r16,(1 << INT0)
		out		GICR,r16

		ldi		r16, HIGH(RAMEND)
		out		SPH, r16
		ldi		r16, LOW(RAMEND)
		out		SPL, r16

		ldi		r16, $FF
		out		DDRA, r16
		out		DDRC, r16

		sei
MAIN:
		;;call	DRAW_RECTANGLE
		rjmp	MAIN


INTERRUPT_0:
		sbis	PIND,0
		call	TOGGLE_PEN

		sbis	PIND,7
		call	MOVE_NE
		sbis	PIND,6
		call	MOVE_WEST
		sbis	PIND,4
		call	MOVE_NORTH
		sbis	PIND,5
		call	MOVE_SOUTH
		reti


TOGGLE_PEN:
		sbis	PINC,7
		jmp		TOGGLE_PEN_ON
		cbi		PORTC,7
		jmp		TOGGLE_PEN_EXIT
TOGGLE_PEN_ON:
		sbi		PORTC,7
TOGGLE_PEN_EXIT:
		ret


MOVE_EAST:
		push	r16
		ldi		ZH, HIGH(STEP_DATA*2)
		ldi		ZL, LOW(STEP_DATA*2)
MOVE_EAST_LOOP:
		lpm		r16,Z+
		cpi		r16,$00
		breq	MOVE_EAST_EXIT
		out		PORTA,r16
		call	DELAY_STEP_PULSE
		jmp		MOVE_EAST_LOOP
MOVE_EAST_EXIT:
		pop		r16
		ret

MOVE_WEST:
		push	r16
		ldi		ZH, HIGH(STEP_DATA_REVERSE*2)
		ldi		ZL, LOW(STEP_DATA_REVERSE*2)
MOVE_WEST_LOOP:
		lpm		r16,Z+
		cpi		r16,$00
		breq	MOVE_WEST_EXIT
		out		PORTA,r16
		call	DELAY_STEP_PULSE
		jmp		MOVE_WEST_LOOP
MOVE_WEST_EXIT:
		pop		r16
		ret

MOVE_NORTH:
		push	r16
		ldi		ZH, HIGH(STEP_DATA*2)
		ldi		ZL, LOW(STEP_DATA*2)
MOVE_NORTH_LOOP:
		lpm		r16,Z+
		cpi		r16,$00
		breq	MOVE_NORTH_EXIT
		swap	r16
		out		PORTA,r16
		call	DELAY_STEP_PULSE
		jmp		MOVE_NORTH_LOOP
MOVE_NORTH_EXIT:
		pop		r16
		ret
MOVE_SOUTH:
		push	r16
		ldi		ZH, HIGH(STEP_DATA_REVERSE*2)
		ldi		ZL, LOW(STEP_DATA_REVERSE*2)
MOVE_SOUTH_LOOP:
		lpm		r16,Z+
		cpi		r16,$00
		breq	MOVE_SOUTH_EXIT
		swap	r16
		out		PORTA,r16
		call	DELAY_STEP_PULSE
		jmp		MOVE_SOUTH_LOOP
MOVE_SOUTH_EXIT:
		pop		r16
		ret
		
MOVE_NE:
		push	r17
		push	r16
		ldi		ZH, HIGH(STEP_DATA*2)
		ldi		ZL, LOW(STEP_DATA*2)

MOVE_NE_LOOP:
		lpm		r16,Z+
		cpi		r16,$00
		breq	MOVE_NE_EXIT
		mov		r17,r16
		swap	r16
		or		r16,r17
		out		PORTA,r16
		call	DELAY_STEP_PULSE
		jmp		MOVE_NE_LOOP

MOVE_NE_EXIT:
		pop		r16
		pop		r17
		ret






DELAY_STEP_PULSE:
		push	r16
		push	r17
		ldi		r17, $FF
DELAY_STEP_PULSE_OUTER:	
		ldi		r16, $05
DELAY_STEP_PULSE_INNER:
		dec		r16
		brne	DELAY_STEP_PULSE_INNER
		dec		r17
		brne	DELAY_STEP_PULSE_OUTER
		pop		r17
		pop		r16
		ret



/*
.equ length = 60
DRAW_RECTANGLE:
		call	TOGGLE_PEN
		ldi		r16, length
FIRST:
		rcall	MOVE_EAST	
		dec		r16
		brne	FIRST
		ldi		r16, length
SECOND:
		rcall	MOVE_NORTH	
		dec		r16
		brne	SECOND
		ldi		r16, length
THIRD:
		rcall	MOVE_WEST
		dec		r16
		brne	THIRD

		ldi		r16, length
LAST:
		rcall	MOVE_SOUTH	
		dec		r16
		brne	LAST	
		call TOGGLE_PEN
		ret
		*/