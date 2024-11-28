; CompareHLDE (RST 4)
; Сравниает HL и DE с таким же логическим результатом (флаги C и Z), что и стандартное 8-мибитное сравнение.

CompareHLDE:
	LD	A,H
	SUB	D
	RET	NZ
	LD	A,L
	SUB	E
	RET
