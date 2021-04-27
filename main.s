 
#include <xc.inc>
; This file is the main program file

; ********** External and global modules **********
    
extrn	interrupt_setup, high_priority_interrupt ; From interrupt.s
extrn	load_to_RAM ; From Pattern_table.s			
extrn	pattern_timer_setup, layer_by_layer, edges_column_cycle ; From Patterns.s
extrn	small_and_big, vertical_sweep, diagonal_fill, voxel_cycle, cube_frame
extrn	part_filled, cross, three_cubes, random_noise, rain, fill_cube, wave
extrn	light_sensor_setup, get_light_sensor_data ; From Light_sensor.s

global	pattern_counter, pattern_number, pattern_select
    
; ********** Variables ********** 
psect	udata_acs	    ; Reserve data space in access RAM
	
pattern_counter:    ds 1    ; Reserve one byte for a counter variable 

pattern_number EQU  13	    ; This is the number of available patterns (THIS MUST BE UPDATED WITH ANY NEW PATTERN)

; ********** Interrupt **********
psect	code, abs

	org	0x0000
	goto	setup
	
	org	0x0008
	goto	high_priority_interrupt 

; ********** Setup routines **********	
psect	code, abs
	
setup:			    ; Configure ports D,H,J as outputs and clear them
	clrf	TRISD, A
	clrf	LATD, A
	clrf	TRISH, A
	clrf	LATH, A
	clrf	TRISJ, A
	clrf	LATJ, A

	movlw	0b11111111
	movwf	TRISB, A
	call	load_to_RAM ; Load all pattern data to RAM
	call	interrupt_setup	; Set up button interrupt routine
	call	pattern_timer_setup ; Setup a timer for moving patterns
	call	light_sensor_setup  ; Set up SPI communication with light sensor

	goto	start
	
; ********** Main code starts here **********
	
start:
	call	get_light_sensor_data ; Start by checking if light level is low enough
	movlw	pattern_number	
	movwf	pattern_counter
	
pattern_select:			    ; Start displaying patterns
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
