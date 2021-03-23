#include <xc.inc>


extrn	Interrupt_setup, High_priority_interrupt, pattern_timer_setup; From interrupt.s
extrn	load_to_RAM ; From Pattern_table.s			
extrn	layer_by_layer, cube_frame, edges_column_cycle
extrn	small_and_big, vertical_sweep, diagonal_fill, voxel_cycle
extrn	part_filled, cross, three_cubes, random_noise, rain

global	pattern_counter, pattern_number, pattern_select
    
psect	udata_acs   ; reserve data space in access ram
pattern_counter:    ds 1    ; reserve one byte for a counter variable 
pattern_number EQU  7	    ; This is the number of available patterns (THIS MUST BE UPDATED WITH ANY NEW PATTERN)
    
psect	code, abs

	org	0x0000
	goto	setup
	
	org	0x0008
	goto	High_priority_interrupt 

	
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
	call	Interrupt_setup



	call	pattern_timer_setup ; Setup a timer for moving patterns

	goto	start

	

	
start:
	movlw	pattern_number
	movwf	pattern_counter
	;call	light_sensor_loop
	
pattern_select:
	movf	pattern_counter, W, A
	addlw	0xFF
	addwf	WREG,A
	addwf	WREG,A
	addwf	PCL, F, A
	   ; Lookup table goes here
	goto	layer_by_layer
	goto	small_and_big
	goto	vertical_sweep
	goto	cube_frame
	goto	voxel_cycle
	goto	diagonal_fill
	goto	edges_column_cycle
	
	
	
	bra	$

	end	start

