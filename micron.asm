; ═════════════════════════════════════════════════════════════════════════════════
;  БЕЙСИК-МИКРОН для РАДИО-86РК
; ═════════════════════════════════════════════════════════════════════════════════
;
; Это дизассемблер Бейсика-Микрон для "Радио-86РК".
; Имена меток взяты с дизассемблера Altair BASIC 3.2 (4K)

	CPU	8080
	Z80SYNTAX	EXCLUSIVE

        ORG     0000h

DATA_STM	EQU	211Ah
LINE_BUFFER	EQU	2090h
CURRENT_LINE	EQU	213Bh
PROG_PTR_TEMP	EQU	2137h
VALTYP		EQU	2119h
PROGRAM_BASE	EQU	2143h
VAR_TOP		EQU	2149h
TERMINAL_X	EQU	2063h
STACK_TOP	EQU	2141H
STR_TOP		EQU	212FH

Start:  LD      SP,75FFh
        JP      Init

	NOP
        NOP

SyntaxCheck:
        LD      A,(HL)
        EX      (SP),HL
        CP      (HL)
        INC     HL
        EX      (SP),HL
        JP      NZ,SyntaxError

NextChar:
        INC     HL
        LD      A,(HL)
        CP      ':'             ; ':'
        RET     NC
        JP      L048B

L0018:  PUSH    BC
        PUSH    HL
        PUSH    AF
        LD      C,A
        JP      L0367

L001F:  NOP

CompareHLDE:
        LD      A,H
        SUB     D
        RET     NZ
        LD      A,L
        SUB     E
        RET

L0026:  DB	01H
	DB	22H

FTestSign:
	LD	A, (2150H)
        OR	A
	JP	NZ, FTestSign_tail
	RET

PushNextWord:
	LD	C, (HL)
        INC     HL
        LD      B,(HL)
        INC     HL
        JP      L003B


L0037:  NOP
        RET

L0039:  NOP
        NOP
L003B:  LD      (2064h),HL
        POP     HL
        PUSH    BC
        PUSH    HL
        LD      HL,(2064h)
        RET

        ; --- START PROC GetFlowPtr ---
GetFlowPtr:
	LD      HL,0004h
        ADD     HL,SP
L0049:  LD      A,(HL)
        INC     HL
        CP      81h
        RET     NZ
        LD      C,(HL)
        INC     HL
        LD      B,(HL)
        INC     HL
        PUSH    HL
        LD      L,C
        LD      H,B
        LD      A,D
        OR      E
        EX      DE,HL
        JP      Z,L005D
        EX      DE,HL
        RST     CompareHLDE
L005D:  LD      BC,000Dh
        POP     HL
        RET     Z
        ADD     HL,BC
        JP      L0049

        ; --- START PROC L0066 ---
L0066:  CALL    L0086
        ; --- START PROC L0069 ---
L0069:  PUSH    BC
        EX      (SP),HL
        POP     BC
L006C:  RST     CompareHLDE
        LD      A,(HL)
        LD      (BC),A
        RET     Z
        DEC     BC
        DEC     HL
        JP      L006C

        ; --- START PROC CheckEnoughVarSpace2 ---
CheckEnoughVarSpace2:
	EX      (SP),HL
        LD      C,(HL)
        INC     HL
        EX      (SP),HL
        ; --- START PROC L0079 ---
L0079:  PUSH    HL
        LD      HL,(VAR_TOP)
        LD      B,00h
        ADD     HL,BC
        ADD     HL,BC
        CALL    L0086
        ; --- START PROC L0084 ---
L0084:  POP     HL
        RET

        ; --- START PROC L0086 ---
L0086:  PUSH    DE
        EX      DE,HL
        LD      HL,0FFDBh
        ADD     HL,SP
        RST     CompareHLDE
        EX      DE,HL
        POP     DE
        RET     NC
L0090:  LD      E,0Ch
        JP      Error

L0095:  LD      HL,(2133h)
        LD      (CURRENT_LINE),HL
        ; --- START PROC SyntaxError ---
SyntaxError:
	LD      E,02h
        XOR     A
        LD      (2078h),A
L00A1:  LD      BC,141Eh
L00A4:  LD      BC,001Eh
        ; --- START PROC Error ---
Error:  CALL    L01D6
        XOR     A
        LD      (2117h),A
        CALL    L06DF
        LD      A,E
        RRCA
        LD      E,A
        INC     E
        LD      HL,1CD3h
L00B8:  DEC     E
        JP      Z,L00C5
L00BC:  LD      A,(HL)
        INC     HL
        OR      A
        JP      Z,L00B8
        JP      L00BC

L00C5:  CALL    0F818h
        LD      HL,1DC1h
        ; --- START PROC L00CB ---
L00CB:  CALL    0F818h
        LD      HL,(CURRENT_LINE)
        LD      A,H
        AND     L
        INC     A
        JP      Z,L00F1
        PUSH    HL
        CALL    L1313
        LD      A,3Ah           ; ':'
        RST     18H
        LD      A,(208Dh)
        INC     A
        LD      E,A
        LD      D,00h
        CALL    L131C
        POP     HL
        EX      DE,HL
        LD      A,(2078h)
        OR      A
        JP      Z,L171B
        ; --- START PROC L00F1 ---
L00F1:  LD      HL,1DC9h
        CALL    0F818h
        LD      HL,0FFFFh
        LD      (CURRENT_LINE),HL
        LD      (2078h),HL
        ; --- START PROC L0100 ---
L0100:  XOR     A
        LD      (2117h),A
        LD      (LINE_BUFFER),A
        LD      (TERMINAL_X),A
        CALL    L0279
        ; --- START PROC L010D ---
L010D:  CALL    L06DA
        ; --- START PROC L0110 ---
L0110:  RST     NextChar
        INC     A
        DEC     A
        JP      Z,L0100
        PUSH    AF
        CALL    LineNumberFromStr
        PUSH    DE
        CALL    Tokenize
        LD      B,A
        POP     DE
        POP     AF
        JP      NC,L0461
        PUSH    DE
        PUSH    BC
        RST     NextChar
        PUSH    AF
        CALL    FindProgramLine
        PUSH    BC
        JP      NC,L0141
        EX      DE,HL
        LD      HL,(2145h)
L0133:  LD      A,(DE)
        LD      (BC),A
        INC     BC
        INC     DE
        RST     CompareHLDE
        JP      NC,L0133
        LD      H,B
        LD      L,C
        INC     HL
        LD      (2145h),HL
L0141:  POP     DE
        POP     AF
        JP      Z,L0168
        LD      HL,(2145h)
        EX      (SP),HL
        POP     BC
        ADD     HL,BC
        PUSH    HL
        CALL    L0066
        POP     HL
        LD      (2145h),HL
        EX      DE,HL
        LD      (HL),H
        INC     HL
        INC     HL
        POP     DE
        LD      (HL),E
        INC     HL
        LD      (HL),D
        INC     HL
        LD      DE,LINE_BUFFER
L0160:  LD      A,(DE)
        LD      (HL),A
        INC     HL
        INC     DE
        OR      A
        JP      NZ,L0160
        ; --- START PROC L0168 ---
L0168:  CALL    ResetAll
        INC     HL
L016C:  LD      D,H
        LD      E,L
        LD      A,(HL)
        INC     HL
        OR      (HL)
        JP      Z,L0185
        INC     HL
        INC     HL
        INC     HL
        XOR     A
L0178:  CP      (HL)
        INC     HL
        JP      NZ,L0178
        EX      DE,HL
        LD      (HL),E
        INC     HL
        LD      (HL),D
        EX      DE,HL
        JP      L016C

L0185:  LD      A,(2117h)
        OR      A
        JP      Z,L0100
        DEC     A
        JP      Z,L00F1
        XOR     A
        LD      (2117h),A
        JP      L18E7

        ; --- START PROC FindProgramLine ---
FindProgramLine:
	LD      HL,(PROGRAM_BASE)
        ; --- START PROC FindProgramLineInMem ---
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

        ; --- START PROC New ---
New:  RET     NZ
        LD      HL,(PROGRAM_BASE)
        XOR     A
        LD      (HL),A
        INC     HL
        LD      (HL),A
        INC     HL
        LD      (2145h),HL
        ; --- START PROC ResetAll ---
ResetAll:  LD      HL,(PROGRAM_BASE)
        DEC     HL
        LD      (HL),00h
        ; --- START PROC ClearAll ---
ClearAll:  LD      (PROG_PTR_TEMP),HL
        LD      HL,(211Bh)
        LD      (STR_TOP),HL
        CALL    L04A5
        ; --- START PROC L01CD ---
L01CD:  LD      HL,(2145h)
        LD      (2147h),HL
        LD      (VAR_TOP),HL
        ; --- START PROC L01D6 ---
L01D6:  POP     BC
        LD      HL,(STACK_TOP)
        LD      SP,HL
        LD      HL,211Fh
        LD      (211Dh),HL
        LD      HL,0000h
        PUSH    HL
        LD      (213Fh),HL
        LD      HL,(PROG_PTR_TEMP)
        XOR     A
        LD      (2135h),A
        PUSH    BC
        RET

        ; --- START PROC Tokenize ---
Tokenize:
	XOR     A
        ; --- START PROC L01F2 ---
L01F2:  LD      (DATA_STM),A
        LD      C,05h
        LD      DE,LINE_BUFFER
L01FA:  LD      A,(HL)
        CP      20h             ; ' '
        JP      Z,L023C
        LD      B,A
        CP      22h             ; '"'
        JP      Z,L025C
        OR      A
        JP      Z,L0270
        LD      A,(DATA_STM)
        OR      A
        LD      B,A
        LD      A,(HL)
        JP      NZ,L023C
        CP      30h             ; '0'
        JP      C,L021D
        CP      3Ch             ; '<'
        JP      C,L023C
L021D:  PUSH    DE
        LD      DE,KEYWORDS-1
        PUSH    HL
L0222:  LD      A,23h           ; '#'
        INC     DE
L0225:  LD      A,(DE)
        AND     7Fh             ; ''
        JP      Z,L0238+1       ; reference not aligned to instruction
        CP      (HL)
        JP      NZ,L0263
        LD      A,(DE)
        OR      A
        JP      P,L0222+1       ; reference not aligned to instruction
        POP     AF
        LD      A,B
        OR      80h
L0238:  JP      P,7EE1h
        POP     DE
L023C:  INC     HL
        LD      (DE),A
        INC     DE
        INC     C
        SUB     3Ah             ; ':'
        JP      Z,L024A
        CP      49h             ; 'I'
        JP      NZ,L024D
L024A:  LD      (DATA_STM),A
L024D:  SUB     54h             ; 'T'
        JP      NZ,L01FA
        LD      B,A
L0253:  LD      A,(HL)
        OR      A
        JP      Z,L0270
        CP      B
        JP      Z,L023C
L025C:  INC     HL
        LD      (DE),A
        INC     C
        INC     DE
        JP      L0253

L0263:  POP     HL
        PUSH    HL
        INC     B
        EX      DE,HL
L0267:  OR      (HL)
        INC     HL
        JP      P,L0267
        EX      DE,HL
        JP      L0225

L0270:  LD      HL,208Fh
        LD      (DE),A
        INC     DE
        LD      (DE),A
        INC     DE
        LD      (DE),A
        RET

        ; --- START PROC L0279 ---
L0279:  LD      DE,LINE_BUFFER
        ; --- START PROC L027C ---
L027C:  LD      H,D
        LD      L,E
        LD      BC,027Eh
        PUSH    BC
        CALL    L0351
        CP      0Dh
        EX      DE,HL
        JP      Z,L02D5
        EX      DE,HL
        LD      C,A
        CP      0Ah
        RET     Z
        CP      0Ch
        RET     Z
        DEC     A
        JP      Z,L02E5
        SUB     07h
        JP      Z,L02D7
        SUB     10h
        JP      Z,L02DF
        CP      03h
        RET     C
        LD      A,C
        DEC     B
        JP      P,L0306
        ; --- START PROC L02A9 ---
L02A9:  LD      A,(TERMINAL_X)
        INC     A
        RET     M
        LD      (TERMINAL_X),A
        LD      B,00h
        INC     DE
        PUSH    DE
        PUSH    HL
        LD      H,D
        LD      L,E
L02B8:  DEC     DE
        LD      A,(DE)
        LD      (HL),A
        INC     B
        EX      (SP),HL
        RST     CompareHLDE
        EX      (SP),HL
        DEC     HL
        JP      NZ,L02B8
        LD      (HL),C
        ; --- START PROC L02C4 ---
L02C4:  CALL    0F818h
        LD      C,20h           ; ' '
        CALL    0F809h
        LD      A,08h
L02CE:  RST     18H
        DEC     B
        JP      NZ,L02CE
        POP     HL
        INC     HL
        ; --- START PROC L02D5 ---
L02D5:  POP     DE
        RET

        ; --- START PROC L02D7 ---
L02D7:  LD      A,L
        CP      90h
        RET     Z
        DEC     HL
        JP      0F809h

        ; --- START PROC L02DF ---
L02DF:  RST     CompareHLDE
        RET     Z
        INC     HL
        JP      0F809h

        ; --- START PROC L02E5 ---
L02E5:  RST     CompareHLDE
        RET     Z
        LD      A,(TERMINAL_X)
        DEC     A
        RET     M
        LD      (TERMINAL_X),A
        LD      B,00h
        DEC     DE
        PUSH    DE
        DEC     HL
        PUSH    HL
        INC     HL
        PUSH    HL
        LD      D,H
        LD      E,L
L02F9:  INC     DE
        LD      A,(DE)
        LD      (HL),A
        INC     HL
        INC     B
        OR      A
        JP      NZ,L02F9
        POP     HL
        JP      L02C4

        ; --- START PROC L0306 ---
L0306:  PUSH    HL
        LD      HL,1EF6h
        SUB     2Ah             ; '*'
        CP      17h
        JP      C,L032A
        LD      HL,KEYWORDS
        SUB     17h
        CP      24h             ; '$'
        JP      C,L032A
        LD      HL,1E95h
        SUB     24h             ; '$'
        CP      02h
        JP      C,L032A
        LD      HL,1E9Dh
        SUB     02h
L032A:  LD      B,A
L032B:  DEC     B
        JP      M,L033B
L032F:  LD      A,(HL)
        INC     HL
        OR      A
        JP      Z,L0084
        JP      P,L032F
        JP      L032B

L033B:  LD      A,(HL)
        OR      A
        JP      M,L034A
        LD      C,A
        EX      (SP),HL
        CALL    L02A9
        EX      (SP),HL
        INC     HL
        JP      L033B

L034A:  AND     7Fh             ; ''
        LD      C,A
        POP     HL
        JP      L02A9

        ; --- START PROC L0351 ---
L0351:  LD      B,00h
L0353:  CALL    0F803h
        CP      1Fh
        JP      Z,0F800h
        CP      03h
        JP      Z,L1635
        CP      1Bh
        RET     NZ
        LD      B,A
        JP      L0353

L0367:  LD      HL,038Eh
L036A:  LD      A,(HL)
        INC     HL
        CP      C
        JP      Z,L037F
        OR      A
        JP      NZ,L036A
        LD      A,(TERMINAL_X)
        OR      A
        CALL    M,L06DF
        INC     A
        LD      (TERMINAL_X),A
L037F:  LD      A,(2117h)
        OR      A
        LD      A,C
        CALL    NZ,0F80Fh
        CALL    0F809h
        POP     AF
        POP     HL
        POP     BC
        RET

L038E:  DB	08H
        LD      A,(BC)
        DEC     C
        INC     C
        RRA
        DB 018H, 19H

L0395:  LD      A,(DE)
        NOP

List:	CALL    L03B6
        RET     NZ
        POP     BC
        CALL    FindProgramLine
        LD      H,B
        LD      L,C
L03A1:  RST     PushNextWord
        POP     DE
        LD      A,D
        OR      E
        JP      Z,L00F1
        CALL    L04AF
        PUSH    DE
L03AC:  CALL    L03D1
        POP     HL
        JP      C,L00F1
        JP      Z,L03A1
        ; --- START PROC L03B6 ---
L03B6:  CALL    LineNumberFromStr
        RET     Z
        RST     SyntaxCheck
        INC     L
        PUSH    DE
        CALL    LineNumberFromStr
        POP     HL
        RET     NZ
        EX      DE,HL
        LD      A,H
        OR      L
        SCF
        RET     Z
        RST     CompareHLDE
        JP      C,SyntaxError
        XOR     A
        SCF
        LD      (2078h),HL
        RET

        ; --- START PROC L03D1 ---
L03D1:  RST     PushNextWord
        DEC     HL
        EX      (SP),HL
        EX      DE,HL
        LD      HL,(2078h)
        RST     CompareHLDE
        POP     BC
        RET     C
        PUSH    BC
        CALL    L06DF
        JP      L163B

For:
	LD      A,64h           ; 'd'
        LD      (2135h),A
        CALL    L05C8
        EX      (SP),HL
        CALL    GetFlowPtr
        POP     DE
        JP      NZ,L03F4
        ADD     HL,BC
        LD      SP,HL
L03F4:  EX      DE,HL
        CALL    CheckEnoughVarSpace2
        DB	08h
        PUSH    HL
        CALL    Data
        EX      (SP),HL
        PUSH    HL
        LD      HL,(CURRENT_LINE)
        EX      (SP),HL
        CALL    L086C
        RST     SyntaxCheck
        SBC     A,(HL)
        CALL    EvalNumericExpression
        PUSH    HL
        CALL    L11B1
        POP     HL
        PUSH    BC
        PUSH    DE
        LD      BC,8100h
        LD      D,C
        LD      E,D
        LD      A,(HL)
        CP      0A3h
        LD      A,01h
        JP      NZ,L0429
        RST     NextChar
        CALL    EvalNumericExpression
        PUSH    HL
        CALL    L11B1
        POP     HL
        RST     FTestSign
L0429:  PUSH    BC
        PUSH    DE
        PUSH    AF
        INC     SP
        PUSH    HL
        LD      HL,(PROG_PTR_TEMP)
        EX      (SP),HL
        ; --- START PROC L0432 ---
L0432:  LD      B,81h
        PUSH    BC
        INC     SP
        ; --- START PROC ExecNext ---
ExecNext:  CALL    L04AF
        LD      (PROG_PTR_TEMP),HL
        LD      A,(HL)
        EX      DE,HL
        LD      HL,208Dh
        INC     (HL)
        OR      A
        JP      Z,L044F
        CP      3Ah             ; ':'
        JP      NZ,SyntaxError
        EX      DE,HL
        JP      L0461

L044F:  LD      (HL),A
        EX      DE,HL
        INC     HL
        LD      A,(HL)
        INC     HL
        OR      (HL)
        INC     HL
        JP      Z,L04C0
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        EX      DE,HL
        LD      (CURRENT_LINE),HL
        EX      DE,HL
        ; --- START PROC L0461 ---
L0461:  RST     NextChar
        LD      DE,ExecNext
        PUSH    DE
L0466:  RET     Z

ExecA:
L0467:  SUB     80h
        JP      C,L05C8
        CP      1Dh
        JP      C,L0478

        CP      4Ah             ; 'J'
        JP      C,SyntaxError
        SUB     2Dh             ; '-'

L0478:  RLCA
        LD      C,A
        LD      B,00h
        EX      DE,HL
        LD      HL,KW_GENERAL_FNS
        ADD     HL,BC
        LD      C,(HL)
        INC     HL
        LD      B,(HL)
        PUSH    BC
        EX      DE,HL
        ; --- START PROC L0486 ---
L0486:  INC     HL
        LD      A,(HL)
        CP      3Ah             ; ':'
        RET     NC
L048B:  CP      20h             ; ' '
        JP      Z,L0486
        CP      30h             ; '0'
        CCF
        INC     A
        DEC     A
        RET

Restore:
	JP      Z,L04A5
        CALL    LineNumberFromStr
        RET     NZ
        PUSH    HL
        CALL    L0582
        POP     DE
        JP      L04AA

        ; --- START PROC L04A5 ---
L04A5:  EX      DE,HL
        LD      HL,(PROGRAM_BASE)
        DEC     HL
L04AA:  LD      (214Bh),HL
        EX      DE,HL
        RET

        ; --- START PROC L04AF ---
L04AF:  CALL    0F812h
        OR      A
        RET     Z
        CALL    L0351
        CP      05h

	INCLUDE "stStop.inc"
	INCLUDE "stEnd.inc"

InputBreak:
        POP     BC
        ; --- START PROC L04C0 ---
L04C0:  PUSH    AF
        LD      HL,(CURRENT_LINE)
        LD      A,L
        AND     H
        INC     A
        JP      Z,L04D3
        LD      (213Dh),HL
        LD      HL,(PROG_PTR_TEMP)
        LD      (213Fh),HL
L04D3:  POP     AF
        LD      HL,1DD2h
        JP      NZ,L00CB
        JP      L00F1

Cont:
	RET     NZ
        LD      E,20h           ; ' '
        LD      HL,(213Fh)
        LD      A,H
        OR      L
        JP      Z,Error
        EX      DE,HL
        LD      HL,(213Dh)
        LD      (CURRENT_LINE),HL
        EX      DE,HL
        RET

        ; --- START PROC L04F1 ---
L04F1:  LD      A,(HL)
        CP      41h             ; 'A'
        RET     C
        CP      5Bh             ; '['
        CCF
        RET

        ; --- START PROC L04F9 ---
L04F9:  RST     NextChar
        ; --- START PROC L04FA ---
L04FA:  CALL    EvalNumericExpression
        ; --- START PROC L04FD ---
L04FD:  RST     FTestSign
        JP      M,FunctionCallError
        ; --- START PROC FTestIntegerExpression ---
FTestIntegerExpression:  LD      A,(2150h)
        CP      91h
        JP      C,L120B
        LD      BC,8001h
        LD      DE,0000h
        CALL    L11E0
        LD      D,C
        RET     Z
        ; --- START PROC FunctionCallError ---
FunctionCallError:  LD      E,08h
        JP      Error

        ; --- START PROC LineNumberFromStr ---
LineNumberFromStr:  DEC     HL
        ; --- START PROC L051A ---
L051A:  LD      DE,0000h
L051D:  RST     NextChar
        RET     NC
        PUSH    HL
        PUSH    AF
        LD      HL,1998h
        RST     CompareHLDE
        JP      C,SyntaxError
        LD      H,D
        LD      L,E
        ADD     HL,DE
        ADD     HL,HL
        ADD     HL,DE
        ADD     HL,HL
        POP     AF
        SUB     30h             ; '0'
        LD      E,A
        LD      D,00h
        ADD     HL,DE
        EX      DE,HL
        POP     HL
        JP      L051D

Clear:	JP      Z,ClearAll
        CALL    L04FA
        DEC     HL
        RST     NextChar
        RET     NZ
        PUSH    HL
        LD      HL,(211Bh)
        LD      A,L
        SUB     E
        LD      E,A
        LD      A,H
        SBC     A,D
        LD      D,A
        JP      C,SyntaxError
        LD      HL,(2145h)
        LD      BC,0028h
        ADD     HL,BC
        RST     CompareHLDE
        JP      NC,L0090
        EX      DE,HL
        LD      (STACK_TOP),HL
        POP     HL
        JP      ClearAll


	INCLUDE	"stRun.inc"
	INCLUDE	"stGosub.inc"

Goto:
	CALL    LineNumberFromStr
        ; --- START PROC L0582 ---
L0582:  CALL    Rem
        PUSH    HL
        LD      HL,(CURRENT_LINE)
        RST     CompareHLDE
        POP     HL
        INC     HL
        CALL    C,FindProgramLineInMem
        CALL    NC,FindProgramLine
        LD      H,B
        LD      L,C
        DEC     HL
        RET     C

UnknownStringError:
        LD      E,0Eh
        JP      Error

Return:
	RET     NZ
        LD      D,0FFh
        CALL    GetFlowPtr
        LD      SP,HL
        CP      TK_GOSUB
        LD      E,04h
        JP      NZ,Error
        POP     HL
        LD      (CURRENT_LINE),HL
        LD      HL,ExecNext
        EX      (SP),HL
        ; --- START PROC Data ---
Data:
	DB	01H, ":"	;LD BC,..3AH эмулирует LD C, ":"
Rem:	LD	C, 0
        LD      B,00h
L05B7:  LD      A,C
        LD      C,B
        LD      B,A
L05BA:  LD      A,(HL)
        OR      A
        RET     Z
        CP      B
        RET     Z
        INC     HL
        CP      22h             ; '"'
        JP      Z,L05B7
        JP      L05BA

        ; --- START PROC L05C8 ---
L05C8:  CALL    L0A48+1         ; reference not aligned to instruction
        RST     SyntaxCheck
        XOR     H
        LD      A,(VALTYP)
        PUSH    AF
        PUSH    DE
        CALL    L0878
        EX      (SP),HL
        LD      (PROG_PTR_TEMP),HL
        POP     DE
        POP     AF
        PUSH    DE
        RRA
        CALL    L086E
        JP      Z,L060D
L05E3:  PUSH    HL
        LD      HL,(214Dh)
        PUSH    HL
        INC     HL
        INC     HL
        RST     PushNextWord
        POP     DE
        LD      HL,(STACK_TOP)
        RST     CompareHLDE
        POP     DE
        JP      NC,L05FD
        LD      HL,(2145h)
        RST     CompareHLDE
        LD      L,E
        LD      H,D
        CALL    C,L0C5F
L05FD:  LD      A,(DE)
        PUSH    AF
        XOR     A
        LD      (DE),A
        CALL    L0DF0
        POP     AF
        LD      (HL),A
        EX      DE,HL
        POP     HL
        CALL    L11C0
        POP     HL
        RET

L060D:  PUSH    HL
        CALL    L11BD
        POP     DE
        POP     HL
        RET

On:	CALL    L0EDC
        LD      A,(HL)
        LD      B,A
        CP      8Ch
        JP      Z,L0621
        RST     SyntaxCheck
        ADC     A,B
        DEC     HL
L0621:  LD      C,E
L0622:  DEC     C
        LD      A,B
        JP      Z,L0467
        CALL    L051A
        CP      2Ch             ; ','
        RET     NZ
        JP      L0622

If:
	CALL    L0878
        LD      A,(HL)
        CP      88h
        JP      Z,L063C
        RST     SyntaxCheck
        AND     C
        DEC     HL
L063C:  RST     FTestSign
        JP      Z,Rem
        RST     NextChar
        JP      C, Goto
        JP      L0466

        ; --- START PROC L0647 ---
L0647:  RST     NextChar
        ; --- START PROC Print ---
Print:	JP      Z,L06DF
        ; --- START PROC L064B ---
L064B:  RET     Z
        CP      27h             ; '''
        CALL    Z,L06DF
        JP      Z,L0708
        CP      9Dh
        JP      Z,L070C
        CP      9Fh
        JP      Z,L070C
        CP      0C8h		; AT ?
        JP      NZ,L066B
        RST     NextChar
        CALL    Cur
        DEC     HL
        JP      L0708

L066B:  PUSH    HL
        CP      2Ch             ; ','
        JP      Z,L06EA
        CP      3Bh             ; ';'
        JP      Z,L0707
        POP     BC
        CP      0D3h
        JP      Z,L06A8
        CALL    L0878
        DEC     HL
        PUSH    HL
        LD      A,(VALTYP)
        OR      A
        JP      NZ,L06A1
        CALL    L1326
        CALL    L0C7F
        LD      HL,(214Dh)
        LD      A,(TERMINAL_X)
        ADD     A,(HL)
        CP      40h             ; '@'
        CALL    NC,L06DF
        CALL    L0CC6
        LD      A,20h           ; ' '
        RST     18H
        XOR     A
L06A1:  CALL    NZ,L0CC6
L06A4:  POP     HL
        JP      L0647

L06A8:  INC     HL
        CALL    EvalNumericExpression
        DEC     HL
        PUSH    HL
        CALL    FTestIntegerExpression
        LD      A,20h           ; ' '
        RST     18H
        LD      A,D
        OR      A
        JP      Z,L06BD
        LD      B,A
        CALL    L06C5
L06BD:  LD      A,E
        LD      B,A
        CALL    L06C5
        JP      L06A4

        ; --- START PROC L06C5 ---
L06C5:  RRCA
        RRCA
        RRCA
        RRCA
        CALL    L06CD
        LD      A,B
        ; --- START PROC L06CD ---
L06CD:  AND     0Fh
        CP      0Ah
        JP      C,L06D6
        ADD     A,07h
L06D6:  ADD     A,30h           ; '0'
        RST     18H
        RET

        ; --- START PROC L06DA ---
L06DA:  LD      (HL),00h
        LD      HL,208Fh
        ; --- START PROC L06DF ---
L06DF:  LD      A,0Dh
        RST     18H
        LD      A,0Ah
        RST     18H
        XOR     A
        LD      (TERMINAL_X),A
        RET

        ; --- START PROC L06EA ---
L06EA:  LD      A,(TERMINAL_X)
        CP      2Bh             ; '+'
        CALL    NC,L06DF
        JP      NC,L0707
L06F5:  SUB     0Eh
        JP      NC,L06F5
        CPL
        INC     A
        ; --- START PROC L06FC ---
L06FC:  LD      B,A
        LD      A,20h           ; ' '
        ; --- START PROC L06FF ---
L06FF:  DEC     B
        JP      M,L0707
        RST     18H
        JP      L06FF

        ; --- START PROC L0707 ---
L0707:  POP     HL
        ; --- START PROC L0708 ---
L0708:  RST     NextChar
        JP      L064B

        ; --- START PROC L070C ---
L070C:  PUSH    AF
        CALL    L0EDB         ; reference not aligned to instruction
        RST     SyntaxCheck
        ADD     HL,HL
        DEC     HL
        POP     AF
        CP      9Fh
        PUSH    HL
        LD      A,E
        JP      Z,L06FC
        CP      40h             ; '@'
        JP      P,FunctionCallError
        LD      HL,TERMINAL_X
        SUB     (HL)
        LD      (HL),E
        JP      P,L0730
        CPL
        INC     A
        LD      B,A
        LD      A,08h
        JP      L06FF

L0730:  LD      B,A
        LD      A,18h
        JP      L06FF

L0736:  LD      A,(2136h)
        OR      A
        JP      NZ,L0095
        JP      L0873+1         ; reference not aligned to instruction

Input:
	CP      22h             ; '"'
        LD      BC,0120h
        JP      NZ,L0761
        PUSH    BC
        CALL    L0C80
        POP     BC
        LD      A,(HL)
        CP      3Bh             ; ';'
        JP      Z,L0759
        LD      B,A
        CP      2Ch             ; ','
        JP      NZ,SyntaxError
L0759:  RST     NextChar
        PUSH    HL
        PUSH    BC
        CALL    L0CC6
        POP     BC
        POP     HL
L0761:  PUSH    HL
        PUSH    BC
        CALL    L0A48+1         ; reference not aligned to instruction
        POP     BC
        CALL    L0C31
        DEC     B
        CALL    L0777
        LD      A,(VALTYP)
        CALL    L01F2
        JP      L0798+1         ; reference not aligned to instruction

        ; --- START PROC L0777 ---
L0777:  LD      A,3Fh           ; '?'
        JP      Z,L077D
        LD      A,C
        ; --- START PROC L077D ---
L077D:  RST     18H
        LD      DE,LINE_BUFFER
        XOR     A
        LD      (DE),A
        PUSH    DE
        CALL    L027C
        XOR     A
        LD      (HL),A
        POP     HL
        OR      (HL)
        RET     NZ
        ; --- START PROC L078C ---
L078C:  LD      A,3Fh           ; '?'
        RST     18H
        LD      A,08h
        JP      L077D

Read:
	PUSH    HL
        LD      HL,(214Bh)
L0798:  OR      0AFh
        LD      (2136h),A
        EX      (SP),HL
L079E:  LD      BC,2CCFh
        CALL    L0A48+1         ; reference not aligned to instruction
        EX      (SP),HL
        PUSH    DE
        LD      A,(HL)
        CP      2Ch             ; ','
        JP      Z,L07B9
        LD      A,(2136h)
        OR      A
        JP      NZ,L07FE
        LD      A,2Ch           ; ','
        RST     18H
        CALL    L078C
L07B9:  LD      A,(VALTYP)
        OR      A
        JP      Z,L07D9
        RST     NextChar
        LD      D,A
        LD      B,A
        CP      22h             ; '"'
        JP      Z,L07CD
        LD      D,3Ah           ; ':'
        LD      B,2Ch           ; ','
        DEC     HL
L07CD:  CALL    L0C83
        EX      DE,HL
        LD      HL,07E2h
        EX      (SP),HL
        PUSH    DE
        JP      L05E3

L07D9:  RST     NextChar
        CALL    L126A
        EX      (SP),HL
        CALL    L11BD
        POP     HL
        DEC     HL
        RST     NextChar
        JP      Z,L07EC
        CP      2Ch             ; ','
        JP      NZ,L0736
L07EC:  EX      (SP),HL
        DEC     HL
        RST     NextChar
        JP      NZ,L079E+1      ; reference not aligned to instruction
        POP     DE
        LD      A,(2136h)
        OR      A
        JP      Z,L06DF
        EX      DE,HL
        JP      L04AA

L07FE:  CALL    Data
        OR      A
        JP      NZ,L0817
        INC     HL
        RST     PushNextWord
        LD      A,C
        OR      B
        LD      E,06h
        JP      Z,Error
        POP     BC
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        EX      DE,HL
        LD      (2133h),HL
        EX      DE,HL
L0817:  RST     NextChar
        CP      83h
        JP      NZ,L07FE
        JP      L07B9

Next:
	LD      DE,0000h
        ; --- START PROC L0823 ---
L0823:  CALL    NZ,L0A48+1      ; reference not aligned to instruction
        LD      (PROG_PTR_TEMP),HL
        CALL    GetFlowPtr
        JP      NZ,L00A4+1      ; reference not aligned to instruction
        LD      SP,HL
        PUSH    DE
        LD      A,(HL)
        INC     HL
        PUSH    AF
        PUSH    DE
        CALL    L11A3
        EX      (SP),HL
        PUSH    HL
        CALL    L0F07
        POP     HL
        CALL    L11BD
        POP     HL
        CALL    L11B4
        PUSH    HL
        CALL    L11E0
        POP     HL
        POP     BC
        SUB     B
        CALL    L11B4
        JP      Z,L085B
        EX      DE,HL
        LD      (CURRENT_LINE),HL
        LD      L,C
        LD      H,B
        JP      L0432

L085B:  LD      SP,HL
        LD      HL,(PROG_PTR_TEMP)
        LD      A,(HL)
        CP      2Ch             ; ','
        JP      NZ,ExecNext
        RST     NextChar
        CALL    L0823
        ; --- START PROC EvalNumericExpression ---
EvalNumericExpression:  CALL    L0878
        ; --- START PROC L086C ---
L086C:  OR      37h             ; '7'
        ; --- START PROC L086E ---
L086E:  LD      A,(VALTYP)
        ADC     A,A
        RET     PE
L0873:  LD      E,18h
        JP      Error

        ; --- START PROC L0878 ---
L0878:  DEC     HL
        LD      D,00h
        ; --- START PROC L087B ---
L087B:  PUSH    DE
        CALL    CheckEnoughVarSpace2
        LD      BC,0E8CDh
        DB	08H
        LD      (2139h),HL
        ; --- START PROC L0886 ---
L0886:  LD      HL,(2139h)
        POP     BC
        LD      A,B
        CP      78h             ; 'x'
        CALL    NC,L086C
        LD      A,(HL)
        LD      D,00h
L0893:  SUB     0ABh
        JP      C,L08AD
        CP      03h
        JP      NC,L08AD
        CP      01h
        RLA
        XOR     D
        CP      D
        LD      D,A
        JP      C,SyntaxError
        LD      (2131h),HL
        RST     NextChar
        JP      L0893

L08AD:  LD      A,D
        OR      A
        JP      NZ,L09CD
        LD      A,(HL)
        LD      (2131h),HL
        SUB     0A4h
        RET     C
        CP      07h
        RET     NC
        LD      E,A
        LD      A,(VALTYP)
        DEC     A
        OR      E
        LD      A,E
        JP      Z,L0DA2
        RLCA
        ADD     A,E
        LD      E,A
        LD      HL,1FE0h
        ADD     HL,DE
        LD      A,B
        LD      D,(HL)
        CP      D
        RET     NC
        INC     HL
        CALL    L086C
        ; --- START PROC L08D5 ---
L08D5:  PUSH    BC
        LD      BC,0886h
        PUSH    BC
        LD      B,E
        LD      C,D
        CALL    L1196
        LD      E,B
        LD      D,C
        RST     PushNextWord
        LD      HL,(2131h)
        JP      L087B

        ; --- START PROC L08E8 ---
L08E8:  XOR     A
        LD      (VALTYP),A
        RST     NextChar
        JP      C,FIn
        CALL    L04F1
        JP      NC,L0950
        CP      0A4h
        JP      Z,L08E8
        CP      2Eh             ; '.'
        JP      Z,FIn
        CP      0A5h
        JP      Z,L093F
        CP      22h             ; '"'
        ; --- START PROC L0907 ---
L0907:  JP      Z,L0C80
        CP      0A2h
        JP      Z,L0A28
        CP      0A0h
        JP      Z,L0BFC
        CP      0D5h
        JP      Z,L1A46
        CP      0D6h
        JP      Z,L1A55
        CP      0D4h
        JP      Z,L1C57
        CP      0D8h
        JP      Z,L1C86
        CP      0D3h
        JP      Z,SyntaxError
        CP      0D9h
        JP      Z,L1C90
        SUB     0AEh
        JP      NC,L0961
        ; --- START PROC L0937 ---
L0937:  RST     SyntaxCheck
        DB	28H, 0CDH
        LD      A,B
        DB	08H
        RST     SyntaxCheck
        ADD     HL,HL
        RET

        ; --- START PROC L093F ---
L093F:  LD      D,7Dh           ; '}'
        CALL    L087B
        LD      HL,(2139h)
        PUSH    HL
        CALL    L118E
        ; --- START PROC L094B ---
L094B:  CALL    L086C
        POP     HL
        RET

        ; --- START PROC L0950 ---
L0950:  CALL    L0A48+1         ; reference not aligned to instruction
        PUSH    HL
        EX      DE,HL
        LD      (214Dh),HL
        LD      A,(VALTYP)
        OR      A
        CALL    Z,L11A3
        POP     HL
        RET

        ; --- START PROC L0961 ---
L0961:  LD      B,00h
        RLCA
        LD      C,A
        PUSH    BC
        RST     NextChar
        LD      A,C
        CP      29h             ; ')'
        JP      C,L0994
        CP      30h             ; '0'
        JP      C,L097B
        CP      38h             ; '8'
        JP      NC,SyntaxError
        EX      (SP),HL
        JP      L099C

L097B:  RST     SyntaxCheck
        DB	28H, 0CDH
        LD      A,B
        db	08h
        RST     SyntaxCheck
        INC     L
        CALL    L086C+1         ; reference not aligned to instruction
        EX      DE,HL
        LD      HL,(214Dh)
        EX      (SP),HL
        PUSH    HL
        EX      DE,HL
        CALL    L0EDC
        EX      DE,HL
        EX      (SP),HL
        JP      L099C

L0994:  CALL    L0937
        EX      (SP),HL
        LD      DE,094Bh
        PUSH    DE
L099C:  LD      BC,KW_INLINE_FNS
        ADD     HL,BC
        LD      C,(HL)
        INC     HL
        LD      H,(HL)
        LD      L,C
        JP      (HL)

FOr:
	DB	0F6h	;OR 0AFH
FAnd:
	XOR	A	; AFh
        PUSH    AF
        CALL    L086C
        CALL    FTestIntegerExpression
        POP     AF
        EX      DE,HL
        POP     BC
        EX      (SP),HL
        EX      DE,HL
        CALL    L11A6
        PUSH    AF
        CALL    FTestIntegerExpression
        POP     AF
        POP     BC
        LD      A,C
        LD      HL,0BCAh
        JP      NZ,L09C8
        AND     E
        LD      C,A
        LD      A,B
        AND     D
        JP      (HL)

L09C8:  OR      E
        LD      C,A
        LD      A,B
        OR      D
        JP      (HL)

        ; --- START PROC L09CD ---
L09CD:  LD      HL,09DFh
        LD      A,(VALTYP)
        RRA
        LD      A,D
        RLA
        LD      E,A
        LD      D,64h           ; 'd'
        LD      A,B
        CP      D
        RET     NC
        JP      L08D5

L09DF:  POP     HL
        ADD     HL,BC
        LD      A,C
        OR      A
        RRA
        POP     BC
        POP     DE
        PUSH    AF
        CALL    L086E
        LD      HL,0A1Eh
        PUSH    HL
        JP      Z,L11E0
        XOR     A
        LD      (VALTYP),A
        PUSH    DE
        CALL    EvalCurrentString
        POP     DE
        RST     PushNextWord
        RST     PushNextWord
        CALL    L0DF0
        CALL    L11B4
        POP     HL
        EX      (SP),HL
        LD      D,L
        POP     HL
L0A06:  LD      A,E
        OR      D
        RET     Z
        LD      A,D
        OR      A
        CPL
        RET     Z
L0A0D:  XOR     A
        CP      E
        INC     A
        RET     NC
        DEC     D
        DEC     E
        LD      A,(BC)
        CP      (HL)
        INC     HL
        INC     BC
        JP      Z,L0A06
        CCF
        JP      L1174

L0A1E:  INC     A
        ADC     A,A
        POP     BC
        AND     B
        ADD     A,0FFh
        SBC     A,A
        JP      L1179

        ; --- START PROC L0A28 ---
L0A28:  LD      D,5Ah           ; 'Z'
        CALL    L087B
        CALL    L086C
        CALL    FTestIntegerExpression
        LD      A,E
        CPL
        LD      C,A
        LD      A,D
        CPL
        CALL    WordFromACToFACCUM
        POP     BC
        JP      L0886

L0A3F:  DEC     HL
        RST     NextChar
        RET     Z
        RST     SyntaxCheck
        INC     L
Dim:
        LD      BC,0A3Fh
        PUSH    BC
L0A48:  OR      0AFh
        LD      (2118h),A
        LD      B,(HL)
        ; --- START PROC L0A4E ---
L0A4E:  CALL    L04F1
        JP      C,SyntaxError
        XOR     A
        LD      C,A
        LD      (VALTYP),A
        RST     NextChar
        JP      C,L0A63
        CALL    L04F1
        JP      C,L0A6E
L0A63:  LD      C,A
L0A64:  RST     NextChar
        JP      C,L0A64
        CALL    L04F1
        JP      NC,L0A64
L0A6E:  SUB     24h             ; '$'
        JP      NZ,L0A7B
        INC     A
        LD      (VALTYP),A
        RRCA
        ADD     A,C
        LD      C,A
        RST     NextChar
L0A7B:  LD      A,(2135h)
        ADD     A,(HL)
        CP      28h             ; '('
        JP      Z,L0ACD
        XOR     A
        LD      (2135h),A
        PUSH    HL
        LD      HL,(2147h)
        EX      DE,HL
        LD      HL,(2145h)
L0A90:  RST     CompareHLDE
        JP      Z,L0AA7
        LD      A,C
        SUB     (HL)
        INC     HL
        JP      NZ,L0A9C
        LD      A,B
        SUB     (HL)
L0A9C:  INC     HL
        JP      Z,L0ACA
        INC     HL
        INC     HL
        INC     HL
        INC     HL
        JP      L0A90

L0AA7:  PUSH    BC
        LD      BC,0006h
        LD      HL,(VAR_TOP)
        PUSH    HL
        ADD     HL,BC
        POP     BC
        PUSH    HL
        CALL    L0066
        POP     HL
        LD      (VAR_TOP),HL
        LD      H,B
        LD      L,C
        LD      (2147h),HL
L0ABE:  DEC     HL
        LD      (HL),00h
        RST     CompareHLDE
        JP      NZ,L0ABE
        POP     DE
        LD      (HL),E
        INC     HL
        LD      (HL),D
        INC     HL
L0ACA:  EX      DE,HL
        POP     HL
        RET

L0ACD:  PUSH    HL
        LD      HL,(2118h)
        EX      (SP),HL
        LD      D,00h
L0AD4:  PUSH    DE
        PUSH    BC
        CALL    L04F9
        POP     BC
        POP     AF
        EX      DE,HL
        EX      (SP),HL
        PUSH    HL
        EX      DE,HL
        INC     A
        LD      D,A
        LD      A,(HL)
        CP      2Ch             ; ','
        JP      Z,L0AD4
        RST     SyntaxCheck
        ADD     HL,HL
        LD      (2139h),HL
        POP     HL
        LD      (2118h),HL
        PUSH    DE
        LD      HL,(2147h)
L0AF4:  LD      A,19h
        EX      DE,HL
        LD      HL,(VAR_TOP)
        EX      DE,HL
        RST     CompareHLDE
        JP      Z,L0B22
        LD      A,(HL)
        CP      C
        INC     HL
        JP      NZ,L0B07
        LD      A,(HL)
        CP      B
L0B07:  INC     HL
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        INC     HL
        JP      NZ,L0AF4+1      ; reference not aligned to instruction
        LD      A,(2118h)
        OR      A
        LD      E,12h
        JP      NZ,Error
        POP     AF
        CP      (HL)
        JP      Z,L0B81
        ; --- START PROC L0B1D ---
L0B1D:  LD      E,10h
        JP      Error

        ; --- START PROC L0B22 ---
L0B22:  LD      DE,0004h
        LD      (HL),C
        INC     HL
        LD      (HL),B
        INC     HL
        POP     AF
        LD      (2049h),A
        LD      C,A
        CALL    L0079
        LD      (2131h),HL
        INC     HL
        INC     HL
        LD      B,C
        LD      (HL),B
        INC     HL
L0B39:  LD      A,(2118h)
        OR      A
        LD      A,B
        LD      BC,000Bh
        JP      Z,L0B46
        POP     BC
        INC     BC
L0B46:  LD      (HL),C
        INC     HL
        LD      (HL),B
        INC     HL
        PUSH    AF
        PUSH    HL
        CALL    L124F
        EX      DE,HL
        POP     HL
        POP     BC
        DEC     B
        JP      NZ,L0B39
        LD      B,D
        LD      C,E
        EX      DE,HL
        ADD     HL,DE
        JP      C,L0B1D
        CALL    L0086
        LD      (VAR_TOP),HL
L0B63:  DEC     HL
        LD      (HL),00h
        RST     CompareHLDE
        JP      NZ,L0B63
        INC     BC
        LD      H,A
        LD      A,(2118h)
        OR      A
        LD      A,(2049h)
        LD      L,A
        ADD     HL,HL
        ADD     HL,BC
        EX      DE,HL
        LD      HL,(2131h)
        LD      (HL),E
        INC     HL
        LD      (HL),D
        INC     HL
        JP      NZ,L0BA3
        ; --- START PROC L0B81 ---
L0B81:  INC     HL
        LD      BC,0000h
L0B85:  LD      D,0E1h
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        INC     HL
        EX      (SP),HL
        PUSH    AF
        RST     CompareHLDE
        JP      NC,L0B1D
        PUSH    HL
        CALL    L124F
        POP     DE
        ADD     HL,DE
        POP     AF
        DEC     A
        LD      B,H
        LD      C,L
        JP      NZ,L0B85+1      ; reference not aligned to instruction
        ADD     HL,HL
        ADD     HL,HL
        POP     BC
        ADD     HL,BC
        EX      DE,HL
        ; --- START PROC L0BA3 ---
L0BA3:  LD      HL,(2139h)
        DEC     HL
        RST     NextChar
        RET

	INCLUDE	"fnFre.inc"

	INCLUDE	"fnPos.inc"

Def:	CALL    L0C3F
        LD      BC,Data
        PUSH    BC
        PUSH    DE
        CALL    L0C31
        RST     SyntaxCheck
        DB	28H, 0CDH
        LD      C,C
        LD      A,(BC)
        CALL    L086C
        RST     SyntaxCheck
        ADD     HL,HL
        RST     SyntaxCheck
        XOR     H
        LD      B,H
        LD      C,L
        EX      (SP),HL
        JP      L0C28

        ; --- START PROC L0BFC ---
L0BFC:  CALL    L0C3F
        PUSH    DE
        CALL    L0937
        CALL    L086C
        EX      (SP),HL
        RST     PushNextWord
        POP     DE
        RST     PushNextWord
        POP     HL
        RST     PushNextWord
        RST     PushNextWord
        DEC     HL
        DEC     HL
        DEC     HL
        DEC     HL
        PUSH    HL
        RST     CompareHLDE
        PUSH    DE
        LD      E,22h           ; '"'
        JP      Z,Error
        CALL    L11BD
        POP     HL
        CALL    EvalNumericExpression
        DEC     HL
        RST     NextChar
        JP      NZ,SyntaxError
        POP     HL
        POP     DE
        POP     BC
L0C28:  LD      (HL),C
        INC     HL
        LD      (HL),B
        ; --- START PROC L0C2B ---
L0C2B:  INC     HL
        LD      (HL),E
        INC     HL
        LD      (HL),D
        POP     HL
        RET

        ; --- START PROC L0C31 ---
L0C31:  PUSH    HL
        LD      HL,(CURRENT_LINE)
        INC     HL
        LD      A,H
        OR      L
        POP     HL
        RET     NZ
        LD      E,16h
        JP      Error

        ; --- START PROC L0C3F ---
L0C3F:  RST     SyntaxCheck
        AND     B
        LD      A,80h
        LD      (2135h),A
        OR      (HL)
        LD      B,A
        CALL    L0A4E
        JP      L086C

Str:	CALL    L086C
        CALL    L1326
        CALL    L0C7F
        CALL    EvalCurrentString
        POP     BC
        LD      BC,0CA5h
        PUSH    BC
        ; --- START PROC L0C5F ---
L0C5F:  LD      A,(HL)
        INC     HL
        INC     HL
        PUSH    HL
        CALL    L0CD5
        POP     HL
        RST     PushNextWord
        POP     BC
        CALL    L0C76
        PUSH    HL
        LD      L,A
        CALL    L0DDF
        POP     DE
        RET

        ; --- START PROC L0C73 ---
L0C73:  CALL    L0CD5
        ; --- START PROC L0C76 ---
L0C76:  LD      HL,212Bh
        PUSH    HL
        LD      (HL),A
        INC     HL
        JP      L0C2B

        ; --- START PROC L0C7F ---
L0C7F:  DEC     HL
        ; --- START PROC L0C80 ---
L0C80:  LD      B,22h           ; '"'
        LD      D,B
        ; --- START PROC L0C83 ---
L0C83:  PUSH    HL
        LD      C,0FFh
L0C86:  INC     HL
        LD      A,(HL)
        INC     C
        OR      A
        JP      Z,L0C95
        CP      D
        JP      Z,L0C95
        CP      B
        JP      NZ,L0C86
L0C95:  CP      22h             ; '"'
        CALL    Z,L0486
        EX      (SP),HL
        INC     HL
        EX      DE,HL
        LD      A,C
        CALL    L0C76
        RST     CompareHLDE
        CALL    NC,L0C5F
        ; --- START PROC L0CA5 ---
L0CA5:  LD      DE,212Bh
        LD      HL,(211Dh)
        LD      (214Dh),HL
        LD      A,01h
        LD      (VALTYP),A
        CALL    L11C0
        RST     CompareHLDE
        LD      E,1Eh
        JP      Z,Error
        LD      (211Dh),HL
        POP     HL
        LD      A,(HL)
        RET

L0CC2:  INC     HL
        CALL    L0C7F
        ; --- START PROC L0CC6 ---
L0CC6:  CALL    EvalCurrentString
        CALL    L11B4
        INC     E
L0CCD:  DEC     E
        RET     Z
        LD      A,(BC)
        RST     18H
        INC     BC
        JP      L0CCD

        ; --- START PROC L0CD5 ---
L0CD5:  OR      A
        LD      C,0F1h
        PUSH    AF
        LD      HL,(STACK_TOP)
        EX      DE,HL
        LD      HL,(STR_TOP)
        CPL
        LD      C,A
        LD      B,0FFh
        ADD     HL,BC
        INC     HL
        RST     CompareHLDE
        JP      C,L0CF1
        LD      (STR_TOP),HL
        INC     HL
        EX      DE,HL
        POP     AF
        RET

L0CF1:  POP     AF
        LD      E,1Ah
        JP      Z,Error
        CP      A
        PUSH    AF
        LD      BC,0CD7h
        PUSH    BC
        ; --- START PROC GarbageCollection ---
GarbageCollection:  LD      HL,(211Bh)
        ; --- START PROC L0D00 ---
L0D00:  LD      (STR_TOP),HL
        LD      HL,0000h
        PUSH    HL
        LD      HL,(STACK_TOP)
        PUSH    HL
        LD      HL,211Fh
        EX      DE,HL
        LD      HL,(211Dh)
        EX      DE,HL
        RST     CompareHLDE
        LD      BC,0D0Eh
        JP      NZ,L0D5A
        LD      HL,(2145h)
L0D1D:  EX      DE,HL
        LD      HL,(2147h)
        EX      DE,HL
        RST     CompareHLDE
        JP      Z,L0D31
        LD      A,(HL)
        INC     HL
        INC     HL
        OR      A
        CALL    L0D5D
        JP      L0D1D

L0D30:  POP     BC
L0D31:  EX      DE,HL
        LD      HL,(VAR_TOP)
        EX      DE,HL
        RST     CompareHLDE
        JP      Z,L0D7D
        CALL    L11B4
        LD      A,E
        PUSH    HL
        ADD     HL,BC
        OR      A
        JP      P,L0D30
        LD      (2131h),HL
        POP     HL
        LD      C,(HL)
        LD      B,00h
        ADD     HL,BC
        ADD     HL,BC
        INC     HL
        EX      DE,HL
        LD      HL,(2131h)
        EX      DE,HL
        RST     CompareHLDE
        JP      Z,L0D31
        LD      BC,0D4Eh
L0D5A:  PUSH    BC
        OR      80h
        ; --- START PROC L0D5D ---
L0D5D:  RST     PushNextWord
        RST     PushNextWord
        POP     DE
        POP     BC
        RET     P
        LD      A,C
        OR      A
        RET     Z
        LD      B,H
        LD      C,L
        LD      HL,(STR_TOP)
        RST     CompareHLDE
        LD      H,B
        LD      L,C
        RET     C
        POP     HL
        EX      (SP),HL
        RST     CompareHLDE
        EX      (SP),HL
        PUSH    HL
        LD      H,B
        LD      L,C
        RET     NC
        POP     BC
        POP     AF
        POP     AF
        PUSH    HL
        PUSH    DE
        PUSH    BC
        RET

        ; --- START PROC L0D7D ---
L0D7D:  POP     DE
        POP     HL
        LD      A,L
        OR      H
        RET     Z
        DEC     HL
        LD      B,(HL)
        DEC     HL
        LD      C,(HL)
        PUSH    HL
        DEC     HL
        DEC     HL
        LD      L,(HL)
        LD      H,00h
        ADD     HL,BC
        LD      D,B
        LD      E,C
        DEC     HL
        LD      B,H
        LD      C,L
        LD      HL,(STR_TOP)
        CALL    L0069
        POP     HL
        LD      (HL),C
        INC     HL
        LD      (HL),B
        LD      L,C
        LD      H,B
        DEC     HL
        JP      L0D00

        ; --- START PROC L0DA2 ---
L0DA2:  PUSH    BC
        PUSH    HL
        LD      HL,(214Dh)
        EX      (SP),HL
        CALL    L08E8
        EX      (SP),HL
        CALL    L086C+1         ; reference not aligned to instruction
        LD      A,(HL)
        PUSH    HL
        LD      HL,(214Dh)
        PUSH    HL
        ADD     A,(HL)
        LD      E,1Ch
        JP      C,Error
        CALL    L0C73
        POP     DE
        CALL    L0DF0
        EX      (SP),HL
        CALL    L0DEF
        PUSH    HL
        LD      HL,(212Dh)
        EX      DE,HL
        CALL    L0DD9
        CALL    L0DD9
        LD      HL,0889h
        EX      (SP),HL
        PUSH    HL
        JP      L0CA5

        ; --- START PROC L0DD9 ---
L0DD9:  POP     HL
        EX      (SP),HL
        RST     PushNextWord
        RST     PushNextWord
        POP     BC
        POP     HL
        ; --- START PROC L0DDF ---
L0DDF:  INC     L
L0DE0:  DEC     L
        RET     Z
        LD      A,(BC)
        LD      (DE),A
        INC     BC
        INC     DE
        JP      L0DE0

        ; --- START PROC EvalString ---
EvalString:
	CALL    L086C+1         ; reference not aligned to instruction
        ; --- START PROC EvalCurrentString ---
EvalCurrentString:  LD      HL,(214Dh)
        ; --- START PROC L0DEF ---
L0DEF:  EX      DE,HL
        ; --- START PROC L0DF0 ---
L0DF0:  LD      HL,(211Dh)
        DEC     HL
        LD      B,(HL)
        DEC     HL
        LD      C,(HL)
        DEC     HL
        DEC     HL
        RST     CompareHLDE
        EX      DE,HL
        RET     NZ
        LD      (211Dh),HL
        PUSH    DE
        LD      D,B
        LD      E,C
        DEC     DE
        LD      C,(HL)
        LD      HL,(STR_TOP)
        RST     CompareHLDE
        JP      NZ,L0E10
        LD      B,A
        ADD     HL,BC
        LD      (STR_TOP),HL
L0E10:  POP     HL
        RET

	INCLUDE	"fnLen.inc"
	INCLUDE	"fnAsc.inc"

Chr:	CALL    L0EDF
        POP     BC
L0E33:  LD      A,01h
        PUSH    DE
        CALL    L0C73
        POP     DE
        LD      HL,(212Dh)
        LD      (HL),E
        JP      L0CA5

Left:	CALL    L0ECB
        XOR     A
L0E45:  EX      (SP),HL
        LD      C,A
        PUSH    HL
        LD      A,(HL)
        CP      B
        JP      C,L0E4E+1       ; reference not aligned to instruction
        LD      A,B
L0E4E:  LD      DE,000Eh
        PUSH    BC
        CALL    L0CD5
        POP     BC
        POP     HL
        PUSH    HL
        INC     HL
        INC     HL
        LD      B,(HL)
        INC     HL
        LD      H,(HL)
        LD      L,B
        LD      B,00h
        ADD     HL,BC
        LD      B,H
        LD      C,L
        CALL    L0C76
        LD      L,A
        CALL    L0DDF
        POP     DE
        CALL    L0DF0
        JP      L0CA5

Right:	CALL    L0ECB
        POP     DE
        PUSH    DE
        LD      A,(DE)
        SUB     B
        JP      L0E45

Mid:	EX      DE,HL
        LD      A,(HL)
        CALL    L0ECE
        PUSH    BC
        LD      E,0FFh
        CP      29h             ; ')'
        JP      Z,L0E8D
        RST     SyntaxCheck
        INC     L
        CALL    L0EDC
L0E8D:  RST     SyntaxCheck
        ADD     HL,HL
        POP     AF
        EX      (SP),HL
        LD      BC,0E47h
        PUSH    BC
        DEC     A
        CP      (HL)
        LD      B,00h
        RET     NC
        LD      C,A
        LD      A,(HL)
        SUB     C
        CP      E
        LD      B,A
        RET     C
        LD      B,E
        RET

L0EA2:  JP      SyntaxError

L0EA5:  PUSH    BC
        LD      A,0DBh
        CALL    L0EAE
        JP      205Ch

        ; --- START PROC L0EAE ---
L0EAE:  LD      (205Ch),A
        LD      A,0C9h
        LD      (205Eh),A
        CALL    L0EDF
        LD      (205Dh),A
        RET

L0EBD:  JP      SyntaxError

L0EC0:  LD      A,0D3h
        CALL    L0EAE
        CALL    L0ED8
        JP      205Ch

        ; --- START PROC L0ECB ---
L0ECB:  EX      DE,HL
        RST     SyntaxCheck
        ADD     HL,HL
        ; --- START PROC L0ECE ---
L0ECE:  POP     BC
        POP     DE
        PUSH    BC
        LD      B,E
        INC     B
        DEC     B
        JP      Z,FunctionCallError
        RET

        ; --- START PROC L0ED8 ---
L0ED8:  RST     SyntaxCheck
        DB	','
	DB	06h		; ld b,..
L0EDB:	RST	NextChar
        ; --- START PROC L0EDC ---
L0EDC:  CALL    EvalNumericExpression
        ; --- START PROC L0EDF ---
L0EDF:  CALL    L04FD
        LD      A,D
        OR      A
        JP      NZ,FunctionCallError
        DEC     HL
        RST     NextChar
        LD      A,E
        RET

	INCLUDE	"fnVal.inc"

        ; --- START PROC L0F04 ---
L0F04:  LD      HL,13EFh
        ; --- START PROC L0F07 ---
L0F07:  CALL    L11B4
        JP      L0F16

        ; --- START PROC L0F0D ---
L0F0D:  CALL    L11B4
        DB	21h			;LD      HL,...

FSub:
	POP	BC			; Get lhs in BCDE.
	POP	DE

        ; --- START PROC L0F13 ---
L0F13:  CALL    L118E
        ; --- START PROC L0F16 ---
L0F16:  LD      A,B
        OR      A
        RET     Z
        LD      A,(2150h)
        OR      A
        JP      Z,L11A6
        SUB     B
        JP      NC,L0F30
        CPL
        INC     A
        EX      DE,HL
        CALL    L1196
        EX      DE,HL
        CALL    L11A6
        POP     BC
        POP     DE
L0F30:  CP      19h
        RET     NC
        PUSH    AF
        CALL    L11CB
        LD      H,A
        POP     AF
        CALL    L0FDD
        OR      H
        LD      HL,214Dh
        JP      P,L0F56
        CALL    L0FBD
        JP      NC,L0F9C
        INC     HL
        INC     (HL)
        JP      Z,L0FB8
        LD      L,01h
        CALL    L0FF3
        JP      L0F9C

L0F56:  XOR     A
        SUB     B
        LD      B,A
        LD      A,(HL)
        SBC     A,E
        LD      E,A
        INC     HL
        LD      A,(HL)
        SBC     A,D
        LD      D,A
        INC     HL
        LD      A,(HL)
        SBC     A,C
        LD      C,A
        ; --- START PROC L0F64 ---
L0F64:  CALL    C,L0FC9
        ; --- START PROC L0F67 ---
L0F67:  LD      L,B
        LD      H,E
        XOR     A
L0F6A:  LD      B,A
        LD      A,C
        OR      A
        JP      NZ,L0F89
        LD      C,D
        LD      D,H
        LD      H,L
        LD      L,A
        LD      A,B
        SUB     08h
        CP      0E0h
        JP      NZ,L0F6A
        ; --- START PROC FZero ---
FZero:  XOR     A
        ; --- START PROC L0F7D ---
L0F7D:  LD      (2150h),A
        RET

        ; --- START PROC L0F81 ---
L0F81:  DEC     B
        ADD     HL,HL
        LD      A,D
        RLA
        LD      D,A
        LD      A,C
        ADC     A,A
        LD      C,A
        ; --- START PROC L0F89 ---
L0F89:  JP      P,L0F81
        LD      A,B
        LD      E,H
        LD      B,L
        OR      A
        JP      Z,L0F9C
L0F93:  LD      HL,2150h
        ADD     A,(HL)
        LD      (HL),A
        JP      NC,FZero
        RET     Z
        ; --- START PROC L0F9C ---
L0F9C:  LD      A,B
        ; --- START PROC L0F9D ---
L0F9D:  LD      HL,2150h
        OR      A
        CALL    M,L0FAE
        LD      B,(HL)
        INC     HL
        LD      A,(HL)
        AND     80h
        XOR     C
        LD      C,A
        JP      L11A6

        ; --- START PROC L0FAE ---
L0FAE:  INC     E
        RET     NZ
        INC     D
        RET     NZ
        INC     C
        RET     NZ
        LD      C,80h
        INC     (HL)
        RET     NZ
        ; --- START PROC L0FB8 ---
L0FB8:  LD      E,0Ah
        JP      Error

        ; --- START PROC L0FBD ---
L0FBD:  LD      A,(HL)
        ADD     A,E
        LD      E,A
        INC     HL
        LD      A,(HL)
        ADC     A,D
        LD      D,A
        INC     HL
        LD      A,(HL)
        ADC     A,C
        LD      C,A
        RET

        ; --- START PROC L0FC9 ---
L0FC9:  LD      HL,2151h
        LD      A,(HL)
        CPL
        LD      (HL),A
        XOR     A
        LD      L,A
        SUB     B
        LD      B,A
        LD      A,L
        SBC     A,E
        LD      E,A
        LD      A,L
        SBC     A,D
        LD      D,A
        LD      A,L
        SBC     A,C
        LD      C,A
        RET

        ; --- START PROC L0FDD ---
L0FDD:  LD      B,00h
L0FDF:  SUB     08h
        JP      C,L0FEC
        LD      B,E
        LD      E,D
        LD      D,C
        LD      C,00h
        JP      L0FDF

L0FEC:  ADD     A,09h
        LD      L,A
        ; --- START PROC L0FEF ---
L0FEF:  XOR     A
        DEC     L
        RET     Z
        LD      A,C
        ; --- START PROC L0FF3 ---
L0FF3:  RRA
        LD      C,A
        LD      A,D
        RRA
        LD      D,A
        LD      A,E
        RRA
        LD      E,A
        LD      A,B
        RRA
        LD      B,A
        JP      L0FEF

L1001:  NOP
        NOP
        NOP
        ADD     A,C
        INC     BC
        XOR     D
        LD      D,(HL)
        ADD     HL,DE
        ADD     A,B
        POP     AF
        LD      (8076h),HL
        LD      B,L
        XOR     D
        DB 38h, 82h
        ; --- START PROC Log ---
Log:	RST     FTestSign
        JP      PE,FunctionCallError
        LD      HL,2150h
        LD      A,(HL)
        LD      BC,8035h
        LD      DE,04F3h
        SUB     B
        PUSH    AF
        LD      (HL),B
        PUSH    DE
        PUSH    BC
        CALL    L0F16
        POP     BC
        POP     DE
        INC     B
        CALL    L10B2
        LD      HL,1001h
        CALL    L0F0D
        LD      HL,1005h
        CALL    L14B0
        LD      BC,8080h
        LD      DE,0000h
        CALL    L0F16
        POP     AF
        CALL    L12FC
        ; --- START PROC L1047 ---
L1047:  LD      BC,8031h
        LD      DE,7218h
        DB	21h		;LD      HL,...

FMul:					
	POP	BC			; Get lhs in BCDE
	POP	DE
        ; --- START PROC L1050 ---
L1050:  RST     FTestSign
        RET     Z
        LD      L,00h
        CALL    L112E
        LD      A,C
        LD      (204Ah),A
        EX      DE,HL
        LD      (204Bh),HL
        LD      BC,0000h
        LD      D,B
        LD      E,B
        LD      HL,0F67h
        PUSH    HL
        LD      HL,1070h
        PUSH    HL
        PUSH    HL
        LD      HL,214Dh
        LD      A,(HL)
        INC     HL
        OR      A
        JP      Z,L109F
        PUSH    HL
        EX      DE,HL
        LD      E,08h
L107A:  RRA
        LD      D,A
        LD      A,C
        JP      NC,L108C
        PUSH    DE
        EX      DE,HL
        LD      HL,(204Bh)
        ADD     HL,DE
        LD      E,A
        LD      A,(204Ah)
        ADC     A,E
        POP     DE
L108C:  RRA
        LD      C,A
        LD      A,H
        RRA
        LD      H,A
        LD      A,L
        RRA
        LD      L,A
        LD      A,B
        RRA
        LD      B,A
        DEC     E
        LD      A,D
        JP      NZ,L107A
        EX      DE,HL
        ; --- START PROC L109D ---
L109D:  POP     HL
        RET

        ; --- START PROC L109F ---
L109F:  LD      B,E
        LD      E,D
        LD      D,C
        LD      C,A
        RET

        ; --- START PROC L10A4 ---
L10A4:  CALL    L1196
        LD      BC,8420h
        LD      DE,0000h
        CALL    L11A6
FDiv:	POP     BC
        POP     DE
        ; --- START PROC L10B2 ---
L10B2:  RST     FTestSign
        JP      Z,L00A1+1       ; reference not aligned to instruction
        LD      L,0FFh
        CALL    L112E
        INC     (HL)
        INC     (HL)
        DEC     HL
        LD      A,(HL)
        LD      (204Dh),A
        DEC     HL
        LD      A,(HL)
        LD      (204Eh),A
        DEC     HL
        LD      A,(HL)
        LD      (2059h),A
        LD      B,C
        EX      DE,HL
        XOR     A
        LD      C,A
        LD      D,A
        LD      E,A
        LD      (205Ah),A
L10D5:  PUSH    HL
        PUSH    BC
        PUSH    DE
        LD      A,(2059h)
        LD      E,A
        LD      A,L
        SUB     E
        LD      L,A
        LD      A,(204Eh)
        LD      E,A
        LD      A,H
        SBC     A,E
        LD      H,A
        LD      A,(204Dh)
        LD      E,A
        LD      A,B
        SBC     A,E
        LD      B,A
        LD      A,(205Ah)
        SBC     A,00h
        POP     DE
        CCF
        JP      NC,L10FD+1      ; reference not aligned to instruction
        LD      (205Ah),A
        POP     AF
        POP     AF
        SCF
L10FD:  JP      NC,0E1C1h
        LD      A,C
        INC     A
        DEC     A
        RRA
        JP      M,L0F9D
        RLA
        LD      A,E
        RLA
        LD      E,A
        LD      A,D
        RLA
        LD      D,A
        LD      A,C
        RLA
        LD      C,A
        ADD     HL,HL
        LD      A,B
        RLA
        LD      B,A
        LD      A,(205Ah)
        RLA
        LD      (205Ah),A
        LD      A,C
        OR      D
        OR      E
        JP      NZ,L10D5
        PUSH    HL
        LD      HL,2150h
        DEC     (HL)
        POP     HL
        JP      NZ,L10D5
        JP      L0FB8

        ; --- START PROC L112E ---
L112E:  LD      A,B
        OR      A
        JP      Z,L1150
        LD      A,L
        LD      HL,2150h
        XOR     (HL)
        ADD     A,B
        LD      B,A
        RRA
        XOR     B
        LD      A,B
        JP      P,L114F
        ADD     A,80h
        LD      (HL),A
        JP      Z,L109D
        CALL    L11CB
        LD      (HL),A
        DEC     HL
        RET

        ; --- START PROC L114C ---
L114C:  RST     FTestSign
        CPL
        POP     HL
L114F:  OR      A
L1150:  POP     HL
        JP      P,FZero
        JP      L0FB8

        ; --- START PROC L1157 ---
L1157:  CALL    L11B1
        LD      A,B
        OR      A
        RET     Z
        ADD     A,02h
        JP      C,L0FB8
        LD      B,A
        CALL    L0F16
        LD      HL,2150h
        INC     (HL)
        RET     NZ
        JP      L0FB8

FTestSign_tail:
	LD      A,(214Fh)
        CP      2Fh             ; '/'
        RLA
L1174:  SBC     A,A
        RET     NZ
        INC     A
        RET

Sgn:	RST     FTestSign
        ; --- START PROC L1179 ---
L1179:  LD      B,88h
        LD      DE,0000h
        ; --- START PROC ReturnInteger ---
ReturnInteger:  LD      HL,2150h
        LD      C,A
        LD      (HL),B
        LD      B,00h
        INC     HL
        LD      (HL),80h
        RLA
        JP      L0F64

Abs:	RST     FTestSign
        RET     P
        ; --- START PROC L118E ---
L118E:  LD      HL,214Fh
        LD      A,(HL)
        XOR     80h
        LD      (HL),A
        RET

        ; --- START PROC L1196 ---
L1196:  EX      DE,HL
        LD      HL,(214Dh)
        EX      (SP),HL
        PUSH    HL
        LD      HL,(214Fh)
        EX      (SP),HL
        PUSH    HL
        EX      DE,HL
        RET

        ; --- START PROC L11A3 ---
L11A3:  CALL    L11B4
        ; --- START PROC L11A6 ---
L11A6:  EX      DE,HL
        LD      (214Dh),HL
        LD      H,B
        LD      L,C
        LD      (214Fh),HL
        EX      DE,HL
        RET

        ; --- START PROC L11B1 ---
L11B1:  LD      HL,214Dh
        ; --- START PROC L11B4 ---
L11B4:  LD      E,(HL)
        INC     HL
        LD      D,(HL)
        INC     HL
        LD      C,(HL)
        INC     HL
        LD      B,(HL)
        ; --- START PROC L11BB ---
L11BB:  INC     HL
        RET

        ; --- START PROC L11BD ---
L11BD:  LD      DE,214Dh
        ; --- START PROC L11C0 ---
L11C0:  LD      B,04h
L11C2:  LD      A,(DE)
        LD      (HL),A
        INC     DE
        INC     HL
        DEC     B
        JP      NZ,L11C2
        RET

        ; --- START PROC L11CB ---
L11CB:  LD      HL,214Fh
        LD      A,(HL)
        RLCA
        SCF
        RRA
        LD      (HL),A
        CCF
        RRA
        INC     HL
        INC     HL
        LD      (HL),A
        LD      A,C
        RLCA
        SCF
        RRA
        LD      C,A
        RRA
        XOR     (HL)
        RET

        ; --- START PROC L11E0 ---
L11E0:  LD      A,B
        OR      A
        JP      Z,FTestSign
        LD      HL,1172h
        PUSH    HL
        RST     FTestSign
        LD      A,C
        RET     Z
        LD      HL,214Fh
        XOR     (HL)
        LD      A,C
        RET     M
        CALL    L11F8
        RRA
        XOR     C
        RET

        ; --- START PROC L11F8 ---
L11F8:  INC     HL
        LD      A,B
        CP      (HL)
        RET     NZ
        DEC     HL
        LD      A,C
        CP      (HL)
        RET     NZ
        DEC     HL
        LD      A,D
        CP      (HL)
        RET     NZ
        DEC     HL
        LD      A,E
        SUB     (HL)
        RET     NZ
        POP     HL
        POP     HL
        RET

        ; --- START PROC L120B ---
L120B:  LD      B,A
        LD      C,A
        LD      D,A
        LD      E,A
        OR      A
        RET     Z
        PUSH    HL
        CALL    L11B1
        CALL    L11CB
        XOR     (HL)
        LD      H,A
        CALL    M,L122F
        LD      A,98h
        SUB     B
        CALL    L0FDD
        LD      A,H
        RLA
        CALL    C,L0FAE
        LD      B,00h
        CALL    C,L0FC9
        POP     HL
        RET

        ; --- START PROC L122F ---
L122F:  DEC     DE
        LD      A,D
        AND     E
        INC     A
        RET     NZ
        DEC     C
        RET

        ; --- START PROC Int ---
Int:	LD      HL,2150h
        LD      A,(HL)
        CP      98h
        LD      A,(214Dh)
        RET     NC
        LD      A,(HL)
        CALL    L120B
        LD      (HL),98h
        LD      A,E
        PUSH    AF
        LD      A,C
        RLA
        CALL    L0F64
        POP     AF
        RET

        ; --- START PROC L124F ---
L124F:  LD      HL,0000h
        LD      A,B
        OR      C
        RET     Z
        LD      A,10h
L1257:  ADD     HL,HL
        JP      C,L0B1D
        EX      DE,HL
        ADD     HL,HL
        EX      DE,HL
        JP      NC,L1265
        ADD     HL,BC
        JP      C,L0B1D
L1265:  DEC     A
        JP      NZ,L1257
        RET

        ; --- START PROC L126A ---
L126A:  LD      A,(2136h)
        OR      A
        JP      Z,EvalNumericExpression
        LD      A,(HL)
        ; --- START PROC FIn ---
FIn:  CP      2Dh             ; '-'
        PUSH    AF
        JP      Z,L127E
        CP      2Bh             ; '+'
        JP      Z,L127E
        DEC     HL
L127E:  CALL    FZero
        LD      B,A
        LD      D,A
        LD      E,A
        CPL
        LD      C,A
        ; --- START PROC L1286 ---
L1286:  RST     NextChar
        JP      C,L12E5
        CP      26h             ; '&'
        JP      NZ,L1294
        CALL    L16AB
        POP     AF
        RET

L1294:  CP      2Eh             ; '.'
        JP      Z,L12C0
        CP      45h             ; 'E'
        JP      NZ,L12C4
        RST     NextChar
        PUSH    HL
        LD      HL,12B4h
        EX      (SP),HL
        DEC     D
        CP      0A5h
        RET     Z
        CP      2Dh             ; '-'
        RET     Z
        INC     D
        CP      2Bh             ; '+'
        RET     Z
        CP      0A4h
        RET     Z
        POP     AF
        DEC     HL
        ; --- START PROC L12B4 ---
L12B4:  RST     NextChar
        JP      C,L1307
        INC     D
        JP      NZ,L12C4
        XOR     A
        SUB     E
        LD      E,A
        INC     C
        ; --- START PROC L12C0 ---
L12C0:  INC     C
        JP      Z,L1286
        ; --- START PROC L12C4 ---
L12C4:  PUSH    HL
        LD      A,E
        SUB     B
L12C7:  CALL    P,L12DD
        JP      P,L12D3
        PUSH    AF
        CALL    L10A4
        POP     AF
        INC     A
L12D3:  JP      NZ,L12C7
        POP     DE
        POP     AF
        CALL    Z,L118E
        EX      DE,HL
        RET

        ; --- START PROC L12DD ---
L12DD:  RET     Z
        ; --- START PROC L12DE ---
L12DE:  PUSH    AF
        CALL    L1157
        POP     AF
        DEC     A
        RET

        ; --- START PROC L12E5 ---
L12E5:  PUSH    DE
        LD      D,A
        LD      A,B
        ADC     A,C
        LD      B,A
        PUSH    BC
        PUSH    HL
        PUSH    DE
        CALL    L1157
        POP     AF
        SUB     30h             ; '0'
        CALL    L12FC
        POP     HL
        POP     BC
        POP     DE
        JP      L1286

        ; --- START PROC L12FC ---
L12FC:  CALL    L1196
        CALL    L1179
FAdd:
        POP     BC
        POP     DE
        JP      L0F16

        ; --- START PROC L1307 ---
L1307:  LD      A,E
        RLCA
        RLCA
        ADD     A,E
        RLCA
        ADD     A,(HL)
        SUB     30h             ; '0'
        LD      E,A
        JP      L12B4

        ; --- START PROC L1313 ---
L1313:  PUSH    HL
        LD      HL,1DD9h
        CALL    0F818h
        POP     HL
        ; --- START PROC L131B ---
L131B:  EX      DE,HL
        ; --- START PROC L131C ---
L131C:  XOR     A
        LD      B,98h
        CALL    ReturnInteger
        LD      HL,0CC2h
        PUSH    HL
        ; --- START PROC L1326 ---
L1326:  LD      HL,2152h
        PUSH    HL
        RST     FTestSign
        LD      (HL),20h        ; ' '
        JP      P,L1332
        LD      (HL),2Dh        ; '-'
L1332:  INC     HL
        LD      (HL),30h        ; '0'
        JP      Z,L13DB
        PUSH    HL
        CALL    M,L118E
        XOR     A
        PUSH    AF
        CALL    L13E1
L1341:  LD      BC,9143h
        LD      DE,4FF8h
        CALL    L11E0
        JP      PO,L135E
        POP     AF
        CALL    L12DE
        PUSH    AF
        JP      L1341

        ; --- START PROC L1355 ---
L1355:  CALL    L10A4
        POP     AF
        INC     A
        PUSH    AF
        CALL    L13E1
L135E:  CALL    L0F04
        INC     A
        CALL    L120B
        CALL    L11A6
        LD      BC,0206h
        POP     AF
        ADD     A,C
        JP      M,L1379
        CP      07h
        JP      NC,L1379
        INC     A
        LD      B,A
        LD      A,01h
L1379:  DEC     A
        POP     HL
        PUSH    AF
        LD      DE,13F3h
L137F:  DEC     B
        LD      (HL),2Eh        ; '.'
        CALL    Z,L11BB
        PUSH    BC
        PUSH    HL
        PUSH    DE
        CALL    L11B1
        POP     HL
        LD      B,2Fh           ; '/'
L138E:  INC     B
        LD      A,E
        SUB     (HL)
        LD      E,A
        INC     HL
        LD      A,D
        SBC     A,(HL)
        LD      D,A
        INC     HL
        LD      A,C
        SBC     A,(HL)
        LD      C,A
        DEC     HL
        DEC     HL
        JP      NC,L138E
        CALL    L0FBD
        INC     HL
        CALL    L11A6
        EX      DE,HL
        POP     HL
        LD      (HL),B
        INC     HL
        POP     BC
        DEC     C
        JP      NZ,L137F
        DEC     B
        JP      Z,L13BF
L13B3:  DEC     HL
        LD      A,(HL)
        CP      30h             ; '0'
        JP      Z,L13B3
        CP      2Eh             ; '.'
        CALL    NZ,L11BB
L13BF:  POP     AF
        JP      Z,L13DE
        LD      (HL),45h        ; 'E'
        INC     HL
        LD      (HL),2Bh        ; '+'
        JP      P,L13CF
        LD      (HL),2Dh        ; '-'
        CPL
        INC     A
L13CF:  LD      B,2Fh           ; '/'
L13D1:  INC     B
        SUB     0Ah
        JP      NC,L13D1
        ADD     A,3Ah           ; ':'
        INC     HL
        LD      (HL),B
L13DB:  INC     HL
        LD      (HL),A
        INC     HL
L13DE:  LD      (HL),C
        POP     HL
        RET

        ; --- START PROC L13E1 ---
L13E1:  LD      BC,9474h
        LD      DE,23F7h
        CALL    L11E0
        POP     HL
        JP      PO,L1355
        JP      (HL)

L13EF:  NOP
        NOP
        NOP
        ADD     A,B
        AND     B
        ADD     A,(HL)
        LD      BC,2710h
        NOP
        RET     PE
        INC     BC
        NOP
        LD      H,H
        NOP
        NOP
        LD      A,(BC)
        NOP
        NOP
        LD      BC,0000h
        ; --- START PROC L1405 ---
L1405:  LD      HL,118Eh
        EX      (SP),HL
        JP      (HL)

        ; --- START PROC Sqr ---
Sqr:	CALL    L1196
        LD      HL,13EFh
        CALL    L11A3

FPower:
        POP     BC
        POP     DE
        ; --- START PROC L1415 ---
L1415:  RST     FTestSign
        JP      Z,Exp
        LD      A,B
        OR      A
        JP      Z,L0F7D
        PUSH    DE
        PUSH    BC
        LD      A,C
        OR      7Fh             ; ''
        CALL    L11B1
        JP      P,L1437
        PUSH    DE
        PUSH    BC
        CALL    Int
        POP     BC
        POP     DE
        PUSH    AF
        CALL    L11E0
        POP     HL
        LD      A,H
        RRA
L1437:  POP     HL
        LD      (214Fh),HL
        POP     HL
        LD      (214Dh),HL
        CALL    C,L1405
        CALL    Z,L118E
        PUSH    DE
        PUSH    BC
        CALL    Log
        POP     BC
        POP     DE
        CALL    L1050
Exp:	CALL    L1196
        LD      BC,8138h
        LD      DE,0AA38h
        CALL    L1050
        LD      A,(2150h)
        CP      88h
        JP      NC,L114C
        CALL    Int
        ADD     A,80h
        ADD     A,02h
        JP      C,L114C
        PUSH    AF
        LD      HL,1001h
        CALL    L0F07
        CALL    L1047
        POP     AF
        POP     BC
        POP     DE
        PUSH    AF
        CALL    L0F13
        CALL    L118E
        LD      HL,148Fh
        CALL    L14BF
        LD      DE,0000h
        POP     BC
        LD      C,D
        JP      L1050

L148F:  db 08h
        LD      B,B
        LD      L,94h
        LD      (HL),H
        LD      (HL),B
        LD      C,A
        LD      L,77h           ; 'w'
        LD      L,(HL)
        LD      (BC),A
        ADC     A,B
        LD      A,D
        AND     0A0h
        LD      HL,(507Ch)
        XOR     D
        XOR     D
        LD      A,(HL)
        RST     38H
        RST     38H
        LD      A,A
        LD      A,A
        NOP
        NOP
        ADD     A,B
        ADD     A,C
        NOP
        NOP
        NOP
        ADD     A,C
        ; --- START PROC L14B0 ---
L14B0:  CALL    L1196
        LD      DE,104Eh
        PUSH    DE
        PUSH    HL
        CALL    L11B1
        CALL    L1050
        POP     HL
        ; --- START PROC L14BF ---
L14BF:  CALL    L1196
        LD      A,(HL)
        INC     HL
        CALL    L11A3
L14C7:  LD      B,0F1h
        POP     BC
        POP     DE
        DEC     A
        RET     Z
        PUSH    DE
        PUSH    BC
        PUSH    AF
        PUSH    HL
        CALL    L1050
        POP     HL
        CALL    L11B4
        PUSH    HL
        CALL    L0F16
        POP     HL
        JP      L14C7+1         ; reference not aligned to instruction

Rnd:	RST     FTestSign
        JP      M,L14FD
        LD      HL,206Dh
        CALL    L11A3
        RET     Z
        LD      BC,9835h
        LD      DE,447Ah
        CALL    L1050
        LD      BC,6828h
        LD      DE,0B146h
        CALL    L0F16
L14FD:  CALL    L11B1
        LD      A,E
        LD      E,C
        LD      C,A
        LD      (HL),80h
        DEC     HL
        LD      B,(HL)
        LD      (HL),80h
        CALL    L0F67
        LD      HL,206Dh
        JP      L11BD

        ; --- START PROC Cos ---
Cos:	LD      HL,1558h
        CALL    L0F07
        ; --- START PROC Sin ---
Sin:	CALL    L1196
        LD      BC,8349h
        LD      DE,0FDBh
        CALL    L11A6
        POP     BC
        POP     DE
        CALL    L10B2
        CALL    L1196
        CALL    Int
        POP     BC
        POP     DE
        CALL    L0F13
        LD      HL,155Ch
        CALL    L0F0D
        RST     FTestSign
        SCF
        JP      P,L1544
        CALL    L0F04
        RST     FTestSign
        OR      A
L1544:  PUSH    AF
        CALL    P,L118E
        LD      HL,155Ch
        CALL    L0F07
        POP     AF
        CALL    NC,L118E
        LD      HL,1560h
        JP      L14B0

L1558:  IN      A,(0Fh)
        LD      C,C
        ADD     A,C
        NOP
        NOP
        NOP
        LD      A,A
        DEC     B
        CP      D
        RST     NextChar
        LD      E,86h
        LD      H,H
        LD      H,99h
        ADD     A,A
        LD      E,B
        INC     (HL)
        INC     HL
        ADD     A,A
        RET     PO
        LD      E,L
        AND     L
        ADD     A,(HL)
        JP      C,490Fh
        ADD     A,E
        XOR     D
        JP      PO,0EEF7h
        AND     B
        CP      B
        OR      A
        XOR     D

Tan:
	CALL    L1196
        CALL    Sin
        POP     BC
        POP     HL
        CALL    L1196
        EX      DE,HL
        CALL    L11A6
        CALL    Cos
        JP      FDiv

        ; --- START PROC Atn ---
Atn:	RST     FTestSign
        CALL    M,L1405
        CALL    M,L118E
        LD      A,(2150h)
        CP      81h
        JP      C,L15AD
        LD      BC,8100h
        LD      D,C
        LD      E,C
        CALL    L10B2
        LD      HL,0F0Dh
        PUSH    HL
L15AD:  LD      HL,15B7h
        CALL    L14B0
        LD      HL,1558h
        RET

L15B7:  ADD     HL,BC
        LD      C,D
        RST     NextChar
        DEC     SP
        LD      A,B
        LD      (BC),A
        LD      L,(HL)
        ADD     A,H
        LD      A,E
        CP      0C1h
        CPL
        LD      A,H
        LD      (HL),H
        LD      SP,7D9Ah
        ADD     A,H
        DEC     A
        LD      E,D
        LD      A,L
        RET     Z
        LD      A,A
        SUB     C
        LD      A,(HL)
        CALL    PO,4CBBh
        LD      A,(HL)
        LD      L,H
        XOR     D
        XOR     D
        LD      A,A
        NOP
        NOP
        NOP
        ADD     A,C
        NOP
        NOP

	INCLUDE	"fnPeek.inc"

Poke:
	CALL    EvalNumericExpression
        RST     FTestSign
        CALL    FTestIntegerExpression
        PUSH    DE
        CALL    L0ED8
        POP     DE
        LD      (DE),A
        RET

	INCLUDE	"fnUsr.inc"

        ; --- START PROC CallHL ---
CallHL:  JP      (HL)

Init:   LD      HL,(L0026)
        LD      (PROGRAM_BASE),HL
        LD      HL,(Start+1)    ; reference not aligned to instruction
        DEC     HL
        LD      (211Bh),HL
        LD      DE,0FFCEh
        ADD     HL,DE
        LD      (STACK_TOP),HL
        XOR     A
        LD      (TERMINAL_X),A
        LD      HL,804Fh
        LD      (206Dh),HL
        LD      (206Fh),HL
        LD      A,2Ch           ; ','
        LD      (208Fh),A
        LD      HL,1DE4h
        CALL    0F818h
        CALL    L0351
        RST     18H
        CP      59h             ; 'Y'
        CALL    New
        ; --- START PROC L1635 ---
L1635:  CALL    L01D6
        JP      L00F1

        ; --- START PROC L163B ---
L163B:  EX      DE,HL
        CALL    L131B
        LD      DE,LINE_BUFFER
        LD      HL,2153h
L1645:  LD      A,(HL)
        LD      (DE),A
        INC     DE
        INC     HL
        OR      A
        JP      NZ,L1645
        DEC     DE
        LD      A,20h           ; ' '
L1650:  POP     HL
L1651:  AND     7Fh             ; ''
        LD      (DE),A
        RET     Z
        RST     18H
        INC     HL
        INC     DE
        LD      A,E
        CPL
        CP      0F0h
        JP      M,L0FB8
        LD      A,(HL)
        OR      A
        JP      P,L1651
        SUB     7Fh             ; ''
        LD      C,A
        PUSH    HL
        PUSH    DE
        LD      DE,KEYWORDS
L166C:  PUSH    DE
L166D:  LD      A,(DE)
        INC     DE
        OR      A
        JP      P,L166D
        DEC     C
        POP     HL
        JP      NZ,L166C
        POP     DE
L1679:  LD      A,(HL)
        OR      A
        JP      M,L1650
        LD      (DE),A
        RST     18H
        INC     HL
        INC     DE
        JP      L1679

Inkey:	CALL    0F81Bh
        OR      A
        LD      E,A
        JP      P,L0E33
        XOR     A
        CALL    L0C73
        JP      L0CA5

Home:
	LD      C,1Fh
        JP      0F809h

Pause:  CALL    L1A5F
        ; --- START PROC L169C ---
L169C:  LD      C,55h           ; 'U'
L169E:  DEC     C
        JP      NZ,L169E
        DEC     DE
        LD      A,D
        OR      E
        JP      NZ,L169C
        RET

Amp:	POP     HL
        DEC     HL
        ; --- START PROC L16AB ---
L16AB:  LD      DE,0000h
L16AE:  RST     NextChar
        JP      M,L16D7
        SUB     30h             ; '0'
        JP      M,L16D7
        CP      0Ah
        JP      M,L16C8
        CP      11h
        JP      M,L16D7
        CP      17h
        JP      P,L16D7
        SUB     07h
L16C8:  PUSH    HL
        LD      H,00h
        LD      L,A
        EX      DE,HL
        ADD     HL,HL
        ADD     HL,HL
        ADD     HL,HL
        ADD     HL,HL
        ADD     HL,DE
        EX      DE,HL
        POP     HL
        JP      L16AE

        ; --- START PROC L16D7 ---
L16D7:  PUSH    HL
        LD      A,D
        RLCA
        LD      A,00h
        JP      NC,L16E0
        DEC     A
L16E0:  LD      B,98h
        CALL    ReturnInteger
        POP     HL
        RET

Himem:	CALL    EvalNumericExpression
        CALL    FTestIntegerExpression
        DEC     HL
        RST     NextChar
        RET     NZ
        PUSH    HL
        LD      HL,(VAR_TOP)
        LD      BC,0400h
        ADD     HL,BC
        EX      DE,HL
        RST     CompareHLDE
L16FA:  LD      E,20h           ; ' '
        JP      C,Error
        EX      DE,HL
        LD      HL,(Start+1)    ; reference not aligned to instruction
        RST     CompareHLDE
        JP      C,L16FA
        EX      DE,HL
        LD      (211Bh),HL
        LD      BC,0FFCEh
        ADD     HL,BC
        LD      (STACK_TOP),HL
        POP     HL
        JP      ClearAll

Edit:
	CALL    LineNumberFromStr
        RET     NZ
        POP     BC
        ; --- START PROC L171B ---
L171B:  CALL    FindProgramLine
        LD      H,B
        LD      L,C
        RST     PushNextWord
        POP     BC
        LD      A,B
        OR      C
        JP      Z,L00F1
        CALL    L03D1
        CALL    L027C
        JP      L010D

Delete:
	CALL    L03B6
        JP      NC,SyntaxError
        POP     BC
        CALL    FindProgramLine
        PUSH    BC
        PUSH    BC
L173C:  POP     HL
        RST     PushNextWord
        POP     DE
        LD      A,D
        OR      E
        JP      Z,L1752
        PUSH    DE
        RST     PushNextWord
        POP     DE
        PUSH    HL
        LD      HL,(2078h)
        RST     CompareHLDE
        POP     HL
        JP      NC,L173C
        POP     DE
        DEC     HL
L1752:  DEC     HL
        DEC     HL
        DEC     HL
        EX      DE,HL
        POP     HL
L1757:  LD      C,03h
L1759:  LD      A,(DE)
        LD      (HL),A
        INC     HL
        INC     DE
        OR      A
        JP      NZ,L1757
        DEC     C
        JP      NZ,L1759
        JP      L1BC3

Renum:
	EX      DE,HL
        CALL    L01CD
        EX      DE,HL
        CALL    L189A
        PUSH    DE
        LD      A,(207Ah)
        LD      C,A
        LD      B,00h
        LD      HL,(VAR_TOP)
        EX      DE,HL
        LD      HL,(PROGRAM_BASE)
L177E:  PUSH    BC
        CALL    CheckEnoughVarSpace2
        INC     B
        POP     BC
        LD      A,(HL)
        INC     HL
        OR      (HL)
        JP      Z,L17B7
        INC     HL
        LD      A,(HL)
        INC     HL
        LD      (DE),A
        INC     DE
        LD      A,(HL)
        LD      (DE),A
        INC     DE
        EX      DE,HL
        EX      (SP),HL
        LD      A,H
        LD      (DE),A
        DEC     DE
        LD      A,L
        LD      (DE),A
        EX      (SP),HL
        EX      DE,HL
        EX      (SP),HL
        LD      A,L
        LD      (DE),A
        INC     DE
        LD      A,H
        LD      (DE),A
        ADD     HL,BC
        EX      (SP),HL
        EX      DE,HL
        INC     HL
        LD      (2147h),HL
        LD      (VAR_TOP),HL
        PUSH    HL
        EX      DE,HL
        DEC     HL
        DEC     HL
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        EX      DE,HL
        POP     DE
        JP      L177E

L17B7:  POP     HL
        LD      HL,(PROGRAM_BASE)
L17BB:  LD      A,(HL)
        INC     HL
        OR      (HL)
        JP      Z,L1BC8
        INC     HL
        INC     HL
L17C3:  RST     NextChar
        OR      A
        INC     HL
        JP      Z,L17BB
        DEC     HL
        JP      P,L17C3
        CP      89h
        JP      Z,L17E6
        CP      0A1h
        JP      Z,L17E6
        CP      88h
        JP      Z,L17E6
        CP      8Bh
        JP      Z,L17E6
        CP      8Ch
        JP      NZ,L17C3
L17E6:  PUSH    HL
        RST     NextChar
        POP     HL
        JP      NC,L17C3
        INC     HL
        PUSH    HL
        CALL    LineNumberFromStr
        PUSH    HL
        PUSH    DE
        LD      HL,(2145h)
        EX      DE,HL
L17F7:  LD      HL,(VAR_TOP)
        EX      DE,HL
        RST     CompareHLDE
        POP     DE
        JP      Z,L1813
        LD      A,(HL)
        INC     HL
        LD      B,(HL)
        INC     HL
        PUSH    HL
        LD      L,A
        LD      H,B
        RST     CompareHLDE
        POP     HL
        JP      Z,L181F
        INC     HL
        INC     HL
        PUSH    DE
        EX      DE,HL
        JP      L17F7

L1813:  POP     HL
        POP     AF
L1815:  LD      A,(HL)
        CP      2Ch             ; ','
        JP      Z,L17E6
        DEC     HL
        JP      L17C3

L181F:  LD      E,(HL)
        INC     HL
        LD      D,(HL)
        XOR     A
        LD      B,98h
        CALL    ReturnInteger
        CALL    L1326
        LD      HL,2153h
L182E:  LD      BC,0000h
        LD      A,(HL)
        OR      A
        JP      Z,L183B
        INC     BC
        INC     HL
        JP      L182E+2         ; reference not aligned to instruction

L183B:  POP     HL
        POP     DE
        PUSH    DE
        LD      A,L
        SUB     E
        INC     BC
        SUB     C
        CPL
        INC     A
        LD      C,A
        JP      Z,L1859
        JP      P,L1886
        LD      A,B
        CPL
        LD      B,A
        CALL    L1870
L1851:  RST     CompareHLDE
        LD      A,(HL)
        LD      (BC),A
        INC     HL
        INC     BC
        JP      NZ,L1851
L1859:  LD      HL,(2147h)
        LD      (VAR_TOP),HL
        POP     HL
        LD      (HL),20h        ; ' '
        LD      DE,2153h
L1865:  INC     HL
        LD      A,(DE)
        OR      A
        JP      Z,L1815
        LD      (HL),A
        INC     DE
        JP      L1865

        ; --- START PROC L1870 ---
L1870:  PUSH    HL
        ADD     HL,BC
        EX      DE,HL
        LD      HL,(2145h)
        ADD     HL,BC
        LD      (2145h),HL
        LD      HL,(VAR_TOP)
        ADD     HL,BC
        LD      (2147h),HL
        EX      DE,HL
        LD      B,H
        LD      C,L
        ; --- START PROC L1884 ---
L1884:  POP     HL
        RET

L1886:  CALL    L1870
        LD      B,D
        LD      C,E
        EX      DE,HL
        LD      HL,(VAR_TOP)
L188F:  RST     CompareHLDE
        JP      C,L1859
        LD      A,(HL)
        LD      (BC),A
        DEC     HL
        DEC     BC
        JP      L188F

        ; --- START PROC L189A ---
L189A:  LD      DE,000Ah
        LD      A,E
        LD      (207Ah),A
        CALL    L18C2
        LD      A,(HL)
        OR      A
        RET     Z
        CP      2Ch             ; ','
        JP      Z,L18B3
        CALL    LineNumberFromStr
        CALL    L18C2
        RET     Z
L18B3:  CALL    L0ED8
        OR      A
        JP      Z,L18BD
        LD      (207Ah),A
L18BD:  LD      HL,(207Bh)
        EX      DE,HL
        RET

        ; --- START PROC L18C2 ---
L18C2:  EX      DE,HL
        ; --- START PROC L18C3 ---
L18C3:  LD      (207Bh),HL
        EX      DE,HL
        RET

Auto:
	EX      DE,HL
        CALL    L01CD
        EX      DE,HL
        CALL    L189A
        ; --- START PROC L18D0 ---
L18D0:  LD      HL,18D7h
        PUSH    HL
        CALL    L163B
        NOP
        NOP
        CALL    L027C
        CALL    L06DA
        LD      A,02h
        LD      (2117h),A
        JP      L0110

        ; --- START PROC L18E7 ---
L18E7:  LD      D,00h
        LD      A,(207Ah)
        LD      E,A
        LD      HL,(207Bh)
        ADD     HL,DE
        CALL    L18C3
        JP      L18D0

        ; --- START PROC L18F7 ---
L18F7:  CALL    L0EDC
        CP      40h             ; '@'
        JP      NC,FunctionCallError
        LD      C,A
        PUSH    BC
        CALL    L0ED8
        POP     BC
        LD      B,A
        CP      19h
L1908:  JP      NC,FunctionCallError
        PUSH    HL
        LD      HL,7F12h
        LD      DE,0FFB2h
L1912:  OR      A
        JP      Z,L191B
        ADD     HL,DE
        DEC     A
        JP      L1912

L191B:  LD      D,A
        LD      E,C
        ADD     HL,DE
        POP     DE
        RET

        ; --- START PROC Cur ---
Cur:
	CALL    L18F7
        LD      (7600h),HL
        LD      A,1Bh
        SUB     B
        LD      H,A
        LD      A,C
        LD      (TERMINAL_X),A
        ADD     A,08h
        LD      L,A
        LD      (7602h),HL
        EX      DE,HL
        RET

Plot:
	CALL    L0EDC
        LD      (2054h),A
        CALL    L0ED8
        LD      (2055h),A
        CALL    L0ED8
        LD      (2056h),A
        ; --- START PROC L1948 ---
L1948:  LD      A,(2054h)
        OR      A
        JP      M,FunctionCallError
        LD      A,(2055h)
        CP      32h             ; '2'
        JP      NC,FunctionCallError
        XOR     A
        LD      A,(2054h)
        RRA
        LD      E,A
        LD      A,C
        RRA
        LD      C,A
        XOR     A
        LD      A,(2055h)
        RRA
        LD      D,A
        LD      A,C
        RLA
        RLA
        LD      C,A
        PUSH    BC
        LD      A,D
        LD      C,E
        CALL    L1908+2         ; reference not aligned to instruction
        POP     BC
        LD      A,C
        AND     03h
        LD      B,10h
        JP      Z,L1986
        LD      B,04h
        DEC     A
        JP      Z,L1986
        DEC     A
        LD      B,01h
        JP      Z,L1986
        INC     B
L1986:  LD      A,(HL)
        CP      20h             ; ' '
        JP      C,L198E
        XOR     A
        LD      (HL),A
L198E:  LD      A,(2056h)
        RRA
        LD      A,B
        JP      C,L199A
        CPL
        AND     (HL)
        LD      (HL),A
        XOR     A
L199A:  OR      (HL)
        LD      (HL),A
        EX      DE,HL
        RET

Line:	CALL    L0EDC
        LD      (2052h),A
        CALL    L0ED8
        LD      (2053h),A
        PUSH    HL
        LD      HL,0100h
        LD      (204Eh),HL
        LD      HL,0001h
        LD      (2050h),HL
        LD      HL,(2054h)
        LD      A,(2052h)
        SUB     L
        LD      E,A
        OR      A
        JP      P,L19CB
        CPL
        INC     A
        LD      E,A
        LD      A,0FFh
        LD      (2050h),A
L19CB:  LD      A,(2053h)
        SUB     H
        LD      D,A
        OR      A
        JP      P,L19DC
        CPL
        INC     A
        LD      D,A
        LD      A,0FFh
        LD      (204Fh),A
L19DC:  LD      A,E
        CP      D
        JP      P,L19F7
        LD      B,E
        LD      E,D
        LD      D,B
        LD      A,(2050h)
        LD      (204Eh),A
        LD      A,(204Fh)
        LD      (2051h),A
        XOR     A
        LD      (2050h),A
        LD      (204Fh),A
L19F7:  LD      A,E
        RRA
        LD      C,A
        LD      B,01h
        ; --- START PROC L19FC ---
L19FC:  LD      A,E
        CP      B
        JP      M,L1884
        LD      HL,(2054h)
        LD      A,(2050h)
        ADD     A,L
        LD      (2054h),A
        LD      A,(2051h)
        ADD     A,H
        LD      (2055h),A
        LD      A,D
        ADD     A,C
        LD      C,A
        INC     B
        LD      A,E
        ; --- START PROC L1A17 ---
L1A17:  CP      C
        JP      P,L1A2F
        LD      A,C
        SUB     E
        LD      C,A
        LD      HL,(2054h)
        LD      A,(204Eh)
        ADD     A,L
        LD      (2054h),A
        LD      A,(204Fh)
        ADD     A,H
        LD      (2055h),A
L1A2F:  PUSH    BC
        PUSH    DE
        CALL    L1948
        POP     DE
        POP     BC
        JP      L19FC

Screen:	POP     HL
        CALL    L18F7
        EX      DE,HL
        RST     SyntaxCheck
        ADD     HL,HL
        EX      DE,HL
        PUSH    DE
        LD      E,(HL)
        JP      L0E33

        ; --- START PROC L1A46 ---
L1A46:  RST     NextChar
        RST     SyntaxCheck
        DB	28H, 0cdh
        LD      C,C
        LD      A,(BC)
        RST     SyntaxCheck
        ADD     HL,HL
        XOR     A
        LD      (VALTYP),A
        JP      L16D7

        ; --- START PROC L1A55 ---
L1A55:  RST     NextChar
        LD      BC,8249h
        LD      DE,0FDBh
        JP      L11A6

        ; --- START PROC L1A5F ---
L1A5F:  CALL    EvalNumericExpression
        RST     FTestSign
        POP     BC
        JP      Z,0F803h
        PUSH    BC
        PUSH    HL
        LD      BC,8A7Ah
        LD      DE,0000h
        CALL    L1050
        CALL    L04FD
        POP     HL
        RET

Beep:	CALL    L1A5F
        PUSH    DE
        RST     SyntaxCheck
        INC     L
        CALL    EvalNumericExpression
        EX      (SP),HL
        PUSH    HL
        LD      BC,8107h
        LD      DE,9C7Dh
        CALL    L1415
        LD      BC,865Ah
        LD      DE,0FA95h
        CALL    L10B2
        CALL    L04FD
        EX      DE,HL
        POP     DE
        LD      B,20h           ; ' '
L1A9B:  PUSH    HL
        LD      A,C
        XOR     01h
        LD      C,A
        LD      (8002h),A
L1AA3:  DEC     B
        JP      NZ,L1AAF
        DEC     DE
        LD      A,D
        OR      E
        JP      Z,L1AB9
        LD      B,20h           ; ' '
L1AAF:  DEC     HL
        LD      A,H
        OR      L
        JP      NZ,L1AA3
        POP     HL
        JP      L1A9B

L1AB9:  POP     HL
        POP     HL
        RET

        ; --- START PROC L1ABC ---
L1ABC:  PUSH    HL
        LD      A,(HL)
        CP      22h             ; '"'
        JP      NZ,SyntaxError
L1AC3:  INC     HL
        LD      A,(HL)
        OR      A
        JP      Z,SyntaxError
        CP      22h             ; '"'
        JP      NZ,L1AC3
        POP     HL
        RET

        ; --- START PROC L1AD0 ---
L1AD0:  PUSH    HL
        LD      HL,(PROGRAM_BASE)
        LD      DE,0000h
L1AD7:  LD      B,03h
L1AD9:  LD      A,(HL)
        ADD     A,E
        LD      E,A
        LD      A,00h
        ADC     A,D
        LD      D,A
        LD      A,(HL)
        INC     HL
        OR      A
        JP      NZ,L1AD7
        DEC     B
        JP      NZ,L1AD9
        EX      DE,HL
        LD      (2115h),HL
        POP     HL
        RET

        ; --- START PROC L1AF0 ---
L1AF0:  LD      B,00h
L1AF2:  CALL    L1CCF
        DEC     B
        JP      NZ,L1AF2
        DEC     E
        JP      NZ,L1AF0
        RET

        ; --- START PROC L1AFE ---
L1AFE:  CALL    L1CCF
        DEC     E
        JP      NZ,L1AFE
        RET

Csave:  CALL    L1ABC
        CALL    L1AD0
        XOR     A
        LD      E,01h
        CALL    L1AF0
        LD      A,0E6h
        CALL    L1CCF
        LD      A,0D3h
        LD      E,04h
        CALL    L1AFE
L1B1E:  INC     HL
        LD      A,(HL)
        CP      22h             ; '"'
        JP      Z,L1B2B
        CALL    L1CCF
        JP      L1B1E

L1B2B:  INC     HL
        EX      DE,HL
        LD      HL,(L1BB9+1)    ; reference not aligned to instruction
        LD      A,3Dh           ; '='
        ADD     A,(HL)
        PUSH    HL
        PUSH    DE
        RET     NZ
        XOR     A
        LD      E,03h
        CALL    L1AFE
        LD      A,55h           ; 'U'
        LD      E,03h
        CALL    L1AF0
        LD      A,0E6h
        CALL    L1CCF
        LD      A,0D3h
        LD      E,03h
        CALL    L1AFE
        LD      HL,(PROGRAM_BASE)
        DEC     HL
L1B53:  LD      B,03h
L1B55:  LD      A,(HL)
        CALL    L1CCF
        OR      A
        INC     HL
        JP      NZ,L1B53
        DEC     B
        JP      NZ,L1B55
        LD      HL,(2115h)
        LD      A,L
        CALL    L1CCF
        LD      A,H
        CALL    L1CCF
        ; --- START PROC L1B6D ---
L1B6D:  POP     HL
        RET

Cload:	LD      BC,0000h
        ; --- START PROC L1B72 ---
L1B72:  OR      A
        PUSH    AF
        PUSH    BC
        CALL    NZ,L1BD5
        POP     BC
        LD      E,03h
        CALL    L1C12
        LD      HL,(PROGRAM_BASE)
        CALL    L1BD0
L1B84:  LD      E,03h
L1B86:  CALL    L1BD0
        INC     B
        DEC     B
        JP      NZ,L1B96
        LD      (HL),A
        CALL    L0086
        LD      A,(HL)
        JP      L1B9A

L1B96:  CP      (HL)
        JP      NZ,L1BB8
L1B9A:  OR      A
        INC     HL
        JP      NZ,L1B84
        DEC     E
        JP      NZ,L1B86
        POP     AF
        PUSH    HL
        JP      Z,L1BB8
        CALL    L1BD0
        LD      L,A
        CALL    L1BD0
        LD      H,A
        CALL    L1AD0
        EX      DE,HL
        LD      HL,(2115h)
        RST     CompareHLDE
L1BB8:  PUSH    AF
L1BB9:  CALL    0F82Dh
        POP     AF
        LD      E,18h
        JP      NZ,Error
        POP     HL
L1BC3:  LD      (2145h),HL
        DEC     C
        RET     Z
L1BC8:  LD      A,01h
        LD      (2117h),A
        JP      L0168

        ; --- START PROC L1BD0 ---
L1BD0:  LD      A,08h
        JP      0F806h

        ; --- START PROC L1BD5 ---
L1BD5:  LD      A,(HL)
        CP      22h             ; '"'
        JP      NZ,SyntaxError
        CALL    L1ABC
        INC     HL
        PUSH    HL
L1BE0:  LD      HL,2000h
        PUSH    HL
        LD      E,04h
        CALL    L1C12
        CALL    L1C25
        LD      HL,1DFAh
        CALL    0F818h
        POP     HL
        PUSH    HL
        CALL    0F818h
        CALL    0F82Dh
        LD      DE,0BB8h
        CALL    L169C
        POP     HL
        POP     DE
        PUSH    DE
L1C03:  LD      A,(DE)
        CP      22h             ; '"'
        JP      Z,L1B6D
        CP      (HL)
        JP      NZ,L1BE0
        INC     HL
        INC     DE
        JP      L1C03

        ; --- START PROC L1C12 ---
L1C12:  LD      D,E
L1C13:  LD      E,D
        LD      A,0FFh
L1C16:  CALL    0F806h
        CP      0D3h
        JP      NZ,L1C13
        DEC     E
        RET     Z
        LD      A,08h
        JP      L1C16

        ; --- START PROC L1C25 ---
L1C25:  LD      E,03h
L1C27:  CALL    L1BD0
        LD      (HL),A
        INC     HL
        OR      A
        JP      NZ,L1C25
        DEC     E
        JP      NZ,L1C27
        RET

Verify:
	LD      BC,0100h
        JP      L1B72

Merge:
	LD      BC,0001h
        CALL    NZ,L1ABC
        PUSH    HL
        LD      HL,(2145h)
        DEC     HL
        DEC     HL
        LD      (PROGRAM_BASE),HL
        POP     HL
        CALL    L1B72
        LD      HL,(L0026)
        LD      (PROGRAM_BASE),HL
        JP      L1BC8

        ; --- START PROC L1C57 ---
L1C57:  RST     NextChar
        CALL    L0937
        PUSH    HL
        CALL    L1196
        CALL    L11B1
        CALL    L1050
        LD      BC,8100h
        LD      D,C
        LD      E,C
        CALL    L0F13
        CALL    Sqr
        POP     BC
        POP     DE
        RST     FTestSign
        JP      Z,L1C7E
        CALL    L10B2
        CALL    Atn
        POP     HL
        RET

        ; --- START PROC L1C7E ---
L1C7E:  LD      HL,1558h
        CALL    L0F07
        POP     HL
        RET

        ; --- START PROC L1C86 ---
L1C86:  CALL    L1C57
        PUSH    HL
        CALL    L118E
        JP      L1C7E

        ; --- START PROC L1C90 ---
L1C90:  RST     NextChar
        CALL    L0937
        PUSH    HL
        CALL    Log
        CALL    L1196
        LD      BC,8213h
        LD      DE,5D8Eh
        CALL    L11A6
        POP     BC
        POP     DE
        CALL    L10B2
        POP     HL
        RET

Lprint:
	PUSH    AF
        LD      A,01h
        LD      (2117h),A
        POP     AF
        CALL    Print
        XOR     A
        LD      (2117h),A
        RET

Llist:  LD      A,01h
        LD      (2117h),A
        JP      List

Cls:
	LD      DE,76D0h
ClsLoop:
	XOR     A
        LD      (DE),A
        INC     DE
        LD      A,D
        CP      80h
        RET     Z
        JP      ClsLoop

        ; --- START PROC L1CCF ---
L1CCF:  LD      C,A
        JP      0F80Ch

L1CD3:  LD      C,(HL)
        LD      B,L
        LD      E,B
        LD      D,H
        DB	20H, 64H
        LD      H,L
        LD      A,D
        DB 20H, 44H
        LD      C,A
        LD      D,D
        NOP
        LD      (HL),E
        LD      L,C
        LD      L,(HL)
        LD      (HL),H
        LD      H,C
        LD      L,E
        LD      (HL),E
        LD      L,C
        LD      A,(HL)
        LD      H,L
        LD      (HL),E
        LD      L,E
        LD      H,C
        LD      (HL),C
        NOP
        LD      D,D
        LD      B,L
        LD      D,H
        LD      D,L
        LD      D,D
        LD      C,(HL)
        DB	20H, 62H
        LD      H,L
        LD      A,D
        DB 20H, 47H
        LD      C,A
        LD      D,E
        LD      D,L
        LD      B,D
        NOP
        LD      L,L
        LD      H,C
        LD      L,H
        LD      L,A
        DB	20H, 64H
        LD      H,C
        LD      L,(HL)
        LD      L,(HL)
        LD      A,C
        LD      L,B
        DB	20H, 70H
        LD      (HL),D
        LD      L,C
        DB 20H, 44H
        LD      B,C
        LD      D,H
        LD      B,C
        NOP
        LD      L,(HL)
        LD      H,L
        LD      (HL),A
        LD      H,L
        LD      (HL),D
        LD      L,(HL)
        LD      A,C
        LD      L,D
        DB 20h,61h
        LD      (HL),D
        LD      H,A
        LD      (HL),L
        LD      L,L
L1D23:  LD      H,L
        LD      L,(HL)
        LD      (HL),H
        NOP
        LD      (HL),B
        LD      H,L
        LD      (HL),D
        LD      H,L
        LD      (HL),B
        LD      L,A
        LD      L,H
        LD      L,(HL)
        LD      H,L
        LD      L,(HL)
        LD      L,C
        LD      H,L
        NOP
        LD      L,L
        LD      H,C
        LD      L,H
        LD      L,A
        DB	20H,6fh
        LD      A,D
L1D3B:  LD      (HL),L
        NOP
        LD      L,(HL)
        LD      H,L
        LD      (HL),H
        DB 20h, 73h
L1D42:  LD      (HL),H
        LD      (HL),D
        LD      L,A
        LD      L,E
        LD      L,C
        NOP
        LD      L,(HL)
        LD      H,L
        LD      (HL),A
        LD      H,L
        LD      (HL),D
        LD      L,(HL)
        LD      A,C
        LD      L,D
        db 20h, 69h
        LD      L,(HL)
        LD      H,H
        LD      H,L
L1D55:  LD      L,E
        LD      (HL),E
        NOP
        LD      (HL),B
L1D59:  LD      L,A
        LD      (HL),A
        LD      (HL),H
        LD      L,A
        LD      (HL),D
        LD      L,(HL)
        LD      L,A
        LD      H,L
        db 20h, 6fh
        LD      (HL),B
        LD      L,C
        LD      (HL),E
        LD      H,C
        LD      L,(HL)
        LD      L,C
        LD      H,L
L1D6A:  NOP
        LD      H,H
        LD      H,L
        LD      L,H
        LD      H,L
        LD      L,(HL)
        LD      L,C
        LD      H,L
        db 20h, 6eh
        LD      H,C
        db 20h, 30h
        NOP
        LD      (HL),H
        LD      L,A
        LD      L,H
        LD      A,B
        LD      L,E
L1D7D:  LD      L,A
        db 20h,77h
L1D80:  db 20h,70h
        LD      (HL),D
        LD      L,A
        LD      H,A
        LD      (HL),D
        LD      H,C
        LD      L,L
        LD      L,L
        LD      H,L
        NOP
        LD      L,(HL)
        LD      H,L
        LD      (HL),E
        LD      L,A
        LD      L,A
        LD      (HL),H
        LD      (HL),A
        LD      L,64h           ; 'd'
        LD      H,C
        LD      L,(HL)
        LD      L,(HL)
        LD      A,C
        LD      L,B
        NOP
        LD      L,L
        LD      H,C
        LD      L,H
        DB 20h, 62h
        LD      (HL),L
        LD      H,(HL)
        LD      H,L
        LD      (HL),D
        NOP
        LD      E,B
        INC     H
L1DA6:  LD      A,32h           ; '2'
        DEC     (HL)
L1DA9:  DEC     (HL)
        NOP
        LD      (HL),E
        LD      L,H
        LD      L,A
        HALT
        LD      L,(HL)
        LD      L,A
        NOP
        LD      L,(HL)
        LD      H,L
        LD      L,H
L1DB5:  LD      A,B
        LD      A,D
        LD      (HL),C
        NOP
        LD      L,(HL)
        LD      H,L
L1DBB:  LD      (HL),H
        db 20h, 44h
        LD      B,L
        LD      B,(HL)
        NOP
        db 20h, 6fh
        LD      A,E
        LD      L,C
        LD      H,D
        LD      L,E
        LD      H,C
        NOP
        DEC     C
        LD      A,(BC)
        HALT
        LD      H,H
        LD      (HL),L
        LD      A,(L0A0D)
        NOP
L1DD2:  DEC     C
        LD      A,(BC)
        LD      (HL),E
        LD      (HL),H
        LD      L,A
        LD      (HL),B
        NOP
        db 20h, 77h, 20h,73h
        LD      (HL),H
        LD      (HL),D
        LD      L,A
        LD      L,E
        LD      H,L
L1DE2:  db 20h, 00h
L1DE4:  RRA
        LD      B,D
        LD      B,C
        LD      D,E
        LD      C,C
        LD      B,E
        DB 20h, 2ah
        LD      L,L
        LD      L,C
        LD      L,E
        LD      (HL),D
        LD      L,A
        LD      L,(HL)
L1DF2:  LD      HL,(L0A0D)
        LD      C,(HL)
        LD      B,L
L1DF7:  LD      D,A
        CCF
        NOP
        DEC     C
        LD      A,(BC)
        LD      (HL),B
        LD      (HL),D
        LD      L,A
        LD      H,A
        LD      (HL),D
L1E01:  LD      H,C
L1E02:  LD      L,L
        LD      L,L
        LD      H,C
	db	3ah, 00h

TOKEN	MACRO	name
name	EQU	Q
Q	SET	Q+1
name_ADDR equ $
	ENDM

FIRST_TK	EQU	80H

KEYWORDS:
Q	SET	FIRST_TK
	TOKEN	TK_CLS
	DB	"CL", 'S'+80H
	TOKEN	TK_FOR
	DB	"FO", 'R'+80h
	TOKEN	TK_NEXT
	DB	"NEX", 'T'+80h
	TOKEN	TK_DATA
	DB	"DAT", 'A'+80h
	TOKEN	TK_INPUT
	DB	"INPU", 'T'+80h
	TOKEN	TK_DIM
	DB	"DI", 'M'+80h
	TOKEN	TK_READ
	DB	"REA", 'D'+80h
	TOKEN	TK_CUR
	DB	"CU", 'R'+80h
	TOKEN	TK_GOTO
	DB	"GOT", 'O'+80h
	TOKEN	TK_RUN
	DB	"RU", 'N'+80h
	TOKEN	TK_IF
	DB	"I", 'F'+80h
	TOKEN	TK_RESTORE
	DB	"RESTOR", 'E'+80h
	TOKEN	TK_GOSUB
	DB	"GOSU", 'B'+80h
	TOKEN	TK_RETURN
	DB	"RETUR", 'N'+80h
	TOKEN	TK_REM
	DB	"RE", 'M'+80h
	TOKEN	TK_STOP
	DB	"STO", 'P'+80h
	TOKEN	TK_OUT
	DB	"OU", 'T'+80h
	TOKEN	TK_ON
	DB	"O", 'N'+80h
	TOKEN	TK_PLOT
	DB	"PLO", 'T'+80h
	TOKEN	TK_LINE
	DB	"LIN", 'E'+80h
	TOKEN	TK_POKE
	DB	"POK", 'E'+80h
	TOKEN	TK_PRINT
	DB	"PRIN", 'T'+80h
	TOKEN	TK_DEF
	DB	"DE", 'F'+80h
	TOKEN	TK_CONT
	DB	"CON", 'T'+80h
	TOKEN	TK_LIST
	DB	"LIS", 'T'+80h
	TOKEN	TK_CLEAR
	DB	"CLEA", 'R'+80h
	TOKEN	TK_CLOAD
	DB	"CLOA", 'D'+80h
	TOKEN	TK_CSAVE
	DB	"CSAV", 'E'+80h
	TOKEN	TK_NEW
	DB	"NE", 'W'+80h

TKCOUNT	EQU	Q-FIRST_TK

	TOKEN	TK_TAB
	DB	"TAB", '('+80h
	TOKEN	TK_TO
	DB	"T", 'O'+80h
	TOKEN	TK_SPC
	DB	"SPC", '('+80h
	TOKEN	TK_FN
	DB	"F", 'N'+80h
	TOKEN	TK_THEN
	DB	"THE",'N'+80h
	TOKEN	TK_NOT
	DB	"NO", 'T'+80h
	TOKEN	TK_STEP
	DB	"STE", 'P'+80h

	TOKEN	TK_PLUS
	DB 	"+"+80h
	TOKEN	TK_MINUS
	DB 	"-"+80h
	TOKEN	TK_MUL
	DB	"*"+80h
	TOKEN	TK_DIV
	DB 	"/"+80h
	TOKEN	TK_POWER
	DB	'^'+80h
	TOKEN	TK_AND
	DB	"AN", 'D'+80h
	TOKEN	TK_OR
	DB	"O", 'R'+80h
	TOKEN	TK_GT
	DB 	">"+80h
	TOKEN	TK_EQ
	DB	"="+80h
	TOKEN	TK_LT
	DB 	"<"+80h

	TOKEN	TK_SGN
	DB	"SG", 'N'+80h
	TOKEN	TK_INT
	DB	"IN", 'T'+80h
	TOKEN	TK_ABS
	DB	"AB", 'S'+80h
	TOKEN	TK_USR
	DB	"US", 'R'+80h
	TOKEN	TK_FRE
	DB	"FR", 'E'+80h
	TOKEN	TK_INP
	DB	"IN", 'P'+80h
	TOKEN	TK_POS
	DB	"PO", 'S'+80h
	TOKEN	TK_SQR
	DB	"SQ", 'R'+80h
	TOKEN	TK_RND
	DB	"RN", 'D'+80h
	TOKEN	TK_LOG
	DB	"LO", 'G'+80h
	TOKEN	TK_EXP
	DB	"EX", 'P'+80h
	TOKEN	TK_COS
	DB	"CO", 'S'+80h
	TOKEN	TK_SIN
	DB	"SI", 'N'+80h
	TOKEN	TK_TAN
	DB	"TA", 'N'+80h
	TOKEN	TK_ATN
	DB	"AT", 'N'+80h
	TOKEN	TK_PEEK
	DB	"PEE", 'K'+80h
	TOKEN	TK_LEN
	DB	"LE", 'N'+80h
	TOKEN	TK_STRS
	DB	"STR", '$'+80h
	TOKEN	TK_VAL
	DB	"VA", 'L'+80h
	TOKEN	TK_ASC
	DB	"AS", 'C'+80h
	TOKEN	TK_CHRS
	DB	"CHR", '$'+80h
	TOKEN	TK_LEFTS
	DB	"LEFT", '$'+80h
	TOKEN	TK_RIGHTS
	DB	"RIGHT", '$'+80h
	TOKEN	TK_MIDS
	DB	"MID", '$'+80h

TK_INLINE_COUNT EQU Q-TK_SGN

	TOKEN	TK_SCREENS
	DB	"SCREEN$", '('+80h
	TOKEN	TK_INKEYS
	DB	"INKEY", '$'+80h
	TOKEN	TK_AT
	DB	"A", 'T'+80h
	TOKEN	TK_AMP
	DB	'&'+80h

	TOKEN	TK_BEEP
	DB	"BEE", 'P'+80h
	TOKEN	TK_PAUSE
	DB	"PAUS", 'E'+80h
	TOKEN	TK_VERIFY
	DB	"VERIF", 'Y'+80h
	TOKEN	TK_HOME
	DB	"HOM", 'E'+80h
	TOKEN	TK_EDIT
	DB	"EDI", 'T'+80h
	TOKEN	TK_DELETE
	DB	"DELET", 'E'+80h
	TOKEN	TK_MERGE
	DB	"MERG", 'E'+80h
	TOKEN	TK_AUTO
	DB	"AUT", 'O'+80h
	TOKEN	TK_HIMEM
	DB	"HIME", 'M'+80h
	TOKEN	TK_ATSGN
	DB	'@'+80h
	TOKEN	TK_ASN
	DB	"AS", 'N'+80h
	TOKEN	TK_ADDR
	DB	"ADD", 'R'+80h
	TOKEN	TK_PI
	DB	"P", 'I'+80h
	TOKEN	TK_RENUM
	DB	"RENU", 'M'+80h
	TOKEN	TK_ACS
	DB	"AC", 'S'+80h
	TOKEN	TK_LG
	DB	"L", 'G'+80h
	TOKEN	TK_LPRINT
	DB	"LPRIN", 'T'+80h
	TOKEN	TK_LLIST
	DB	"LLIS", 'T'+80h
	DB	0

KW_GENERAL_FNS:
	DW	Cls 		; Cls
	DW	For 		; For         03e2
	DW	Next 		; Next        0820
	DW	Data 		; Data        05b1
	DW	Input 		; Input       0740
	DW	Dim 		; Dim         0a44
	DW	Read 		; Read        0794
	DW	Cur 		; Cur	      1920
	DW	Goto 		; Goto        057f
	DW	Run 		; Run         0563
	DW	If 		; If          0630
	DW	Restore		; Restore     0496
	DW	Gosub 		; Gosub       056f
	DW	Return 		; Return      059b
	DW	Rem 		; Rem         05b3
	DW	Stop 		; Stop        04b9
	DW	SyntaxError	; Out
	DW	On 		; On          0614
	DW	Plot 		; Plot        1936
	DW	Line 		; Line        199e
	DW	Poke 		; Poke        15e6
	DW	Print 		; Print       0648
	DW	Def 		; Def         0bdf
	DW	Cont 		; Cont        04dd
	DW	List 		; List        0397
	DW	Clear 		; Clear       053a
	DW	Cload 		; Cload       1b6f
	DW	Csave 		; Csave       1b06
	DW	New 		; New

        DW	Beep		; Beep        1a77
        DW	Pause		; Pause       1699
        DW	Verify          ; Verify      1c35
	DW	Home		; Home        1694
	DW	Edit		; Edit        1716
        DW      Delete		; Delete      1730
	DW	Merge		; Merge       1c3b
        DW	Auto		; Auto        18c8
        DW	Himem		; Himem       16e7

L1F95:  DW	SyntaxError	; @
	DW	SyntaxError	; Asn
	DW	SyntaxError	; Addr
	DW	SyntaxError	; Pi
	DW	Renum		; Renum       1768
	DW	SyntaxError	; Acs
	DW	SyntaxError	; Lg
	DW	Lprint		; Lprint      1cab
	DW	Llist		; Llist       1cba

KW_INLINE_FNS:
	DW	Sgn		; 1178
	DW	Int		; 1236
	DW	Abs		; 118c
	DW	Usr		; 15f4
	DW	Fre		; 0ba9
	DW	SyntaxError	; Inp
	DW	Pos		; 0bd7
	DW	Sqr		; 140a
	DW	Rnd		; 14e0
	DW	Log		; 1012
	DW	Exp		; 144f
	DW	Cos		; 1512
	DW	Sin		; 1518
	DW	Tan		; 157d
	DW	Atn		; 1592
	DW	Peek		; 15de
	DW	Len		; 0e12
	DW	Str		; 0c4e
	DW	Val		; 0eeb
	DW	Asc		; 0e21
	DW	Chr		; 0e2f
	DW	Left		; 0e41
	DW	Right		; 0e71
	DW	Mid		; 0e7b

	DW	Screen		; Screen   1a39
	DW	Inkey		; Inkey    1685
	DW	SyntaxError	; At 009b
	DW	Amp		; &  16a9

KW_ARITH_OP_FNS:
	DB	079h
	DW	FAdd	; + 1302
	DB	079h
	DW	FSub	; - 0f11
	DB	07Bh
	DW	FMul	; * 104e
	DB	07Bh
	DW	FDiv	; / 10b0
	DB	07Fh
	DW	FPower	; ^ 1413
	DB	50H
	DW	FAnd	; AND 09a6
	DB	46H
	DW	FOr	; OR 09a5

	DB	"MI(C)RON/88"
