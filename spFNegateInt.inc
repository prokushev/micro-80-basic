;FNegateInt
;Negate the 32-bit integer in CDEB by subtracting it from zero. Also flips the sign in FTEMP. Used by FAsInteger and FAdd.

FNegateInt:
	LD      HL,FTEMP
        LD      A,(HL)
        CPL
        LD      (HL),A
        XOR     A
        LD      L,A
        SUB     B
        LD      B,A
        LD      A,L
        SBC     A,E
        LD      E,A
        LD      A,L
        SBC     A,D
        LD      D,A
        LD      A,L
        SBC     A,C
        LD      C,A
        RET

