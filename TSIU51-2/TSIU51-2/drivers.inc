;drivers.inc
*
*  Created: 2019-02-19 15:48:52
*   Author: Jensg
*/ 

;---------------------------------------------
;Används för att kunna använda jumptables 
;Börjar där Z-pekaren pekar
;Register r16 är en parameter och bestämmer index
;------------------------------------------
JUMP_TABLE:
    push	r17
    lsl		r16	
    add		ZL, r16
    brcc	PC+2
    subi	ZH, -1
    lpm		r16, Z+
    lpm		r17, Z
    lsl		r17
    lsl		r16
    brcc	PC+2
    subi	r17, -1		
    mov		ZH, r17
    mov		ZL, r16
    pop		r17
    ret

;---------------------------------------------
;Börjar rita enligt kodning där Z-pekaren pekar och avslutar när den hittar $FF
;------------------------------------
DRAW_FUNC:	
    push	ZH	
    push	ZL
    push	r16
    push	r18
DRAW_FUNC_LOOP:
    lpm		r16, Z+
    cpi		r16, $FF
    breq	DRAW_FUNC_DONE
    sbrc	r16, 7
    rcall	LOWER_PEN
    sbrs	r16, 7
    rcall	RAISE_PEN
    andi	r16, $7F
    lpm		r18, Z+
    rcall	MOVE_FUNC
    rjmp	DRAW_FUNC_LOOP					
DRAW_FUNC_DONE:
    rcall	RAISE_PEN
    pop		r18
    pop		r16
    pop		ZL
    pop		ZH
    ret	


;------------------------------------
;------ DRIVRUTIEN FÖR PLOTTERN
;------ parameter -  r16 bestämmer villket hål den ska röra sig
;------ parameter - r18 hur långt den ska rörar sig (max 65 535)
;------------------------------------
MOVE_FUNC:
    push	ZH
    push	ZL
    push	r17
    push	r19
    mov		r19, r16
MOVE_FUNC_SEQUENCE:
    mov		r16, r19
    ldi		r17, 8
    ldi		ZH, HIGH(FIRST_PULSE*2)
    ldi		ZL, LOW(FIRST_PULSE*2)
    add		ZL, r16
    MOVE_FUNC_LOOP:		
    lpm		r16, Z
    out		PORTA, r16
    call	PULSE_DELAY
    subi	ZL, -8
    dec		r17
    brne	MOVE_FUNC_LOOP
    dec		r18
    brne	MOVE_FUNC_SEQUENCE
    pop		r19
    pop		r17
    pop		ZL
    pop		ZH
    ret

;------------------------------------
;Sänker pennan
;------------------------------------
LOWER_PEN:
    sbic	PORTC,7
    rjmp	LOWER_PEN_EXIT
    sbi		PORTC, 7
    rcall	PEN_DELAY
    LOWER_PEN_EXIT:
    ret

;------------------------------------
;Höjer pennan
;------------------------------------
RAISE_PEN:
    sbis	PORTC, 7
    rjmp	RAISE_PEN_EXIT
    cbi		PORTC, 7
    rcall	PEN_DELAY
    RAISE_PEN_EXIT:
    ret

;------------------------------------
;Delay som används efter pennan höjts/sänkts så den ska hinna innan plottern rör på sig igen
;------------------------------------
PEN_DELAY:
    push	r24
    push	r25
    ldi		r25, $FF
    ldi		r24, $FF
PEN_DELAY_LOOP:
    sbiw	r25:r24, 1
    brne	PEN_DELAY_LOOP
    pop		r25
    pop		r24
    ret

;------------------------------------
;Delay som används mellan pulserna, så att plottern inte ska vara för snabb
;Använder 16-bitar registret r25:r24
;------------------------------------
PULSE_DELAY:
    push	r24
    push	r25
    ldi		r25, $0A
    ldi		r24, $00
    PULSE_DELAY_LOOP:
    sbiw	r25:r24, 1
    brne	PULSE_DELAY_LOOP
    pop		r25
    pop		r24
    ret

