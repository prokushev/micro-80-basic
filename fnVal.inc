Val:
        CALL    GetStringLength
        JP      Z,FZero
        LD      E,A
        INC     HL
        INC     HL
        RST     PushNextWord
        LD      H,B
        LD      L,C
        ADD     HL,DE
        LD      B,(HL)
        LD      (HL),D
        EX      (SP),HL
        PUSH    BC
        LD      A,(HL)
        CALL    FIn
        POP     BC
        POP     HL
        LD      (HL),B
        RET     
