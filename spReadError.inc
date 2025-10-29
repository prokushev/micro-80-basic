ReadError:
	CALL    Data
        OR      A
        JP      NZ,ReadError1
        INC     HL
        RST     PushNextWord
        LD      A,C
        OR      B
        LD      E,ERR_OD
        JP      Z,Error
        POP     BC
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        EX      DE,HL
        LD      (DATA_LINE),HL
        EX      DE,HL
ReadError1:
	RST     NextChar
        CP      TK_DATA
        JP      NZ,ReadError
        JP      GotDataItem

