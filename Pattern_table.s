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
PatternArray:    ds 0x100 ; reserve 256 bytes for message data
    
psect	udata_bank5 ; reserve data anywhere in RAM (here in 0x500)
PatternArray2:    ds 0x100 ; reserve 256 bytes for message data
   
   

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
	
	; Cross
	db	0b00001111, 0b00001111, 0b11110000, 0b11110000, 0b11110000, 0b11110000, 0b00001111, 0b00001111
	
	; Part-filled
	db	0b01111111, 0b00110001, 0b00110111, 0b00010000, 0b00010011, 0b00000000, 0b00000001, 0b00000000
	
	; Random noise
	db	0b00110010, 0b01011000, 0b01101001, 0b01100001, 0b10110010, 0b00010001, 0b10100010, 0b01100110
	db	0b10010010, 0b11100101, 0b00101011, 0b10100010, 0b11001010, 0b01001001, 0b11001001, 0b11010101
	db	0b01101010, 0b11001001, 0b01101001, 0b10101000, 0b11000101, 0b10010101, 0b10010101, 0b10001010
	db	0b01010101, 0b01011010, 0b01010100, 0b10101010, 0b11010110, 0b00101100, 0b10101010, 0b10100010

	; Three cubes
	db	0b00110011, 0b00000000, 0b00110011, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000
	db	0b01010111, 0b01110000, 0b00000101, 0b01010000, 0b01010111, 0b01110000, 0b00000000, 0b00000000
	
	; Rain
	db	0b00100000, 0b00000010, 0b10000000, 0b00000010, 0b00010000, 0b00000000, 0b00010010, 0b00100000
	db	0b10000000, 0b00000010, 0b00010000, 0b00000000, 0b00010010, 0b00100000, 0b00000000, 0b00000100
	db	0b00010000, 0b00000000, 0b00010010, 0b00100000, 0b00000000, 0b00000100, 0b00100000, 0b00000010
	db	0b00010010, 0b00100000, 0b00000000, 0b00000100, 0b00100000, 0b00000010, 0b00000000, 0b00100000
	db	0b00000000, 0b00000100, 0b00100000, 0b00000010,	0b00000000, 0b00100000, 0b00000000, 0b00000000
	db	0b00100000, 0b00000010, 0b00000000, 0b00100000, 0b00000000, 0b00000000, 0b10000000, 0b10000000
	db	0b00000000, 0b00100000, 0b00000000, 0b00000000, 0b10000000, 0b10000000, 0b00000001, 0b00000000
	db	0b00000000, 0b00000000, 0b10000000, 0b10000000, 0b00000001, 0b00000000, 0b00000000, 0b00010000
	
	myTable_l   EQU	280	; length of data
	align	2