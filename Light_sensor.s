#include <xc.inc>
    

global	Light_sensor_setup, light_sensor_get_data, delay3
    
psect	udata_acs   ; reserve data space in access ram
sensor_low:    ds 1    ; reserve one byte for low byte of counter measurement
sensor_high:    ds 1    ; reserve one byte for high byte of counter measurement
    
    
psect	Light_sensor, class = CODE

Light_sensor_setup:
	movlw	0b00000000
	movwf	TRISC, A	    ; clear SPI port (except for MISO pin)
	clrf	TRISE, A	    ; clear chip select port
	bcf	SSP1STAT,7,A	    ; sample data at end of output time
	bsf	SSP1CON1,5,A	    ; enable SPI on port C
	bsf	SSP1CON1,1,A	    ; set clock speed
	bsf	RE0		    ; set CS high
	; note the clock speed is Fosc/64 (0010) and is set by SSP1CON1<3:0>
	return
    
light_sensor_get_data:	
	bcf	RE0		    ; begin transmission with CS
	movlw	0b10011001	    
	movwf	SSP1BUF, A	    ; begin recieve
wait_high:
	btfss	SSP1STAT, 0,A	    ; check whether recieve complete
	bra	wait_high
	movff	SSP1BUF,PORTD;sensor_high	    ; save high byte
	bcf	SSP1STAT, 0,A	    ; reset transmission flag
	movlw	0b10011001
	movwf	SSP1BUF, A	    ; begin recieve
wait_low:
	btfss	SSP1STAT, 0,A	    ; check whether recieve complete
	bra	wait_low

	movff	SSP1BUF,PORTE; sensor_low	    ; save low byte (actually low nibble twice back to back)
	bcf	SSP1STAT, 0,A	    ; reset transmission flag
	bsf	RE0		    ; end transmission

	;return			    revove for main program, insert for testing only

light_level_test:
	movlw	0b00001000	    ; high byte comparison (max light level)
	cpfslt	sensor_high	    ; loops and gets new data is light level too high
	bra	light_sensor_get_data
	return			    ; if light level low enough, go back to main
	

 delay1:
	movlw   0xFF		    ; Put value 0x10 into W
	movwf   0x20, A		    ; Move value in W to file register address 0x20
	decfsz  0x20, F, A	    ; Decrement value in 0x20. If 0, skip next line
	bra	$-2
	return
	
delay2:
	movlw	0xFF		    ; Put the value 0x20 into W
	movwf	0x30, A		    ; Move value in W to file register address 0x30
	call	delay1		    ; Call counter delay1
	decfsz	0x30,F,A	    ; Decrement value in 0x30. If 0, skip next line
	bra	$-6
	return
	
delay3:
	movlw	0x50
	movwf	0x40, A
	call	delay2
	decfsz	0x40, F, A
	bra	$-6
	return


