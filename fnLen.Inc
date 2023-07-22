Len:
        LD      BC,ByteFromAToFACCUM
        PUSH    BC
GetStringLength:
	CALL    EvalString
        XOR     A
        LD      D,A
        LD      (VALTYP),A
        LD      A,(HL)
        OR      A
        RET     
