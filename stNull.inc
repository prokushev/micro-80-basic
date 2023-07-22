; Реализация команды NULL,
; которая определяла, сколько нулей выводить после конца строки.

Null:
	IF	BASICNEW
	RET				; К следующей команде
	ELSE
	CALL    EvalByteExpression	; Парсим байт
        RET     NZ			; Общибка, если не байт

        INC     A
        CP      48H			; Проверяем максимум
        JP      NC,FunctionCallError
        LD      (NULLS),A		; Сохраняем, сколько выводить нулей
        RET				; К следующей команде
	ENDIF
