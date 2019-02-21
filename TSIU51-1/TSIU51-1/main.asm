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

//TABELLER-------------------------------------------------------
BOKSTAV:		.db "ABCDEFGHIJKLMNOPQRSTUVWXYZ",$13,$15,$17,$0
USED_MESSAGE:	.db " ANV",$15,"ND " // l�gga till space f�rst
FREE_MESSAGE:	.db " VALBAR " //l�ga till space f�rst
WIN_MESSAGE:	.db "GRATTIS",$21
LOSE_MESSAGE:	.db "DU SUGER"//"F",$17,"RLORAT" //space $20
DRAW_MESSAGE:	.db " RITAR",$21,$20
START_MESSAGE:	.db " START",$21,$20
RAINBOW:		.db $01,$03,$02,$06,$04,$05


//SRAM-----------------------------------------------------------
	.dseg 
USED:
	.byte		29
CURRENT_LETTER:
	.byte		1
START_STATUS:
	.byte		1
BLINK_COLOURS:
	.byte		1
	.cseg

//MAIN-----------------------------------------------------------
COLD:
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


//STARTUP--------------------------------------------------------
START_FUNCTION:
	ldi		ZH,HIGH(START_MESSAGE*2)
	ldi		ZL,LOW(START_MESSAGE*2)
	rcall	PRINT_ENTIRE_DISPLAY
	ldi		r16,$57
	sts		BLINK_COLOURS,r16
START_STALL:
	rcall	BLINK
	lds		r17,START_STATUS
	cpi		r17,$00
	breq	START_STALL
START_DONE:
	ret



//KONTROLL OM ANV�ND BOKSTAV-----------------------------------------------
USED_CHECK:
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
	ldi		r16,$06 //Fixat s� att vi clearar tomma rutan till v�nster om meddelandet
	add		ZL,r16
	ldi		r18,$07 //samma h�r
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

//SKRIV NUVARANDE BOKSTAV SAMT ANV�NDSTATUS--------------------------------
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

//SKRIV ETT TECKEN-------------------------------------------------
PRINT_DISPLAY:
	push	r19
	ldi		r19,PINB
	andi	r19,$F8
	or		r16,r19
	out		PORTB,r16	//a0-a2 - 0 (L�ngst till v�nster)		
	rcall	SHORT_DELAY
	out		PORTA,r17
	rcall	SHORT_DELAY
	cbi		PORTC,7 //ce l�g
	rcall	SHORT_DELAY
	sbi		PORTC,7 //ce h�g
	rcall	SHORT_DELAY
	pop		r19
	ret
//SKRIV ALLA �TTA TECKEN P� DISPLAYEN--------------------------------
PRINT_ENTIRE_DISPLAY:
		//Kr�ver att r�tt tabell �r laddad i z-register f�rst. Tabellen m�ste vara 8 tecken l�ng.
	ldi		r16,$07  //ladda platsen f�r sista bokstaven i tabellen. 
	add		ZL,r16  //h�mta den platsen i tabellen 'T'
	ldi		r18,$08 //antalet loops
PRINT_ENTIRE_DISPLAY_LOOP:
	lpm		r17,Z
	rcall	PRINT_DISPLAY
	dec		ZL
	dec		r16
	dec		r18
	brne	PRINT_ENTIRE_DISPLAY_LOOP
	ret

//LADDA NUVARANDE BOKSTAV FR�N ALFABETSTABELLEN---------------------------------------------------------------
LOAD_LETTER:
		//Kr�ver att r18 �r laddat med CURRENT_LETTER fr�n SRAM
	push	ZH
	push	ZL
	ldi		ZH,HIGH(BOKSTAV*2)
	ldi		ZL,LOW(BOKSTAV*2)
	add		ZL,r18
	lpm		r17,Z
	pop		ZL
	pop		ZH
	ret

//KONTROLLERA OM VIRDNING SKER P� REGLAGET--------------------------------------
ROTARY_CHECK:
			//D6, D7 �r knappen
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

//HANTERA VRIDNING V�NSTER---------------------------------------
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

//HANTERA VRIDNING H�GER-------------------------------------------
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



//INTERRUPT F�R KNAPPTRYCKNING--------------------------------------------
BUTTON_PRESSED:
	push	r16
	push	r17
	push	r18
	push	r24
	push	r25
	push	YH
	push	YL
	push	ZH
	push	ZL
	in		r16,SREG
	push	r16

	//Kontrollera om spelet �r startat eller inte	
	lds		r16,START_STATUS
	cpi		r16,$00
	brne	GAME_IN_PROGRESS
	inc		r16
	sts		START_STATUS,r16
	rcall	DRAW
				//H�R �R KOD SOM INITIERAR PLOTTER (F�r den att rita spaces o.s.v.)
	rjmp	BUTTON_PRESSED_END

	//Om spelet redan �r startat
GAME_IN_PROGRESS:
	//Kontrollerar om nuvarande bokstav �r anv�nd och hoppar i s� fall till slut av funktionen
	lds		r16,CURRENT_LETTER
	ldi		YH,HIGH(USED)
	ldi		YL,LOW(USED)
	add		YL,r16
	ld		r16,Y
	cpi		r16,$00
	brne	BUTTON_PRESSED_END
	rcall	DRAW
	//val f�r forts�tt
	//val och rcall WIN
	//val och rcall LOSE
	
NEXT_LETTER:
	lds		r18,CURRENT_LETTER
	ldi		YH,HIGH(USED)
	ldi		YL,LOW(USED)
	add		YL,r18
	ldi		r16,$01
	st		Y,r16
	rcall	PRINT_LETTER

BUTTON_PRESSED_END:
	ldi		r16,$20
BUTTON_PRESSED_END_LOOP:
	rcall	SHORT_DELAY
	dec		r16
	brne	BUTTON_PRESSED_END_LOOP
	in		r16,GIFR
	andi	r16,$80
	cpi		r16,$80
	brne	GIFR_NOT_SET
	ldi		r16,(1<<INTF1)
	out		GIFR,r16
GIFR_NOT_SET:
	pop		r16
	out		SREG,r16
	pop		ZL
	pop		ZH
	pop		YL
	pop		YH
	pop		r25
	pop		r24
	pop		r18
	pop		r17
	pop		r16
	reti



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
	andi	r17,$F8
	ori		r17,$04  //�ndrar f�rgen till gul
	ldi		r16,$47 //Gul
	sts		BLINK_COLOURS,r16
DRAW_STALL:
	rcall	BLINK
	//V�nta p� plotter
	//rjmp	DRAW_STALL			//Kommentera in n�r vi kan hantera svarsignal fr�n plotter
	ret






//STARTA SPI-�VERF�RING (�nnu ej testad)------------------------------------
INITIATE_SPI_TRANSFER:
		//F�ruts�tter r�tt data i r16
	cbi		PORTB,4			//Slave select l�g
	out		SPDR,r16
SPI_WAIT:
	sbis	SPSR,SPIF
	rjmp	SPI_WAIT
	sbi		PORTB,4			//Slave select h�g
	ret

//KORT DELAY, T.EX. VID SKRIVNING TILL DISPLAY---------------------------------------------------------------
SHORT_DELAY:
	push	r16
	ldi		r16,$FF
SHORT_DELAY_LOOP:
	dec		r16
	brne	SHORT_DELAY_LOOP
	pop		r16
	ret	

//L�NG DELAY, T.EX. F�R KNAPPBLINKNING---------------------------------------------------------------
LONG_DELAY:
	push	r24
	push	r25
	ldi		r24,$FF
	ldi		r25,$0E
LONG_DELAY_LOOP:
	rcall	SHORT_DELAY
	sbiw	r25:r24,1
	brne	LONG_DELAY_LOOP
	pop		r25
	pop		r24
	ret



//SEGERMEDDELANDE----------------------------------
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


//F�RLUSTMEDDELANDE--------------------------------------
LOSE:
	cli
	ldi		ZH,HIGH(LOSE_MESSAGE*2)
	ldi		ZL,LOW(LOSE_MESSAGE*2)
	rcall	PRINT_ENTIRE_DISPLAY
	clr		r17
	ldi		r16,$76 // ladda r�d f�rg
	sts		BLINK_COLOURS,r16
LOSE_STALL:
	rcall	BLINK	
	rjmp	LOSE_STALL
	ret

//BLINKA LAMPAN P� VRIDREGLAGET--------------------------------------
BLINK:
	//Kr�ver att r�tt f�rger �r laddade p� de fyra h�gsta respektive l�gsta bitarna i BLINK_COLOURS i SRAM
	push	r16
	push	r17
	in		r17,PIND
	lds		r16,BLINK_COLOURS
	swap	r16
	sts		BLINK_COLOURS,r16
	andi	r17,$F8
	andi	r16,$07
	or		r16,r17
	out		PORTD,r16
	rcall	LONG_DELAY
	pop		r17
	pop		r16
	ret

//H�RDVARUINITIERING SAMT CLEAR AV SRAM-------------------------------------------------
	INIT:
	ldi		r18,$05 //temp satt dioden till gr�n
	out		PORTD,r18// same same
	sbi		PORTC,0		//a3-1
	sbi		PORTC,1		//a4-1
	sbi		PORTC,7		//S�tt ce h�g f�r sk�rmen
	sbi		PORTD,5		//Flash h�g
	rcall	SHORT_DELAY
	ldi		r16,$FF
	out		DDRA,r16
	ldi		r16,$B7
	out		DDRB,r16
	ldi		r16,$83
	out		DDRC,r16
	ldi		r16,$37
	out		DDRD,r16
			//S�tt alla minnesbitar f�r anv�nda bokst�ver till noll
	ldi		r16,$0
	ldi		YH,HIGH(USED)
	ldi		YL,LOW(USED)
	ldi		r17,$0
CLEAR_LOOP:
	st		Y+,r16
	inc		r17
	cpi		r17,$20
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

