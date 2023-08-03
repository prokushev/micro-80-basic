; New
; Команда NEW. Записывает нулевой номер строки в конец области программ (т.е. пустая программа),
; обновляет указатель на область переменных и переходит в ResetAll.

New:
; Команд не поддерживает аргументов.
	RET     NZ

New2:
; Записывает два нулевых байта как признак окончание программы в начало области программы.
	LD      HL,(PROGRAM_BASE)
        XOR     A
        LD      (HL),A
        INC     HL
        LD      (HL),A
        INC     HL
; И устанавливаем область переменных сразу за концом программы.
        LD      (VAR_BASE),HL

; ResetAll
; Очищает все.
		
ResetAll:
; Set PROG_PTR_TEMP to just before the start of the program.
	LD      HL,(PROGRAM_BASE)
        DEC     HL
ClearAll:
	LD      (PROG_PTR_TEMP),HL
        LD      HL,(MEMSIZ)
        LD      (STR_TOP),HL
;Reset the data pointer
        CALL    Restore
;Reset variable pointers
        LD      HL,(VAR_BASE)
        LD      (VAR_ARRAY_BASE),HL
        LD      (VAR_TOP),HL
;Get return address in BC and reset the stack pointer to it's top. 
ResetStack:
	POP     BC
        LD      HL,(STACK_TOP)
        LD      SP,HL

        LD      HL,TMPST	;021FH
        LD      (TEMPPT),HL	;021DH

        LD      HL,0000H
        PUSH    HL

        LD      (OLD_TEXT),HL

        LD      HL,(PROG_PTR_TEMP)
        XOR     A
        LD      (NO_ARRAY),A
        PUSH    BC
        RET     
