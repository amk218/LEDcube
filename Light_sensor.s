#include <xc.inc>
; This file contains all routines for setting up communications with the light sensor
; and taking light level data to determine if it is dark enough to switch on the cube
    
; ********** External and global modules **********
    
global	light_sensor_setup, get_light_sensor_data

; ********** Variables ********** 
psect	udata_acs   ; reserve data space in access ram
	
sensor_low:    ds 1 ; reserve one byte for low byte of counter measurement
sensor_high:   ds 1 ; reserve one byte for high byte of counter measurement
    
; ********** Setup routine **********    
psect	Light_sensor, class = CODE

light_sensor_setup:
	movlw	0b00010000
	movwf	TRISC, A	; Configure SPI ports as outputs (except for MISO pin)
	clrf	TRISE, A	; Configure chip select (CS) as an output
	bcf	SSP1STAT,7,A	; Sample data at end of output time
	bsf	SSP1CON1,5,A	; Enable SPI on port C
	bsf	SSP1CON1,1,A	; Set clock speed
	bsf	RE0		; Set chip select high
	; the clock speed is Fosc/64 (0010) and is set by SSP1CON1<3:0>
	return

	
; ********** Light sensor code **********
	
clear_pattern:			; Clear cube LEDs if light level gets too high
	clrf	LATD
	clrf	LATJ
    
get_light_sensor_data:	
	bcf	RE0		; Begin transmission with CS
	movlw	0b10011001	    
	movwf	SSP1BUF, A	; Begin receive
    wait_high:
	btfss	SSP1STAT, 0,A	; Check whether receive complete
	bra	wait_high
	movff	SSP1BUF, sensor_high	; Save high byte to variable
	bcf	SSP1STAT, 0,A	; Reset transmission flag
	movlw	0b10011001
	movwf	SSP1BUF, A	; Begin receive
    wait_low:
	btfss	SSP1STAT, 0,A	; Check whether recieve complete
	bra	wait_low

	movff	SSP1BUF, sensor_low	; Save low byte (actually low nibble twice back to back)
	bcf	SSP1STAT, 0,A	; Reset transmission flag
	bsf	RE0		; End transmission

light_level_test:
	movlw	0b00000011	; Compare high byte to this number
	cpfslt	sensor_high	; Loops and get new data is light level too high
	bra	clear_pattern	; Clear cube LEDs if light level gets too high
	
	return			; If light level low enough, go back to main program

