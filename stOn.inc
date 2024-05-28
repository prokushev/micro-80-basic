; Обработчик ON x GOTO/ON x GOSUB
On:
        CALL    EvalByteExpression
        LD      A,(HL)
        LD      B,A
        CP      TK_GOSUB
        JP      Z,OkToken
        RST     SyntaxCheck
        DB		TK_GOTO
        DEC     HL
OkToken:
		LD      C,E
OnLoop:
		DEC     C
        LD      A,B
        JP      Z, ExecA
        CALL    LineNumberFromStr2
        CP      ','
        RET     NZ

        JP      OnLoop
