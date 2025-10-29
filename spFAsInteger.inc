;
;FAsInteger
;Returns the integer part of FACCUM in CDE.
;
;Return with BCDE=0 if A=0.
FAsInteger:
		LD      B,A
        LD      C,A
        LD      D,A
        LD      E,A
        OR      A
        RET     Z

        PUSH    HL
        CALL    FCopyToBCDE
        CALL    FUnpackMantissas
        XOR     (HL)
        LD      H,A
        CALL    M,FMantissaDec
        LD      A,98H
        SUB     B
        CALL    FMantissaRtMult
        LD      A,H
        RLA
        CALL    C,FMantissaInc
        LD      B,00H
        CALL    C,FNegateInt
        POP     HL
        RET
