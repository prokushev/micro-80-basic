
End:	RET     NZ		; Syntax Error if args
	LD      (PROG_PTR_TEMP),HL	; Сохраняем адрес останова во временную переменную
	JP	InputBreak
