#include <xc.inc>

extrn	DAC_Int_Hi, DAC_Setup
extrn	High_priority_interrupt, Low_priority_interrupt, Interrupt_setup ; From interrupt.s
extrn	load_to_RAM ; From Pattern_table.s	
extrn	single_layer_test, layer_by_layer, static_output ; From Patterns.s		
	

psect	code, abs

	org	0x0000
	goto	setup
	

	
psect	code, abs
setup:			    ; Set ports D-F as outputs and clear them
	clrf	TRISD, A
	clrf	LATD, A
	clrf	TRISH, A
	clrf	LATH, A
	clrf	TRISE, A
	clrf	LATE, A
	call	load_to_RAM
	;call	Interupt_setup
    Load_initial_config:
	; FSR1, FSR2 = 0x400
	; set pattern counter to 0
	goto	start



	
start:
	lfsr	1, 0x400
	call	static_output


	
	bra	$

	end	start
