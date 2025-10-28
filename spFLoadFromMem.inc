;FLoadFromMem
;FLoadFromMem loads FACCUM with the fp number pointed to by HL. It does this by calling a function to load BCDE with the in-memory number, then falls into FLoadFromBCDE.

FLoadFromMem:
		CALL    FLoadBCDEfromMem

;FLoadFromBCDE
;Loads FACCUM with BCDE.
FLoadFromBCDE:
		EX      DE,HL
        LD      (FACCUM),HL
        LD      H,B
        LD      L,C
        LD      (FACCUM+2),HL
        EX      DE,HL
        RET
