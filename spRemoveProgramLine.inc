; Carry was set by the call to FindProgramLine, meaning that the line already exists.
; So we have to remove the old program line before inserting the new one in it's place.
; To remove the program line we simply move the remainder of the program 
;(ie every line that comes after it) down in memory.

RemoveProgramLine:
        EX      DE,HL
        LD      HL,(VAR_BASE)
RemoveProgramLineLoop:
		LD      A,(DE)
        LD      (BC),A
        INC     BC
        INC     DE
        RST     CompareHLDE
        JP      NC, RemoveProgramLineLoop
        LD      H,B
        LD      L,C
        INC     HL
        LD      (VAR_BASE),HL
	JP	InsertProgramLine
