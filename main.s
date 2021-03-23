#include <xc.inc>

;extrn	DAC_Int_Hi, DAC_Setup
;extrn	High_priority_interrupt, Low_priority_interrupt, Interrupt_setup ; From interrupt.s
extrn	load_to_RAM ; From Pattern_table.s	
extrn	layer_by_layer ; From Patterns.s
extrn	cube_frame, small_and_big, vertical_sweep, diagonal_fill, voxel_cycle
extrn	edges_column_cycle, part_filled, cross, three_cubes, random_noise, rain
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

	
;pattern_lookup:
	;goto	layer_by_layer
	;goto	small_and_big
	;goto	vertical_sweep
	;goto	cube_frame
	;goto	voxel_cycle
	;goto	diagonal_fill
	
start:

	call	cube_frame
	bra	$

	end	start

