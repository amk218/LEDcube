 
#include <xc.inc>


extrn	Interrupt_setup, High_priority_interrupt, pattern_timer_setup; From interrupt.s
extrn	load_to_RAM ; From Pattern_table.s			
extrn	layer_by_layer, cube_frame, edges_column_cycle
extrn	small_and_big, vertical_sweep, diagonal_fill, voxel_cycle
extrn	part_filled, cross, three_cubes, random_noise, rain, fill_cube, wave
extrn	Light_sensor_setup, light_sensor_get_data

global	pattern_counter, pattern_number, pattern_select
    
psect	udata_acs   ; reserve data space in access ram
pattern_counter:    ds 1    ; reserve one byte for a counter variable 

pattern_number EQU  13	    ; This is the number of available patterns (THIS MUST BE UPDATED WITH ANY NEW PATTERN)

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
	call	Light_sensor_setup

	goto	start

start:
	call	small_and_big
	movlw	pattern_number
	movwf	pattern_counter
	call	light_sensor_get_data
	
pattern_select:
	call	fill_cube
	call	layer_by_layer
	call	small_and_big
	call	part_filled
	call	voxel_cycle
	call	vertical_sweep
	call	cube_frame
	call	edges_column_cycle
	call	rain
	call	three_cubes
	call	diagonal_fill
	call	random_noise
	call	wave
	bra	pattern_select
	

	bra	$

	end	start
