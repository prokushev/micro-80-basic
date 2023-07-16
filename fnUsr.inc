Usr:
        RST     FTestSign
        CALL    FTestIntegerExpression
        EX      DE,HL
        CALL    CallHL
	JP	ByteFromAToFACCUM
