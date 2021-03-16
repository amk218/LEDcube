#include <xc.inc>

global	single_layer_test, pattern_lookup, layer_by_layer, static_output

    
psect   udata_acs
test_space: ds 1    
layer_counter: ds   1		; A counter to track layers

    
psect	patterns, class=CODE

pattern_lookup:
	;addwf	PCL, 1, A
	;retlw	0x400		; some kind of trash that I entered at random (8 bytes)
	

	
static_output:			
	lfsr	0, 0x400
	movlw	4
	movwf	layer_counter, A
	movlw	0b00000001
    layer_cycle:	
	movff	INDF0, LATD, A
	incf	FSR0, A
	movff	INDF0, LATE, A
	incf	FSR0, A
	movwf	LATH, A
	rlncf	WREG, F, A
	clrf	LATH, A
	; tiniest delay here?
	decfsz	layer_counter, A
	bra	layer_cycle
	return	
	
	
	
	
layer_by_layer:			; lights up the layers going up, and down, and up, and down ....
	movlw	0b11111111	; Set all columns high to light all LED in a layer
	movwf	LATD, A
	movlw	0b11111111
	movwf	LATE, A
    layer_loop:
	bsf	LATH, 0, A	; Light bottom layer
	call	delay3		; delay to visible speeds
	bsf	LATH, 1, A	; light 2nd layer
	bcf	LATH, 0, A	; switch off first layer
	call	delay3		; repeat sequence
	bsf	LATH, 2, A
	bcf	LATH, 1, A
	call	delay3
	bsf	LATH, 3, A
	bcf	LATH, 2, A
	call	delay3		; reached the top, going down
	bsf	LATH, 2, A
	bcf	LATH, 3, A
	call	delay3
	bsf	LATH, 1, A
	bcf	LATH, 2, A
	call	delay3
	bcf	LATH, 1, A
	bra	layer_loop	; start again at the bottom
    	
	
	
single_layer_test:		; Static pattern on bottom layer only
	bsf	LATH, 0, A	; Select bottom layer
	movlw	0b10011111
	movwf	LATD, A
	movlw	0b11111001
	movwf	LATE, A
	
	return



delay1:
	movlw   0xFF		    ; Put value 0x10 into W
	movwf   0x20, A		    ; Move value in W to file register address 0x20
	decfsz  0x20, F, A	    ; Decrement value in 0x20. If 0, skip next line
	bra	$-2
	return
	
delay2:
	movlw	0xFF		    ; Put the value 0x20 into W
	movwf	0x30, A		    ; Move value in W to file register address 0x30
	call	delay1		    ; Call counter delay1
	decfsz	0x30,F,A	    ; Decrement value in 0x30. If 0, skip next line
	bra	$-6
	return
	
delay3:
	movlw	0x50
	movwf	0x40, A
	call	delay2
	decfsz	0x40, F, A
	bra	$-6
	return