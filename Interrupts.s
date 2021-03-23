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
    bcf	    INT1IF
    retfie  f


    
change_pattern:			    ; High priority interupt that will change the pattern cycle on button press
    pop				    ; remove return from stack
    bcf	    INT1IF		    ; clear the interrupt flag
    bsf	    GIE
    decfsz  pattern_counter	    ; change pattern counter (i.e. pattern)
    goto    pattern_select	    ; select new pattern
    movf    pattern_number, W, A    ; if pattern number is maxed then reset counter
    goto    pattern_select	    ; select new pattern after counter reset
