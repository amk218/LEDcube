#include <xc.inc>
	
global	High_priority_interrupt, Interrupt_setup
extrn	pattern_counter, pattern_select
    
psect	dac_code, class=CODE
    

	
DAC_Int_Hi:	
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	incf	LATJ, F, A	; increment PORTD
	bcf	TMR0IF		; clear interrupt flag
	retfie	f		; fast return from interrupt


	
Interrupt_setup:
	bsf	GIE		; enable globale interrupts
	bsf	RBIE		; enable interrrupt on port B4:7 change state
	bcf	RBPU		; disable PORTB pull ups
	bsf	RBIP		; set it to be high priority
	return

    
    
    
High_priority_interrupt:
    btfss   PORTB, 5, A
    bra	    change_pattern
    ;check for light sensor
    ;go to light override
    bcf	    RBIF
    retfie  f


    
Change_pattern:			    ; High priority interupt that will change the pattern cycle on button press
    pop				    ; remove return from stack
    bcf	    RBIF		    ; clear the interrupt flag
    decfsz  pattern_counter	    ; change pattern counter (i.e. pattern)
    goto    pattern_select	    ; select new pattern
    movf    pattern_number, W, A    ; if pattern number is maxed then reset counter
    goto    pattern_select	    ; select new pattern after counter reset