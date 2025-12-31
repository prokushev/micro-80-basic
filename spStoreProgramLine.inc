; StoreProgramLine
; Here's where a program line has been typed, which we now need to store in program memory.

StoreProgramLine:
        PUSH    DE
        PUSH    BC
        RST     NextChar
        PUSH    AF
        CALL    FindProgramLine			; Ищем строку в программе
        PUSH    BC
        JP      NC,InsertProgramLine	; Если не нашли, то вставляем строку
	JP	RemoveProgramLine
