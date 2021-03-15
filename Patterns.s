#include <xc.inc>

global	single_layer_test, pattern_lookup
    
psect	patterns, class=CODE
    
layer_counter: ds   1		; A counter to track layers

    


pattern_lookup:
	addwf	PCL, 1, A
	retlw	0x400		; some kind of trash that I entered at random (8 bytes)
	
	
	
2x4_output:			; needs renaming
	lfsr	0, FSR1
	movlw	3
	movwf	layer_counter
    layer_cycle:
	clrf	LATF, A
	movff	POSTINC0, LATD, A
	movff	POSTINC0, LATE, A
	bsf	LATF, layer_counter, A
	; tiniest delay here?
	decfsz	layer_counter
	bra	layer_cycle
	bra	2x4_output	; problem here 2x means expecting hex number
	
	
	
	
layer_by_layer:			; lights up the layers going up, and down, and up, and down ....
	movlw	0b11111111	; Set all columns high to light all LED in a layer
	movwf	LATD, A
	movlw	0b11111111
	movwf	LATE, A
    layer_loop:
	bsf	LATF, 0, A	; Light bottom layer
	call	delay3		; delay to visible speeds
	bsf	LATF, 1, A	; light 2nd layer
	bcf	LATF, 0, A	; switch off first layer
	call	delay3		; repeat sequence
	bsf	LATF, 2, A
	bcf	LATF, 1, A
	call	delay3
	bsf	LATF, 3, A
	bcf	LATF, 2, A
	call	delay3		; reached the top, going down
	bsf	LATF, 2, A
	bcf	LATF, 3, A
	call	delay3
	bsf	LATF, 1, A
	bcf	LATF, 2, A
	call	delay3
	bcf	LATF, 1, A
	bra	layer_loop	; start again at the bottom
    	
	
	
single_layer_test:		; Static pattern on bottom layer only
	bsf	PORTF, 0, A	; Select bottom layer
	movlw	0b10011111
	movwf	PORTD, A
	movlw	0b11111001
	movwf	PORTE, A
	
	return



