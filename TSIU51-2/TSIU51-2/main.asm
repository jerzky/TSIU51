;
; TSIU51-2.asm
;
; Created: 2019-01-29 10:36:44
; Author : Fredrik
;


; Replace with your application code

;using 1026 -> 490

	


	.equ PULSE_TABLE_WIDTH = 8


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


//	0         0        0  0     0 0       0    0
// PENUP/DOWN                       DIRECTION  


//                    1                2                3                4                5                6                7                8                9                10                11                12                13
ALPHA_A: .db	$80, $00, $0E,	 $84, $00, $02,	  $82, $00, $04,   $86, $00, $02,   $81, $00, $06,   $83, $00, $08,   $02, $00, $08,   $81, $00, $08, $FF

ALPHA_B: .db $80, $00, $10, $82, $00, $06, $86, $00, $02, $81, $00, $04, $87, $00, $02, $83, $00, $06, $02, $00, $06, $86, $00, $02, $81, $00, $04, $87, $00, $02, $83, $00, $06, $02, $00, $08, $FF

;ALPHA_B: .db	$80, $00, $10,   $82, $00, $08,   $81, $00, $04,   $87, $00, $02,   $83, $00, $04,   $82, $00, $04,   $86, $00, $02,   $81, $00, $08,   $83, $00, $08,   $82, $00, $08,   $FF, $00

ALPHA_C: .db	$00, $00, $04,   $80, $00, $08,   $84, $00, $04,   $82, $00, $04,   $01, $00, $10,   $83, $00, $04,   $85, $00, $04,   $02, $00, $08,   $01, $00, $04,   $FF

ALPHA_D: .db  	$80, $00, $10,   $82, $00, $06,   $86, $00, $02,   $81, $00, $0C,   $87, $00, $02,   $83, $00, $06,   $02, $00, $08,   $FF  

ALPHA_E: .db  	$80, $00, $10,   $82, $00, $08,   $01, $00, $06,   $83, $00, $08,   $81, $00, $0A,   $82, $00, $08,   $FF  

ALPHA_F: .db  	$80, $00, $10,   $82, $00, $08,   $01, $00, $06,   $83, $00, $08,   $81, $00, $0A,   $02, $00, $08,   $FF  

ALPHA_G: .db	$00, $00, $04,   $80, $00, $08,   $84, $00, $04,   $82, $00, $04,   $01, $00, $10,   $83, $00, $04,   $85, $00, $04,   $02, $00, $08,   $01, $00, $04,   $80, $00, $08,   $83, $00, $04,   $02, $00, $04,   $01, $00, $08,   $FF

ALPHA_H: .db    $80, $00, $10,   $01, $00, $08,   $82, $00, $08,   $80, $00, $08,   $01, $00, $08,   $81, $00, $08,   $FF

ALPHA_I: .db	$02, $00, $06, $82, $00, $02, $80, $00, $10, $83, $00, $02, $02, $00, $02, $82, $00, $02, $01, $00, $10, $83, $00, $02, $02, $00, $08, $FF

ALPHA_J: .db	$00, $00, $10, $82, $00, $08, $81, $00, $0E, $87, $00, $02, $83, $00, $04, $85, $00, $02, $02, $00, $08, $01, $00, $02, $FF

ALPHA_K: .db	$80, $00, $10, $02, $00, $08, $87, $00, $08, $86, $00, $08, $FF

ALPHA_L: .db	$04, $00, $08, $00, $00, $08, $81, $00, $10, $82, $00, $08, $FF

ALPHA_M: .db	$80, $00, $10, $82, $00, $01, $81, $00, $02, $82, $00, $01, $81, $00, $02, $82, $00, $01, $81, $00, $02, $82, $00, $01, $81, $00, $02, $80, $00, $02, $82, $00, $01, $80, $00, $02, $82, $00, $01, $80, $00, $02, $82, $00, $01, $80, $00, $02, $82, $00, $01, $81, $00, $10, $FF

ALPHA_N: .db	$80, $00, $10, $82, $00, $01, $81, $00, $02, $82, $00, $01, $81, $00, $02, $82, $00, $01, $81, $00, $02, $82, $00, $01, $81, $00, $02, $82, $00, $01, $81, $00, $02, $82, $00, $01, $81, $00, $02, $82, $00, $01, $81, $00, $02, $82, $00, $01, $81, $00, $02, $80, $00, $10, $01, $00, $10, $FF

ALPHA_O: .db	$00, $00, $02, $80, $00, $0C, $84, $00, $02, $82, $00, $04, $86, $00, $02, $81, $00, $0C, $87, $00, $02, $83, $00, $04, $85, $00, $02, $01, $00, $02, $02, $00, $08, $FF

ALPHA_P: .db	$80, $00, $10, $82, $00, $06, $86, $00, $02, $81, $00, $04, $87, $00, $02, $83, $00, $06, $02, $00, $08, $01, $00, $08, $FF

ALPHA_Q: .db	$00, $00, $02,		$80, $00, $0C,		$84, $00, $02,		$82, $00, $04,		$86, $00, $02,		$81, $00, $0C,		$87, $00, $02,		$83, $00, $04,		$85, $00, $02,		$01, $00, $02,		$02, $00, $08, $85, $00, $04, $06, $00, $04, $FF

ALPHA_R: .db	$80, $00, $10,		$82, $00, $06,		$86, $00, $02,		$81, $00, $04,		$87, $00, $02,		$83, $00, $06,		$86, $00, $08,		$FF

ALPHA_S: .db	$00, $00, $03, $86, $00, $03, $82, $00, $02, $84, $00, $03, $80, $00, $02, $85, $00, $03, $83, $00, $02, $85, $00, $03, $80, $00, $02, $84, $00, $03, $82, $00, $02, $86, $00, $03, $01, $00, $10, $FF
// S för lågt
ALPHA_T: .db    $02, $00, $04, $80, $00, $10, $03, $00, $04, $82, $00, $08, $03, $00, $04, $01, $00, $10, $02, $00, $04, $FF

ALPHA_U: .db    $00, $00, $10, $81, $00, $0D, $86, $00, $03, $82, $00, $02, $84, $00, $03, $80, $00, $0D, $01, $00, $10, $FF

ALPHA_V: .db    $00, $00, $10, $81, $00, $04, $82, $00, $01, $81, $00, $04, $82, $00, $01, $81, $00, $04, $82, $00, $01, $81, $00, $04, $80, $00, $04, $82, $00, $01, $80, $00, $04, $82, $00, $01, $80, $00, $04, $82, $00, $01, $80, $00, $04, $01, $00, $10, $FF

ALPHA_X: .db    $80, $00, $04, $84, $00, $08, $80, $00, $04, $03, $00, $08, $81, $00, $04, $86, $00, $08, $81, $00, $04, $FF 

ALPHA_Y: .db    $02, $00, $04, $80, $00, $0A, $85, $00, $04, $80, $00, $02, $02, $00, $08, $81, $00, $02, $87, $00, $04, $01, $00, $0C, $02, $00, $04, $FF

ALPHA_Z: .db    $80, $00, $02, $82, $00, $01, $80, $00, $02, $82, $00, $01, $80, $00, $02, $82, $00, $01, $80, $00, $02, $82, $00, $01, $80, $00, $02, $82, $00, $01, $80, $00, $02, $82, $00, $01, $80, $00, $02, $82, $00, $01, $80, $00, $02, $82, $00, $01, $83, $00, $08, $01, $00, $10, $82, $00, $08, $FF



ALPHA_ALL: .dw  ALPHA_A, ALPHA_B, ALPHA_C, ALPHA_D, ALPHA_E, ALPHA_F, ALPHA_G, ALPHA_H, ALPHA_I, ALPHA_J, ALPHA_K, ALPHA_L, ALPHA_M, ALPHA_N, ALPHA_O, ALPHA_P, ALPHA_Q, ALPHA_R, ALPHA_S, ALPHA_T, ALPHA_U, ALPHA_V, ALPHA_X, ALPHA_Y, ALPHA_Z, $FF

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
			//För att ha lite mellan bokstäverna			
			ldi		r16, $02
			ldi		r25, $00
			ldi		r24, $0A
			rcall	MOVE_FUNC
			//------------
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








LOWER_PEN:
		sbic	PORTC,7
		rjmp	LOWER_PEN_EXIT
		sbi		PORTC, 7
		rcall	LOWER_PEN_DELAY
LOWER_PEN_EXIT:
		ret

RAISE_PEN:
		sbis	PORTC, 7
		rjmp	RAISE_PEN_EXIT
		cbi		PORTC, 7
		rcall	LOWER_PEN_DELAY
RAISE_PEN_EXIT:
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



