; Обработчик команды Restore
; Сбрасываем указатель данных на адрес перед началом программы.

	IF	MICRON
Restore:
	JP      Z,Restore0
        CALL    LineNumberFromStr
        RET     NZ
        PUSH    HL
        CALL    Goto2
        POP     DE
        JP      SetDataPtr

Restore0:
	EX      DE,HL
        LD      HL,(PROGRAM_BASE)
        DEC     HL
SetDataPtr:
	LD      (DATA_PROG_PTR),HL
        EX      DE,HL
        RET
	ELSE
Restore:
	EX      DE,HL
        LD      HL,(PROGRAM_BASE)
	IF	BASICNEW
	JP	Z, Restore0		; Номер строки не задан
	EX	DE,HL
	CALL	LineNumberFromStr
	PUSH	HL
	CALL	FindProgramLine
	LD	H, B
	LD	L, C
	POP	DE
	JP	NC, UnknownStringError
Restore0:
	ENDIF
        DEC     HL
SetDataPtr:
	LD      (DATA_PROG_PTR),HL
        EX      DE,HL
        RET     
	ENDIF