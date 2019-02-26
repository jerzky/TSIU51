/*
 * drivers.inc
 *
 *  Created: 2019-02-19 15:48:52
 *   Author: Jensg
 */ 

;---------------------------------------------
;Used for jumtables 
;Starts whereever Z-pointer is
;EX
;			ldi		ZH, HIGH(ALPHA_ALL*2)
;			ldi		ZL, LOW(ALPHA_ALL*2)
;Parameter r16 decides index
;------------------------------------------
JUMP_TABLE:
			push	r17
			lsl		r16	
			add		ZL, r16
			brcc	PC+2
			subi	ZH, -1
			lpm		r16, Z+
			lpm		r17, Z
			lsl		r17
			lsl		r16
			brcc	PC+2
			subi	r17, -1		
			mov		ZH, r17
			mov		ZL, r16
			pop		r17
			ret

;---------------------------------------------
;STARTS DRAWING TO WHEREVER THE Z-POINTER POINTS TO, STOPS ON $FF
;------------------------------------
DRAW_FUNC:	
			push	ZH	
			push	ZL
			push	r16
			push	r18
DRAW_FUNC_LOOP:
			lpm		r16, Z+
			cpi		r16, $FF
			breq	DRAW_FUNC_DONE
			sbrc	r16, 7
			rcall	LOWER_PEN
			sbrs	r16, 7
			rcall	RAISE_PEN
			andi	r16, $7F
			lpm		r18, Z+
			rcall	MOVE_FUNC
			rjmp	DRAW_FUNC_LOOP					
DRAW_FUNC_DONE:
			rcall	RAISE_PEN
			pop		r18
			pop		r16
			pop		ZL
			pop		ZH
			ret	


;------ DRIVER FOR PLOTTER
;------ parameter -  r16 direction, use consts NORTH, SOUTH .. etc
;------ parameter - r18 how far to move (max 65 535)
MOVE_FUNC:
		push	ZH
		push	ZL
		push	r17
		push	r19
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
		dec		r18
		brne	MOVE_FUNC_SEQUENCE
		pop		r19
		pop		r17
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
		push	r24
		push	r25
		ldi		r25, $FF
		ldi		r24, $FF
PEN_DELAY_LOOP:
		sbiw	r25:r24, 1
		brne	PEN_DELAY_LOOP
		pop		r25
		pop		r24
		ret

PULSE_DELAY:
		push	r24
		push	r25
		ldi		r25, $0A
		ldi		r24, $00
PULSE_DELAY_LOOP:
		sbiw	r25:r24, 1
		brne	PULSE_DELAY_LOOP
		pop		r25
		pop		r24
		ret
