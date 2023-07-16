Asc:
        CALL    GetStringLength
        JP      Z,FunctionCallError
        INC     HL
        INC     HL
        RST     PushNextWord
        POP     HL
        LD      A,(HL)
        JP      ByteFromAToFACCUM
