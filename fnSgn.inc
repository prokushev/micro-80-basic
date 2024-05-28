;Sgn
;Returns an integer that indicates FACCUM's sign. We do this by a simple call to FTestSign which gets the answer in A, then fall into FCharToFloat to get that answer back into FACCUM.
;
;Get FACCUM's sign in A. A will be 0x01 for positive, 0 for zero, and 0xFF for negative.

Sgn:	RST     FTestSign

;FCharToFloat
;Converts the signed byte in A to a floating-point number in FACCUM..

FCharToFloat:
		LD      B,88H
        LD      DE,0000H
ReturnInteger:
		LD      HL,FACCUM+3
        LD      C,A
        LD      (HL),B
        LD      B,00H
        INC     HL
        LD      (HL),80H
        RLA     
        JP      FNormalise
