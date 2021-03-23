#include <xc.inc>
	
global	High_priority_interrupt, Interrupt_setup, pattern_timer_setup
extrn	pattern_counter, pattern_select, pattern_number
    
psect	dac_code, class=CODE
    
	
Interrupt_setup:
	bsf	GIE		; enable globale interrupts
	bsf	INT1IE
	bsf	INT1IP
	bsf	INTEDG1
	bsf	RBPU		; disable PORTB pull ups

	return
pattern_timer_setup:
	movlw	10000110B	; Set timer0 to 16-bit, Fosc/4/128
	movwf	T0CON, A	; = 62.5KHz clock rate, approx 0.5sec rollover
	return
	   
    
High_priority_interrupt:
    btfsc   INT1IF
    bra	    change_pattern
    ;check for light sensor
    ;go to light override
    bsf	    GIE
    retfie  f


    
change_pattern:			    ; High priority interupt that will change the pattern cycle on button press
    bcf	    INT1IF
    bsf	    GIE
    decfsz  pattern_counter	    ; change pattern counter (i.e. pattern)
    return			    ; select new pattern
    movlw   pattern_number	    ; if pattern number is maxed then reset counter
    movwf   pattern_counter
    return
