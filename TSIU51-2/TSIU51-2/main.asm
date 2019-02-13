;
; TSIU51-2.asm
;
; Created: 2019-01-29 10:36:44
; Author : Fredrik
;


; Replace with your application code

;using 1026

	


	.equ PULSE_TABLE_WIDTH = 8
	
	.macro		MOVE
		ldi		r16, @0
		ldi		r24, LOW(@1)
		ldi		r25, HIGH(@1)
		rcall	MOVE_FUNC
	.endmacro


	.org 0000
	jmp INIT


FIRST_PULSE:	.db $10, $50, $01, $05, $11, $15, $51, $55
SECOND_PULSE:	.db $90, $40, $09, $04, $99, $94, $49, $44    
THIRD_PULSE:	.db $80, $60, $08, $06, $88, $86, $68, $66
FOURTH_PULSE:	.db $A0, $20, $0A, $02, $AA, $A2, $2A, $22
FIFTH_PULSE:	.db $20, $A0, $02, $0A, $22, $2A, $A2, $AA
SIXTH_PULSE:	.db $60, $80, $06, $08, $66, $68, $86, $88
SEVENTH_PULSE:	.db $40, $90, $04, $09, $44, $49, $94, $99
EIGHT_PULSE:	.db $50, $10, $05, $01, $55, $51, $15, $11


	.equ NORTH = 0 
	.equ SOUTH = 1 
	.equ EAST = 2 
	.equ WEST =  3
	.equ NORTH_EAST = 4
	.equ NORTH_WEST = 5
	.equ SOUTH_EAST = 6
	.equ SOUTH_WEST = 7

	.equ FONT_HEIGHT = 16 ; MUST BE DIVISIBLE BY 8
	.equ FONT_WIDTH = 8 ; MUST BE DIVISIBLE BY 8

//	0         0        0  0     0 0       0    0
// PENUP/DOWN                       DIRECTION  


//                    1                2                3                4                5                6                7                8                9                10                11                12                13
ALPHA_A: .db	$80, $00, $0E,   $84, $00, $02,   $28, $00, $04,   $86, $00, $02,   $81, $00, $04,   $83, $00, $08,   $82, $00, $08,   $01, $00, $0A,   $FF, $00

ALPHA_B: .db	$80, $00, $10,   $82, $00, $08,   $81, $00, $04,   $87, $00, $02,   $83, $00, $04,   $82, $00, $04,   $86, $00, $02,   $81, $00, $08,   $83, $00, $08,   $82, $00, $08,   $FF, $00

ALPHA_C: .db	$00, $00, $04,   $80, $00, $08,   $84, $00, $04,   $82, $00, $04,   $01, $00, $10,   $83, $00, $04,   $85, $00, $04,   $02, $00, $08,   $01, $00, $04,   $FF

ALPHA_D: .db  	$80, $00, $10,   $82, $00, $06,   $86, $00, $02,   $81, $00, $0C,   $87, $00, $02,   $83, $00, $06,   $02, $00, $08,   $FF  

ALPHA_E: .db  	$80, $00, $10,   $82, $00, $08,   $01, $00, $06,   $83, $00, $08,   $81, $00, $0A,   $82, $00, $08,   $FF  

ALPHA_F: .db  	$80, $00, $10,   $82, $00, $08,   $01, $00, $06,   $83, $00, $08,   $81, $00, $0A,   $02, $00, $08,   $FF  

ALPHA_G: .db	$00, $00, $04,   $80, $00, $08,   $84, $00, $04,   $82, $00, $04,   $01, $00, $10,   $83, $00, $04,   $85, $00, $04,   $02, $00, $08,   $01, $00, $04,   $80, $00, $08,   $83, $00, $04,   $02, $00, $04,   $01, $00, $08,   $FF




TEST_DRAW:
			ldi		ZH, HIGH(ALPHA_G*2)
			ldi		ZL, LOW(ALPHA_G*2)
	
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
		ldi		r17, PULSE_TABLE_WIDTH
		ldi		ZH, HIGH(FIRST_PULSE*2)
		ldi		ZL, LOW(FIRST_PULSE*2)
		add		ZL, r16
MOVE_FUNC_LOOP:		
		lpm		r16, Z
		out		PORTA, r16
		call	PULSE_DELAY
		subi	ZL, -PULSE_TABLE_WIDTH
		dec		r17
		brne	MOVE_FUNC_LOOP
		sbiw	r25:r24,1
		brne	MOVE_FUNC_SEQUENCE
		pop		ZL
		pop		ZH
		ret



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
		rcall	TEST_DRAW
END:
		jmp	end

	DRAW_H:
		rcall	LOWER_PEN
		MOVE	NORTH, FONT_HEIGHT
		MOVE	SOUTH, FONT_HEIGHT / 2
		MOVE	EAST, FONT_WIDTH
		MOVE	NORTH, FONT_HEIGHT / 2
		MOVE	SOUTH,	FONT_HEIGHT
		rcall	RAISE_PEN
		ret
	DRAW_I:
		MOVE	EAST, FONT_WIDTH / 4
		rcall	LOWER_PEN
		MOVE	EAST, FONT_WIDTH / 4
		MOVE	NORTH, FONT_HEIGHT
		MOVE	WEST, FONT_WIDTH / 4
		rcall	RAISE_PEN
		MOVE	EAST, FONT_WIDTH / 2
		rcall	LOWER_PEN
		MOVE	WEST, FONT_WIDTH / 4
		rcall	RAISE_PEN
		MOVE	SOUTH, FONT_HEIGHT
		rcall	LOWER_PEN
		MOVE	EAST, FONT_WIDTH / 4
		rcall	RAISE_PEN
		MOVE	EAST, FONT_WIDTH / 4
		ret
	DRAW_J:
		MOVE	NORTH, FONT_HEIGHT
		MOVE	EAST, FONT_WIDTH / 4
		rcall	LOWER_PEN
		MOVE	EAST, FONT_WIDTH-(FONT_WIDTH / 4)
		MOVE	SOUTH, FONT_HEIGHT-(FONT_HEIGHT / 8)
		MOVE	SOUTH_WEST, FONT_WIDTH / 4
		MOVE	WEST, FONT_WIDTH - (FONT_HEIGHT / 4)
		MOVE	NORTH_WEST,	FONT_WIDTH / 4
		rcall	RAISE_PEN
		MOVE	NORTH_EAST, FONT_WIDTH / 4
		MOVE	EAST, FONT_WIDTH - (FONT_HEIGHT / 4)
		MOVE	SOUTH_EAST,	FONT_WIDTH / 4
		MOVE	SOUTH, FONT_HEIGHT / 8
		ret
	DRAW_K:
		MOVE	NORTH, FONT_HEIGHT
		rcall	LOWER_PEN
		MOVE	SOUTH, FONT_HEIGHT/2
		MOVE	EAST, FONT_WIDTH/4
		MOVE	NORTH_EAST, (FONT_WIDTH/2)+(FONT_WIDTH/4)
		MOVE	NORTH, FONT_WIDTH/4
		rcall	RAISE_PEN
		MOVE	SOUTH, FONT_WIDTH/4
		MOVE	SOUTH_WEST,	(FONT_WIDTH/2)+(FONT_WIDTH/4)
		rcall	LOWER_PEN
		MOVE	SOUTH_EAST, (FONT_WIDTH/2)+(FONT_WIDTH/4)
		MOVE	SOUTH, FONT_WIDTH/4
		rcall	RAISE_PEN
		MOVE	NORTH, FONT_WIDTH/4
		MOVE	NORTH_WEST, (FONT_WIDTH/2)+(FONT_WIDTH/4)
		MOVE	WEST, FONT_WIDTH/4
		rcall	LOWER_PEN
		MOVE	SOUTH, FONT_HEIGHT/2
		rcall	RAISE_PEN
		MOVE	EAST, FONT_WIDTH
		ret


LOWER_PEN:
		
		sbi		PORTC, 7
		rcall	LOWER_PEN_DELAY
		ret
RAISE_PEN:
		cbi		PORTC, 7
		rcall	LOWER_PEN_DELAY
		ret

LOWER_PEN_DELAY:
		push	r16
		push	r17
		ldi		r17, $FF
LOWER_PEN_OUTER:
		ldi		r16, $FF
LOWER_PEN_INNER:
		dec		r16
		brne	LOWER_PEN_INNER
		dec		r17
		brne	LOWER_PEN_OUTER
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



