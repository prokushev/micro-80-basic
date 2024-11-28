Tan:
		CALL    FPush
        CALL    Sin
        POP     BC
        POP     HL
        CALL    FPush
        EX      DE,HL
        CALL    FLoadFromBCDE
        CALL    Cos
        JP      FDiv
