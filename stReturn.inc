; Return
; Returns program execution to the statement following the last GOSUB. Information about where to return to is kept on the stack in a flow struct (see notes).

Return:
        RET     NZ		;No arguments allowed.
        LD      D,0FFH
        CALL    GetFlowPtr
        LD      SP,HL
        CP      TK_GOSUB
        LD      E,ERR_RG
        JP      NZ,Error
        POP     HL
        LD      (CURRENT_LINE),HL
        LD      HL,ExecNext
        EX      (SP),HL

;Safe to fall into FindNextStatement, since we're already at the end of the line!...

	;JP FindNextStatement
