;1.12 Assigning Variables
;Let
;Assigns a value to a variable.

Let:	CALL    GetVar
        RST     SyntaxCheck
        DB		TK_EQ			; '='
        LD      A,(VALTYP)
        PUSH    AF
        PUSH    DE
        CALL    EvalExpression
        EX      (SP),HL
        LD      (PROG_PTR_TEMP),HL
        POP     DE
        POP     AF
        PUSH    DE
        RRA     
        CALL    CheckType
        JP      Z,CopyNumeric
L072B:  PUSH    HL
        LD      HL,(FACCUM)
        PUSH    HL
        INC     HL
        INC     HL
        RST     PushNextWord
        POP     DE
        LD      HL,(STACK_TOP)
        RST     CompareHLDE
        POP     DE
        JP      NC,Let1
        LD      HL,(VAR_BASE)
        RST     CompareHLDE
        LD      L,E
        LD      H,D
        CALL    C,L0D2F
Let1:	LD      A,(DE)
        PUSH    AF
        XOR     A
        LD      (DE),A
        CALL    L0EC5
        POP     AF
        LD      (HL),A
        EX      DE,HL
        POP     HL
        CALL    L131C
        POP     HL
        RET     

CopyNumeric:
	PUSH    HL
        CALL    FCopyToMem
        POP     DE
        POP     HL
        RET     
