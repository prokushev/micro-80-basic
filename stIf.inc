;1.13 IF Keyword Handler
;If
;Evaluates a condition. A condition has three mandatory parts : a left-hand side expression, a comparison operator, and a right-hand side expression. Examples are 'A=2', 'B<=4' and so on.

;The comparison operator is one or more of the three operators '>', '=', and '<'. Since these three operators can appear more than once, and in any order, the code does something rather clever to convert them to a single 'comparison operator value'. This value has bit 0 set if '>' is present, bit 1 for '=', and bit 2 for '<'. Thus the comparison operators '<=' and '=<' are both 6, likewise '>=' and '=>' are both 3, and '<>' is 5

;You can therefore get away with stupid operators such as '>>>>>' (value 1, the same as a single '>') and '>=<' (value 7), the latter being particularly dense as it causes the condition to always evaluate to true.

If:
        CALL    EvalExpression
        LD      A,(HL)
        CP      TK_GOTO			; !!Добавить IF x GOSUB
        JP      Z, NoThen
        RST     SyntaxCheck
        DB	TK_THEN
        DEC     HL
NoThen:
	RST     FTestSign
        JP      Z,Rem

;Condition evaluated to True. Here we get the first character of the THEN statement,
; and if it's a digit then we jump to GOTO's handler as it's an implicit GOTO. 
;Otherwise we jump to near the top of Exec to run the THEN statement.
	
        RST     NextChar
        JP      C,Goto			; Если число, то это GOTO
        JP      ExecANotZero		; Если конец строки, то возврат, иначе исполняем команду
