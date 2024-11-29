;2.6 Moving FACCUM about
;A group of functions for loading, copying, and pushing FACCUM.

FPush:
		EX      DE,HL
        LD      HL,(FACCUM)
        EX      (SP),HL
        PUSH    HL
        LD      HL,(FACCUM+2)
        EX      (SP),HL
        PUSH    HL
        EX      DE,HL
        RET
