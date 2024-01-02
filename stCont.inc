Cont:	
	RET     NZ			; Ощибка, если есть аргументы
	LD      E,ERR_CN		; Подготавливаем номер ошибки
	LD      HL,(OLD_TEXT)		; Восстанавливаем адрес останова
	LD      A,H
	OR      L
	JP      Z,Error			; Если он нулевой, то ошибка
	EX      DE,HL
	LD      HL,(OLD_LINE)		; Восстанавливаем номер строки
	LD      (CURRENT_LINE),HL
	EX      DE,HL			; HL=Адрес, DE=Строка
	RET				; Продолжаем выполнение со места останова

