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

BOKSTAV: .db "ABCDEFGHIJKLMNOPQRSTUVWXYZ",$13,$15,$17,$0

USED_MESSAGE: .db " ANV",$15,"ND " // lägga till space först
FREE_MESSAGE: .db " VALBAR " //läga till space först
WIN_MESSAGE: .db "GRATTIS",$21
LOSE_MESSAGE: .db "DU SUGER"//"F",$17,"RLORAT" //space $20
DRAW_MESSAGE:	.db " RITAR",$21,$20
START_MESSAGE: .db " START",$21,$20
RAINBOW: .db $01,$03,$02,$06,$04,$05

	.dseg 
USED:
	.byte		29
CURRENT_LETTER:
	.byte		1
START_STATUS:
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


WARM:
	rcall	START_FUNCTION
	rcall	PRINT_LETTER

MAIN_LOOP:
	rcall	ROTARY_CHECK
	rjmp	MAIN_LOOP


START_FUNCTION:
	ldi		ZH,HIGH(START_MESSAGE*2)
	ldi		ZL,LOW(START_MESSAGE*2)
	rcall	PRINT_ENTIRE_DISPLAY
	cbi		PORTD,0
	sbi		PORTD,1
	cbi		PORTD,2

START_STALL:
	rcall	LONG_DELAY
	clr		r17
	lds		r17,START_STATUS
	cpi		r17,$00
	breq	START_STALL
START_DONE:
	ret

USED_CHECK:
	/*
	Kolla i tabell över använda
	om använd gör lampa röd
	om inte gör grön
	om använd
	skriv använd
	annars skriv valbar
	*/
	push	r16
	push	r17
	ldi		YH,HIGH(USED)
	ldi		YL,LOW(USED)
	add		YL,r18
	ld		r16,Y
	cpi		r16,0
	brne	USED_CHECK_TRUE
	sbi		PORTD,0
	cbi		PORTD,1
	sbi		PORTD,2
	ldi		ZH,HIGH(FREE_MESSAGE*2)
	ldi		ZL,LOW(FREE_MESSAGE*2)
	rjmp	USED_CHECK_FALSE
USED_CHECK_TRUE:
	cbi		PORTD,0
	sbi		PORTD,1
	sbi		PORTD,2
	ldi		ZH,HIGH(USED_MESSAGE*2)
	ldi		ZL,LOW(USED_MESSAGE*2)
USED_CHECK_FALSE:
	ldi		r16,$06 //Fixat så att vi clearar tomma rutan till vänster om meddelandet
	add		ZL,r16
	ldi		r18,$07 //samma här
	ldi		r16,$07
USED_CHECK_PRINT_LOOP:
	lpm		r17,Z
	rcall	PRINT_DISPLAY
	dec		ZL
	dec		r16
	dec		r18
	brne	USED_CHECK_PRINT_LOOP
	pop		r17
	pop		r16
	ret

	
PRINT_LETTER:
	push	r16
	push	r17
	push	r18
	ldi		r16,$00
	lds		r18,CURRENT_LETTER
	rcall	LOAD_LETTER								
	rcall	PRINT_DISPLAY
	rcall	USED_CHECK
	pop		r18
	pop		r17
	pop		r16
	ret

PRINT_DISPLAY:
	push	r19
	ldi		r19,PINB
	andi	r19,$F8
	or		r16,r19
	out		PORTB,r16	//a0-a2 - 0 (Längst till vänster)		
	rcall	SHORT_DELAY
	out		PORTA,r17
	rcall	SHORT_DELAY
	cbi		PORTC,7 //ce låg
	rcall	SHORT_DELAY
	sbi		PORTC,7 //ce hög
	rcall	SHORT_DELAY
	pop		r19
	ret

	PRINT_ENTIRE_DISPLAY:
		//Skriver hela displayen
		//Kräver att rätt tabell är laddad i z-register först. Tabellen måste vara 8 tecken lång.
	ldi		r16,$07  //ladda platsen för sista bokstaven i tabellen. 
	add		ZL,r16  //hämta den platsen i tabellen 'T'
	ldi		r18,$08 //antalet loops
PRINT_ENTIRE_DISPLAY_LOOP:
	lpm		r17,Z
	rcall	PRINT_DISPLAY
	dec		ZL
	dec		r16
	dec		r18
	brne	PRINT_ENTIRE_DISPLAY_LOOP
	ret

LOAD_LETTER:
	push	ZH
	push	ZL
	ldi		ZH,HIGH(BOKSTAV*2)
	ldi		ZL,LOW(BOKSTAV*2)
	add		ZL,r18
	lpm		r17,Z
	pop		ZL
	pop		ZH
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
	cli
	push	r16
	push	r17
	push	r18
	push	r24
	push	r25
	push	YH
	push	YL
	push	ZH
	push	ZL

	
	lds		r16,START_STATUS
	cpi		r16,$00
	brne	GAME_IN_PROGRESS
	inc		r16
	sts		START_STATUS,r16
				//HÄR ÄR KOD SOM INITIERAR PLOTTER (Får den att rita spaces o.s.v.)
	rjmp	BUTTON_PRESSED_END

GAME_IN_PROGRESS:
	//Kontrollerar om nuvarande bokstav är använd och hoppar i så fall till slut av funktionen
	lds		r16,CURRENT_LETTER
	ldi		YH,HIGH(USED)
	ldi		YL,LOW(USED)
	add		YL,r16
	ld		r16,Y
	cpi		r16,$00
	brne	BUTTON_PRESSED_END

DRAW:
	ldi		ZH,HIGH(DRAW_MESSAGE*2)
	ldi		ZL,LOW(DRAW_MESSAGE*2)
	ldi		r16,$07 //sista platsen i tabellen
	add		ZL,r16
	ldi		r18,$08
DRAW_LOOP:
	lpm		r17,Z
	rcall	PRINT_DISPLAY
	dec		ZL
	dec		r16
	dec		r18
	brne	DRAW_LOOP
	in		r17,PIND  //sparar D
	andi	r17,$F8
	ori		r17,$04  //Ändrar färgen till gul
	push	r17  //lägger PORTD på stacken
	ldi		r16,$47 //Gul

DRAW_STALL:
	swap	r16
	out		PORTD,r16
	rcall	LONG_DELAY

	//Här måste vi vänta på svar från plottern

	//rjmp	DRAW_STALL

	//val för fortsätt
	//val och rcall WIN
	//val och rcall LOSE
	
NEXT_LETTER:
	pop		r17 //Hämtar portD från stacken
	out		PORTD,r17 // tillbaka på r17
	lds		r18,CURRENT_LETTER
	ldi		YH,HIGH(USED)
	ldi		YL,LOW(USED)
	add		YL,r18
	ldi		r16,$01
	st		Y,r16
	rcall	PRINT_LETTER

BUTTON_PRESSED_END:
	
	pop		ZL
	pop		ZH
	pop		YL
	pop		YH
	pop		r25
	pop		r24
	pop		r18
	pop		r17
	pop		r16
	sei
	reti


INITIATE_SPI_TRANSFER:
		//Förutsätter rätt data i r16
	cbi		PORTB,4			//Slave select låg
	out		SPDR,r16
SPI_WAIT:
	sbis	SPSR,SPIF
	rjmp	SPI_WAIT
	sbi		PORTB,4			//Slave select hög
	ret

SHORT_DELAY:
	push	r16
	ldi		r16,$FF
SHORT_DELAY_LOOP:
	dec		r16
	brne	SHORT_DELAY_LOOP
	pop		r16
	ret	

LONG_DELAY:
	push	r24
	push	r25
	ldi		r24,$FF
	ldi		r25,$0A
LONG_DELAY_LOOP:
	rcall	SHORT_DELAY
	sbiw	r25:r24,1
	brne	LONG_DELAY_LOOP
	pop		r25
	pop		r24
	ret




WIN:
	cli
	ldi		ZH,HIGH(WIN_MESSAGE*2)
	ldi		ZL,LOW(WIN_MESSAGE*2)
	rcall	PRINT_ENTIRE_DISPLAY
	ldi		ZH,HIGH(RAINBOW*2)
	ldi		ZL,LOW(RAINBOW*2)
	clr		r17
WIN_STALL:
	lpm		r16,Z+
	cpi		r16,$05
	brne	WIN_COLOUR_CHECK_DONE
	subi	ZL,$06
WIN_COLOUR_CHECK_DONE:
	out		PORTD,r16
	ldi		r24,$FF
	ldi		r25,$04
WIN_DELAY_LOOP:
	rcall	SHORT_DELAY
	sbiw	r24:r25,1
	brne	WIN_DELAY_LOOP
	rjmp	WIN_STALL
	ret



LOSE:
	cli
	ldi		ZH,HIGH(LOSE_MESSAGE*2)
	ldi		ZL,LOW(LOSE_MESSAGE*2)
	rcall	PRINT_ENTIRE_DISPLAY
	clr		r17
	ldi		r16,$76 // ladda röd färg
	//ldi		r18,$1 //behövs för XOR, vi vill ändra på bit 0
LOSE_STALL:
	//eor		r16,r18		//XOR r16, med ett. Ändrar från röd färg till ingen färg
	swap	r16
	out		PORTD,r16
	rcall	LONG_DELAY
	rjmp	LOSE_STALL
	ret


	
	INIT:
	ldi		r18,$05 //temp satt dioden till grön
	out		PORTD,r18// same same
	sbi		PORTC,0		//a3-1
	sbi		PORTC,1		//a4-1
	sbi		PORTC,7		//Sätt ce hög för skärmen
	sbi		PORTD,5		//Flash hög
	rcall	SHORT_DELAY
	ldi		r16,$FF
	out		DDRA,r16
	ldi		r16,$B7
	out		DDRB,r16
	ldi		r16,$83
	out		DDRC,r16
	ldi		r16,$37
	out		DDRD,r16

			//Sätt alla minnesbitar för använda bokstäver till noll
	ldi		r16,$0
	ldi		YH,HIGH(USED)
	ldi		YL,LOW(USED)
	ldi		r17,$0
CLEAR_LOOP:
	st		Y+,r16
	inc		r17
	cpi		r17,$1F
	brne	CLEAR_LOOP

	//konfigurera SPI
	ldi		r16,(1<<SPE)|(1<<MSTR)|(1<<SPR0)
	out		SPCR,r16


	//konfigurera avbrott
	ldi		r16,(1<<ISC11)|(0<<ISC10)|(1<<INT1)
	out		MCUCR,r16
	//aktivera avbrott
	ldi		r16,(1<<INT1)
	out		GICR,r16
	//aktivera avbrott globalt
	sei
	ret



/*LUCK:
	cli
	ldi		ZH,HIGH(LUCK_MESSAGE*2)
	ldi		ZL,LOW(LUCK_MESSAGE*2)
	ldi		r16,$07  //ladda platsen för sista bokstaven i tabellen. 
	add		ZL,r16  //hämta den platsen i tabellen 'L'
	ldi		r18,$08 //antalet loops
LUCK_LOOP:
	lpm		r17,Z
	rcall	PRINT_DISPLAY
	dec		ZL
	dec		r16
	dec		r18
	brne	LUCK_LOOP
	clr		r17
	*/
