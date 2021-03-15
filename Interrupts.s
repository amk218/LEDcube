#include <xc.inc>
	
global	DAC_Setup, DAC_Int_Hi
    
psect	dac_code, class=CODE
	
DAC_Int_Hi:	
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	incf	LATJ, F, A	; increment PORTD
	bcf	TMR0IF		; clear interrupt flag
	retfie	f		; fast return from interrupt

DAC_Setup:
	clrf	TRISJ, A	; Set PORTD as all outputs
	clrf	LATJ, A		; Clear PORTD outputs
	movlw	10000111B	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return
	
	end
	
High_priority_interupt:
    ;check for button press
    ;go to change pattern
    ;check for light sensor
    ;go to light override
    ; reset flags
    ; return to main program

Low_priority_interupt:		; checks flags, sends to correct code segment, resets flags
    ; check timer flag
    ; if flag set then call change_static_pattern
    ; if not then return
    ; reset flag
    ; return to main program
	
	
	
change_static_pattern:		; Low priority interupt which will change the static pattern displayed every second
    ;check if end of pattern
    ;if no +8 to FSR1
    ;if yes reset FSR1 to pattern start
    ;reset interupt flag
    ;return 
    
Change_pattern:			; High priority interupt that will change the pattern cycle on button press
    ; +1 to pattern counter
    ; call pattern lookup
    ; put WREG into FSR1, FSR2
    ; return