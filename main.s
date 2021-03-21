#include <xc.inc>

extrn	Interrupt_setup, High_priority_interrupt
extrn	High_priority_interrupt, Low_priority_interrupt, Interrupt_setup ; From interrupt.s
extrn	load_to_RAM ; From Pattern_table.s	
extrn	single_layer_test, layer_by_layer, static_output ; From Patterns.s		

global	pattern_counter    
    
psect	udata_acs   ; reserve data space in access ram
pattern_counter:    ds 1    ; reserve one byte for a counter variable 
pattern_number EQU  6	    ; This is the number of available patterns (THIS MUST BE UPDATED WITH ANY NEW PATTERN)
    
psect	code, abs

	org	0x0000
	goto	setup
	
	org	0x0008
	goto	

	
psect	code, abs
setup:			    ; Set ports D-F as outputs and clear them
	clrf	TRISD, A
	clrf	LATD, A
	clrf	TRISH, A
	clrf	LATH, A
	clrf	TRISE, A
	clrf	LATE, A
	movlw	0b11111111
	movwf	TRISB, A
	call	load_to_RAM
	call	Interupt_setup
	movlw	pattern_number
	movwf	pattern_counter

	goto	start



	
start:
	;call	light_sensor_loop
	
Pattern_select:
	movlw	pattern_counter
	addwf	W,W,A
	addwf	PCL, F, A
	   ; Lookup table goes here
	
	bra	$

	end	start
