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
	CURRENT_WORD_LENGTH: .byte 1
	CURRENT_WORD_INDEX: .byte 1
	.cseg

	CURRENT_WORD: .db $0D, $00, $13, $08, $0E, $0D, $00, $0B, $04, $0D, $02, $18, $0A, $0E, $0F, $04, $03, $08, $0D,  $FF

INIT:
		
			ldi		r16, HIGH(RAMEND)
			out		SPH, r16
			ldi		r16, LOW(RAMEND)
			out		SPL, r16
			ldi		r16, $FF
			out		DDRA, r16
			ldi		r16, $80
			out		DDRC, r16
			ldi		r16, $44
			out		DDRB, r16

			ldi		r16, $00
			sts		WRONG_GUESS_INDEX, r16
			sts		CURRENT_LETTER_INDEX, r16
			sts		CURRENT_WORD_INDEX, r16

			//INIT för SPI.
			; Enable SPI
			ldi		r16,(1<<SPE)|(0<<MSTR)
			out		SPCR,r16
						

START:		
//			cbi		PORTB,3
//			ldi		r17,$00
//			out		SPDR,r17
//			sbis	SPSR,SPIF
//			rjmp	START
//			in		r17,SPDR

			call	SETUP_GAME ; SÄTTER WORD LENGTH MED


GAME_LOOP:
			cbi		PORTB,3
			ldi		r17,$00
			rcall	SPI_RECIEVE			
			rcall	GUESS_LETTER
			ldi		r17, $01
			sbi		PORTB, 3
			rcall	SPI_RECIEVE
			rjmp	GAME_LOOP	
		


END:
			jmp	end

SPI_RECIEVE:
			out			SPDR,r17
			; Wait for reception compete
			sbis		SPSR,SPIF
			rjmp		SPI_RECIEVE
			; Read recieve data and return
			in			r17,SPDR
			ret


GET_CURRENT_WORD:
			push	r16
			ldi		ZH, HIGH(WORDS*2)
			ldi		ZL, LOW(WORDS*2)
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

			lds		r16, CURRENT_LETTER_INDEX
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






