#include <xc.inc>

global	layer_by_layer, cube_frame, edges_column_cycle
global	small_and_big, vertical_sweep, diagonal_fill, voxel_cycle
global	part_filled, cross, three_cubes, random_noise, rain
    
extrn	pattern_counter

    
psect   udata_acs
test_space:    ds   1    
layer_counter: ds   1		; A counter to track layers
delay_counter1:ds   1		; Counters for program delays
delay_counter2:ds   1
delay_counter3:ds   1
delay_counter4:ds   1
byte_counter:  ds   1
nibble_counter:ds   1

    
psect	patterns, class=CODE

; ****** Helper routines for patterns ******
    

static_output:		; Subroutine to display	any static pattern on the layers
	; Need to load FSR with starting address of pattern table before this routine!
	movlw	4
	movwf	layer_counter, A
	movlw	0b00000001	; Starting from layer 1 = bottom layer
	movwf	LATH, A
	
layer_cycle:			; Cycle through the 4 layers
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
	return	
	
	
; ***** Different pattern subroutines ******
	
layer_by_layer:			; lights up the layers going up, and down, and up, and down ....
	movlw	0b11111111	; Set all columns high to light all LED in a layer
	movwf	LATD, A
	movlw	0b11111111
	movwf	LATE, A
	
    layer_loop:

	movlw	1
	cpfseq	pattern_counter
	return
	
	bsf	LATH, 0, A	; Light bottom layer
	call	very_long_delay	; delay to visible speeds
	bsf	LATH, 1, A	; light 2nd layer
	bcf	LATH, 0, A	; switch off first layer
	call	very_long_delay	; repeat sequence
	bsf	LATH, 2, A
	bcf	LATH, 1, A
	call	very_long_delay
	bsf	LATH, 3, A
	bcf	LATH, 2, A
	call	very_long_delay	; Reached the top, going down
	bsf	LATH, 2, A
	bcf	LATH, 3, A
	call	very_long_delay
	bsf	LATH, 1, A
	bcf	LATH, 2, A
	call	very_long_delay
	bcf	LATH, 1, A
	bra	layer_loop	; start again at the bottom
    	

cube_frame:			; Static pattern that displays only the cube frame
    
    	lfsr	0, 0x400	; load FSR with starting point of pattern in the table
	call	static_output
	bra	cube_frame
	
    
small_and_big:			; Pattern that changes between small and big cube frames
	movlw	2
	cpfseq	pattern_counter
	return
    big_cube:
	lfsr	0, 0x400	; Load FSR with starting point of cube frame in the table
	call	static_output
	btfss	TMR0IF		; Check if timer flag has been set,
	bra	big_cube	; if not, keep displaying big cube
	bcf	TMR0IF		; If yes, clear timer flag and continue to small cube
    small_cube:
	lfsr	0, 0x408
	call	static_output
	btfss	TMR0IF
	bra	small_cube
	bcf	TMR0IF
	bra	small_and_big

	
vertical_sweep:			; Pattern that sweeps vertical layers of the cube
	movlw	3
	cpfseq	pattern_counter
	return
    row1:
	lfsr	0, 0x410	; Load FSR with starting point of pattern
	call	static_output
	btfss	TMR0IF		; Check if timer flag has been set,
	bra	row1		; if not, keep displaying first row on all layers
	bcf	TMR0IF		; If yes, clear timer flag and continue to next row
	
    row2:			; Repeat for all rows
	lfsr	0, 0x418
	call	static_output
	btfss	TMR0IF		
	bra	row2
	bcf	TMR0IF
	
    row3:		
	lfsr	0, 0x420	
	call	static_output
	btfss	TMR0IF		
	bra	row3
	bcf	TMR0IF
	
    row4:	
	lfsr	0, 0x428	
	call	static_output
	btfss	TMR0IF		
	bra	row4
	bcf	TMR0IF
	bra	vertical_sweep		; Go back to 1st row when done
	
	
diagonal_fill:			; Pattern that fills and then empties diagonal "rows" of the cube
    
    fill1:
	lfsr	0, 0x430	; Load FSR with starting point of pattern
	call	static_output
	btfss	TMR0IF		; Check if timer flag has been set,
	bra	fill1		; if not, keep displaying first set of bytes
	bcf	TMR0IF		; If yes, clear timer flag and continue to next part
    
    fill2:			; Repeat 6 times to fill all diagonal cross sections
	lfsr	0, 0x438	
	call	static_output
	btfss	TMR0IF		
	bra	fill2
	bcf	TMR0IF
    
    fill3:
	lfsr	0, 0x440	
	call	static_output
	btfss	TMR0IF		
	bra	fill3
	bcf	TMR0IF
    
    fill4:
	lfsr	0, 0x448	
	call	static_output
	btfss	TMR0IF		
	bra	fill4
	bcf	TMR0IF
    
    fill5:
	lfsr	0, 0x450	
	call	static_output
	btfss	TMR0IF		
	bra	fill5
	bcf	TMR0IF
    
    fill6:
	lfsr	0, 0x458	
	call	static_output
	btfss	TMR0IF		
	bra	fill6
	bcf	TMR0IF

    fill7:
	lfsr	0, 0x460	
	call	static_output
	btfss	TMR0IF		
	bra	fill7
	bcf	TMR0IF
    
    substract1:			; Start removing diagonals from the other end
	lfsr	0, 0x468	
	call	static_output
	btfss	TMR0IF		
	bra	substract1
	bcf	TMR0IF
    
    substract2:
	lfsr	0, 0x470	
	call	static_output
	btfss	TMR0IF		
	bra	substract2
	bcf	TMR0IF
    
    substract3:
	lfsr	0, 0x478	
	call	static_output
	btfss	TMR0IF		
	bra	substract3
	bcf	TMR0IF
    
    substract4:
	lfsr	0, 0x480	
	call	static_output
	btfss	TMR0IF		
	bra	substract4
	bcf	TMR0IF
    
    substract5:
	lfsr	0, 0x488	
	call	static_output
	btfss	TMR0IF		
	bra	substract5
	bcf	TMR0IF
    
    substract6:
	lfsr	0, 0x490	
	call	static_output
	btfss	TMR0IF		
	bra	substract6
	bcf	TMR0IF

    empty:			    ; Display empty cube in between rounds
	clrf	LATE
	clrf	LATD
	btfss	TMR0IF		
	bra	empty
	bcf	TMR0IF
	bra	fill1
    
    
voxel_cycle:			    ; Pattern that lights up each "voxel" one by one in order
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
	bra	cross

part_filled:			    ; Static pattern, part-filled cube form one corner
    	lfsr	0, 0x4A0	    ; load FSR with starting point of pattern in the table
	call	static_output
	bra	part_filled
	
edges_column_cycle:
	movlw	0b11111111
	movwf	LATH		    ; Switch on all layers
	movlw	3
	movwf	nibble_counter	    ; Count to 3 to rotate 3 times
	bsf	LATD, 0
	
    edge1:
	call	long_delay
	rlncf	LATD
	decfsz	nibble_counter
	bra	edge1
	call	long_delay
	clrf	LATD
	
    edge2:
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
	call	long_delay
	rrncf	LATE
	decfsz	nibble_counter
	bra	edge3
	call	long_delay
	clrf	LATE
	
    edge4:
	bsf	LATE, 4
	call	long_delay
	bcf	LATE, 4
	bsf	LATD, 4
	call	long_delay
	bcf	LATD, 4
	bra	edges_column_cycle
	
random_noise:			; Pattern that lights up a random bunch on pixel on the cube
    
    part1:
	lfsr	0, 0x4A8	; Load FSR with starting point of pattern
	call	static_output
	btfss	TMR0IF		; Check if timer flag has been set,
	bra	part1		; if not, keep displaying
	bcf	TMR0IF		; If yes, clear timer flag and continue to next part
	
    part2:
	lfsr	0, 0x4B0
	call	static_output
	btfss	TMR0IF
	bra	part2
	bcf	TMR0IF
	
    part3:
	lfsr	0, 0x4B8
	call	static_output
	btfss	TMR0IF
	bra	part3
	bcf	TMR0IF
	
    part4:
	lfsr	0, 0x4C0
	call	static_output
	btfss	TMR0IF
	bra	part4
	bcf	TMR0IF
	bra	part1
	
three_cubes:
    
    two:
	lfsr	0, 0x4C8
	call	static_output
	btfss	TMR0IF
	bra	two
	bcf	TMR0IF
	
    three:
    	lfsr	0, 0x4D0
	call	static_output
	btfss	TMR0IF
	bra	three
	bcf	TMR0IF
	
    four:
    	lfsr	0, 0x400
	call	static_output
	btfss	TMR0IF
	bra	four
	bcf	TMR0IF

    three_back:
	lfsr	0, 0x4D0
	call	static_output
	btfss	TMR0IF
	bra	three_back
	bcf	TMR0IF
	bra	two
	
rain:
    set1:
	lfsr	0, 0x4D8
	call	static_output
	btfss	TMR0IF
	bra	set1
	bcf	TMR0IF
	
    set2:
	lfsr	0, 0x4E0
	call	static_output
	btfss	TMR0IF
	bra	set2
	bcf	TMR0IF
	
    set3:
	lfsr	0, 0x4E8
	call	static_output
	btfss	TMR0IF
	bra	set3
	bcf	TMR0IF
	
    set4:
	lfsr	0, 0x4F0
	call	static_output
	btfss	TMR0IF
	bra	set4
	bcf	TMR0IF
	
    set5:
	lfsr	0, 0x4F8
	call	static_output
	btfss	TMR0IF
	bra	set5
	bcf	TMR0IF

    set6:
	lfsr	0, 0x500
	call	static_output
	btfss	TMR0IF
	bra	set6
	bcf	TMR0IF
	
    set7:
	lfsr	0, 0x508
	call	static_output
	btfss	TMR0IF
	bra	set7
	bcf	TMR0IF
	
    set8:
	lfsr	0, 0x510
	call	static_output
	btfss	TMR0IF
	bra	set8
	bcf	TMR0IF
	bra	set1
    
; ****** Delays ******
	
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