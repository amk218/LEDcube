#include <xc.inc>

global	single_layer_test
    
psect	patterns, class=CODE
    
single_layer_test:		; Static pattern on bottom layer only
	bsf	PORTF, 0, A	; Select bottom layer
	movlw	0b10011111
	movwf	PORTD, A
	movlw	0b11111001
	movwf	PORTE, A
	
	return
	
	
    



