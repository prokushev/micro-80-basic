Pos:
        LD      A,(TERMINAL_X)

; Преобразует байт из A в число с плавающей точкой в FACCUM
ByteFromAToFACCUM:
	LD      B,A
        XOR     A
        JP      WordFromABToFACCUM
