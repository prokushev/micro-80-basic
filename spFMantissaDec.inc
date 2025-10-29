FMantissaDec:
		DEC     DE
        LD      A,D
        AND     E
        INC     A
        RET     NZ

        DEC     C
        RET

