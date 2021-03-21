#include <xc.inc>
    
global	load_to_RAM
     
    
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable    
    
psect	pattern_table, class=CODE 
    
       
load_to_RAM: 	
	lfsr	0, PatternArray		    ; Load FSR0 with address in RAM	
	movlw	low highword(PatternTable)  ; address of data in PM
	movwf	TBLPTRU, A		    ; load upper bits to TBLPTRU
	movlw	high(PatternTable)	    ; address of data in PM
	movwf	TBLPTRH, A		    ; load high byte to TBLPTRH
	movlw	low(PatternTable)	    ; address of data in PM
	movwf	TBLPTRL, A		    ; load low byte to TBLPTRL
	movlw	myTable_l		    ; bytes to read
	movwf 	counter, A		    ; our counter register
    loop: 
	tblrd*+				    ; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0	    ; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		    ; count down to zero
	bra	loop			    ; keep going until finished
	return
	

psect	udata_bank4 ; reserve data anywhere in RAM (here in 0x400)
PatternArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
PatternTable:
	;	layer 1			layer 2			layer 3			layer 4
	
	; Cube frame pattern
	db	0b10011111, 0b10011111, 0b00001001, 0b00001001, 0b00001001, 0b00001001, 0b10011111, 0b10011111
	
	; Small frame pattern
	db	0b00000000, 0b00000000, 0b01100000, 0b01100000, 0b01100000, 0b01100000, 0b00000000, 0b00000000
	
	; Sideways sweep: 4x8 bytes to light up each row of columns at a time
	db	0b00001111, 0b00000000, 0b00001111, 0b00000000, 0b00001111, 0b00000000, 0b00001111, 0b00000000
	db	0b11110000, 0b00000000, 0b11110000, 0b00000000, 0b11110000, 0b00000000, 0b11110000, 0b00000000
	db	0b00000000, 0b11110000, 0b00000000, 0b11110000, 0b00000000, 0b11110000, 0b00000000, 0b11110000
	db	0b00000000, 0b00001111,	0b00000000, 0b00001111, 0b00000000, 0b00001111, 0b00000000, 0b00001111
	
	; Diagonal fill
	db	0b00000001, 0b00000000, 0b00000001, 0b00000000, 0b00000001, 0b00000000, 0b00000001, 0b00000000
	db	0b00010011, 0b00000000, 0b00010011, 0b00000000, 0b00010011, 0b00000000, 0b00010011, 0b00000000
	db	0b00110111, 0b00010000,	0b00110111, 0b00010000, 0b00110111, 0b00010000, 0b00110111, 0b00010000
	db	0b01111111, 0b00110001, 0b01111111, 0b00110001, 0b01111111, 0b00110001, 0b01111111, 0b00110001
	db	0b11111111, 0b01110011, 0b11111111, 0b01110011, 0b11111111, 0b01110011, 0b11111111, 0b01110011
	db	0b11111111, 0b11110111, 0b11111111, 0b11110111, 0b11111111, 0b11110111, 0b11111111, 0b11110111
	db	0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111
	; Diagonal empty from other direction
	db	0b11111110, 0b11111111, 0b11111110, 0b11111111, 0b11111110, 0b11111111, 0b11111110, 0b11111111
	db	0b11101100, 0b11111111, 0b11101100, 0b11111111, 0b11101100, 0b11111111, 0b11101100, 0b11111111
	db	0b11001000, 0b11101111, 0b11001000, 0b11101111, 0b11001000, 0b11101111, 0b11001000, 0b11101111
	db	0b10000000, 0b11001110, 0b10000000, 0b11001110, 0b10000000, 0b11001110, 0b10000000, 0b11001110
	db	0b00000000, 0b10001100,	0b00000000, 0b10001100, 0b00000000, 0b10001100, 0b00000000, 0b10001100
	db	0b00000000, 0b00001000, 0b00000000, 0b00001000, 0b00000000, 0b00001000, 0b00000000, 0b00001000

	myTable_l   EQU	152	; length of data
	align	2