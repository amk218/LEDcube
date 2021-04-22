#include <xc.inc>

global	layer_by_layer, cube_frame, edges_column_cycle
global	small_and_big, vertical_sweep, diagonal_fill, voxel_cycle
global	part_filled, cross, three_cubes, random_noise, rain, fill_cube, wave
    
extrn	pattern_counter, light_sensor_get_data

  
psect   udata_acs
; ********** Variables **********     
pattern_number:ds   1		; Variable to hold the number label of each pattern
layer_counter: ds   1		; A counter to track layers
delay_counter1:ds   1		; Counters for program delays
delay_counter2:ds   1
delay_counter3:ds   1
delay_counter4:ds   1
byte_counter:  ds   1
nibble_counter:ds   1
frame_counter: ds   1		; Number of animation frames for moving patterns
stack_depth:   ds   1		; Variable: 0 if depth=2, 1 if depth=1
    

    
psect	patterns, class=CODE

; ********** Helper routines for patterns **********
    

static_output:		; Subroutine to display	any static pattern on the layers
	; Need to load FSR0 with starting address of pattern table before this routine!
	movlw	1
	movwf	stack_depth
	movlw	4
	movwf	layer_counter, A
	movlw	8
	movwf	byte_counter, A
	movlw	0b00000001	; Starting from layer 1 = bottom layer
	movwf	LATH, A
	
    layer_cycle:		; Cycle through the 4 layers
	movff	INDF0, LATD, A	; Take value from address pointed to by FSR and output to D
	call	medium_delay
	incf	FSR0, A		; Increment FSR
	movff	INDF0, LATE, A	; Output the following byte to E
	call	medium_delay
	incf	FSR0, A
	clrf	LATD
	clrf	LATE
	rlncf	LATH, F, A	; Rotate bit in H to activate next layer
	
	decfsz	layer_counter, A ; Decrement layer counter
	bra	layer_cycle
	
    reset_FSR:
	decf	FSR0, A
	decfsz	byte_counter
	bra	reset_FSR
	return	
	
	
dynamic_output:			; Subroutine to show any multi-step animated pattern
	; Need to load FSR0 with correct data address before calling this!
	call	static_output	; Display static stage
	movlw	0
	movwf	stack_depth
	call	pattern_check	; Check for button press
	btfss	TMR0IF		; Check if timer flag has been set,
	bra	dynamic_output	; if not, keep displaying
	bcf	TMR0IF		; If yes, clear timer flag and continue
	movlw	8
	addwf	FSR0, A		; Increment FSR0 by 8 to move onto next frame
	decfsz	frame_counter	; Count down all frames of animated pattern	
	bra	dynamic_output	; Repeat
	return			; Go back to pattern subroutine
	
	
pattern_check:  ; Subroutine to check current pattern counter value
	call	light_sensor_get_data
	movff	pattern_number, WREG	; Check if pattern counter still
	cpfseq	pattern_counter	; corresponds to given pattern number
	bra	back_to_main
	return			; If yes, return to pattern subroutine
    back_to_main:		; If not, return to main program
	pop			; Remove layers from call stack
	btfss	stack_depth, 0	; Determine if 1 or 2 pops needed
	pop
	return			; Return to main program
	
; ********* Different pattern subroutines **********
	
layer_by_layer:			; Pattern that lights up the layers going up and down
	movlw	2
	movwf	pattern_number	; Set label of this pattern to 2
	movlw	1
	movwf	stack_depth
	movlw	0b11111111	; Set all columns high to light all LED in a layer
	movwf	LATD, A
	movlw	0b11111111
	movwf	LATE, A
	bsf	LATH, 0, A	; Light bottom layer
	
    up:
	movlw	3
	movwf	layer_counter	; Set a counter to 3
    up_loop:
	call	pattern_check	; If not, return to main program
	call	very_long_delay	; Delay to visible speeds
	rlncf	LATH, F, A	; Rotate bit in H to activate above layer
	decfsz	layer_counter, A
	bra	up_loop
	
    down:	
	movlw	3
	movwf	layer_counter	; Reset layer counter back to 3 before going down
    down_loop:
    	call	pattern_check
	call	very_long_delay	; Delay to visible speeds
	rrncf	LATH, F, A	; Rotate bit in H to activate below layer
	decfsz	layer_counter, A
	bra	down_loop
	bra up

	
cube_frame:			; Static pattern that displays only the cube frame
	movlw	1
	movwf	stack_depth
    	movlw	7
	movwf	pattern_number	; Set label of this pattern to 7
    	lfsr	0, 0x400	; load FSR with starting point of pattern in the table
	call	static_output
	call	pattern_check
	bra	cube_frame
	
    
small_and_big:			; Pattern that changes between small and big cube frames
    
	movlw	3
	movwf	pattern_number  ; Set label of this pattern to 3
	movlw	2
	movwf	frame_counter	; Set counter for number of animation steps
	lfsr	0, 0x400	; Load FSR with starting point of cube frame in the table
	call	dynamic_output
	bra	small_and_big
   
	
vertical_sweep:			; Pattern that sweeps vertical layers of the cube
	movlw	6
	movwf	pattern_number  ; Set label of this pattern to 6
	movlw	4
	movwf	frame_counter	; 	
	lfsr	0, 0x410	; Load FSR with starting point of pattern
	call	dynamic_output	
	bra	vertical_sweep
	
diagonal_fill:			; Pattern that fills and then empties diagonal "rows" of the cube
    	movlw	11
	movwf	pattern_number  ; Set label of this pattern to 11
	movlw	13
	movwf	frame_counter, A ; Set a counter to 13
	lfsr	0, 0x430	; Load FSR with starting point of pattern
	call	dynamic_output
    empty:			; Display empty cube in between rounds
	clrf	LATE
	clrf	LATD
	movlw	1
	movwf	stack_depth
	call	pattern_check
	btfss	TMR0IF		
	bra	empty
	bcf	TMR0IF
	bra	diagonal_fill	; Start again when done
	
	
voxel_cycle:			    ; Pattern that lights up each "voxel" one by one in order
	movlw	1
	movwf	stack_depth
	movlw	5
	movwf	pattern_number	    ; Set label of this pattern to 5
	clrf	LATH
	clrf	LATD
	clrf	LATE
	movlw	4
	movwf	layer_counter	    ; Set up counter to 4
	bsf	LATH, 0		    ; Start with bottom layer
	
    layers:
	movlw	3
	movwf	nibble_counter	    ; Set up counter to 3
	bsf	LATD, 0		    ; Light first LED
	
    D_nibble1:			    ; Cycle through all PORTD first nibble LEDs
	call	pattern_check
	call	long_delay	    ; Delay to visible speeds
	rlncf	LATD, F, A	    ; Rotate bit to light next LED
	call	long_delay
	decfsz	nibble_counter
	bra	D_nibble1
	clrf	LATD		    ; Clear D once finished
	movlw	3		    ; Start counting again
	movwf	nibble_counter
	bsf	LATD, 7
	
    D_nibble2:			    ; Repeat for second nibble
	call	pattern_check
	call	long_delay
	rrncf	LATD, F, A	    ; Rotate right this time
	call	long_delay
	decfsz	nibble_counter
	bra	D_nibble2
	clrf	LATD
	movlw	3
	movwf	nibble_counter
	bsf	LATE, 4 
	
    E_nibble2:			    ; Now repeat for PORTE, i.e second half of a layer
	call	pattern_check
	call	long_delay
	rlncf	LATE, F, A
	call	long_delay
	decfsz	nibble_counter
	bra	E_nibble2
	clrf	LATE
	movlw	3
	movwf	nibble_counter
	bsf	LATE, 3
	
    E_nibble1:
	call	pattern_check
	call	long_delay
	rrncf	LATE, F, A
	call	long_delay
	decfsz	nibble_counter
	bra	E_nibble1
	clrf	LATE
	
	decfsz	layer_counter	    ; Count to 4 for each horisontal layer
	bra	$+4		    
	bra	voxel_cycle	    ; If 0, start whole cycle again
	
	movf	LATH, 0,0	    ; If not 0 yet, move on to next layer by rotating bit in H
	clrf	LATH
	rlncf	WREG, F, A	    
	movwf	LATH
	bra	layers
	
cross:				    ; Static cross pattern (viewed from side)
    	lfsr	0, 0x498	    ; load FSR with starting point of pattern in the table
	call	static_output
	call	pattern_check
	bra	cross

part_filled:			    ; Static pattern, part-filled cube form one corner
	movlw	4
	movwf	pattern_number	    ; Set label of this pattern to 4
    	lfsr	0, 0x4A0	    ; load FSR with starting point of pattern in the table
	call	static_output
	call	pattern_check
	bra	part_filled
	
edges_column_cycle:
	movlw	1
	movwf	stack_depth
	movlw	8
	movwf	pattern_number	    ; Set label of this pattern to 8
	movlw	0b11111111
	movwf	LATH		    ; Switch on all layers
	movlw	3
	movwf	nibble_counter	    ; Count to 3 to rotate 3 times
	bsf	LATD, 0
	
    edge1:
	call	pattern_check
	call	long_delay
	rlncf	LATD
	decfsz	nibble_counter
	bra	edge1
	call	long_delay
	clrf	LATD
	
    edge2:
	call	pattern_check
	bsf	LATD, 7
	call	long_delay
	bcf	LATD, 7
	bsf	LATE, 7
	call	long_delay
	bcf	LATE, 7
	bsf	LATE, 3
	movlw	3
	movwf	nibble_counter	
	
    edge3:
	call	pattern_check
	call	long_delay
	rrncf	LATE
	decfsz	nibble_counter
	bra	edge3
	call	long_delay
	clrf	LATE
	
    edge4:
	call	pattern_check
	bsf	LATE, 4
	call	long_delay
	bcf	LATE, 4
	bsf	LATD, 4
	call	long_delay
	bcf	LATD, 4
	bra	edges_column_cycle
	
	
random_noise:			; Pattern that lights up a random bunch on pixel on the cube
    
	movlw	12
	movwf	pattern_number	; Set label of this pattern to 12
	movlw	4
	movwf	frame_counter	; Set counter to 4
	lfsr	0, 0x4A8
	call	dynamic_output
	bra	random_noise
		
three_cubes:
	movlw	10
	movwf   pattern_number	    ; Set label of this pattern to 10
    two:
	lfsr	0, 0x4C8
	call	static_output
	call	pattern_check
	btfss	TMR0IF
	bra	two
	bcf	TMR0IF
	
    three:
    	lfsr	0, 0x4D0
	call	static_output
	call	pattern_check
	btfss	TMR0IF
	bra	three
	bcf	TMR0IF
	
    four:
    	lfsr	0, 0x400
	call	static_output
	call	pattern_check
	btfss	TMR0IF
	bra	four
	bcf	TMR0IF

    three_back:
	lfsr	0, 0x4D0
	call	static_output
	call	pattern_check
	btfss	TMR0IF
	bra	three_back
	bcf	TMR0IF
	bra	two
	
rain:
	movlw	9
	movwf	pattern_number	; Set label of this pattern to 9
	movlw	5
	movwf	frame_counter
	lfsr	0, 0x4D8
	call	dynamic_output
	
	lfsr	0, 0x500	; Move onto 0x500
	movlw	3
	movwf	frame_counter	; Three more steps to go
	call	dynamic_output
	bra	rain

fill_cube:
	movlw	1
	movwf	pattern_number	; Set label of this pattern to 1
	movlw	21
	movwf	frame_counter
	lfsr	0, 0x518
	call	dynamic_output
	call	very_long_delay
	bra	fill_cube
	
wave:
	movlw	13
	movwf	pattern_number  ; Set label of this pattern to 13
	movlw	6
	movwf	frame_counter
	lfsr	0, 0x5C0
	call	dynamic_output
	bra	wave
    
; ********** Delays **********
	
short_delay:
	movlw	0xFF
	movwf	delay_counter1
	decfsz	delay_counter1
	bra	$-2
	return

medium_delay:
	movlw	0x15
	movwf	delay_counter2
	call	short_delay
	decfsz	delay_counter2
	bra	$-6
	return
	
long_delay:
	movlw	0x15
	movwf	delay_counter3
	call	medium_delay
	decfsz	delay_counter3
	bra	$-6
	return
	
very_long_delay:
	movlw	0x05
	movwf	delay_counter4
	call	long_delay
	decfsz	delay_counter4
	bra	$-6
	return