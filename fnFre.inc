Fre:
        LD      HL,(VAR_TOP)
        EX      DE,HL
        LD      HL,0000H
        ADD     HL,SP
        LD      A,(VALTYP)
        OR      A
        JP      Z,FreNumeric
        CALL    EvalCurrentString
        CALL    GarbageCollection
        LD      HL,(STACK_TOP)
        EX      DE,HL
        LD      HL,(STR_TOP)
FreNumeric:
	LD      A,L
        SUB     E
        LD      C,A
        LD      A,H
        SBC     A,D
WordFromACToFACCUM:
	LD      B,C
WordFromABToFACCUM:
	LD      D,B
        LD      E,00H
        LD      HL,VALTYP
        LD      (HL),E
        LD      B,80H+16        ; 16 bit integer
        JP      ReturnInteger
