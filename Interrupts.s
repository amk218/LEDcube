#include <xc.inc>
; This file contains the interrupt setup and the code to be executed on button press

; ********** External and global modules **********
    
global	high_priority_interrupt, interrupt_setup
extrn	pattern_counter, pattern_select, pattern_number
    
; ********** Setup routine **********
psect	interrupt_code, class=CODE
    
interrupt_setup:
	bsf	GIE		; Enable global interrupts
	bsf	INT1IE
	bsf	INT1IP
	bsf	INTEDG1
	bsf	RBPU		; Disable PORTB pull ups
	return
	   
; ********** Button press interrupt **********  
	
high_priority_interrupt:
    btfsc   INT1IF
    bra	    change_pattern
    bsf	    GIE
    retfie  f

change_pattern:			    ; High priority interupt that will change the pattern cycle on button press
    bcf	    INT1IF
    bsf	    GIE
    decfsz  pattern_counter	    ; Change pattern counter (i.e. pattern)

    return			    ; Select new pattern
    movlw   pattern_number	    ; If pattern number is maxed then reset counter
    movwf   pattern_counter
    return

    
