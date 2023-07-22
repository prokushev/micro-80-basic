;STOP / END
;
; Команды STOP и END синонемы
; Но по STOP мы запоминаем адрес останова для последующего
; восстановления по CONT
; We don't need to do anything other than lose the return address and fall into Main.

Stop:
	RET	NZ		; Syntax Error if args
	DB	0F6H            ; Устанавливаем флаг "STOP" и пропускаем RET NZ ; OR 0C0H

	; OR 0C0H
	; JMP End+1
