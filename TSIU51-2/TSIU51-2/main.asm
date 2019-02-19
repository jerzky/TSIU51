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

	.dseg
	WRONG_GUESS_FLAG: .byte	1
	WRONG_GUESS_INDEX: .byte 1
	CURRENT_LETTER_INDEX: .byte 1
	.cseg

	CURRENT_WORD: .db $13, $13, $00, $01, $0B, $04, $FF

INIT:
		
			ldi		r16, HIGH(RAMEND)
			out		SPH, r16
			ldi		r16, LOW(RAMEND)
			out		SPL, r16
			ldi		r16, $FF
			out		DDRA, r16
			ldi		r16, $80
			out		DDRC, r16

			ldi		r16, $00
			sts		WRONG_GUESS_INDEX, r16
			sts		CURRENT_LETTER_INDEX, r16
						

START:		
			call	SETUP_GAME
			
			ldi		r17, $0B //L
			rcall	GUESS_LETTER

			ldi		r17, 1 //B
			rcall	GUESS_LETTER
			
			ldi		r17, $14 //U
			rcall	GUESS_LETTER
			
			ldi		r17, $15 //V
			rcall	GUESS_LETTER
			
			ldi		r17, $04 //E
			rcall	GUESS_LETTER

			ldi		r17, $13//T
			rcall	GUESS_LETTER

			ldi		r17, 0 //A
			rcall	GUESS_LETTER
			

END:
			jmp	end



WRONG_GUESS:


			push	ZH
			push	ZL
			push	r16
			push	r17
			ldi		ZH, HIGH(GRAPHICS_ALL*2)
			ldi		ZL, LOW(GRAPHICS_ALL*2)
			lds		r16, WRONG_GUESS_INDEX
	

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
			rcall	DRAW_FUNC
			pop		r17
			pop		r16
			pop		ZL
			pop		ZH
WRONG_GUESS_EXIT:
			
			
			ret


WRITE_WRONG_LETTER:
			push	ZH
			push	ZL
			ldi		ZH, HIGH(WRONG_LETTERS_START_POS*2)
			ldi		ZL, LOW(WRONG_LETTERS_START_POS*2)
			rcall	DRAW_FUNC
			lds		r16, WRONG_GUESS_INDEX
			ldi		ZH, HIGH(LETTERS_MOVE_RIGHT*2)
			ldi		ZL, LOW(LETTERS_MOVE_RIGHT*2)
			push	r16
WRITE_WRONG_LETTER_LOOP:
			cpi		r16, $00
			breq	WRITE_WRONG_LETTER_LOOP_EXIT		
			rcall	DRAW_FUNC
			dec		r16
			rjmp	WRITE_WRONG_LETTER_LOOP
WRITE_WRONG_LETTER_LOOP_EXIT:
			pop		r16

			lds		r16, WRONG_GUESS_INDEX
			inc		r16
			sts		WRONG_GUESS_INDEX, r16

			lds		r16, CURRENT_LETTER_INDEX
			rcall	DRAW_LETTER

			lds		r16, WRONG_GUESS_INDEX
			ldi		ZH, HIGH(LETTER_SUB_BACK*2)
			ldi		ZL, LOW(LETTER_SUB_BACK*2)
WRITE_WRONG_LETTER_BACK_LOOP:
			rcall	DRAW_FUNC		
			dec		r16
			brne	WRITE_WRONG_LETTER_BACK_LOOP

			ldi		ZH, HIGH(WRONG_LETTERS_BACK_HOME*2)
			ldi		ZL, LOW(WRONG_LETTERS_BACK_HOME*2)
			rcall	DRAW_FUNC
			pop		ZL
			pop		ZH
			ret


SETUP_GAME:
			push	ZH
			push	ZL
			ldi		ZH, HIGH(LETTERS_SETUP_START_POS*2)
			ldi		ZL, LOW(LETTERS_SETUP_START_POS*2)
			rcall	DRAW_FUNC
			rcall	GET_CURRENT_WORD
SETUP_GAME_LOOP:
			lpm		r16, Z+
			cpi		r16, $FF
			breq	SETUP_GAME_LOOP_DONE
			push	ZH
			push	ZL
			ldi		ZH, HIGH(LETTER_SUB*2)
			ldi		ZL, LOW(LETTER_SUB*2)
			rcall	DRAW_FUNC
			pop		ZL
			pop		ZH
			rjmp	SETUP_GAME_LOOP
SETUP_GAME_LOOP_DONE:		
			rcall	GET_CURRENT_WORD
SETUP_BACK_LOOP:
			lpm		r16, Z+
			cpi		r16, $FF
			breq	SETUP_BACK_DONE
			push	ZH
			push	ZL
			ldi		ZH, HIGH(LETTER_SUB_BACK*2)
			ldi		ZL, LOW(LETTER_SUB_BACK*2)
			rcall	DRAW_FUNC
			pop		ZL
			pop		ZH
			rjmp	SETUP_BACK_LOOP
SETUP_BACK_DONE:

			ldi		ZH, HIGH(LETTERS_SETUP_BACK_HOME*2)
			ldi		ZL, LOW(LETTERS_SETUP_BACK_HOME*2)
			rcall	DRAW_FUNC
			pop		ZL
			pop		ZH
			ret



//R17 is what letter to guess
//r18 is 0 if no letter matched
GUESS_LETTER:
			sts		CURRENT_LETTER_INDEX, r17
			clr		r18
			push	ZH
			push	ZL
			ldi		ZH, HIGH(LETTERS_START_POS*2)
			ldi		ZL, LOW(LETTERS_START_POS*2)
			rcall	DRAW_FUNC
			rcall	GET_CURRENT_WORD
GUESS_LETTER_LOOP:
			lpm		r16, Z+
			cpi		r16, $FF
			breq	GUESS_LETTER_LOOP_DONE
			push	ZH
			push	ZL
			cp		r16, r17
			brne	NO_MATCH
			rcall	DRAW_LETTER
			ldi		r18, $FF
			ldi		ZH, HIGH(LETTERS_MOVE_RIGHT_LITTLE*2)
			ldi		ZL, LOW(LETTERS_MOVE_RIGHT_LITTLE*2)
			rjmp	GUESS_CONTINUE_LOOP
NO_MATCH:
			ldi		ZH, HIGH(LETTERS_MOVE_RIGHT*2)
			ldi		ZL, LOW(LETTERS_MOVE_RIGHT*2)			
GUESS_CONTINUE_LOOP:
			rcall	DRAW_FUNC
			pop		ZL
			pop		ZH
			rjmp	GUESS_LETTER_LOOP

GUESS_LETTER_LOOP_DONE:
			rcall	GET_CURRENT_WORD
GUESS_LETTER_GO_BACK:			
			lpm		r16, Z+
			cpi		r16, $FF
			breq	GUESS_LETTER_GO_BACK_DONE
			push	ZH
			push	ZL
			ldi		ZH, HIGH(LETTERS_MOVE_LEFT*2)
			ldi		ZL, LOW(LETTERS_MOVE_LEFT*2)
			rcall	DRAW_FUNC
			pop		ZL
			pop		ZH
			rjmp	GUESS_LETTER_GO_BACK
GUESS_LETTER_GO_BACK_DONE:
			ldi		ZH, HIGH(LETTERS_BACK_HOME*2)
			ldi		ZL, LOW(LETTERS_BACK_HOME*2)
			rcall	DRAW_FUNC
			pop		ZL
			pop		ZH
			cpi		r18, $FF
			breq	GUESS_EXIT
			rcall	WRONG_GUESS
			rcall	WRITE_WRONG_LETTER
GUESS_EXIT:
			ret






GOTO_LETTER_STARTT:

			ldi		r16, 2
			rcall	DRAW_LETTER
			ldi		r16, 3
			ldi		r25, $00
			ldi		r24, $08
			rcall	MOVE_FUNC
			ldi		ZH, HIGH(LETTERS_BACK_HOME*2)
			ldi		ZL, LOW(LETTERS_BACK_HOME*2)
			rcall	DRAW_FUNC
			ret

GET_CURRENT_WORD:
			ldi		ZH,	HIGH(CURRENT_WORD*2)
			ldi		ZL, LOW(CURRENT_WORD*2)
			ret




//---------------------------------------------
//INPUT r16 decides wich letter (0 for A, 1 for B....)
//------------------------------------------
DRAW_LETTER:
			push	ZH
			push	ZL
			push	r16
			push	r17
			ldi		ZH, HIGH(ALPHA_ALL*2)
			ldi		ZL, LOW(ALPHA_ALL*2)
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
			rcall	DRAW_FUNC
			pop		r17
			pop		r16
			pop		ZL
			pop		ZH
			ret

//---------------------------------------------
//STARTS DRAWING TO WHEREVER THE Z-POINTER POINTS TO
//------------------------------------
DRAW_FUNC:	
			push	ZH	
			push	ZL
			push	r16
DRAW_FUNC_LOOP:
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
			rjmp	DRAW_FUNC_LOOP					
DRAW_FUNC_DONE:
			rcall	RAISE_PEN
			pop		r16
			pop		ZL
			pop		ZH
			ret	


;------ DRIVER FOR PLOTTER
;------ r16 direction, use consts NORTH, SOUTH .. etc
;------ r24-r25 how far to move (max 65 535)
MOVE_FUNC:
		push	ZH
		push	ZL
		push	r17
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



