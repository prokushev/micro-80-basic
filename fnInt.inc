;Int
;Removes the fractional part of FACCUM.

;If FACCUM's exponent is >= 2^24, then it's too big to hold any fractional part - it is already an integer, so we just return.

Int:
		LD      HL,FACCUM+3
        LD      A,(HL)
        CP      98H
        LD      A,(FACCUM)
        RET     NC

        LD      A,(HL)
        CALL    FAsInteger
        LD      (HL),98H
        LD      A,E
        PUSH    AF
        LD      A,C
        RLA
        CALL    FNormalise
        POP     AF
        RET
