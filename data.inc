; токены и прочие данные
; 1.2 Ключевые слова
;
; Всего существует три типа ключевых слов:
;
; Основные ключевые слова. These typically start a statement; examples are LET, PRINT, GOTO and so on.
; Вспомогательные слова. Used in statements but not as part of an expression, eg TO, STEP, TAB
; Функции. Only used in expressions, eg, SIN, RND, INT.
; 
;
; KW_INLINE_FNS
; Таблица указателей на функции.
;

KW_INLINE_FNS:
	DW	Sgn
	DW	Int
	DW	Abs
	DW	Usr
	DW	Fre
	DW	Inp
	DW	Pos
	DW	Sqr
	DW	Rnd
	DW	Log
	DW	Exp
	DW	Cos
	DW	Sin
	DW	Tan
	DW	Atn
	DW	Peek
	DW	Len
	DW	Str
	DW	Val
	DW	Asc
	IF	BASICNEW
	DW	Pi
	ENDIF
	DW	Chr
	DW	Left
	DW	Right
	DW	Mid

; KW_ARITH_OP_FNS
;
; Таблица указателей на функции арифметических операций.
; Каждая запись состоит из трех байт. Первый байт - это
; приоритет, следующие два байта - указатель на функцию.

KW_ARITH_OP_FNS:
	DB	079h
	DW	FAdd	; + 144C
	DB	079h
	DW	FSub	; - 107D
	DB	07Bh
	DW	FMul	; * 11BA
	DB	07Bh
	DW	FDiv	; / 1218
	DB	07Fh
	DW	FPower	; ^ 155D
	DB	50H
	DW	FAnd	; AND 0A77
	DB	46H
	DW	FOr	; OR 0A76

 
; KEYWORDS
;
; Строковые константы для всех ключевых слов, включая арифметические операторы. Последний символ определяется установкой в 1 старшего разряда.
; Конец таблицы отмечается нулевым байтом.

; Основные ключевые слова

	CHK	088h, "Сдвижка кода"
; LET и END выкинули зачем-то... И этим поломали совместимость... В отчечественных бейсиках так много где произошло...

; Таблица токенов. В основном в Бейсиках от M$ начало токенов либо 80h, либо 81h. Когда произошла сдвижка,
; не выяснял. В советских Бейсиках в основе лежит эта таблица токенов, которая расширялась разными версиями.

TOKEN	MACRO	name
name	EQU	Q
Q	SET	Q+1
	ENDM

FIRST_TK	EQU	80H
KEYWORDS:
Q	SET	FIRST_TK
	TOKEN	TK_CLS
	DB	"CL", 'S'+80h	;	80
	TOKEN	TK_FOR
	DB	"FO", 'R'+80h	;	81
	TOKEN	TK_NEXT
	DB	"NEX", 'T'+80h	;	82
	TOKEN	TK_DATA
	DB	"DAT", 'A'+80h	;	83
	TOKEN	TK_INPUT
	DB 	"INPU", 'T'+80h	;	84
	TOKEN	TK_DIM
	DB 	"DI", 'M'+80h	;	85
	TOKEN	TK_READ
	DB 	"REA", 'D'+80h	;	86
	TOKEN	TK_CUR
	DB 	"CU",	'R'+80h	;	87
	TOKEN	TK_GOTO
	DB 	"GOT", 'O'+80h	;	88
	TOKEN	TK_RUN
	DB 	"RU", 'N'+80h	;	89
	TOKEN	TK_IF
	DB 	"I", 'F'+80h	;	8A
	TOKEN	TK_RESTORE
	DB 	"RESTOR", 'E'+80h	;	8B
	TOKEN	TK_GOSUB
	DB 	"GOSU", 'B'+80h	;	8C
	TOKEN	TK_RETURN
	DB 	"RETUR", 'N'+80h;	8D
	TOKEN	TK_REM
	DB 	"RE", 'M'+80h	;	8E
	TOKEN	TK_STOP
	DB 	"STO", 'P'+80h	;	8F
	TOKEN	TK_OUT
	DB	"OU", 'T'+80h	;	90
	TOKEN	TK_ON
	DB	"O", 'N'+80h	;	91
	TOKEN	TK_PLOT
	DB	"PLO", 'T'+80h	;	92
	TOKEN	TK_LINE
	DB	"LIN", 'E'+80h	;	93
	TOKEN	TK_POKE
	DB	"POK", 'E'+80h	;	94
	TOKEN	TK_PRINT
	DB 	"PRIN", 'T'+80h	;	95
	TOKEN	TK_DEF
	DB	"DE", 'F'+80h	;	96
	TOKEN	TK_CONT
	DB	"CON", 'T'+80h	;	97
	TOKEN	TK_LIST
	DB 	"LIS", 'T'+80h	;	98
	TOKEN	TK_CLEAR
	DB 	"CLEA", 'R'+80h	;	99
	TOKEN	TK_MLOAD
	DB	"MLOA", 'D'+80h	;	9a
	TOKEN	TK_MSAVE
	DB	"MSAV", 'E'+80h	;	9b
	TOKEN	TK_NEW
	DB 	"NE" , 'W'+80h	;	9c
	IF	BASICNEW
	TOKEN	TK_SYSTEM
	DB	"SYSTE", 'M'+80h
	TOKEN	TK_MONITOR
	DB	"MONITO", 'R'+80h
	TOKEN	TK_HOME
	DB	"HOM", 'E'+80h
	ENDIF
	IF	OPTION
	TOKEN	TK_OPTION
	DB	"OPTIO", 'N'+80h
	ENDIF
	IF	LET
	TOKEN	TK_LET
	DB	"LE", 'T'+80h
	ENDIF
	IF	RANDOMIZE
	TOKEN	TK_RANDOMIZE
	DB	"RANDOMIZE", 'E'+80h
	ENDIF
	IF	END
	TOKEN	TK_END
	DB	"EN", 'D'+80h
	ENDIF

TKCOUNT	EQU	Q-FIRST_TK

;Supplementary keywords
	TOKEN	TK_TAB
	DB 	"TAB", '('+80h	;	9d
	TOKEN	TK_TO
	DB 	"T", 'O'+80h	;	9e
	TOKEN	TK_SPC
	DB	"SPC", '('+80h	;	9f
	TOKEN	TK_FN
	DB	"F", 'N'+80h	;	a0
	TOKEN	TK_THEN
	DB 	"THE", 'N'+80h	;	a1
	TOKEN	TK_NOT
	DB	"NO", 'T'+80h	;	a2
	TOKEN	TK_STEP
	DB 	"STE", 'P'+80h	;	a3

;Arithmetic and logical operators
	TOKEN	TK_PLUS
	DB 	"+"+80h		;	a4
	TOKEN	TK_MINUS
	DB 	"-"+80h		;	a5
	TOKEN	TK_MUL
	DB	"*"+80h		;	a6
	TOKEN	TK_DIV
	DB 	"/"+80h		;	a7
	TOKEN	TK_POWER
	DB	'^'+80h		;	a8
	TOKEN	TK_AND
	DB	"AN", 'D'+80h	;	a9
	TOKEN	TK_OR
	DB	"O", 'R'+80h	;	aa
	TOKEN	TK_GT
	DB 	">"+80h		;	ab
	TOKEN	TK_EQ
	DB	"="+80h		;	ac
	TOKEN	TK_LT
	DB 	"<"+80h		;	ad

;Inline keywords
	TOKEN	TK_SGN
	DB 	"SG", 'N'+80h	;	ae
	TOKEN	TK_INT
	DB 	"IN", 'T'+80h	;	af
	TOKEN	TK_ABS
	DB 	"AB", 'S'+80h	;	b0
	TOKEN	TK_USR
	DB 	"US", 'R'+80h	;	b1
	TOKEN	TK_FRE
	DB	"FR", 'E'+80h	;	b2
	TOKEN	TK_INP
	DB	"IN", 'P'+80h	;	b3
	TOKEN	TK_POS
	DB	"PO", 'S'+80h	;	b4
	TOKEN	TK_SQR
	DB 	"SQ", 'R'+80h	;	b5
	TOKEN	TK_RND
	DB 	"RN", 'D'+80h	;	b6
	TOKEN	TK_LOG
	DB	"LO", 'G'+80h	;	b7
	TOKEN	TK_EXP
	DB	"EX", 'P'+80h	;	b8
	TOKEN	TK_COS
	DB	"CO", 'S'+80h	;	b9
	TOKEN	TK_SIN
	DB 	"SI", 'N'+80h	;	ba
	TOKEN	TK_TAN
	DB	"TA", 'N'+80h	;	bb
	TOKEN	TK_ATN
	DB	"AT", 'N'+80h	;	bc
	TOKEN	TK_PEEK
	DB	"PEE", 'K'+80h	;	bd
	TOKEN	TK_LEN
	DB	"LE", 'N'+80h	;	be
	TOKEN	TK_STRS
	DB	"STR", '$'+80h	;	bf
	TOKEN	TK_VAL
	DB	"VA", 'L'+80h	;	c0
	TOKEN	TK_ASC
	DB	"AS", 'C'+80h	;	c1
	IF	BASICNEW
	TOKEN	TK_PI
	DB	"P", 'I'+80h
	ENDIF
	TOKEN	TK_CHRS
	DB	"CHR", '$'+80h	;	c2
	TOKEN	TK_LEFTS
	DB	"LEFT", '$'+80h	;	c3
	TOKEN	TK_RIGHTS
	DB	"RIGHT", '$'+80h	;c4
	TOKEN	TK_MIDS
	DB	"MID", '$'+80h	;	c5
TK_INLINE_COUNT EQU Q-TK_SGN

; --------------- Это потом из микрона возмем
;c7:SCREEN$( 1eee 1fd8 1a39
;c8: INKEY$ 1ef6 1fda 1685
;c9: AT 1efc 1fdc 009b
;ca: & 1efe 1fde 16a9
;cb: BEEP 1eff 1fe0 0279
;cc: PAUSE 1f03 1fe2 7913
;cd: VERIFY 1f08 1fe4 0f11
;cf: EDIT 1f12 1fe8 7b10
;d0: DELETE 1f16 1fea 10b0
;d1: MERGE 1f1c 1fec 137f
;d2: AUTO 1f21 1fee 5014
;d3: HIMEM 1f25 1ff0 09a6
;d4: @ 1f2a 1ff2 a546
;d5: ASN 1f2b 1ff4 4d09
;d6: ADDR 1f2e 1ff6 2849
;d7: PI 1f32 1ff8 2943
;d8: RENUM 1f34 1ffa 4f52
;d9: ACS 1f39 1ffc 2f4e
;da: LG 1f3c 1ffe 3838
;db: LPRINT 1f3e 2000 6e65
;dc: LLIST 1f44 2002 6075
;Null terminator.
	DB	00	 	 	
 
;
;KW_GENERAL_FNS
;Pointers to the functions for the 20 general keywords at the start of the KEYWORDS table above.

	CHK	0170H, "Сдвижка кода"
	
KW_GENERAL_FNS:
; Altair 4k			;	Altair 4K	MBASIC 5.2
	DW	Cls		;	END
	DW	For		;	FOR
	DW	Next		;	NEXT
	DW	Data		;	DATA
	DW	Input		;	INPUT
	DW	Dim		;	DIM
	DW	Read		;	READ
	DW	Cur		;	LET
	DW	Goto		;	GOTO
	DW	Run		;	RUN
	DW	If		;	IF
	DW	Restore		;	RESTORE
	DW	Gosub		;	GOSUB
	DW	Return		;	RETURN
	DW	Rem		;	REM
	DW	Stop		;	STOP
	DW	Out		;	PRINT
	DW	On		;	LIST
	DW	Plot		;	CLEAR
	DW	Line		;	NEW
; МИКРО-80
	DW	Poke		;			ONGOTO
	DW	Print		;			NULL
	DW	Def		;			WAIT
	DW	Cont		;			DEF
	DW	List		;			POKE
	DW	Clear		;			CONT
	DW	Mload		;			CLOAD
	DW	Msave		;			OUT
	DW	New		;			LPRINT
				;			LLIST
	IF	BASICNEW
	DW	Monitor
	DW	Monitor		; SYSTEM то же, что и MONITOR (пока)
	DW	Home
	ENDIF

	IF	OPTION
	DW	Option
	ENDIF
	IF	LET
	DW	Let
	ENDIF
	IF	RANDOMIZE
	DW	Randomize
	ENDIF
	IF	END
	DW	End
	ENDIF

;1.3 Коды ошибок и глобальные переменные
;
; Таблица двухсимвольных кодов для 18 ошибок.

;Ошибка 01. В программе встретился оператор NEXT, для которого не был выполнен соответствующий оператор FOR.
;Ошибка 02. Неверный синтаксис.
;Ошибка 03. В программе встретился оператор RETURN без предварительного выполнения оператора GOSUB.
;Ошибка 04. При выполнении программы не хватает данных для оператора READ. т.е. данных, описанных операторами DATA меньше, чем переменных в операторах READ.
;Ошибка 05. Аргумент функции не соответствует области определения данной функции. Например, отрицательный или нулевой аргумент функции LOG(X), отрицательный аргумент у функции SQR(X) и т. д.
;Ошибка 06. Переполнение при выполнении арифметических операций Результат любой операции не может быть больше +1,7-1035 или меньше -1,7-1035.
;Ошибка 07. Недостаточен объем памяти. Возможные причины:
;	велик текст программы:
;	слишком длинны массивы данных:
;	вложенность подпрограмм и циклов больше нормы;
;	слишком много переменных.
;Ошибка 08. Нет строки с данным номером. Возникает при выполнении операторов перехода.
;Ошибка 09. Индекс не соответствует размерности массива.
;Ошибка 10. Повторное выполнение операторов DIM или DEF, описывающих массив или функцию, которые уже были описаны ранее.
;Ошибка 11. Деление на ноль.
;Ошибка 12. Попытка выполнить операторы INPUT или DEP в непосредственном режиме.
;Ошибка 13. Несоответствие типов данных. Возникает при попытке символьной переменной присвоить числовое значение и наоборот.
;Ошибка 14. Переполнение буферной области памяти, отведенной для хранения символьных переменных. Для расширения объема буфера служит директива CLEAR.
;Ошибка 15. Длина символьной переменной превышает 255.
;Ошибка 16. Выражение, содержащее символьные переменные, слишком сложно для интерпретатора.
;Ошибка 17. Невозможность продолжения выполнения программы по директиве CONT.
;Ошибка 18. Обращение к функции, не описанной оператором DEF.


ERROR_CODES:
	IF	BASICNEW
ERR_NF	EQU	$-ERROR_CODES
	DB	'NEXT bez FOR',0
ERR_SN	EQU	$-ERROR_CODES
	DB	'sintaksi~eskaq',0
ERR_RG	EQU	$-ERROR_CODES
	DB	'RETURN bez GOSUB',0
ERR_OD	EQU	$-ERROR_CODES
	DB	'malo dannyh pri DATA', 0
ERR_FC	EQU	$-ERROR_CODES
	DB	'newernyj argument', 0
ERR_OV	EQU	$-ERROR_CODES
	DB	'0','6'+80h	; 0A Overflow
ERR_OM	EQU	$-ERROR_CODES
	DB	'0','7'+80h	; 0C Out of memory
ERR_US	EQU	$-ERROR_CODES
	DB	'0','8'+80h	; 0E Undefined Subroutine
ERR_BS	EQU	$-ERROR_CODES
	DB	'0','9'+80h	; 10 Bad Subscript
ERR_DD	EQU	$-ERROR_CODES
	DB	'1','0'+80h	; 12 Duplicate Definition
ERR_DZ	EQU	$-ERROR_CODES
	DB	'1','1'+80h	; 14 Division by zero
ERR_ID	EQU	$-ERROR_CODES
	DB	'1','2'+80h	; 16 Invalid in Direct mode
ERR_TM	EQU	$-ERROR_CODES
	DB	'1','3'+80h	; 18 Type mismatch
ERR_SO	EQU	$-ERROR_CODES
	DB	'1','4'+80h	; 1AH Out of string space
ERR_LS	EQU	$-ERROR_CODES
	DB	'1','5'+80h	; 1CH String too long
ERR_ST	EQU	$-ERROR_CODES
	DB	'1','6'+80h	; 1EH String formula too complex
ERR_CN	EQU	$-ERROR_CODES
	DB	'1','7'+80h	; 20H Can't continue
ERR_UF	EQU	$-ERROR_CODES
	DB	'1','8'+80h	; 22H Undefined function
	ELSE
ERR_NF	EQU	$-ERROR_CODES
	DB	'0','1'+80h	; 00 NEXT without FOR
ERR_SN	EQU	$-ERROR_CODES
	DB	'0','2'+80h	; 02 Syntax Error
ERR_RG	EQU	$-ERROR_CODES
	DB	'0','3'+80h	; 04 RETURN without GOSUB
ERR_OD	EQU	$-ERROR_CODES
	DB	'0','4'+80h	; 06 Out of Data
ERR_FC	EQU	$-ERROR_CODES
	DB	'0','5'+80h	; 08 Illegal Function Call
ERR_OV	EQU	$-ERROR_CODES
	DB	'0','6'+80h	; 0A Overflow
ERR_OM	EQU	$-ERROR_CODES
	DB	'0','7'+80h	; 0C Out of memory
ERR_US	EQU	$-ERROR_CODES
	DB	'0','8'+80h	; 0E Undefined Subroutine
ERR_BS	EQU	$-ERROR_CODES
	DB	'0','9'+80h	; 10 Bad Subscript
ERR_DD	EQU	$-ERROR_CODES
	DB	'1','0'+80h	; 12 Duplicate Definition
ERR_DZ	EQU	$-ERROR_CODES
	DB	'1','1'+80h	; 14 Division by zero
ERR_ID	EQU	$-ERROR_CODES
	DB	'1','2'+80h	; 16 Invalid in Direct mode
ERR_TM	EQU	$-ERROR_CODES
	DB	'1','3'+80h	; 18 Type mismatch
ERR_SO	EQU	$-ERROR_CODES
	DB	'1','4'+80h	; 1AH Out of string space
ERR_LS	EQU	$-ERROR_CODES
	DB	'1','5'+80h	; 1CH String too long
ERR_ST	EQU	$-ERROR_CODES
	DB	'1','6'+80h	; 1EH String formula too complex
ERR_CN	EQU	$-ERROR_CODES
	DB	'1','7'+80h	; 20H Can't continue
ERR_UF	EQU	$-ERROR_CODES
	DB	'1','8'+80h	; 22H Undefined function
	ENDIF

	CHK 01ceh, "Сдвижка кода"

;LINE_BUFFER
;Buffer for a line of input or program, 73 bytes long.
;
;The line buffer is prefixed with this comma. It's here because the INPUT handler defers to the READ handler,
;which expects items of data (which the line buffer is treated as) to be prefixed with commas. Quite a neat trick!

	DB	','
LINE_BUFFER: 
        DB	9ch
	DB	65 DUP (0)
	DB	32h, 32h, 37h, 30h
	NOP

	CHK     0216h, "Сдвижка кода"
TMPSTACK:
	NOP     
ControlChar:
	DB		00		; Тип символа: 00 - обычный символ, FF - управляющий
DIM_OR_EVAL:
	DB	0			; Обработка массива или...
VALTYP:
	DB	01h			; Тип переменной: 00 - числовая, 01 - символьная
DATA_STM:
	DB	0			; Признак обработки TK_DATA
MEMSIZ:	DW	MEM_TOP			; Размер памяти //021BH

TEMPPT:	DW	TMPST			; POINTER AT FIRST FREE TEMP DESCRIPTOR
					; INITIALIZED TO POINT TO TEMPST
;TEMPST:	DS	STRSIZ*NUMTMP
TMPST:	LD      B,00H			; STORAGE FOR NUMTMP TEMP DESCRIPTORS
        LD      L,E
        LD      (BC),A
        LD      BC,8900H
        RLA     
	IF SERVICE
L0227:	DB	0AH
	DB	0
	ELSE
	DB	0
	DB	0
	ENDIF
	IF SERVICE
L0229:	DW	0
	ELSE
	DB	0
	DB	0
	ENDIF
L022B:        LD      B,00H
        LD      L,E
        LD      (BC),A
STR_TOP:
	DW	MEM_TOP
CUR_TOKEN_ADR:
	DW	01D5H
DATA_LINE:
	DW	0000H				; Номер строка с DATA, где возникла ошибка
NO_ARRAY:
	DB	00H				; Флаг, что переменная-массив недопустима (для TK_FOR, например)
INPUT_OR_READ:
	DB	00H				; Выполняем INPUT или READ
PROG_PTR_TEMP:
	DW	1722h				; Мусор, можно=0
PROG_PTR_TEMP2:
	DW	01d5h				; Мусор, можно=0
CURRENT_LINE:
	DW	0FFFFH		; Номер текущей исполняемой строки FFFF - никакая не исполняется
OLD_LINE:
	DB	6eh, 0ah	; Номер строки для CONT
OLD_TEXT:
	db	0,0		; Адрес(?) для CONT
	CHK	0241H, "Сдвижка кода"
STACK_TOP:
	DW	MEM_TOP-50	; Верхушка стека бейсика. Размер (50) для РК86 используется для вычисления при инициализации.
PROGRAM_BASE:
	DW	PROGRAM_BASE_INIT+01h
VAR_BASE:
	DW	PROGRAM_BASE_INIT+03h
VAR_ARRAY_BASE:
	DW	PROGRAM_BASE_INIT+03h
VAR_TOP:
	DW	PROGRAM_BASE_INIT+03h
DATA_PROG_PTR:
	DW	PROGRAM_BASE_INIT
FACCUM:	DB	1fh,02h,84h,87h	; Видимо, мусор. Заменить на DD	0 ?
FTEMP:	DB	0c2h
FBUFFER:
; Small buffer (13 bytes) used by the math package functions FOut and Sqr.
	DB	20h
	db	32h, 35h,36h, 0 ; "256"
	db	30h, 30h,30h, 0	; "000"
	CHK	025bh, "Сдвижка кода"
	db	0, 0, 0, 0
	if	BASICNEW
szError:	DB		" o{ibka", 00h		; "ОШИБКА"
	else
szError:	DB		"o{ibk", "a"+80h, 00h		; "ОШИБКА"
	endif
szIn:		DB		"  w", " "+80h, 00h 			; "  В "
szOK:		DB		0Dh, 0Ah, "="+080h, ">", 0Dh, 0Ah, 00h		; "=>"
szStop:		DB		0Dh, 0Ah, "stop", " "+080h, 00h		; "СТОП "

	if	BASICNEW
	include "szRepeat.inc"
	include "szOverflow.inc"
	include "szHello.inc"
	include "prnflag.inc"
	include "tmpvars.inc"
	endif
; конец токенов
