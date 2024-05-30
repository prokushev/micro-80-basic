; FindProgramLine
; Given a line number in DE, this function returns the address of that progam line in BC.
; If the line doesn't exist, then BC points to the next line's address, ie where the 
; line could be inserted. Carry flag is set if the line exists, otherwise carry reset.

FindProgramLine:
		LD      HL,(PROGRAM_BASE)
FindProgramLineInMem:
		LD      B,H
        LD      C,L
        LD      A,(HL)
        INC     HL
        OR      (HL)
        DEC     HL
        RET     Z

        PUSH    BC
        RST     PushNextWord
        RST     PushNextWord
        POP     HL
        RST     CompareHLDE
        POP     HL
        POP     BC
        CCF     
        RET     Z

        CCF     
        RET     NC

        JP      FindProgramLineInMem
