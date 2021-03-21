#include <xc.inc>

;extrn	DAC_Int_Hi, DAC_Setup
;extrn	High_priority_interrupt, Low_priority_interrupt, Interrupt_setup ; From interrupt.s
extrn	load_to_RAM ; From Pattern_table.s	
extrn	layer_by_layer ; From Patterns.s
extrn	cube_frame, small_and_big, vertical_sweep, diagonal_fill
extrn	pattern_timer_setup
	

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
	call	load_to_RAM ; Load pattern data to RAM
	call	pattern_timer_setup ; Setup a timer for moving patterns
	;call	Interupt_setup
	goto	start


	
start:

	call	diagonal_fill
	bra	$

	end	start
