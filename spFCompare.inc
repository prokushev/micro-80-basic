;FCompare
;Compares FACCUM to BCDE, with the result being returned in A as follows :

;FACCUM > BCDE, A = 0x01.
;FACCUM < BCDE, A = 0xFF.
;FACCUM = BCDE, A = 0.

;If BCDE is zero, then we don't need to compare and can just return via FTestSign.
FCompare:
		LD      A,B
        OR      A
        JP      Z, FTestSign
        LD      HL,InvSignToInt
        PUSH    HL
        RST     FTestSign
        LD      A,C
        RET     Z

        LD      HL,FACCUM+2
        XOR     (HL)
        LD      A,C
        RET     M

        CALL    FIsEqual
        RRA
        XOR     C
        RET

;Test for equality between BCDE and FACCUM.
FIsEqual:
		INC     HL
        LD      A,B
        CP      (HL)
        RET     NZ

        DEC     HL
        LD      A,C
        CP      (HL)
        RET     NZ

        DEC     HL
        LD      A,D
        CP      (HL)
        RET     NZ

        DEC     HL
        LD      A,E
        SUB     (HL)
        RET     NZ

        POP     HL
        POP     HL
        RET
