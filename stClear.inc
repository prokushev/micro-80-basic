Clear:
        JP      Z,ClearAll
        CALL    EvalPisitiveNumericExpression
        DEC     HL
        RST     NextChar
        RET     NZ

        PUSH    HL
        LD      HL,(MEMSIZ)
        LD      A,L
        SUB     E
        LD      E,A
        LD      A,H
        SBC     A,D
        LD      D,A
        JP      C,SyntaxError
        LD      HL,(VAR_BASE)
        LD      BC,0028H
        ADD     HL,BC
        RST     CompareHLDE
        JP      NC,OutOfMemory
        EX      DE,HL
        LD      (STACK_TOP),HL
        POP     HL
        JP      ClearAll
