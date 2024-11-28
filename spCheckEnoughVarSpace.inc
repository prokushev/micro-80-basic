; CheckEnoughVarSpace2
; То же, что и ниже, но C берется из следующей ячейки, откуда вызвана подпрограмма.
; Более эффективно, чем в Altair Basic
CheckEnoughVarSpace2:
		EX      (SP),HL
        LD      C,(HL)
        INC     HL
        EX      (SP),HL

; CheckEnoughVarSpace
; Checks that there is enough room for C*4 bytes on top of (VAR_TOP) before it 
; intrudes on the stack. Probably varspace.

CheckEnoughVarSpace:
		PUSH    HL
        LD      HL,(VAR_TOP)
        LD      B,00H			;BC=C*4
        ADD     HL,BC
        ADD     HL,BC
        CALL    CheckEnoughMem
POPHL_RET:
        POP     HL
        RET     
