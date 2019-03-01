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
	.include "words.inc"
	.dseg
	WRONG_GUESS_INDEX: .byte 1
	CURRENT_LETTER_INDEX: .byte 1
	CURRENT_WORD_LENGTH: .byte 1
	CURRENT_WORD_INDEX: .byte 1
	WORD_TABLE_INDEX: .byte 1
	RANDOM_SEED: .byte 1
	RIGHT_GUESS_INDEX: .byte 1
	OUTCOME_VALUE: .byte 1
	.cseg
	.equ	MAX_GUESSES = $0B

INIT:
		
			ldi		r16, HIGH(RAMEND)
			out		SPH, r16
			ldi		r16, LOW(RAMEND)
			out		SPL, r16
			ldi		r16, $FF
			out		DDRA, r16
			ldi		r16, $80
			out		DDRC, r16
			ldi		r16, $48
			out		DDRB, r16

			ldi		r16, $00
			sts		WRONG_GUESS_INDEX, r16
			sts		CURRENT_LETTER_INDEX, r16
			sts		CURRENT_WORD_INDEX, r16
			sts		RIGHT_GUESS_INDEX, r16
			sts		OUTCOME_VALUE,r16
			//INIT för SPI.
			; Enable SPI
			ldi		r16,(1<<SPE)|(0<<MSTR)
			out		SPCR,r16
						

START:		
			cbi		PORTB,3	
			rcall	SPI_RECIEVE

			sts		WORD_TABLE_INDEX, r17
			lds		r16,RANDOM_SEED
			sts		CURRENT_WORD_INDEX,r16
			call	SETUP_GAME ; SÄTTER WORD LENGTH MED

			cbi		PORTB,3
			rcall	SPI_RECIEVE 

GAME_LOOP:
			ldi		r17,$00
			cbi		PORTB,3			
			rcall	SPI_RECIEVE		
				
			rcall	GUESS_LETTER
			rcall	OUTCOME
		
			rcall	SPI_RECIEVE
			rjmp	GAME_LOOP	
		


END:
			jmp	end


RANDOM:
			push	r16
			lds		r16,RANDOM_SEED
			inc		r16
			andi	r16, $1F
			sts		RANDOM_SEED,r16
			pop		r16
			ret
OUTCOME:
			push	r16
			push	r17
			ldi		r16, MAX_GUESSES
			lds		r17,WRONG_GUESS_INDEX
			cp		r16,r17
			brne	NOT_WRONG
			rcall	GUESS_LETTER
			ldi		r16,$08
			sts		OUTCOME_VALUE,r16
			rjmp	OUTCOME_EXIT
NOT_WRONG:
			lds		r16,CURRENT_WORD_LENGTH
			lds		r17,RIGHT_GUESS_INDEX
			cp		r16,r17
			brne	OUTCOME_EXIT
			ldi		r16,$04
			sts		OUTCOME_VALUE,r16
OUTCOME_EXIT:
			pop		r17
			pop		r16
			ret
			
SPI_RECIEVE:
			rcall		RANDOM
			sbi			PORTB,3
			lds			r17,OUTCOME_VALUE
			out			SPDR, r17
			; Wait for reception compete
			sbis		SPSR,SPIF
			rjmp		SPI_RECIEVE
			; Read recieve data and return
			in			r17,SPDR
			cbi			PORTB,3			
			ldi			r16, $00
			sts			OUTCOME_VALUE, r16
			ret


GET_CURRENT_WORD:
			push	r16
			ldi		ZH, HIGH(ALL_WORDS*2)
			ldi		ZL, LOW(ALL_WORDS*2)
			lds		r16,WORD_TABLE_INDEX
			rcall	JUMP_TABLE
			lds		r16, CURRENT_WORD_INDEX
			rcall	JUMP_TABLE
			pop		r16
			ret


SETUP_GAME:
			push	ZH
			push	ZL
			push	r16
			push	r18
			clr		r18
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
			inc		r18 ; COUNT WORD LENGTH
			rjmp	SETUP_GAME_LOOP
SETUP_GAME_LOOP_DONE:					
			rcall	GET_CURRENT_WORD ; SET WORD LENGTH
			sts		CURRENT_WORD_LENGTH, r18
			mov		r16, r18
			ldi		ZH, HIGH(LETTER_SUB_BACK*2)
			ldi		ZL, LOW(LETTER_SUB_BACK*2)
			rcall	GO_BACK_FUNCTION		
			ldi		r16, $01
			ldi		ZH, HIGH(LETTERS_SETUP_BACK_HOME*2)
			ldi		ZL, LOW(LETTERS_SETUP_BACK_HOME*2)
			rcall	GO_BACK_FUNCTION
			pop		r18
			pop		r16
			pop		ZL
			pop		ZH
			ret


//R17 is what letter to guess
GUESS_LETTER:
			push	r18
			andi	r17, $1F //för att fixa en bugg
			sts		CURRENT_LETTER_INDEX, r17
			clr		r18
			push	ZH
			push	ZL
			ldi		r16,$02
			sts		OUTCOME_VALUE,r16
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
				
			lds		r20, WRONG_GUESS_INDEX
			cpi		r20, MAX_GUESSES
			brne	CHECK
			sts		CURRENT_LETTER_INDEX, r16
			rjmp	DONT_CHECK
CHECK:		
			cp		r16, r17
			brne	NO_MATCH
DONT_CHECK:
			rcall	DRAW_LETTER
			ldi		r18, $FF
			lds		r16,RIGHT_GUESS_INDEX
			inc		r16
			sts		RIGHT_GUESS_INDEX,r16
			ldi		r16,$01
			sts		OUTCOME_VALUE,r16
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
			
			lds		r16, CURRENT_WORD_LENGTH
			ldi		ZH, HIGH(LETTERS_MOVE_LEFT*2)
			ldi		ZL, LOW(LETTERS_MOVE_LEFT*2)
			rcall	GO_BACK_FUNCTION			
			ldi		r16, 1
			ldi		ZH, HIGH(LETTERS_BACK_HOME*2)
			ldi		ZL, LOW(LETTERS_BACK_HOME*2)
			rcall	DRAW_FUNC
			cpi		r18, $FF
			breq	GUESS_EXIT
			ldi		ZH, HIGH(GRAPHICS_ALL*2)
			ldi		ZL, LOW(GRAPHICS_ALL*2)
			lds		r16, WRONG_GUESS_INDEX
			rcall	JUMP_TABLE
			rcall	DRAW_FUNC
			rcall	WRITE_WRONG_LETTER
GUESS_EXIT:
			pop		ZL
			pop		ZH
			pop		r18
			ret





;r16 för hur många i loopen
GO_BACK_FUNCTION:
			cpi		r16, $00
			breq	GO_BACK_FUNCTION_EXIT
			push	r17
			push	r18
			mov		r17, ZH
			mov		r18, ZL
GO_BACK_FUNCTION_LOOP:
			mov		ZH, r17
			mov		ZL, r18
			rcall	DRAW_FUNC
			dec		r16
			brne	GO_BACK_FUNCTION_LOOP
			pop		r18
			pop		r17
GO_BACK_FUNCTION_EXIT:
			ret







WRITE_WRONG_LETTER:
			push	ZH
			push	ZL
			ldi		ZH, HIGH(WRONG_LETTERS_START_POS*2)
			ldi		ZL, LOW(WRONG_LETTERS_START_POS*2)
			rcall	DRAW_FUNC			
		
			ldi		ZH, HIGH(LETTERS_MOVE_RIGHT*2)
			ldi		ZL, LOW(LETTERS_MOVE_RIGHT*2)
			lds		r16, WRONG_GUESS_INDEX
			rcall	GO_BACK_FUNCTION

			//lds		r16, CURRENT_LETTER_INDEX
			rcall	DRAW_LETTER
			
			ldi		ZH, HIGH(WRONG_LETTERS_MOVE_LITTLE_LEFT*2)
			ldi		ZL, LOW(WRONG_LETTERS_MOVE_LITTLE_LEFT*2)
			rcall	DRAW_FUNC
			
			lds		r16, WRONG_GUESS_INDEX
			ldi		ZH, HIGH(WRONG_LETTERS_MOVE_LEFT*2)
			ldi		ZL, LOW(WRONG_LETTERS_MOVE_LEFT*2)
			rcall	GO_BACK_FUNCTION
			
			ldi		ZH, HIGH(WRONG_LETTERS_BACK_HOME*2)
			ldi		ZL, LOW(WRONG_LETTERS_BACK_HOME*2)
			rcall	DRAW_FUNC

			lds		r16, WRONG_GUESS_INDEX
			inc		r16
			sts		WRONG_GUESS_INDEX, r16

			pop		ZL
			pop		ZH
			ret


DRAW_LETTER:
			push	ZH
			push	ZL
			push	r16

			ldi		ZH, HIGH(ALPHA_ALL*2)
			ldi		ZL, LOW(ALPHA_ALL*2)
			lds		r16, CURRENT_LETTER_INDEX
			rcall	JUMP_TABLE
			rcall	DRAW_FUNC
			pop		r16
			pop		ZH
			pop		ZL	
			ret






