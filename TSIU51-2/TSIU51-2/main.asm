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
	.include "drivers.inc"
	.dseg
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
		/*	call	SETUP_GAME
			
			ldi		r17, $0B //L
			rcall	GUESS_LETTER

			ldi		r17, 1 //B
			rcall	GUESS_LETTER
			*/
			ldi		r17, $14 //U
			rcall	GUESS_LETTER
			
			ldi		r17, $10 //V
			rcall	GUESS_LETTER
			
			ldi		r17, $16 //W
			rcall	GUESS_LETTER
			
			ldi		r17, $02 //c
			rcall	GUESS_LETTER
			
			ldi		r17, $04 //E
			rcall	GUESS_LETTER

			ldi		r17, $13//T
			rcall	GUESS_LETTER

			ldi		r17, 0 //A
			rcall	GUESS_LETTER			
			
END:
			jmp	end


GET_CURRENT_WORD:
			ldi		ZH,	HIGH(CURRENT_WORD*2)
			ldi		ZL, LOW(CURRENT_WORD*2)
			ret





SETUP_GAME:
			push	ZH
			push	ZL
			push	r16
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
			pop		r16
			pop		ZL
			pop		ZH
			ret



//R17 is what letter to guess
GUESS_LETTER:
			push		r18
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
			rcall	DRAW_GRAPHICS
			rcall	WRITE_WRONG_LETTER
GUESS_EXIT:
			pop		r18
			ret




WRITE_WRONG_LETTER:
			push	ZH
			push	ZL
			ldi		ZH, HIGH(WRONG_LETTERS_START_POS*2)
			ldi		ZL, LOW(WRONG_LETTERS_START_POS*2)
			rcall	DRAW_FUNC
			
			lds		r16, WRONG_GUESS_INDEX
			cpi		r16, $00
			breq	WRITE_WRONG_LETTER_LOOP_EXIT
		
			ldi		ZH, HIGH(LETTERS_MOVE_RIGHT*2)
			ldi		ZL, LOW(LETTERS_MOVE_RIGHT*2)
			push	r16
WRITE_WRONG_LETTER_LOOP:		
			rcall	DRAW_FUNC
			dec		r16
			brne	WRITE_WRONG_LETTER_LOOP
			pop		r16
WRITE_WRONG_LETTER_LOOP_EXIT:

			lds		r16, CURRENT_LETTER_INDEX
			rcall	DRAW_LETTER

			ldi		ZH, HIGH(WRONG_LETTERS_MOVE_LITTLE_LEFT*2)
			ldi		ZL, LOW(WRONG_LETTERS_MOVE_LITTLE_LEFT*2)
			rcall	DRAW_FUNC

			lds		r16, WRONG_GUESS_INDEX
			ldi		ZH, HIGH(WRONG_LETTERS_MOVE_LEFT*2)
			ldi		ZL, LOW(WRONG_LETTERS_MOVE_LEFT*2)

			cpi		r16, $00
			breq	WRITE_WRONG_LETTER_BACK_LOOP_EXIT
WRITE_WRONG_LETTER_BACK_LOOP:
			rcall	DRAW_FUNC		
			dec		r16
			brne	WRITE_WRONG_LETTER_BACK_LOOP
WRITE_WRONG_LETTER_BACK_LOOP_EXIT:

			ldi		ZH, HIGH(WRONG_LETTERS_BACK_HOME*2)
			ldi		ZL, LOW(WRONG_LETTERS_BACK_HOME*2)
			rcall	DRAW_FUNC

			lds		r16, WRONG_GUESS_INDEX
			inc		r16
			sts		WRONG_GUESS_INDEX, r16

			pop		ZL
			pop		ZH
			ret












			
DRAW_GRAPHICS:
			push	ZH
			push	ZL
			push	r16

			ldi		ZH, HIGH(GRAPHICS_ALL*2)
			ldi		ZL, LOW(GRAPHICS_ALL*2)
			lds		r16, WRONG_GUESS_INDEX
			rcall	JUMP_TABLE
			
			pop		r16
			pop		ZH
			pop		ZL
			ret

DRAW_LETTER:
			push	ZH
			push	ZL
			push	r16

			ldi		ZH, HIGH(ALPHA_ALL*2)
			ldi		ZL, LOW(ALPHA_ALL*2)
			lds		r16, CURRENT_LETTER_INDEX
			rcall	JUMP_TABLE
			
			pop		r16
			pop		ZH
			pop		ZL	
			ret






