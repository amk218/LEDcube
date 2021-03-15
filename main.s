#include <xc.inc>

extrn	DAC_Setup, DAC_Int_Hi, single_layer_test, Load_to_RAM

psect	code, abs

	org	0x0000
	goto	setup
	
psect	code, abs
setup:			    ; Set ports D-F as outputs and clear them
	clrf	TRISD
	clrf	LATD
	clrf	TRISF
	clrf	LATF
	clrf	TRISE
	clrf	LATE
	call	Load_to_RAM
	call	Interupt_setup
    Load_initial_config:
	; FSR1, FSR2 = 0x400
	; set pattern counter to 0

	
	
start:
	call	single_layer_test
	
	

	end	start
