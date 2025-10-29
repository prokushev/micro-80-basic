;1.8 FOR Handler
;For
;Although FOR indicates the beginning of a program loop, the handler only gets 
;called the once. Subsequent iterations of the loop return to the following
;statement or program line, not the FOR statement itself.
For:		
        LD      A,64H
        LD      (NO_ARRAY),A
; First we call LET to assign the initial value to the variable. On return, HL points to the next bit of program (the TO clause with any luck)
        CALL    Let
;Stick program ptr onto stack. We lose the return address, since we don't need it as this function conveniently falls into ExecNext by itself.
        EX      (SP),HL
        CALL    GetFlowPtr
;Get program ptr into DE.
        POP     DE
        JP      NZ,L0547
        ADD     HL,BC
        LD      SP,HL
;HL=prog ptr, DE=stack. Here we check we've at least 8*4 bytes of space to use for the flow struct.
L0547:  EX      DE,HL
        CALL    CheckEnoughVarSpace2
        DB	08H
;Get pointer to end of statement (or end of program line) onto stack. This is the prog ptr that NEXT will return to.
        PUSH    HL
        CALL    FindNextStatement
        EX      (SP),HL
;Push current line number onto stack.
        PUSH    HL
        LD      HL,(CURRENT_LINE)
        EX      (SP),HL
        CALL    IsNumeric		; Is Numeric
;Syntax check that TO clause is next.
        RST     SyntaxCheck
        DB	TK_TO
;Evaluate expression following 'TO', and push the result of that expression (a floating point number of course) on the stack
        CALL    EvalNumericExpression		; Eval numeric expression
        PUSH    HL
        CALL    FCopyToBCDE
        POP     HL
        PUSH    BC
        PUSH    DE
;Initialise the STEP value in BCDE to 1.
        LD      BC,8100H
        LD      D,C
        LD      E,D
;If a STEP clause has not been given, skip ahead with the direction byte (in A) as 0x01.
        LD      A,(HL)
        CP      TK_STEP
        LD      A,01H
        JP      NZ,PushStepValue
;STEP clause has been given so we evaluate it and get it into BCDE. The sign of this value becomes the direction byte (0x01 for fowards, 0xFF for backwards).
        RST     NextChar
        CALL    EvalNumericExpression		; Eval numeric expression
        PUSH    HL
        CALL    FCopyToBCDE
        POP     HL
        RST     FTestSign
;Initialise the STEP value in BCDE to 1.
PushStepValue:
	PUSH    BC
        PUSH    DE
;Push A onto stack. (A=1 if no step clause, else ???)
        PUSH    AF
        INC     SP
        
;Push the prog ptr to the end of the FOR statement (kept on PROG_PTR_TEMP) on the stack.
	PUSH    HL
	
	
        LD      HL,(PROG_PTR_TEMP)
        EX      (SP),HL
;Push TK_FOR onto the stack, and fall into ExecNext
EndOfForHandler:
	LD      B,TK_FOR
        PUSH    BC
        INC     SP

	JP	ExecNext
