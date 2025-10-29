; SyntaxCheck (RST 1)
; Here is a truly beautiful piece of code, it's Golden Weasel richly deserved. It's used at run-time to check syntax in a very cool way : the byte 
; immediately following an RST 1 instruction is not the following instruction, but the keyword or operator ID that's expected to appear in the program 
; at that point. If the keyword or operator is not present, then it Syntax Errors out, but if it is present then the return address is fixed-up - ie 
; advanced one byte - and the function falls into NextChar so the caller has even less work to do. I honestly doubt syntax checks could be done more 
; efficiently than this. Sheer bloody genius.

SyntaxCheck:
	LD	A,(HL)
	EX	(SP),HL
	CP	(HL)
	INC	HL
	EX	(SP),HL
	JP	NZ,SyntaxError

;	JP	NextChar
