;Goto
;Sets program execution to continue from the line number argument.

;Get line number argument in DE and return NZ indicating syntax error if the argument was a non-number .

Goto:
	CALL    LineNumberFromStr
Goto2:
        CALL    Rem
        PUSH    HL
        LD      HL,(CURRENT_LINE)
        RST     CompareHLDE
        POP     HL
        INC     HL
        CALL    C,FindProgramLineInMem
        CALL    NC,FindProgramLine
        LD      H,B
        LD      L,C
        DEC     HL
        RET     C

UnknownStringError:
        LD      E,ERR_US
        JP      Error

