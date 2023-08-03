;Gosub
;Gosub sets up a flow struct on the stack and then falls into Goto. The flow struct is KWID_GOSUB, preceded by the line number of the gosub statement, in turn preceded by prog ptr to just after the gosub statement.

Gosub:
        CALL    CheckEnoughVarSpace2
        DB	03h
        POP     BC
        PUSH    HL
        PUSH    HL
        LD      HL,(CURRENT_LINE)
        EX      (SP),HL
        LD      D,TK_GOSUB
        PUSH    DE
        INC     SP
;Push return address preserved in BC, and fall into GOTO.
GosubBC:  PUSH    BC

	; JMP Goto
