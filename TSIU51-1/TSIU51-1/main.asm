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
	ldi		r18,3		//TEMP


WARM:
	rcall	ROTARY_TEST
	rcall	DISPLAY_TEST
	rjmp	WARM



DISPLAY_TEST:
	/*
	sätt a0-a4 rätt
	sätt ce låg
	vänta
	sätt d0-d7
	vänta
	sätt ce hög
	*/
	sbi		PORTC,0		//a3-1
	sbi		PORTC,1		//a4-1
	clr		r16
	out		PORTB,r16	//a0-a2 - 0 (Längst till vänster)
	rcall	SHORT_DELAY
	cbi		PORTC,7
	rcall	SHORT_DELAY
	ldi		r16,$58
	out		PORTA,r16
	rcall	SHORT_DELAY
	sbi		PORTC,7
	rcall	SHORT_DELAY
	rcall	SHORT_DELAY
	ret



ROTARY_TEST:
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
	out		PORTD,r18
	ret


LEFT:
	ldi		r16,$FF
LEFT_LOOP:
	dec		r16
	brne	LEFT_LOOP
	sbic	PIND,7
	rjmp	LEFT_DONE
	inc		r18
	andi	r18,$07
LEFT_CHECK_1:
	sbic	PIND,6
	rjmp	LEFT_CHECK_1
LEFT_CHECK_2:
	sbis	PIND,7
	rjmp	LEFT_CHECK_2
	sbis	PIND,6
	rjmp	LEFT_CHECK_2
LEFT_DONE:
	ret	

RIGHT:
	ldi		r16,$FF
RIGHT_LOOP:
	dec		r16
	brne	RIGHT_LOOP
	sbic	PIND,6
	rjmp	RIGHT_DONE
	dec		r18
	andi	r18,$07
RIGHT_CHECK_1:
	sbic	PIND,7
	rjmp	RIGHT_CHECK_1
RIGHT_CHECK_2:
	sbis	PIND,6
	rjmp	RIGHT_CHECK_2
	sbis	PIND,7
	rjmp	RIGHT_CHECK_2
RIGHT_DONE:
	ret	




BUTTON_PRESSED:
	ldi		r16,$00
	out		PORTD,r16
	ldi		r16,$FF
OUTER:
	ldi		r17,$FF
INNER:
	dec		r17
	brne	INNER
	dec		r16
	brne	OUTER
	out		PORTD,r16
	reti


SHORT_DELAY:
	push	r16
	ldi		r16,$FF
SHORT_DELAY_LOOP:
	dec		r16
	brne	SHORT_DELAY_LOOP
	pop		r16
	ret	


	INIT:
	sbi		PORTC,7	//Sätt ce hög för skärmen
	sbi		PORTD,5		//Flash hög
	rcall	SHORT_DELAY
	ldi		r16,$FF
	out		DDRA,r16
	ldi		r16,$B7
	out		DDRB,r16
	ldi		r16,$83
	out		DDRC,r18
	ldi		r16,$37
	out		DDRD,r16

	//konfigurera avbrott
	ldi		r16,(1<<ISC11)|(0<<ISC10)|(1<<INT1)
	out		MCUCR,r16
	//aktivera avbrott
	ldi		r16,(1<<INT1)
	out		GICR,r16
	//aktivera avbrott globalt
	sei
	ret