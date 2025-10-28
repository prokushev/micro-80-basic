;FUnpackMantissas
;Unpacks the mantissas of FACCUM and BCDE. This is simple enough - we just restore the missing most-significant bit, invariably a 1 (see tech note). Unfortunately, doing this loses the sign bits of both packed numbers.
;
;To compensate for this, a combination of both signs is returned. Duing the function FACC's sign is negated and later xor'ed with BCDE's sign, and returned in bit 7 of A. The effect of this is when the function returns, A is +ve if the signs mismatched, o
;r -ve if the signs matched.
;
;FACC	Negated
;FACC	BCDE	Result
;after XOR
;+	-	+	-
;+	-	-	+
;-	+	+	+
;-	+	-	-


FUnpackMantissas:
		LD      HL,FACCUM+2
        LD      A,(HL)
        RLCA
        SCF
        RRA
        LD      (HL),A
        CCF
        RRA
        INC     HL
        INC     HL
        LD      (HL),A
        LD      A,C
        RLCA
        SCF
        RRA
        LD      C,A
        RRA
        XOR     (HL)
        RET
