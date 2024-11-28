;
;FTestSign (RST 5)
;Tests the state of FACCUM. This part returns with A=0 and zero set if FACCUM==0, the tail of the function sets the sign flag and A accordingly (0xFF is negative, 0x01 if positive) before returning.

FTestSign:
	LD	A,(FACCUM+3)
	OR	A
	JP	NZ,FTestSign_tail
	RET  
