
;Abs
;FACCUM = |FACCUM|.
;
;Return if FACCUM is already positive, otherwise fall into FNegate to make it positive.
Abs:
        RST     FTestSign
        RET     P

FNegate:
		LD      HL,FACCUM+2	;024FH
        LD      A,(HL)
        XOR     80H
        LD      (HL),A
        RET
