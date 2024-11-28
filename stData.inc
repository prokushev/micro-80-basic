;FindNextStatement
; Finds the end of the statement or the end of the program line.

; Rem is jumped to in two places - it is the REM handler, and also when an 
; IF statement's condition evals to false and the rest of the line needs
; to be skipped. Luckily in both these cases, C just happens to be
; loaded with a byte that cannot occur in the program so the null 
; byte marking the end of the line is found as expected.

Data:
FindNextStatement:
	DB	01H, ":"	;LD BC,..3AH эмулирует LD C, ":"
Rem:	LD	C, 0
	LD      B,00H
ExcludeQuote:
	LD      A,C
        LD      C,B
        LD      B,A
FindNextStatementLoop:
	LD      A,(HL)
        OR      A
        RET     Z

        CP      B
        RET     Z

        INC     HL
        CP      '"'
        JP      Z,ExcludeQuote
        JP      FindNextStatementLoop

