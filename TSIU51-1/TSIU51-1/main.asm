;
; TSIU51-1.asm
;
; Created: 2019-01-29 10:41:18
; Author : Jensg
;

	.org		0
	rjmp		COLD
	.org		INT1addr
	rjmp		BUTTON_PRESSED

BOKSTAV: .db "ABCDEFGHIJKLMNOPQRSTUVWXYZ" .db $13,$15,$17,$0

	.dseg 
USED:
	.byte		29
CURRENT_LETTER:
	.byte		1
	.cseg
COLD:
	ldi		r16,$FF
INITIAL_DELAY:	
	dec		r16
	brne	INITIAL_DELAY
	ldi		r16,HIGH(RAMEND)
	out		SPH,r16
	ldi		r16,LOW(RAMEND)
	out		SPL,r16
	rcall	INIT
	ldi		r18,0
	rcall	PRINT_LETTER
	//ldi		r18,3		//TEMP


WARM:
	rcall	ROTARY_CHECK
	//rcall	PRINT_LETTER
	
	rjmp	WARM



PRINT_LETTER:
	push	r16
	push	r17
	push	r18
	ldi		r16,$00
	lds		r18,CURRENT_LETTER
	rcall	PRINT_DISPLAY
	pop		r18
	pop		r17
	pop		r16
	ret

PRINT_DISPLAY:
	ldi		r17,PINB
	andi	r17,$F8
	or		r16,r17
	out		PORTB,r16	//a0-a2 - 0 (Längst till vänster)		
	rcall	SHORT_DELAY
	cbi		PORTC,7 //ce låg
	rcall	SHORT_DELAY
	rcall	LOAD_LETTER								
	out		PORTA,r17
	rcall	SHORT_DELAY
	sbi		PORTC,7 //ce hög
	rcall	SHORT_DELAY

	ret



ROTARY_CHECK:
			//D6, D7 är knappen
	sbis	PIND,7
	rjmp	LEFT_CHECK_DONE
	sbic	PIND,6
	rjmp	LEFT_CHECK_DONE
	rcall	LEFT
LEFT_CHECK_DONE:
	sbis	PIND,6
	rjmp	RIGHT_CHECK_DONE
	sbic	PIND,7
	rjmp	RIGHT_CHECK_DONE
	rcall	RIGHT
RIGHT_CHECK_DONE:
	ret


LEFT:
	lds		r18,CURRENT_LETTER
	ldi		r16,$FF
LEFT_LOOP:
	dec		r16
	brne	LEFT_LOOP
	sbic	PIND,7
	rjmp	LEFT_DONE

	inc		r18
	cpi		r18,$1D
	brne	LEFT_CHECK_1
	ldi		r18,$00
	

LEFT_CHECK_1:
	sbic	PIND,6
	rjmp	LEFT_CHECK_1
LEFT_CHECK_2:
	
	sbis	PIND,7
	rjmp	LEFT_CHECK_2
	sbis	PIND,6
	rjmp	LEFT_CHECK_2
	sts		CURRENT_LETTER,r18
	rcall	PRINT_LETTER
LEFT_DONE:
	ret	

RIGHT:
	lds		r18,CURRENT_LETTER
	ldi		r16,$FF
RIGHT_LOOP:
	dec		r16
	brne	RIGHT_LOOP
	sbic	PIND,6
	rjmp	RIGHT_DONE
	dec		r18
	cpi		r18,$FF
	brne	RIGHT_CHECK_1
	ldi		r18,$1C
		//andi	r18,$07  Nej!
RIGHT_CHECK_1:
	sbic	PIND,7
	rjmp	RIGHT_CHECK_1
RIGHT_CHECK_2:
	sbis	PIND,6
	rjmp	RIGHT_CHECK_2
	sbis	PIND,7
	rjmp	RIGHT_CHECK_2
	sts		CURRENT_LETTER,r18
	rcall	PRINT_LETTER
RIGHT_DONE:

	ret	




BUTTON_PRESSED:
	push	r16
	push	r17
	cbi		PORTD,0
	cbi		PORTD,1
	cbi		PORTD,2
	ldi		r16,$FF
OUTER:
	ldi		r17,$FF
INNER:
	dec		r17
	brne	INNER
	dec		r16
	brne	OUTER
	sbi		PORTD,0
	cbi		PORTD,1
	sbi		PORTD,2
	pop		r17
	pop		r16
	reti


SHORT_DELAY:
	push	r16
	ldi		r16,$FF
SHORT_DELAY_LOOP:
	dec		r16
	brne	SHORT_DELAY_LOOP
	pop		r16
	ret	

LOAD_LETTER:
	ldi		ZH,HIGH(BOKSTAV*2)
	ldi		ZL,LOW(BOKSTAV*2)
	add		ZL,r18
	lpm		r17,Z
	ret


	INIT:
	ldi		r18,$05 //temp satt dioden till grön
	out		PORTD,r18// same same
	sbi		PORTC,0		//a3-1
	sbi		PORTC,1		//a4-1
	rcall	SHORT_DELAY
	ldi		r16,$FF
	out		DDRA,r16
	ldi		r16,$B7
	out		DDRB,r16
	ldi		r16,$83
	out		DDRC,r16
	ldi		r16,$37
	out		DDRD,r16
	sbi		PORTC,7		//Sätt ce hög för skärmen
	sbi		PORTD,5		//Flash hög
			//Sätt alla minnesbitar för använda bokstäver till noll
	ldi		r16,$0
	ldi		YH,HIGH(USED)
	ldi		YL,LOW(USED)
	ldi		r17,$0
CLEAR_LOOP:
	st		Y+,r16
	inc		r17
	cpi		r17,$1E
	brne	CLEAR_LOOP


	//konfigurera avbrott
	ldi		r16,(1<<ISC11)|(0<<ISC10)|(1<<INT1)
	out		MCUCR,r16
	//aktivera avbrott
	ldi		r16,(1<<INT1)
	out		GICR,r16
	//aktivera avbrott globalt
	sei
	ret