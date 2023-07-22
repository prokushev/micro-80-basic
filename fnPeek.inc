Peek:	
        RST     FTestSign
        CALL    FTestIntegerExpression
        LD      A,(DE)
        JP      ByteFromAToFACCUM
