#include <xc.inc>

global	layer_by_layer, cube_frame
global	small_and_big, vertical_sweep, diagonal_fill

    
psect   udata_acs
test_space:    ds   1    
layer_counter: ds   1		; A counter to track layers
delay_counter1:ds   1		; Counters for program delays
delay_counter2:ds   1
delay_counter3:ds   1

    
psect	patterns, class=CODE

; ****** Helper routines for patterns ******
    

static_output:		; Subroutine to display	a static pattern on the layers
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
	bsf	LATH, 0, A	; Light bottom layer
	call	long_delay	; delay to visible speeds
	bsf	LATH, 1, A	; light 2nd layer
	bcf	LATH, 0, A	; switch off first layer
	call	long_delay	; repeat sequence
	bsf	LATH, 2, A
	bcf	LATH, 1, A
	call	long_delay
	bsf	LATH, 3, A
	bcf	LATH, 2, A
	call	long_delay	; Reached the top, going down
	bsf	LATH, 2, A
	bcf	LATH, 3, A
	call	long_delay
	bsf	LATH, 1, A
	bcf	LATH, 2, A
	call	long_delay
	bcf	LATH, 1, A
	bra	layer_loop	; start again at the bottom
    	

cube_frame:			; Static pattern that displays only the cube frame
    
    	lfsr	0, 0x400	; load FSR with starting point of pattern in the table
	call	static_output
	bra	cube_frame
	
    
small_and_big:			; Pattern that changes between small and big cube frames

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
	bra	big_cube

	
vertical_sweep:			; Pattern that sweeps horsontal layers of the cube
    
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
	bra	row1		; Go back to 1st row when done
	
	
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
    
    
;voxel_cycle:			    ; Pattern that lights up each "voxel" one by one in order
    
	
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
	bra	$-4
	return
	
long_delay:
	movlw	0x15
	movwf	delay_counter3
	call	medium_delay
	decfsz	delay_counter3
	bra	$-4
	return
    