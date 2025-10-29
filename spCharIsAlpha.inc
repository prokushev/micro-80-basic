;
;CharIsAlpha
;If character pointed to by HL is alphabetic, the carry flag is reset otherwise set.
;
CharIsAlpha:
		LD      A,(HL)
        CP      'A'
        RET     C
        CP      'Z'+1
        CCF
        RET
