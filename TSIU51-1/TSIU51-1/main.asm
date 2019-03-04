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
BOKSTAV:		.db "ABCDEFGHIJKLMNOPQRSTUVWXYZ",$13,$15,$17,$0	//$13 = �, $15 = �, $17 = �
USED_MESSAGE:	.db " ANV",$15,"ND " 
FREE_MESSAGE:	.db " VALBAR "
WIN_MESSAGE:	.db "GRATTIS!"
LOSE_MESSAGE:	.db "DU SUGER"//"F",$17,"RLORAT" //space $20
CORRECT_MESSAGE:.db	"  R",$15,"TT  "
WRONG_MESSAGE:	.db	"  FEL!  "
DRAW_MESSAGE:	.db " RITAR! "
START_MESSAGE:	.db " START! "
EASY_MESSAGE:	.db "  L",$15,"TT  "
NORMAL_MESSAGE: .db " NORMAL "
HARD_MESSAGE:	.db "  SV",$13,"R  "
LEVEL_MESSAGE:	.db	"NIV",$13,"VAL?  "
RAINBOW:		.db $01,$03,$02,$06,$04,$05

//SRAM-----------------------------------------------------------
	.dseg 
USED:
	.byte		29		//Lista �ver anv�nda bokst�ver, 0 = inte anv�nd, 1 = anv�nd
CURRENT_LETTER:		
	.byte		1		//Nuvarande bokstav att visa p� display samt v�lja
BLINK_COLOURS:
	.byte		1		//Ska laddas med de tv� blinkande f�rgerna p� l�g respektive h�g nibble
BUTTON_STATUS:
	.byte		1		//S�tts till 1 vid knapptryckning, ska s�ttas till 0 vid hantering.
ROTARY_STATUS:
	.byte		1		//S�tts till 1 vid v�nster, 2 vid h�ger. Rensa till 0.
PLOTTER_RESPONSE:
	.byte		1		//Inneh�ller responskod fr�n plottern, bit 0 = r�tt, bit 1 = fel, bit 2 = vinst, bit 3 = f�rlust
DIFFICULTY_CHOICE:
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
	rcall	CLEAR_SRAM

START:
	rcall	START_FUNCTION
	rcall	START_MENU
	lds		r16,DIFFICULTY_CHOICE
	rcall	DRAW
	rcall	PRINT_LETTER
	rcall	CLEAR_INTERRUPT

MAIN_LOOP:
	rcall	ROTARY_CHECK
	rcall	LETTER_CHANGE_CHECK
	lds		r16,BUTTON_STATUS
	cpi		r16,$00
	breq	MAIN_DONE
	rcall	LETTER_CHOSEN
MAIN_DONE:
	rjmp	MAIN_LOOP

//STARTUP--------------------------------------------
START_FUNCTION:
	ldi		ZH,HIGH(START_MESSAGE*2)
	ldi		ZL,LOW(START_MESSAGE*2)
	rcall	PRINT_ENTIRE_DISPLAY
	ldi		r16,$57
	sts		BLINK_COLOURS,r16
START_STALL:
	rcall	BLINK
	lds		r17,BUTTON_STATUS
	cpi		r17,$00
	breq	START_STALL
START_DONE:
	ldi		r16,$80
	rcall	CLEAR_INTERRUPT
	ret

//VAL AV SV�RIGHETSGRAD------------------------------
START_MENU:
	sbi		PORTD,0
	cbi		PORTD,1
	cbi		PORTD,2
	ldi		ZH,HIGH(LEVEL_MESSAGE*2)
	ldi		ZL,LOW(LEVEL_MESSAGE*2)
	rcall	PRINT_ENTIRE_DISPLAY
	ldi		r24,$FF
	ldi		r25,$50
	rcall	LONG_DELAY
	rcall	CLEAR_INTERRUPT
	ldi		ZH,HIGH(NORMAL_MESSAGE*2)
	ldi		ZL,LOW(NORMAL_MESSAGE*2)
	rcall	PRINT_ENTIRE_DISPLAY
	ldi		r16,$01
	sts		DIFFICULTY_CHOICE,r16
START_MENU_LOOP:
	rcall	ROTARY_CHECK
	lds		r16,ROTARY_STATUS
	cpi		r16,$00
	breq	NO_LEVEL_CHANGE
	rcall	LEVEL_INPUT
NO_LEVEL_CHANGE:
	lds		r16,BUTTON_STATUS
	sbrs	r16,0
	rjmp	START_MENU_LOOP
START_MENU_END:
	rcall	CLEAR_INTERRUPT
	ret

//HANTERA DISPLAYEN OCH SPARAD SV�RIGHETSGRAD VID NIV�VAL------------
LEVEL_INPUT:
	lds		r17,DIFFICULTY_CHOICE
	cpi		r16,$01
	brne	LEVEL_NOT_LEFT
	sbrs	r17,1
	inc		r17
LEVEL_NOT_LEFT:
	cpi		r16,$02
	brne	LEVEL_NOT_RIGHT
	dec		r17
	sbrc	r17,7
	ldi		r17,$00
LEVEL_NOT_RIGHT:
	sts		DIFFICULTY_CHOICE,r17
	ldi		ZH,HIGH(EASY_MESSAGE*2)
	ldi		ZL,LOW(EASY_MESSAGE*2)
LEVEL_INC_LOOP:
	cpi		r17,$00
	breq	LEVEL_INPUT_DONE
	adiw	Z,$08
	dec		r17
	rjmp	LEVEL_INC_LOOP
LEVEL_INPUT_DONE:
	rcall	PRINT_ENTIRE_DISPLAY
	ldi		r16,$00
	sts		ROTARY_STATUS,r16
	ret

//KONTROLL OM ANV�ND BOKSTAV-----------------------------------------------
USED_CHECK:
	//Kr�ver att CURRENT_LETTER ligger p� r18
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
	ldi		r16,$00
	lds		r18,CURRENT_LETTER
	rcall	LOAD_LETTER								
	rcall	PRINT_DISPLAY
	rcall	USED_CHECK
	ret

//SKRIV ETT TECKEN-------------------------------------------------
PRINT_DISPLAY:
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
	rcall	SHORT_DELAY
	sbic	PIND,7
	rjmp	LEFT_DONE
LEFT_CHECK_1:
	sbic	PIND,6
	rjmp	LEFT_CHECK_1
LEFT_CHECK_2:
	sbis	PIND,7
	rjmp	LEFT_CHECK_2
	sbis	PIND,6
	rjmp	LEFT_CHECK_2
	ldi		r16,$01
	sts		ROTARY_STATUS,r16
LEFT_DONE:
	ret	

//HANTERA VRIDNING H�GER-------------------------------------------
RIGHT:
	rcall	SHORT_DELAY
	sbic	PIND,6
	rjmp	RIGHT_DONE
RIGHT_CHECK_1:
	sbic	PIND,7
	rjmp	RIGHT_CHECK_1
RIGHT_CHECK_2:
	sbis	PIND,6
	rjmp	RIGHT_CHECK_2
	sbis	PIND,7
	rjmp	RIGHT_CHECK_2
	ldi		r16,$02
	sts		ROTARY_STATUS,r16
RIGHT_DONE:
	ret	
		
//�KA ELLER S�NK NUVARANDE BOKSTAV-------------------------
LETTER_CHANGE_CHECK:
	lds		r16,ROTARY_STATUS
	sbrc	r16,0
	rcall	INC_LETTER
	sbrc	r16,1
	rcall	DEC_LETTER
	ldi		r16,$00
	sts		ROTARY_STATUS,r16
	ret

//MINSKA NUVARANDE BOKSTAV-------------------------------------
DEC_LETTER:
	lds		r18,CURRENT_LETTER
	dec		r18
	cpi		r18,$FF
	brne	NOT_MIN
	ldi		r18,$1C
NOT_MIN:
	sts		CURRENT_LETTER,r18
	rcall	PRINT_LETTER
	ret

//�KA NUVARANDE BOKSTAV-----------------------------------------
INC_LETTER:
	lds		r18,CURRENT_LETTER
	inc		r18
	cpi		r18,$1D
	brne	NOT_MAX
	ldi		r18,$00
NOT_MAX:
	sts		CURRENT_LETTER,r18
	rcall	PRINT_LETTER
	ret



//INTERRUPT F�R KNAPPTRYCKNING-----------------------------------
BUTTON_PRESSED:
	push	r16
	in		r16,SREG
	push	r16
	ldi		r16,$01
	sts		BUTTON_STATUS,r16
	pop		r16
	out		SREG,r16
	pop		r16
	reti



//KONTROLLERAR VALD BOKSTAV OCH SKRIVER UT DEN OM TILLG�NGLIG-----
LETTER_CHOSEN:
	//Kontrollerar om nuvarande bokstav �r anv�nd och hoppar i s� fall till slut av funktionen
	lds		r16,CURRENT_LETTER
	ldi		YH,HIGH(USED)
	ldi		YL,LOW(USED)
	add		YL,r16
	ld		r16,Y
	cpi		r16,$00
	brne	LETTER_CHOSEN_END
	lds		r16,CURRENT_LETTER
	rcall	DRAW

SET_LETTER_USED:
	lds		r18,CURRENT_LETTER
	ldi		YH,HIGH(USED)
	ldi		YL,LOW(USED)
	add		YL,r18
	ldi		r16,$01
	st		Y,r16
	rcall	PRINT_LETTER
LETTER_CHOSEN_END:
	rcall	CLEAR_INTERRUPT
	ret

//RENSAR INTERRUPTFLAGGAN-----------------------------------
CLEAR_INTERRUPT:
	ldi		r16,$20
CLEAR_INTERRUPT_LOOP:
	rcall	SHORT_DELAY
	dec		r16
	brne	CLEAR_INTERRUPT_LOOP
	in		r16,GIFR
	andi	r16,$80
	sbrc	r16,$07
	rjmp	GIFR_NOT_SET
	ldi		r16,(1<<INTF1)
	out		GIFR,r16
GIFR_NOT_SET:
	ldi		r16,$00
	sts		BUTTON_STATUS,r16
	ret

//SKRIVER UT "RITAR" OCH V�NTAR P� SVAR FR�N PLOTTER-------------------
DRAW:
	//Kr�ver r�tt kod till plottern p� r16
	rcall	INITIATE_SPI_TRANSFER
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
	sbis	PINB,3
	rjmp	DRAW_STALL
	ldi		r16,$00
	rcall	INITIATE_SPI_TRANSFER
	rcall	PLOTTER_RESPONSE_CHECK
	ret

//STARTA SPI-�VERF�RING------------------------------------
INITIATE_SPI_TRANSFER:
	//F�ruts�tter r�tt data i r16
	cbi		PORTB,4			//Slave select l�g
	out		SPDR,r16
SPI_WAIT:
	sbis	SPSR,SPIF
	rjmp	SPI_WAIT
	in		r16,SPDR
	sbi		PORTB,4			//Slave select h�g
	sts		PLOTTER_RESPONSE,r16
	ret

//KONTROLLERAR SVAR FR�N PLOTTER------------------------
PLOTTER_RESPONSE_CHECK:
	lds		r16,PLOTTER_RESPONSE
	sbrc	r16,0
	rcall	CORRECT
	sbrc	r16,1
	rcall	WRONG
	sbrc	r16,2
	rcall	WIN
	sbrc	r16,3
	rcall	LOSE
PLOTTER_RESPONSE_DONE:
	ldi		r16,$00
	sts		PLOTTER_RESPONSE,r16
	ret

//KORT DELAY, T.EX. VID SKRIVNING TILL DISPLAY-----------
SHORT_DELAY:
	push	r16
	ldi		r16,$FF
SHORT_DELAY_LOOP:
	dec		r16
	brne	SHORT_DELAY_LOOP
	pop		r16
	ret	

//L�NG DELAY, T.EX. F�R KNAPPBLINKNING--------------
LONG_DELAY:
	rcall	SHORT_DELAY
	sbiw	r25:r24,1
	brne	LONG_DELAY
	ret

//MEDDELANDE VID R�TT BOKSTAV-----------------------
CORRECT:
	push	r16
	sbi		PORTD,0
	cbi		PORTD,1
	sbi		PORTD,2
	ldi		ZH,HIGH(CORRECT_MESSAGE*2)
	ldi		ZL,LOW(CORRECT_MESSAGE*2)
	rcall	PRINT_ENTIRE_DISPLAY
	ldi		r24,$FF
	ldi		r25,$40
	rcall	LONG_DELAY
	pop		r16
	ret

//MEDDELANDE VID FEL BOKSTAV-----------------------
WRONG:
	push	r16
	cbi		PORTD,0
	sbi		PORTD,1
	sbi		PORTD,2
	ldi		ZH,HIGH(WRONG_MESSAGE*2)
	ldi		ZL,LOW(WRONG_MESSAGE*2)
	rcall	PRINT_ENTIRE_DISPLAY
	ldi		r24,$FF
	ldi		r25,$40
	rcall	LONG_DELAY	
	pop		r16
	ret

//SEGERMEDDELANDE----------------------------------
WIN:
	push	r16
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
	rcall	LONG_DELAY
	rjmp	WIN_STALL
	pop		r16
	ret

//F�RLUSTMEDDELANDE--------------------------------
LOSE:
	push	r16
	ldi		ZH,HIGH(LOSE_MESSAGE*2)
	ldi		ZL,LOW(LOSE_MESSAGE*2)
	rcall	PRINT_ENTIRE_DISPLAY
	clr		r17
	ldi		r16,$76 // ladda r�d f�rg
	sts		BLINK_COLOURS,r16
LOSE_STALL:
	rcall	BLINK	
	rjmp	LOSE_STALL
	pop		r16
	ret

//BLINKA LAMPAN P� VRIDREGLAGET---------------------
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
	ldi		r24,$FF
	ldi		r25,$0E
	rcall	LONG_DELAY
	pop		r17
	pop		r16
	ret

//S�TTER ALLA BITAR I SRAM TILL NOLL-----------------
CLEAR_SRAM:
	ldi		r16,$0
	ldi		YH,HIGH(USED)
	ldi		YL,LOW(USED)
	ldi		r17,$22
CLEAR_LOOP:
	st		Y+,r16
	dec		r17
	brne	CLEAR_LOOP
	ret

//H�RDVARUINITIERING---------------------------------
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