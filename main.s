#include <xc.inc>

extrn	DAC_Setup, DAC_Int_Hi, single_layer_test

psect	code, abs
	
setup:			    ; Set ports D-F as outputs and clear them
	clrf	TRISD
	clrf	LATD
	clrf	TRISF
	clrf	LATF
	clrf	TRISE
	clrf	LATE

start:
	call	single_layer_test
    

	end	start
