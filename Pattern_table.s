#include <xc.inc>
    
global	load_to_RAM
    
    
    
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable    
    
psect	pattern_table, class=CODE 
    
       
load_to_RAM: 	
	lfsr	0, PatternArray		; Load FSR0 with address in RAM	
	movlw	low highword(PatternTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(PatternTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(PatternTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished
	return
	

psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
PatternArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
PatternTable:
	db	0b11111111, 0b11111111, 0b00000000, 0b00000000, 0b11111111, 0b11111111, 0b00000000, 0b00000000
					; random values I have entered to test with
					; 2 bytes to output x 4 layers = 8 bytes
	db	0b00000000, 0b00000000, 0b11111111, 0b11111111, 0b00000000, 0b00000000, 0b11111111, 0b11111111
	myTable_l   EQU	16	; length of data
	align	2