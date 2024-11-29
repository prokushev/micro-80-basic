; ═════════════════════════════════════════════════════════════════════════════════
;  БЕЙСИК для МИКРО-80/БЕЙСИК для РАДИО-86РК/БЕЙСИК для ЮТ-88
;  БЕЙСИК-СЕРВИС для МИКРО-80/БЕЙСИК-СЕРВИС для РАДИО-86РК
;  БЕЙСИК-СЕРВИС для ЮТ-88/БЕЙСИК-МИКРОН для РАДИО-86РК
; ═════════════════════════════════════════════════════════════════════════════════
;
; Это дизассемблер Бейсика для "МИКРО-80" и Бейсика для "Радио-86РК" и других...
; Гипотетически Бейсик для МИКРО-80=Бейсик для ЮТ-88, но это пока не проверялось.
; Имена меток взяты с дизассемблера Altair BASIC 3.2 (4K)
; По ходу разбора встречаются мысли и хотелки.
;
; Общие хотелки:
; !!Добавить поддержку каналов и потоков, как в Sinclair Basic, не забывая совместимость с ECMA стандартом
; !!Пересобрать с адреса 100h. Вначале добавить CP/M адаптер. При наличии поддержки дисковых фунок - адаптер не цепляем. 
; !!Добавить OPTION BASE для управления индеском массива (Совместимость ANSI)
; !!Автонастройка памяти (сейчас жестко задано в коде), кроме версии для РК-86
; !!GO TO=GOTO, GO SUB=GOSUB (учесть в токенизаторе)
; ??ГОСТ расширение основных средств уровень 1 и 2 не могут быть реализованы из-за усеченного знакогенератора. Нет строчных букв.
; !!Отвязать по максимуму от работы в ОЗУ (версия для ROM-диска? Мысль интересная, т.к можно высвободить гору ОЗУ. 
;   Больше актуально не для М-80/ЮТ-88, а для РК-86. При этом для самого интерпретатора можно заполучить 32Кб
;   для стандартного ROM-диска).
; !!Добавить IF x GOSUB
;
; Для микроши f82d есть? Или как-то по другому?
;
; БЕЙСИК для МИКРО-80/РАДИО-86РК - Общее устройство
;
; Как распределяется память
;
; +-------------------------------+ FFFFH
; !       ПЗУ  МОНИТОРа  (2К)     !
; +-------------------------------+ F800H
; !     Рабочие  ячейки  МОНИТОРа !
; +-------------------------------+ F750H
; !        Не  использована       !
; +-------------------------------+ F000H (МИКРО-80/ЮТ-88)
; !          ОЗУ  экрана          !
; +-------------------------------+ E800H (МИКРО-807/ЮТ-88)
; !         ОЗУ  курсора          !
; +-------------------------------+ E000H (МИКРО-80)
; !        Не  использована       !
; +-------------------------------+ (MEM_TOP)
; !      Строковые переменные     !
; +-------------------------------+ (STR_TOP)
; !         Стек  Бейсика         !
; +-------------------------------+ (STACK_TOP)
; !            Массивы            !
; +-------------------------------+ (VAR_ARRAY_BASE)
; !      Числовые переменные      !
; +-------------------------------+ (VAR_BASE)
; ! Текст  программы  на  Бейсике !
; +-------------------------------+ (PROGRAM_BASE)
; !         Буфер  экрана         !
; +-------------------------------+ (SCRBUF) (МИКРО-80/ЮТ-88)
; !      Область  подпрограмм     !
; !         пользователя          !
; +-------------------------------+ 1960H
; !    Интерпретатор  Бейсика     !
; +-------------------------------+ 0000H
;
; Рассмотрим блоки памяти, которые идут непосредственно после интерпретатора Бейсика:
;
; The minimum amount of stack space is 18 bytes - at initialisation, after the
; user has stated the options they want, the amount of space is reported as 
; "X BYTES FREE", where X is 4096 minus (amount needed for Basic, plus 18 bytes
; for the stack). With all optional inline functions selected - SIN, RND, and SQR
; - X works out to 727 bytes. With no optional inline functions selected, the 
; amount increases to 973 bytes.
;
; Текст программы на Бейсике
;
; На рис. показан формат строки программы на Бейсике в том виде, в каком она хранится в памяти микро-ЭВМ. 
; В начале каждой строки два байта отведены для хранения указателя адреса начала следующей строки программы,
; следующие два байта хранят номер строки, а заканчивается она байтом, заполненным одними нулями. Таким образом,
; текст программы хранится в памяти в виде специальной структуры данных, называемой в литературе "односвязным списком".
;
; Для большей эффективности по скорости и использованию памяти, программа храниться в токенизированном виде.
; Токенизация заключается в простой замене ключевых слов их идентификаторами. Идентификатора занимают один байта
; (более поздние версии используют 1- и 2-байтовые идентификаторы). Идентификатор определяется установленным
; старшим битом, т.е. коды индентификаторов находятся в диапазоне 0x80 - 0xFF.
;
; Например, строка:
;
; FOR I=1 TO 10
;
; В токенизированном виде выглядит как :
;
; 81 " I=1" 95 " 10"
;
; Здесь 081H - идентификатор для FOR, далее следует строка " I=1", после которой - идентификатор 095H для TO, и оканчивается
; строкой " 10". Всего 9 байт вместо 13 байт для нетокенизированной строки.
;
; This particular example line of input is meaningless unless it is part of a larger program. As you should know already,
; each line of a program is prefixed with a line number. These line numbers get stored as 16-bit integers preceding the
; tokenised line content. Additionally, each line is stored with a pointer to the following line. Let's consider the 
; example input again, this time as a part of a larger program :
;
; 10 FOR I=1 TO 10
; 20 PRINT "HELLO WORLD"
; 30 NEXT I
;
; Приняв начало памяти программы за 0D18, данная программа будет сохранена в памяти следующим образом:
;
;
;
; Таким образом, каждая строка программы состоит из трех компонент:
;
; Указатель на следующую строку
; Номер строки
; Токенизированная строка
;
; Последняя строка программы всегда присутствует и
; содержит нулевой указатель на несуществующую следующую строку.
; Эта нулевая строка, длиной два байта, маркер конца программы.

; Заканчивая обработку очередной строки программы, интерпретатор 
; последовательно просматривает указатели списка до тех пор, пока 
; не будет найдена строка с требуемым номером. Конец списка
; помечается двумя "нулевыми" байтами. Вы таким же образом
; можете вручную (с помощью директив Монитора) определить,
; где заканчивается программа, просматривая указатель списка
; до тех пор, пока не обнаружите три смежных байта, заполненных
; нулями. Во многих практических случаях, воспользовавшись
; рассмотренными рекомендациями, можно восстановить программу,
; в которой в результате сбоя была нарушена целостность списка. 
; После восстановления структуры списка необходимо изменить значения,
; хранящиеся в ячейках памяти 0245Н и 0246Н. В этих ячейках хранятся 
; значения соответственно младшего и старшего байта конечного адреса 
; программы. Этот адрес на двойку превосходит адрес первого байта 
; маркера конца списка.
;
; Переменные
; ----------
;
; Поддержка переменных в этой версии Бейсика достаточно ограниченная.
; Разрешенный тип переменных только числовой - нет символьных, структур, и, конечно,
; не различаются целые числи и числа с плавающей точкой. Все переменные хранятся и
; обрабатываются как числа с плавающей точкой.
;
; Длина имени переменных ограничена максимум двумя символами: первый (обязательный)
; символ должен быть буквой (латинской), а второй (опциональный) символ - число.
; Таким образом следующие определения некорректны:
;
; LET FOO=1
; LET A="HELLO"
; LET AB=A
;
; В то время как следующие - корректны:
;
; LET A=1
; LET B=2.5
; LET B2=5.6
; 	 
; Фиксированная длина переменных существенно упрощает их хранение в памяти.
; Каждая переменная занимает 6 байт в памяти: два байта для имени и четыре
; байта для значения переменной.
;
; Массивы
; -------
;
; Массивы хранятся в отдельной области памяти, сразу после области переменных. Начала области массивов определяется переменной
; VAR_ARRAY_BASE. Массивы определяются ключевым словом DIM. Размерность массива n приводит к выделению n+1 элементов,
; адресуемых значениями индекса от 0 до n включительно.
;
; Соответственно, код ниже корректен:
;
; DIM A(2)
; A(0) = 1
; A(1) = 2
; A(2) = 3
;
; но:
;
; A(3) = 4
;
; приведет к ошибке Ошибка 09. Индекс не соответствует размерности массива.
;
; Массив хранится в памяти аналогично обычным переменным. Вначале следует двух-байтовое имя
; переменной. Далее следует 16-битное целое, содержащее размер в байтах элементов массива.
; Далее следуют непосредственно элементы массива (по 4-е байта на каждый элемент).
; Например, указанный выше массив A(2), если сохранен по адресу 0D20, будет храниться так:
;
; Address	Bytes		Value	Description
; 0D20		0x4100		'A\0'	Variable name
; 0D22		0x000C	 		Total size, in bytes, of the array elements.
; 0D24		0x81000000	1	Element 0 value
; 0D28		0x82000000	2	Element 1 value
; 0D2C		0x82400000	3	Element 2 value
; 
;
; Порядок исполнения
; ------------------
;
; При выполнении команды RUN исполнение начинается с первой строки программы.
; Когда строка заканчивается, исполнение продолжается со следующей строки и так далее до тех
; пор, пока не будет достигнут конец программы, команда END или STOP.
;
; This is too simple for all but the simplest programs - there are two mechanisms in Basic 
; for altering program flow so that code can run in loops and subroutines be called.
; These mechanisms are FOR/NEXT for looping, and GOSUB/RETURN for subroutines.
;
; In both FOR and GOSUB cases, the stack is used to store specific information about
; the program line to return to.
;
	CPU	8080
	Z80SYNTAX	EXCLUSIVE

; Конфигурация

	ifndef MICRON
MICRON 	EQU	0		; Модификации для "Бейсик-Микрон"
	endif

	ifndef MIKROSHA
MIKROSHA 	EQU	0	; Модификации для "Бейсик для Микроша"
	endif

; Т.к. Микроша близок в РК86, то используем его код в качестве основы
	if MIKROSHA
RK86		EQU	1	; Модификации для "Бейсик для Радио-86РК"
RAM			EQU	32	; Микроша шла только с 32кб
	endif

	IF	MICRON
RAM			EQU	32	; Микрон с 32кб
	ENDIF

	ifndef RK86
RK86		EQU	0	; Модификации для "Бейсик для Радио-86РК"
	endif
	ifndef UT88
UT88		EQU	0	; Модификации для "Бейсик для ЮТ-88"
	endif
	ifndef SERVICE
SERVICE		EQU	0	; Модификации для Бейсик-Сервис
	endif
	ifndef BASICNEW
BASICNEW	EQU	0	; Включить мои изменения в коде
	endif
ANSI		EQU	0	; Включить поддержку совместимости с ANSI Minimal Basic
GOST		EQU	0	; Включить поддержку совместимости с ГОСТ 27787-88

	IFNDEF	RAM
RAM			EQU	16
	ENDIF

; Верхний адрес доступной памяти. В МИКРО-80/ЮТ-88 задано жестко, 
; а в РК-86 настраивается при инициализации. В Микроше тоже жестко.
; В Миероне тоже жестко
	if MIKROSHA
MEM_TOP		EQU	075FFH
	else; MIKROSHA
	if MICRON
MEM_TOP		EQU	075FFH
	else; MICRON
	IF	RAM=12
MEM_TOP		EQU	02FFFH
	ELSEIF	RAM=16
MEM_TOP		EQU	03FFFH
	ELSEIF	RAM=32
MEM_TOP		EQU	07FFFH
	ELSEIF	RAM=48
MEM_TOP		EQU	0BFFFH
	ENDIF
	endif; MICRON
	endif; MIKROSHA

	
	IF	BASICNEW
	IF	ANSI
OPTION		EQU	1	; Поддержка команды OPTION
LET			EQU	1	; Поддержка команды LET
RANDOMIZE 	EQU	1	; Поддержка команды RANDOMIZE
END			EQU	1	; Поддержка команды END
	ELSE    ; ANSI
	IF	GOST
OPTION		EQU	1	; Поддержка команды OPTION
LET			EQU	1	; Поддержка команды LET
RANDOMIZE	EQU	1	; Поддержка команды RANDOMIZE
END			EQU	1	; Поддержка команды END
	ELSE	; GOST
OPTION		EQU	0	; Поддержка команды OPTION
LET			EQU	1	; Поддержка команды LET
RANDOMIZE 	EQU	0	; Поддержка команды RANDOMIZE
END			EQU	1	; Поддержка команды END
	ENDIF   ; GOST
	ENDIF   ; ANSI      
	ELSE	; BASICNEW
OPTION		EQU	0	; Поддержка команды OPTION
LET			EQU	0	; Поддержка команды LET
RANDOMIZE 	EQU	0	; Поддержка команды RANDOMIZE
END			EQU	0	; Поддержка команды END
	ENDIF   ; BASICNEW


	IF	BASICNEW
CHK	MACRO	adr, msg
	ENDM
	ELSE
	IF	MICRON
CHK	MACRO	adr, msg
	ENDM
	ELSE
CHK	MACRO	adr, msg
		IF	adr-$
			ERROR	msg
		ENDIF
	ENDM
	ENDIF
	ENDIF

	IF	RK86
	IF SERVICE
PROGRAM_BASE_INIT	EQU	1D00H
	ELSE
PROGRAM_BASE_INIT	EQU	1B00H
	ENDIF


	IF RAM=16
SCRADDR	EQU	037C2H
	ELSE		; 32kb
SCRADDR	EQU	077C2H
	ENDIF

	ELSE

	IF SERVICE

SCRBUF			EQU	1D00H
PROGRAM_BASE_INIT	EQU	2500H

	ELSE
	IF	BASICNEW
SCRBUF			EQU	1D00H
PROGRAM_BASE_INIT	EQU	2500H
	ELSE
SCRBUF			EQU	1A00H
PROGRAM_BASE_INIT	EQU	2200H
	ENDIF
	ENDIF

	ENDIF


	IF	MICRON

VarSize		EQU	2049h
IOCode		EQU	205Ch		; три байта in a, (n) или out (n), a плюс ret
TERMINAL_X	EQU	2063h
TMP_HL		EQU	2064h
LINE_BUFFER	EQU	2090h
ControlChar	EQU	2117h
DIM_OR_EVAL	EQU	2118h
VALTYP		EQU	2119h
DATA_STM	EQU	211Ah
MEMSIZ		EQU	211Bh
TEMPPT		EQU	211Dh
TMPST		EQU	211Fh
TMPSTR		EQU	212Bh
STR_TOP		EQU	212FH
CUR_TOKEN_ADR	EQU	2131h
DATA_LINE	EQU	2133h
NO_ARRAY	EQU	2135h
INPUT_OR_READ	EQU	2136h
PROG_PTR_TEMP	EQU	2137h
PROG_PTR_TEMP2	EQU	2139h
CURRENT_LINE	EQU	213Bh
OLD_LINE	EQU	213Dh
OLD_TEXT	EQU	213Fh
STACK_TOP	EQU	2141H
PROGRAM_BASE	EQU	2143h
VAR_BASE	EQU	2145h
VAR_ARRAY_BASE	EQU	2147h
VAR_TOP		EQU	2149h
DATA_PROG_PTR	EQU	214Bh

FACCUM		EQU	214Dh

ERR_NF		EQU 00H
ERR_SN		EQU 02H		
ERR_RG		EQU 04H
ERR_OD		EQU	06H
ERR_FC		EQU	08H
ERR_OM		EQU 0CH
ERR_US		EQU 0EH
ERR_DD		EQU 12H
ERR_DZ		EQU 14H
ERR_TM		EQU	18H
ERR_CN		EQU 20h

PrintString	EQU	0F818H
		ENDIF
; 
;********************
;* 1. Интерпретатор *
;********************

;================
;= 1.1 Рестарты =
;================

; Полезной возможностью 8080 является возможность вызова ряда адресов в нижних адресах
; памяти однобайтовой инструкцией вместо стандартных 3-х байтовых вызовов
; CALL и подобными командами. Данные адреса называют адресами "Рестартов"
; и обычно используются для часто вызываемых функций, что эконоит по 2 байта на каждом вызове.
; Всего Бейсик использует 7 рестартов. 8-й рестарт используется отладчиками.

; Начало (RST 00h)


; Запуск интерпретатора осуществляется с адреса 0. Проводится инициализация стека и
; переход на код инициализации.

	IF	BASICNEW
	ORG	0
;	ORG	100H
RST	MACRO	adr
	CALL	adr
	ENDM
	ELSE
	ORG	0
	ENDIF

Start:
	IF	RK86
		LD	SP, TMPSTACK
	ELSE
		LD	SP, MEM_TOP
	ENDIF
		JP	Init

; Данные байты не используются? В оригинале здесь указатели на какие-то данные, а не код.
	IF	MICRON
		NOP
		NOP
	ELSE
		INC	HL
		EX	(SP),HL
	ENDIF

		;RST 08h
		INCLUDE "spSyntaxCheck.inc"


	IF	BASICNEW
	ELSE
		;RST 10h
		INCLUDE "spNextChar.inc"
	ENDIF

; OutChar (RST 3)
; Печать символа на терминал.

	IF	BASICNEW
	ELSE
OutChar:
	ENDIF
	IF	MICRON
		PUSH    BC
        PUSH    HL
        PUSH    AF
        LD      C,A
        JP      OutChar_tail

		NOP

		; RST 20h
		include "spCompareHLDE.inc"

INIT_PROGAM_BASE:
		DW	2201H
	ELSE
	IF	BASICNEW
	ELSE
		PUSH	AF
		LD	A,(ControlChar)
		OR	A
		JP	OutChar_tail
	ENDIF

		; RST 20h
		include "spCompareHLDE.inc"

;
	IF	BASICNEW
	ELSE
NULLS:	DB	01	; Число нолей-1, которое надо вывести после перевода строки (это было нужно для терминалов)
	ENDIF
TERMINAL_X:	DB		00	; Variable controlling the current X positions of terminal output

	ENDIF
		; RST 28h
		include "spFTestSign.inc"
	

;
;PushNextWord (RST 6)
;Effectively PUSH (HL). First we write the return address to the JMP instruction at the end of the function; then we read the word at (HL) into BC and push it onto the stack; lastly jumping to the return address.
;
PushNextWord:
	IF	MICRON
		LD		C, (HL)
        INC     HL
        LD      B,(HL)
        INC     HL
        JP      RST6_CONT


	NOP

RST7:	RET

		NOP
        NOP

RST6_CONT:
		LD      (TMP_HL),HL
        POP     HL
        PUSH    BC
        PUSH    HL
        LD      HL,(TMP_HL)
        RET
	ELSE
	EX	(SP),HL
	LD	(RST6RET),HL
	POP	HL
	IF	BASICNEW
	ELSE
	JP	RST6_CONT		; Отличие от Altair - место для обработчика RST 7
;
;
;
;	ORG	38H
RST7:
	RET
	ENDIF

L0039:	DW	0

	IF	BASICNEW
	ELSE
RST6_CONT:
	ENDIF
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	PUSH    BC
RST6RET:	EQU	$+1
	JP	04F9H		; Это самомодифицирующийся код, см. PushNextWord.

	ENDIF

	; Блок данных
	IF	BASICNEW
	ELSE
	IF	MICRON
	ELSE
	include "data.inc"
	ENDIF
	ENDIF


;=========================
;= 1.4 Utility Functions =
;=========================

; Some useful functions.

		CHK 027ah, "Сдвижка кода"
		include	"spGetFlowPtr.inc"
		include	"spCopyMemoryUp.inc"
		include "spCheckEnoughVarSpace.inc"


; CheckEnoughMem
; Checks that HL is more than 32 bytes away from the stack pointer. If HL is within 32 bytes
; of the stack pointer then this function falls into OutOfMemory.

CheckEnoughMem:
		PUSH    DE
        EX      DE,HL
	IF	MICRON
        LD      HL,0FFDBh		; Отличается от более старых версий на 1 байт. Должно быть -34. 0FFDFh. Причину не разбирал
	ELSE
        LD      HL,0FFDAH		; HL=-34 (extra 2 bytes for return address)
	ENDIF
        ADD     HL,SP
        RST     CompareHLDE
        EX      DE,HL
        POP     DE
        RET     NC

; 5 обработчиков ошибки
; Используется трюк с LD BC,...
; (Здесь можно еще пооптимизировать, используя трюки с INC/DEC/LD B,...)

OutOfMemory:
		LD	E, ERR_OM
		JP	Error

DATASyntaxError:
		LD      HL,(DATA_LINE)
		LD      (CURRENT_LINE),HL

SyntaxError:
		LD      E, ERR_SN
		IF	MICRON
	        XOR     A
	        LD      (2078h),A
		ENDIF
		DB	01		; LD BC,...
DivideByZero:
		LD      E, ERR_DZ
		DB		01				; LD BC,...
WithoutFOR:
		LD      E, ERR_NF

; Error
;
; Сбрасывает стек, выводит сообщение об ошибке (смещение 
; сообщение об ошибке передается в E) и прекращает исполнение
; программы.
Error:
	IF	BASICNEW
		LD	A, E			; Делим смещение на 2
		SCF
		CCF
		RRA
		LD	(ErrorCode), A		; И сохраняем для получения по ERR
		LD	HL, (CURRENT_LINE)	; Получаем текущую строку
		LD	(ErrorLine), HL		; И сохраняем ее для получения по ERL
	ENDIF

	CALL    ResetStack
        XOR     A
        LD      (ControlChar),A
        CALL    NewLine
	IF	MICRON
        LD      A,E
        RRCA
        LD      E,A
        INC     E
        LD      HL,ErrorMessages
L00B8:  DEC     E
        JP      Z,MessageFound
L00BC:  LD      A,(HL)
        INC     HL
        OR      A
        JP      Z,L00B8
        JP      L00BC

MessageFound:
	CALL    PrintString
	ELSE
        LD      HL,ERROR_CODES
        LD      D,A
        LD      A,'?'
        RST     OutChar
        ADD     HL,DE
	IF	BASICNEW
		LD	E, (HL)
		INC	HL
		LD	D, (HL)
		EX	DE, HL
		CALL    PrintString
	ELSE
        LD      A,(HL)
        RST     OutChar
        RST     NextChar
        RST     OutChar
	ENDIF

	ENDIF
        LD      HL, szError
PrintInLine:
	CALL    PrintString
        LD      HL, (CURRENT_LINE)
        LD      A,H
        AND     L
        INC     A
        JP      Z,Main
        PUSH    HL
        CALL    PrintIN
        LD      A,':'           ; ':'
        RST    	OutChar
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

;
; Main
; Here's where a BASIC programmer in 1975 spent most of their time : typing at an "OK" prompt, one line at a time. A line of input would either be exec'd immediately (eg "PRINT 2+2"), or it would be a line of a program to be RUN later. Program lines would be prefixed with a line number. The code below looks for that line number, and jumps ahead to Exec if it's not there.
;

Main:
	LD      HL, szOK			; szOK
        CALL    PrintString

		LD		HL,0FFFFH			; Сбрасываем текущую выполняемую строку
		LD		(CURRENT_LINE),HL

        LD      (2078h),HL
		

GetNonBlankLine:
		XOR     A
        LD      (ControlChar),A
        LD      (LINE_BUFFER),A
        LD      (TERMINAL_X),A
        CALL    L0279
		
        ; --- START PROC L010D ---
L010D:  CALL    TerminateInput
        ; --- START PROC L0110 ---

L0110:
		RST		NextChar			; Считываем первый символ из буфера. Флаг переноса =1, если это цифра
		INC		A					; Проверяем на пустую строку. Инкремент/декремент не сбрасывает флаг переноса.
		DEC		A
		JP		Z, GetNonBlankLine	; Снова вводим строку, если пустая
		PUSH	AF					; Сохраняем флаг переноса
		CALL	LineNumberFromStr	; Получаем номер строки в DE
		PUSH	DE					; Запоминаем номер строки
		CALL	Tokenize			; Запускаем токенизатор. В C возвращается длина токенизированной строки, а в А = 0
		LD		B,A					; Теперь BC=длина строки
		POP		DE					; Восстанавливаем номер строки
		POP		AF					; Восстанавлливаем флаг переноса
		JP		NC, Exec			; Если у нас строка без номера, то сразу исполняем

; StoreProgramLine
; Here's where a program line has been typed, which we now need to store in program memory.

StoreProgramLine:
        PUSH    DE
        PUSH    BC
        RST     NextChar
        PUSH    AF
        CALL    FindProgramLine			; Ищем строку в программе
        PUSH    BC
        JP      NC,InsertProgramLine	; Если не нашли, то вставляем строку

; Carry was set by the call to FindProgramLine, meaning that the line already exists.
; So we have to remove the old program line before inserting the new one in it's place.
; To remove the program line we simply move the remainder of the program 
;(ie every line that comes after it) down in memory.

RemoveProgramLine:
        EX      DE,HL
        LD      HL,(VAR_BASE)
RemoveProgramLineLoop:
		LD      A,(DE)
        LD      (BC),A
        INC     BC
        INC     DE
        RST     CompareHLDE
        JP      NC, RemoveProgramLineLoop
        LD      H,B
        LD      L,C
        INC     HL
        LD      (VAR_BASE),HL

;To insert the program line, firstly the program remainder (every line that comes
; after the one to be inserted) must be moved up in memory to make room.

InsertProgramLine:
		POP     DE
        POP     AF
        JP      Z,UpdateLinkedList
        LD      HL,(VAR_BASE)
        EX      (SP),HL
        POP     BC
        ADD     HL,BC
        PUSH    HL
        CALL    CopyMemoryUp
        POP     HL
        LD      (VAR_BASE),HL
        EX      DE,HL
        LD      (HL),H
        INC     HL
        INC     HL
        POP     DE
        LD      (HL),E
        INC     HL
        LD      (HL),D
        INC     HL
		
CopyFromBuffer:
        LD      DE,LINE_BUFFER		;Copy the line into the program
CopyFromBufferLoop:
		LD      A,(DE)
        LD      (HL),A
        INC     HL
        INC     DE
        OR      A
        JP      NZ,CopyFromBufferLoop

;Now the program line has been inserted/removed, all the pointers from each line to the next need to be updated.

UpdateLinkedList:
		CALL    ResetAll
        INC     HL
UpdateLinkedListLoop:
		LD      D,H
        LD      E,L
        LD      A,(HL)
        INC     HL
        OR      (HL)
        JP      Z,GetNonBlankLine2
        INC     HL
        INC     HL
        INC     HL
        XOR     A
FindEndOfLine:
		CP      (HL)
        INC     HL
        JP      NZ,FindEndOfLine
        EX      DE,HL
        LD      (HL),E
        INC     HL
        LD      (HL),D
        EX      DE,HL
        JP      UpdateLinkedListLoop

GetNonBlankLine2:
		LD      A,(ControlChar)
        OR      A
        JP      Z,GetNonBlankLine
        DEC     A
        JP      Z,Main
        XOR     A
        LD      (ControlChar),A
        JP      L18E7

		INCLUDE	"spFindProgramLine.inc"

        ; --- START PROC New ---
New:
		RET     NZ
        LD      HL,(PROGRAM_BASE)
        XOR     A
        LD      (HL),A
        INC     HL
        LD      (HL),A
        INC     HL
        LD      (VAR_BASE),HL
		
        ; --- START PROC ResetAll ---
ResetAll:
		LD      HL,(PROGRAM_BASE)
        DEC     HL
        LD      (HL),00h
		
        ; --- START PROC ClearAll ---
ClearAll:
		LD      (PROG_PTR_TEMP),HL
        LD      HL,(MEMSIZ)
        LD      (STR_TOP),HL
        CALL    L04A5
        ; --- START PROC L01CD ---
L01CD:  LD      HL,(VAR_BASE)
        LD      (VAR_ARRAY_BASE),HL
        LD      (VAR_TOP),HL
        ; --- START PROC ResetStack ---
ResetStack:
		POP     BC
        LD      HL,(STACK_TOP)
        LD      SP,HL
        LD      HL,TMPST
        LD      (TEMPPT),HL
        LD      HL,0000h
        PUSH    HL
        LD      (OLD_TEXT),HL
        LD      HL,(PROG_PTR_TEMP)
        XOR     A
        LD      (NO_ARRAY),A
        PUSH    BC
        RET



	
; Tokenize
;
; Токенизирует строку в буфере LINE_BUFFER, заменяя ключевые слова кодом токена.
; На выходе C содержит длину токенизированной строки плюс несколько байт
; для завершения строки программы.

Tokenize:
		XOR     A
L01F2:

		LD      (DATA_STM),A
		LD      C,05H			; Initialise line length to 5
		LD      DE,LINE_BUFFER		; ie, output ptr is same as input ptr at start.

TokenizeNext:
		LD      A,(HL)			; Получение введенного символа

;If char is a space, jump ahead to write it out.
        CP      ' '
        JP      Z,WriteChar
;If char is a " (indicating a string literal) then freely copy up to the closing ". Obviously we don't want to tokenize string literals.
        LD      B,A
        CP      '"'
        JP      Z,FreeCopy
;If char is null then we've reached the end of input, and can exit this function.
        OR      A
        JP      Z,Exit
; Обработка DATA
        LD      A,(DATA_STM)
        OR      A
        LD      B,A
        LD      A,(HL)			; Восстанавливаем введенный символа
        JP      NZ,WriteChar
	IF	MICRON
	ELSE
; Обработка ?
        CP      '?'
        LD      A, TK_PRINT		; Замена ? на PRINT
        JP      Z, WriteChar

	IF	BASICNEW
; Обработка '
        LD      A,(HL)			; Восстанавливаем введенный символ
        CP      "'"
        LD      A, TK_REM		; Замена ' на REM
        JP      Z, WriteChar
	ENDIF

;
        LD      A,(HL)			; Восстанавливаем введенный символ

	ENDIF
        CP      '0'			; Меньше '0'?
        JP      C,KwSearch			; Ищем ключевое слово
        CP      ';'+1			; 0123456789:;
        JP      C,WriteChar

; Here's where we start to see if we've got a keyword. B здесь содержит 0 (см. код выше где OR A; LD B,A)
KwSearch:
	PUSH    DE			; Preserve output ptr.
        LD      DE,KEYWORDS-1		; 
        PUSH    HL			; Preserve input ptr.
        DB	3Eh			; LD      A, ...

KwCompare:
	INC		HL			; !! Отличается от Микро-80 !!
        INC     DE

KwCompareDE:
		LD      A,(DE)			; Get keyword char to compare with.
        AND     7FH			; Ignore bit 7 of keyword char.
        JP      Z, NotAKeyword		; If keyword char==0, then end of keywords reached.
        CP      (HL)			; Keyword char matches input char?
        JP      NZ, NextKeyword		; If not, jump to get next keyword.
; OK, so input char == keyword char. Now we test bit 7 of the keyword char : if it's 0 then we haven't yet reached the end of the keyword and so have to loop back to continue comparing.
        LD      A,(DE)			
        OR      A
        JP      P, KwCompare
; Matched a keyword! First thing we do is remove input ptr from the stack, as since we're matched to a keyword we don't need to go back and try to match another keyword - HL is already the correct input ptr. Then we set A to the keyword ID which gets written out in the next block but one (notice we LXI over the next block).
        POP     AF			; Remove input ptr from stack. We don't need it.
        LD      A,B			; A=Keyword ID
        OR      80H			; Set bit 7 (indicates a keyword)
        DB	0F2H			; JP      P,...
; Here we have found that the input does not lead with a keyword, so we restore the input ptr and write out the literal character.
NotAKeyword:
	POP 	HL			; Restore input ptr
	LD 	A, (HL)			; and get input char
; Write character, and advance buffer pointers.
        POP	DE			; Restore output ptr

WriteChar:
	INC	HL			; Advance input ptr
        LD	(DE),A			; Store output char
        INC	DE			; Advance output ptr
        INC	C			; C++ (arf!).
; If we've just written the ID of keyword REM then we need to freecopy the rest of the line.
; Here we test for REM (8E) and jump back to the outer loop if it isn't. Note that if it is
; REM, then we set B to 0 so the freecopy won't stop prematurely.
        SUB     ':'
        JP      Z,L024A
        CP      TK_DATA-':'
        JP      NZ,L024D
L024A:  LD      (DATA_STM),A
L024D:  SUB     TK_REM-':'
        JP      NZ,TokenizeNext
        LD      B,A			; B=0

;Free copy loop. This loop copies from input to output without tokenizing, 
;as needs to be done for string literals and comment lines. The B register
;holds the terminating character - when this char is reached the free 
;copy is complete and it jumps back

FreeCopyLoop:
	LD      A,(HL)			; A=Input char
        OR      A			; If char is null then exit
        JP      Z,Exit			; 
        CP      B			; If input char is term char then 
        JP      Z,WriteChar		; we're done free copying.
FreeCopy:
		INC     HL
		LD      (DE),A
        INC     C
        INC     DE
        JP      FreeCopyLoop

; NextKeyword. Advances keyword ptr in DE to point to the next keyword in the table, then jumps back to KwCompare to see if it matches. Note we also increment the keyword ID.

NextKeyword:
	POP     HL			; Restore input ptr
        PUSH    HL
        INC     B			; Keyword ID ++
        EX      DE,HL			; HL=keyword table ptr
NextKwLoop:
	OR      (HL)			; Loop until
        INC     HL			; bit 7 of previous
        JP      P,NextKwLoop		; keyword char is set.
        EX      DE,HL			; DE=keyword ptr, HL=input ptr
        JP      KwCompareDE

Exit:	LD      HL,LINE_BUFFER-1
        LD      (DE),A
        INC     DE
        LD      (DE),A
        INC     DE
        LD      (DE),A
        RET

;InputLine
;Gets a line of input into LINE_BUFFER.

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
L02C4:  CALL    PrintString
        LD      C,' '           ; ' '
        CALL    0F809h
        LD      A,08h
L02CE:  RST     OutChar
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
        JP      Z,POPHL_RET
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

OutChar_tail:  LD      HL,L038E
L036A:  LD      A,(HL)
        INC     HL
        CP      C
        JP      Z,L037F
        OR      A
        JP      NZ,L036A
        LD      A,(TERMINAL_X)
        OR      A
        CALL    M,NewLine
        INC     A
        LD      (TERMINAL_X),A
L037F:  LD      A,(ControlChar)
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
        JP      Z,Main
        CALL    TestBreakKey
        PUSH    DE
L03AC:  CALL    L03D1
        POP     HL
        JP      C,Main
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
        CALL    NewLine
        JP      L163B

	INCLUDE "stFor.inc"

;		
; 1.9 Исполнение
;
; ExecNext
;
; После исполнения одной команды, этот блок осуществляет переход к следующей команде
; в текущей строке или на следующей строке. Если больше команд не найденр, то завершаем
; исполнение программы.
;


ExecNext:

; Даем пользователю шанс прервать исполнение.


	if	BASICNEW
		CALL	TestBreakKey
	else
	if	MICRON
		CALL	TestBreakKey
	else
		CALL    0F812h			;---------------
        NOP				; !! Этот блок можно заменить одним вызовом CALL TestBreakKey
        CALL    NZ,CheckBreak		;---------------
	endif
	endif

; Если у нас ':', являющийся разделителем команд (что позволяет иметь несколько команд в строке), то исполняем следующую команду.
        LD      (PROG_PTR_TEMP),HL
        LD      A,(HL)
        EX      DE,HL
        LD      HL,208Dh
        INC     (HL)

; Если это не ':', то должен быть нулевой байт, завершающий строку. В противном случае у нас синтаксическая ошибка.
        OR      A
        JP      Z,L044F
        CP      ':'
        JP      NZ,SyntaxError
        EX      DE,HL
        JP      Exec
L044F:  LD      (HL),A
        EX      DE,HL

; Следующие два байта должны содержать адрес следующей строки. Можно просто их проигнорировать,
; т.к. строки в памяти идут подряд, но мы должны завершить программу, если дошли до ее конца.
        INC     HL
        LD      A,(HL)
        INC     HL
        OR      (HL)
        INC     HL
        JP      Z, EndOfProgram
; Получаем номер следующей строки, кохраняем ее в CURRENT_LINE и переходим к Exec для ее исполнения.
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        EX      DE,HL
        LD      (CURRENT_LINE),HL
        EX      DE,HL

;		
; Exec
;
; Запуск команды BASIC по адресу в HL.
;
		
; Получаем первый символ команды.
Exec:	RST     NextChar
; Сохраняем адрес ExecNext в стеке, чтобы переходить по RET.
        LD      DE,ExecNext
        PUSH    DE

ExecANotZero:
; Если нет команды, то прекращаем исполнение.
	RET     Z

ExecA:
; Все ключевые слова >=0x80. Если это не ключевое слово, то считаем, что LET было не введено и это команда LET.
	SUB     FIRST_TK
        JP      C,Let
        CP      TKCOUNT
        JP      C,CalcHandler
        CP      4Ah             ; 'J'
        JP      C,SyntaxError
        SUB     2Dh             ; '-'

; Вычисляем адрес обработчика команды в таблице обработчиков в HL, сохранив текущий указатель программы в DE.

CalcHandler:
	RLCA				;	BC = A*2
        LD      C,A
        LD      B,00H
        EX      DE,HL
        LD      HL,KW_GENERAL_FNS
        ADD     HL,BC
; Считываем в BC адрес обработчика.
        LD      C,(HL)
        INC     HL
        LD      B,(HL)
; Помещаем адрес обработчика в стек, восстанавливаем указатель программы в HL,
; получаем следующий символ и переходим по RET в обработчик команды.
        PUSH    BC
        EX      DE,HL
		
; 1.10 Продолжение вспомогательных функций
;
; NextChar_tail
;

;
; Это дублирующий код из RST NextChar. Аналог последовательности RST NextChar ! RET
; Можно убрать для экономии размера.
;
; NextChar (RST 2)
;
; Возвращает следующий введенный символ из буфера по адресу HL, пропуская символы пробелов.
; Флаг переноса C выставлен, если возвращаемый символ не алфавитно-цифровой.
; Также флаг Z выставляется, если символ равен NULL.



	IF	BASICNEW
NextChar:
	ENDIF

NextChar2:
	INC     HL
        LD      A,(HL)
        CP      ':'
        RET     NC

NextChar_tail:
; Пропускаем пробел.
	CP      ' '
        JP      Z,NextChar2

; Если символ >= '0', то устанавливаем флаг переноса.
        CP      '0'
        CCF     
; Проверяем на ноль, не трогая флаг переноса.
        INC     A
        DEC     A
        RET

Restore:
		JP      Z,L04A5
        CALL    LineNumberFromStr
        RET     NZ
        PUSH    HL
        CALL    Goto2
        POP     DE
        JP      L04AA

        ; --- START PROC L04A5 ---
L04A5:  EX      DE,HL
        LD      HL,(PROGRAM_BASE)
        DEC     HL
L04AA:  LD      (DATA_PROG_PTR),HL
        EX      DE,HL
        RET

; TestBreakKey
; Apparently the Altair had a 'break' key, to break program execution. 
; This little function tests to see if the terminal input device is ready,
; and returns if it isn't. If it is ready (ie user has pressed a key) 
; then it reads the char from the device, compares it to the code for
; the break key (0x03) and jumps to Stop. Since the first instruction 
; at Stop is RNZ, this will return at once if the user pressed some other key.

TestBreakKey:
	CALL    0F812h
        OR      A
        RET     Z
        CALL    L0351
        CP      05h


	INCLUDE "stStop.inc"
	INCLUDE "stEnd.inc"

InputBreak:			; При входе по InputBreak Z=0
	POP     BC		; Убираем адрес возврата из стека

EndOfProgram:
	PUSH    AF		; Сохраняем флаг "STOP" для последующего использования
	LD      HL,(CURRENT_LINE)	; Получаем текущий номер строки
	LD      A,L			; Проверяем, что текущая строка =0FFFFH
	AND     H
	INC     A

        JP      Z,L04D3
        LD      (OLD_LINE),HL
        LD      HL,(PROG_PTR_TEMP)
        LD      (OLD_TEXT),HL

L04D3:

        POP     AF
        LD      HL, szStop		; Сообщение "СТОП"
        JP      NZ, PrintInLine		; Если флаг "STOP", то печатаем сообщение
        JP      Main			; Иначе уходим в диалоговый режим

	CHK	0617H, "Сдвижка кода"

	INCLUDE	"stCont.inc"

;
;CharIsAlpha
;If character pointed to by HL is alphabetic, the carry flag is reset otherwise set.
;
CharIsAlpha:
		LD      A,(HL)
        CP      'A'
        RET     C
        CP      'Z'+1
        CCF
        RET

;GetSubscript
;Gets the subscript of an array variable encountered in an expression or a DIM declaration. The subscript is returned as a positive integer in CDE.

GetSubscript:
		RST     NextChar
EvalPositiveNumericExpression:
		CALL    EvalNumericExpression

; If subscript is negative then jump to FC error below.
FTestPositiveIntegerExpression:
		RST     FTestSign
        JP      M,FunctionCallError

;Likewise, if subscript is >32767 then fall into FC error, otherwise exit to FAsInteger.
FTestIntegerExpression:
		LD      A,(FACCUM+3)
        CP      91h
        JP      C,FAsInteger
        LD      BC,8001h
        LD      DE,0000h
        CALL    FCompare
        LD      D,C
        RET     Z

; Invalid function call (FC) error..
FunctionCallError:
		LD      E,ERR_FC
        JP      Error
		
;1.11 Jumping to Program Lines
;
; LineNumberFromStr
;
; Получает номер строки из указателя на строку. Указатель на строку передается в HL,
; а целочисленный результат возвращается в DE. Ведущие пробелы пропускаются, т осуществляется
; возврат, при первом нечисловом символе. Наибольшее возможное число
; 65529 - будет выведена синтаксическая ошибка, если первые четыре цифры больше 6552.

; Одна из интересных фишек этой функции в том, что она возвращает установленным флаг Z,
; если найдено корректное число (или строка пустая), или флаг NZ если строка начинается
; не с цифры.
		
LineNumberFromStr:
; Уменьшение указателя строки (теперь указавает на предыдущий символ) и инициализация результата = 0.
		DEC     HL
LineNumberFromStr2:
		LD      DE,0000H
NextLineNumChar:
; Получить следующий символ и выйти, если он не буквенно-цифровой.
		RST     NextChar
        RET     NC

        PUSH    HL
        PUSH    AF
; Выводится синтаксическая ошибка, если номер строки > 6552. Фактически, ошибка возникает, еслиномер строки >65529,
; т.к. следующая цифра еще не учтена.
        LD      HL,1998H
        RST     CompareHLDE
        JP      C,SyntaxError
; Умножаем результат на 10.
        LD      H,D
        LD      L,E
        ADD     HL,DE
        ADD     HL,HL
        ADD     HL,DE
        ADD     HL,HL
        POP     AF
; Прибавляем значение данной цифры к результату и продолжаем вычисление.
        SUB     '0'
        LD      E,A
        LD      D,00H
        ADD     HL,DE
        EX      DE,HL
        POP     HL
        JP      NextLineNumChar
	
	CHK	0682H, "Сдвижка кода"

	INCLUDE	"stClear.inc"

	CHK	06ABH, "Сдвижка кода"

	INCLUDE	"stRun.inc"
	
	CHK	06B7H, "Сдвижка кода"

	INCLUDE	"stGosub.inc"

	CHK	06C7H, "Сдвижка кода"

	INCLUDE	"stGoto.inc"

	CHK	06e3h, "Сдвижка кода"

	INCLUDE	"stReturn.inc"

	INCLUDE	"stDataRem.inc"

        ; --- START PROC Let ---
Let:  	CALL    GetVar
        RST     SyntaxCheck
        DB		TK_EQ			; '='
        LD      A,(VALTYP)
        PUSH    AF
        PUSH    DE
        CALL    EvalExpression
        EX      (SP),HL
        LD      (PROG_PTR_TEMP),HL
        POP     DE
        POP     AF
        PUSH    DE
        RRA
        CALL    CheckType
        JP      Z,CopyNumeric
L05E3:  PUSH    HL
        LD      HL,(FACCUM)
        PUSH    HL
        INC     HL
        INC     HL
        RST     PushNextWord
        POP     DE
        LD      HL,(STACK_TOP)
        RST     CompareHLDE
        POP     DE
        JP      NC,Let1
        LD      HL,(VAR_BASE)
        RST     CompareHLDE
        LD      L,E
        LD      H,D
        CALL    C,L0C5F
Let1:	LD      A,(DE)
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

CopyNumeric:
		PUSH    HL
        CALL    FCopyToMem
        POP     DE
        POP     HL
        RET

	CHK	075Ch, "Сдвижка кода"
	
	INCLUDE	"stOn.inc"

	CHK	0778h, "Сдвижка кода"

	INCLUDE "stIf.inc"
		
;1.14 Printing
;Print
;Prints something! It can be an empty line, a single expression/literal, 
;or multiple expressions/literals seperated by tabulation directives 
;(comma, semi-colon, or the TAB keyword).


PrintLoop:
		RST     NextChar

		CHK	0791H, "Сдвижка кода"

Print:
        JP      Z,NewLine

L064B:  RET     Z
        CP      27h             ; '''
        CALL    Z,NewLine
        JP      Z,L0708
        CP      9Dh
        JP      Z,Tab
        CP      9Fh
        JP      Z,Tab
        CP      0C8h		; AT ?
        JP      NZ,L066B
        RST     NextChar
        CALL    Cur
        DEC     HL
        JP      L0708

L066B:  PUSH    HL
        CP      ','
        JP      Z,L06EA
        CP      ';'
        JP      Z,L0707
        POP     BC
        CP      0D3h
        JP      Z,L06A8

        CALL    EvalExpression
        DEC     HL
        PUSH    HL
        LD      A,(VALTYP)
        OR      A
        JP      NZ,L06A1
        CALL    L1326
        CALL    L0C7F
        LD      HL,(FACCUM)
        LD      A,(TERMINAL_X)
        ADD     A,(HL)
        CP      '@'
        CALL    NC,NewLine
        CALL    L0CC6
        LD      A, ' '
        RST     OutChar
        XOR     A
L06A1:  CALL    NZ,L0CC6
L06A4:  POP     HL
        JP      PrintLoop

L06A8:  INC     HL
        CALL    EvalNumericExpression
        DEC     HL
        PUSH    HL
        CALL    FTestIntegerExpression
        LD      A,' '           ; ' '
        RST     OutChar
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
L06D6:  ADD     A,'0'           ; '0'
        RST     OutChar
        RET

	
;TerminateInput
;HL points to just beyond the last byte of a line of user input. Here we write a null byte to terminate it,
; reset HL to point to the start of the input line buffer, then fall into NewLine.
		
TerminateInput:
		LD      (HL),00H		; Самомодифицирующийся код
TerminateInput2:
        LD      HL,LINE_BUFFER-1
		
;NewLine
;Prints carriage return + line feed, plus a series of nulls which was probably due to some peculiarity of the teletypes of the day.

NewLine:
	LD      A,0DH

        RST     OutChar
        LD      A,0AH
        RST     OutChar

	XOR	A
        LD      (TERMINAL_X),A
        RET

;ToNextTabBreak
;Calculate how many spaces are needed to get us to the next tab-break then jump to PrintSpaces to do it.



        ; --- START PROC L06EA ---
L06EA:  LD      A,(TERMINAL_X)
        CP      2Bh             ; '+'
        CALL    NC,NewLine
        JP      NC,L0707
L06F5:  SUB     0Eh
        JP      NC,L06F5
        CPL
        INC     A

        ; --- START PROC L06FC ---
L06FC:  LD      B,A
        LD      A, ' '
        ; --- START PROC L06FF ---
L06FF:  DEC     B
        JP      M,L0707
        RST     OutChar
        JP      L06FF

        ; --- START PROC L0707 ---
L0707:  POP     HL
        ; --- START PROC L0708 ---
L0708:  RST     NextChar
        JP      L064B

;Tab и Spc
;Tabulation. The TAB keyword takes an integer argument denoting the absolute column to print spaces up to.
		
Tab:
	PUSH    AF
        CALL    L0EDB
        RST     SyntaxCheck
        DB	')'
        DEC     HL
        POP     AF
        CP      TK_SPC
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


L0736:  LD      A,(INPUT_OR_READ)
        OR      A
        JP      NZ,DATASyntaxError
        JP      L0873+1         ; reference not aligned to instruction

	CHK	0852h, "Сдвижка кода"
Input:
		CP      '"'
        LD      BC,0120h
        JP      NZ,L0761
        PUSH    BC
        CALL    L0C80
        POP     BC
        LD      A,(HL)
        CP      ';'
        JP      Z,L0759
        LD      B,A
        CP      ','
        JP      NZ,SyntaxError
L0759:  RST     NextChar
        PUSH    HL
        PUSH    BC
        CALL    L0CC6
        POP     BC
        POP     HL
L0761:  PUSH    HL
        PUSH    BC
        CALL    GetVar
        POP     BC
        CALL    L0C31
        DEC     B
        CALL    L0777
        LD      A,(VALTYP)
        CALL    L01F2
        JP      ReadParse         ; reference not aligned to instruction

        ; --- START PROC L0777 ---
L0777:  LD      A,3Fh           ; '?'
        JP      Z,L077D
        LD      A,C
        ; --- START PROC L077D ---
L077D:  RST     OutChar
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
        ; --- START PROC InputLineWithQ ---
InputLineWithQ:  LD      A,'?'           ; '?'
        RST     OutChar
        LD      A,08h
        JP      L077D

Read:
        PUSH    HL
        LD      HL,(DATA_PROG_PTR)
        DB	0F6h		; OR 0AFH
ReadParse:
		XOR	A		; 0AFH
        LD      (INPUT_OR_READ),A
;Preserve data prog ptr on stack and restore prog ptr to HL. This should point to the name of the variable to read data into. Note we also LXI over the syntax check for a comma that's done on subsequent reads.
        EX      (SP),HL
        DB	01h		; LD      BC,...
ReadNext:
		RST	SyntaxCheck
		DB	','
;Get variable value address in DE.
        CALL    GetVar
;Preserve prog ptr and get data prog ptr into HL.
        EX      (SP),HL
;Preserve variable value address on stack.
        PUSH    DE
;Get byte of data part of program. If this is a comma seperator then we've found our data item and can jump ahead to GotDataItem
        LD      A,(HL)
        CP      ','
        JP      Z,GotDataItem

        LD      A,(INPUT_OR_READ)
;If the next byte of data is not a null byte terminating the line then syntax error out.
        OR      A
        JP      NZ,ReadError
;We've been called by the INPUT handler, and we have more inputs to take - the interpreter allows 'INPUT A,B,C' -type statement. So here we get the next input, only Bill has made a mistake here - he prints an unnecessary '?' , so the user gets two question marks for all inputs after the first one.

	LD      A,','           ; В микро-80 тут '?'
        RST     OutChar
        CALL    InputLineWithQ

; Restore variable address, advance the data ptr so it points to the start of the next data item, and assign the data item to the variable. 
GotDataItem:
		LD      A,(VALTYP)
        OR      A
        JP      Z,L07D9
        RST     NextChar
        LD      D,A
        LD      B,A
        CP      '"'
        JP      Z,L07CD
        LD      D,':'
        LD      B,','
        DEC     HL
L07CD:  CALL    L0C83
        EX      DE,HL
        LD      HL,L07E2
        EX      (SP),HL
        PUSH    DE
        JP      L05E3

L07D9:  RST     NextChar
        CALL    L126A
        EX      (SP),HL
        CALL    FCopyToMem
        POP     HL
L07E2:
	DEC     HL
        RST     NextChar
        JP      Z,L07EC
        CP      ','
        JP      NZ,L0736
L07EC:  EX      (SP),HL
        DEC     HL
        RST     NextChar
        JP      NZ, ReadNext
        POP     DE
        LD      A,(INPUT_OR_READ)
        OR      A
        JP      Z,NewLine
        EX      DE,HL
        JP      L04AA

ReadError:
	CALL    Data
        OR      A
        JP      NZ,ReadError1
        INC     HL
        RST     PushNextWord
        LD      A,C
        OR      B
        LD      E,ERR_OD
        JP      Z,Error
        POP     BC
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        EX      DE,HL
        LD      (DATA_LINE),HL
        EX      DE,HL
ReadError1:
	RST     NextChar
        CP      TK_DATA
        JP      NZ,ReadError
        JP      GotDataItem


		CHK	091Dh, "Сдвижка кода"

		INCLUDE	"stNext.inc"

; Evalute expression and check is it value is Numeric
EvalNumericExpression:
		CALL    EvalExpression
IsNumeric:
		DB	0F6H			;OR 37H - это сброс флага CY
IsString:
		SCF				;37H
CheckType:
		LD      A,(VALTYP)
        ADC     A,A
        RET     PE

L0873:
	LD      E,ERR_TM
        JP      Error

;1.17 Expression Evaluation
;EvalExpression
;Evaluates an expression, returning with the result in FACCUM. An expression is a combination of terms and operators.

EvalExpression:
		DEC     HL
        LD      D,00H

L087B:
	PUSH    DE
;Check we've got enough space for one floating-point number.
        CALL    CheckEnoughVarSpace2
        LD      BC,0E8CDh		;!!!! Трюк с LD BC,...
        DB		08H
        LD      (PROG_PTR_TEMP2),HL
        ; --- START PROC L0886 ---
L0886:
	LD      HL,(PROG_PTR_TEMP2)
        POP     BC
        LD      A,B
        CP      78H
        CALL    NC,IsNumeric
;Get byte following sub-expression. This is where we deal with arithmetic operators. If the byte is less than KWID_+ then return.
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
        LD      (CUR_TOKEN_ADR),HL
        RST     NextChar
        JP      L0893

L08AD:  LD      A,D
        OR      A
        JP      NZ,L09CD
        LD      A,(HL)
        LD      (CUR_TOKEN_ADR),HL
        SUB     0A4H
        RET     C

        CP      07H
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
        CALL    IsNumeric
;Push counter and address of ArithParse onto the stack (the latter so we return to it after the arith fn runs)

L08D5:  PUSH    BC
        LD      BC,0886h
        PUSH    BC
;Push FACCUM, taking care to preserve the operator precedence byte in D.
        LD      B,E
        LD      C,D
        CALL    FPush
        LD      E,B
        LD      D,C
;Push address of arithmetic fn and jump back to 
        RST     PushNextWord
        LD      HL,(CUR_TOKEN_ADR)
        JP      L087B

        ; --- START PROC L08E8 ---
L08E8:  XOR     A
        LD      (VALTYP),A
        RST     NextChar
        JP      C,FIn
;If the character is alphabetic then we have a variable, so jump ahead to get it.
        CALL    CharIsAlpha
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
        LD      HL,(PROG_PTR_TEMP2)
        PUSH    HL
        CALL    FNegate
        ; --- START PROC L094B ---
L094B:  CALL    IsNumeric
        POP     HL
        RET

        ; --- START PROC L0950 ---
L0950:
	CALL    GetVar
        PUSH    HL
        EX      DE,HL
        LD      (FACCUM),HL
        LD      A,(VALTYP)
        OR      A
        CALL    Z,FLoadFromMem
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

L097B:
	RST     SyntaxCheck
	DB	'('
	CALL	EvalExpression

        RST     SyntaxCheck
        DB	','
        CALL    IsString
        EX      DE,HL
        LD      HL,(FACCUM)
        EX      (SP),HL
        PUSH    HL
        EX      DE,HL
        CALL    EvalByteExpression
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


		CHK	0A76h, "Сдвижка кода"
FOr:
	DB	0F6h	;OR 0AFH

		CHK	0A77h, "Сдвижка кода"
FAnd:
	XOR	A	; AFh
        PUSH    AF
        CALL    IsNumeric
        CALL    FTestIntegerExpression
        POP     AF
        EX      DE,HL
        POP     BC
        EX      (SP),HL
        EX      DE,HL
        CALL    FLoadFromBCDE
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

L09CD:  LD      HL,09DFh
        LD      A,(VALTYP)
        RRA
        LD      A,D
        RLA
        LD      E,A
        LD      D,64H
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
        CALL    CheckType
        LD      HL,0A1Eh
        PUSH    HL
        JP      Z,FCompare
        XOR     A
        LD      (VALTYP),A
        PUSH    DE
        CALL    EvalCurrentString
        POP     DE
        RST     PushNextWord
        RST     PushNextWord
        CALL    L0DF0
        CALL    FLoadBCDEfromMem
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
        ADD     A,0FFH
        SBC     A,A
        JP      FCharToFloat

L0A28:  LD      D,5Ah           ; 'Z'
        CALL    L087B
        CALL    IsNumeric
        CALL    FTestIntegerExpression
        LD      A,E
        CPL
        LD      C,A
        LD      A,D
        CPL
        CALL    WordFromACToFACCUM
        POP     BC
        JP      L0886

DimContd:
	DEC     HL
        RST     NextChar
        RET     Z

        RST     SyntaxCheck
        DB	','

	CHK	0B15H, "Сдвижка кода"
Dim:
        LD      BC,DimContd
        PUSH    BC
        DB	0f6h	; OR      0AFH
GetVar:	XOR	A          ; AFH
        LD      (DIM_OR_EVAL),A
        LD      B,(HL)
L0A4E:  CALL    CharIsAlpha
        JP      C,SyntaxError
        XOR     A
        LD      C,A
        LD      (VALTYP),A		; A=0, т.е. числовая переменная
        RST     NextChar
        JP      C,L0A63
        CALL    CharIsAlpha
        JP      C,L0A6E
L0A63:  LD      C,A
L0A64:  RST     NextChar
        JP      C,L0A64
        CALL    CharIsAlpha
        JP      NC,L0A64
L0A6E:  SUB     24h             ; '$'
        JP      NZ,L0A7B
        INC     A
        LD      (VALTYP),A
        RRCA
        ADD     A,C
        LD      C,A
        RST     NextChar
L0A7B:  LD      A,(NO_ARRAY)
        ADD     A,(HL)
        CP      28h             ; '('
        JP      Z,L0ACD
        XOR     A
        LD      (NO_ARRAY),A
;Preserve program ptr on stack, and get VAR_ARRAY_BASE into DE and VAR_BASE into HL. This is where we iterate through the stored variables (ie from VAR_BASE to VAR_ARRAY_BASE) to see if the variable has already been declared. 
        PUSH    HL
        LD      HL,(VAR_ARRAY_BASE)
        EX      DE,HL
        LD      HL,(VAR_BASE)
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

L0AA7:
	PUSH    BC
        LD      BC,0006H
        LD      HL,(VAR_TOP)
        PUSH    HL
        ADD     HL,BC
        POP     BC
        PUSH    HL
        CALL    CopyMemoryUp
        POP     HL
        LD      (VAR_TOP),HL
        LD      H,B
        LD      L,C
        LD      (VAR_ARRAY_BASE),HL
L0ABE:
	DEC     HL
        LD      (HL),00H
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
        LD      HL,(DIM_OR_EVAL)
        EX      (SP),HL
        LD      D,00h
L0AD4:  PUSH    DE
        PUSH    BC
        CALL    GetSubscript
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
        DB	')'
        LD      (PROG_PTR_TEMP2),HL
        POP     HL
        LD      (DIM_OR_EVAL),HL
        PUSH    DE
        LD      HL,(VAR_ARRAY_BASE)
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
        LD      A,(DIM_OR_EVAL)
        OR      A
        LD      E,ERR_DD
        JP      NZ,Error
        POP     AF
        CP      (HL)
        JP      Z,L0B81
L0B1D:
	LD      E,10h
        JP      Error

L0B22:  LD      DE,0004h
        LD      (HL),C
        INC     HL
        LD      (HL),B
        INC     HL
        POP     AF
        LD      (VarSize),A
        LD      C,A
        CALL    CheckEnoughVarSpace
        LD      (CUR_TOKEN_ADR),HL
        INC     HL
        INC     HL
        LD      B,C
        LD      (HL),B
        INC     HL
L0B39:  LD      A,(DIM_OR_EVAL)
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
        CALL    CheckEnoughMem
        LD      (VAR_TOP),HL
L0B63:  DEC     HL
        LD      (HL),00h
        RST     CompareHLDE
        JP      NZ,L0B63
        INC     BC
        LD      H,A
        LD      A,(DIM_OR_EVAL)
        OR      A
        LD      A,(VarSize)
        LD      L,A
        ADD     HL,HL
        ADD     HL,BC
        EX      DE,HL
        LD      HL,(CUR_TOKEN_ADR)
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
L0BA3:  LD      HL,(PROG_PTR_TEMP2)
        DEC     HL
        RST     NextChar
        RET

	INCLUDE	"fnFre.inc"

	CHK	0CA8h, "Сдвижка кода"

	INCLUDE	"fnPos.inc"
	
	CHK	0CB0h, "Сдвижка кода"
Def:
	CALL    L0C3F
        LD      BC,Data
        PUSH    BC
        PUSH    DE
        CALL    L0C31
        RST     SyntaxCheck
        DB		28H, 0CDH
        LD      C,C
        LD      A,(BC)
        CALL    IsNumeric
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
        CALL    IsNumeric
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
        CALL    FCopyToMem
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
        LD      (NO_ARRAY),A
        OR      (HL)
        LD      B,A
        CALL    L0A4E
        JP      IsNumeric

Str:	CALL    IsNumeric
        CALL    L1326
        CALL    L0C7F
        CALL    EvalCurrentString
        POP     BC
        LD      BC,TempStringToPool
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
        CALL    Z,NextChar2
        EX      (SP),HL
        INC     HL
        EX      DE,HL
        LD      A,C
        CALL    L0C76
        RST     CompareHLDE
        CALL    NC,L0C5F
        ; --- START PROC TempStringToPool ---
TempStringToPool:  LD      DE,212Bh
        LD      HL,(TEMPPT)
        LD      (FACCUM),HL
        LD      A,01h
        LD      (VALTYP),A
        CALL    L11C0
        RST     CompareHLDE
        LD      E,1Eh
        JP      Z,Error
        LD      (TEMPPT),HL
        POP     HL
        LD      A,(HL)
        RET

PrintString1:
		INC     HL
        CALL    L0C7F
        ; --- START PROC L0CC6 ---
L0CC6:  CALL    EvalCurrentString
        CALL    FLoadBCDEfromMem
        INC     E
L0CCD:  DEC     E
        RET     Z
        LD      A,(BC)
        RST     OutChar
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
        LD      B,0FFH
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
; Сборка мусора
GarbageCollection:
		LD      HL,(MEMSIZ)
        ; --- START PROC L0D00 ---
L0D00:  LD      (STR_TOP),HL
        LD      HL,0000h
        PUSH    HL
        LD      HL,(STACK_TOP)
        PUSH    HL
        LD      HL,TMPST
        EX      DE,HL
        LD      HL,(TEMPPT)
        EX      DE,HL
        RST     CompareHLDE
        LD      BC,0D0Eh
        JP      NZ,L0D5A
        LD      HL,(VAR_BASE)
L0D1D:  EX      DE,HL
        LD      HL,(VAR_ARRAY_BASE)
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
        CALL    FLoadBCDEfromMem
        LD      A,E
        PUSH    HL
        ADD     HL,BC
        OR      A
        JP      P,L0D30
        LD      (CUR_TOKEN_ADR),HL
        POP     HL
        LD      C,(HL)
        LD      B,00H
        ADD     HL,BC
        ADD     HL,BC
        INC     HL
        EX      DE,HL
        LD      HL,(CUR_TOKEN_ADR)
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
        LD      H,00H
        ADD     HL,BC
        LD      D,B
        LD      E,C
        DEC     HL
        LD      B,H
        LD      C,L
        LD      HL,(STR_TOP)
        CALL    CopyMemoryUpNoCheck
        POP     HL
        LD      (HL),C
        INC     HL
        LD      (HL),B
        LD      L,C
        LD      H,B
        DEC     HL
        JP      L0D00

L0DA2:  PUSH    BC
        PUSH    HL
        LD      HL,(FACCUM)
        EX      (SP),HL
        CALL    L08E8
        EX      (SP),HL
        CALL    IsString
        LD      A,(HL)
        PUSH    HL
        LD      HL,(FACCUM)
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
        LD      HL,(TMPSTR+2)
        EX      DE,HL
        CALL    L0DD9
        CALL    L0DD9
        LD      HL,0889h
        EX      (SP),HL
        PUSH    HL
        JP      TempStringToPool

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

EvalString:
	CALL    IsString
EvalCurrentString:
	LD      HL,(FACCUM)
L0DEF:  EX      DE,HL
L0DF0:  LD      HL,(TEMPPT)
        DEC     HL
        LD      B,(HL)
        DEC     HL
        LD      C,(HL)
        DEC     HL
        DEC     HL
        RST     CompareHLDE
        EX      DE,HL
        RET     NZ

        LD      (TEMPPT),HL
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

	CHK	0EE7h, "Сдвижка кода"

	INCLUDE	"fnLen.inc"

	CHK	0ef6h, "Сдвижка кода"

	INCLUDE	"fnAsc.inc"

Chr:	CALL    L0EDF
        POP     BC
L0E33:  LD      A,01h
        PUSH    DE
        CALL    L0C73
        POP     DE
        LD      HL,(TMPSTR+2)
        LD      (HL),E
        JP      TempStringToPool

	CHK	0f14h, "Сдвижка кода"
Left:
	CALL    L0ECB
        XOR     A
RightCont:
		EX      (SP),HL
        LD      C,A
MidCont:
		PUSH    HL
        LD      A,(HL)
        CP      B
        JP      C,L0E4F
        LD      A,B
        DB		11H		;LD      DE,000EH
L0E4F:  LD		C, 0
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
        LD      B,00H
        ADD     HL,BC
        LD      B,H
        LD      C,L
        CALL    L0C76
        LD      L,A
        CALL    L0DDF
        POP     DE
        CALL    L0DF0
        JP      TempStringToPool

Right:	CALL    L0ECB
        POP     DE
        PUSH    DE
        LD      A,(DE)
        SUB     B
        JP      RightCont

	CHK	0f4eh, "Сдвижка кода"
Mid:
	EX      DE,HL
        LD      A,(HL)
        CALL    L0ECE
        PUSH    BC
        LD      E,0FFH
        CP      ')'
        JP      Z,L0E8D
        RST     SyntaxCheck
        DB	','
        CALL    EvalByteExpression
L0E8D:  RST     SyntaxCheck
        DB	')'
        POP     AF
        EX      (SP),HL
        LD      BC,MidCont
        PUSH    BC
        DEC     A
        CP      (HL)
        LD      B,00H
        RET     NC

        LD      C,A
        LD      A,(HL)
        SUB     C
        CP      E
        LD      B,A
        RET     C

        LD      B,E
        RET

; Данный код нигде не вызывается, но это рудимент от Inp(x)
L0EA2:  JP      SyntaxError

L0EA5:  PUSH    BC
        LD      A,0DBh		; in (n), a
        CALL    SetIOCode
        JP      IOCode

        ; --- START PROC SetIOCode ---
SetIOCode:
	LD      (IOCode),A
        LD      A,0C9h		; RET
        LD      (IOCode+2),A
        CALL    L0EDF
        LD      (IOCode+1),A
        RET

; Данный код нигде не вызывается, но это рудимент от Out x
L0EBD:  JP      SyntaxError

L0EC0:  LD      A,0D3h           ; out (n), a
        CALL    SetIOCode
        CALL    L0ED8
        JP      IOCode

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
        DB		','
		DB		06h		; ld b,..
L0EDB:	RST		NextChar
        ; --- START PROC EvalByteExpression ---
EvalByteExpression:
		CALL    EvalNumericExpression
        ; --- START PROC L0EDF ---
L0EDF:  CALL    FTestPositiveIntegerExpression
        LD      A,D
        OR      A
        JP      NZ,FunctionCallError
        DEC     HL
        RST     NextChar
        LD      A,E
        RET

	CHK	0Fc8H, "Сдвижка кода"

	INCLUDE	"fnVal.inc"
	
	; IF	MICRON
	; INCLUDE "MATH.INC"
	; ENDIF

FAddOneHalf:
	LD      HL,ONE_HALF

FAddFromMem:
	CALL    FLoadBCDEfromMem
        JP	FAddBCDE

FSubFromMem:
	CALL    FLoadBCDEfromMem
        DB	21h			;LD      HL,...

FSub:
	POP	BC			; Get lhs in BCDE.
	POP	DE

        ; --- START PROC FSubBCDE ---
FSubBCDE:  CALL    FNegate
        ; --- START PROC FAddBCDE ---
FAddBCDE:  LD      A,B
        OR      A
        RET     Z
        LD      A,(FACCUM+3)
        OR      A
        JP      Z,FLoadFromBCDE
        SUB     B
        JP      NC,L0F30
        CPL
        INC     A
        EX      DE,HL
        CALL    FPush
        EX      DE,HL
        CALL    FLoadFromBCDE
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
        LD      HL,FACCUM
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
		
        ; --- START PROC FNormalise ---
FNormalise:
		CALL    C,L0FC9
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
L0F7D:  LD      (FACCUM+3),A
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
L0F93:  LD      HL,FACCUM+3
        ADD     A,(HL)
        LD      (HL),A
        JP      NC,FZero
        RET     Z
        ; --- START PROC L0F9C ---
L0F9C:  LD      A,B
        ; --- START PROC L0F9D ---
L0F9D:  LD      HL,FACCUM+3
        OR      A
        CALL    M,L0FAE
        LD      B,(HL)
        INC     HL
        LD      A,(HL)
        AND     80h
        XOR     C
        LD      C,A
        JP      FLoadFromBCDE

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
        LD      HL,FACCUM+3
        LD      A,(HL)
        LD      BC,8035h
        LD      DE,04F3h
        SUB     B
        PUSH    AF
        LD      (HL),B
        PUSH    DE
        PUSH    BC
        CALL    FAddBCDE
        POP     BC
        POP     DE
        INC     B
        CALL    L10B2
        LD      HL,1001h
        CALL    FSubFromMem
        LD      HL,1005h
        CALL    L14B0
        LD      BC,8080h
        LD      DE,0000h
        CALL    FAddBCDE
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
        LD      HL,FACCUM
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
L10A4:  CALL    FPush
        LD      BC,8420h
        LD      DE,0000h
        CALL    FLoadFromBCDE
FDiv:	POP     BC
        POP     DE
        ; --- START PROC L10B2 ---
L10B2:  RST     FTestSign
        JP      Z,DivideByZero
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
        LD      HL,FACCUM+3
        DEC     (HL)
        POP     HL
        JP      NZ,L10D5
        JP      L0FB8

        ; --- START PROC L112E ---
L112E:  LD      A,B
        OR      A
        JP      Z,L1150
        LD      A,L
        LD      HL,FACCUM+3
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
L1157:  CALL    FCopyToBCDE
        LD      A,B
        OR      A
        RET     Z
        ADD     A,02h
        JP      C,L0FB8
        LD      B,A
        CALL    FAddBCDE
        LD      HL,FACCUM+3
        INC     (HL)
        RET     NZ
        JP      L0FB8

FTestSign_tail:
	LD      A,(FACCUM+2)
        CP      2Fh             ; '/'
        RLA
L1174:  SBC     A,A
        RET     NZ
        INC     A
        RET

		INCLUDE	"fnSgn.inc"
		INCLUDE	"fnAbs.inc"
		INCLUDE	"spFPush.inc"


FLoadFromMem:
	CALL    FLoadBCDEfromMem

FLoadFromBCDE:
	EX      DE,HL
        LD      (FACCUM),HL
        LD      H,B
        LD      L,C
        LD      (FACCUM+2),HL
        EX      DE,HL
        RET

        ; --- START PROC FCopyToBCDE ---
FCopyToBCDE:  LD      HL,FACCUM
        ; --- START PROC FLoadBCDEfromMem ---
FLoadBCDEfromMem:  LD      E,(HL)
        INC     HL
        LD      D,(HL)
        INC     HL
        LD      C,(HL)
        INC     HL
        LD      B,(HL)
        ; --- START PROC L11BB ---
L11BB:  INC     HL
        RET

        ; --- START PROC FCopyToMem ---
FCopyToMem:  LD      DE,FACCUM
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
L11CB:  LD      HL,FACCUM+2
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

        ; --- START PROC FCompare ---
FCompare:  LD      A,B
        OR      A
        JP      Z,FTestSign
        LD      HL,1172h
        PUSH    HL
        RST     FTestSign
        LD      A,C
        RET     Z
        LD      HL,FACCUM+2
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

        ; --- START PROC FAsInteger ---
FAsInteger:  LD      B,A
        LD      C,A
        LD      D,A
        LD      E,A
        OR      A
        RET     Z
        PUSH    HL
        CALL    FCopyToBCDE
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
Int:	LD      HL,FACCUM+3
        LD      A,(HL)
        CP      98h
        LD      A,(FACCUM)
        RET     NC
        LD      A,(HL)
        CALL    FAsInteger
        LD      (HL),98h
        LD      A,E
        PUSH    AF
        LD      A,C
        RLA
        CALL    FNormalise
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
L126A:  LD      A,(INPUT_OR_READ)
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
        CALL    Z,FNegate
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
L12FC:  CALL    FPush
        CALL    FCharToFloat
FAdd:
        POP     BC
        POP     DE
        JP      FAddBCDE

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

PrintIN:  PUSH    HL
        LD      HL,szIn
        CALL    PrintString
        POP     HL

PrintInt:  EX      DE,HL
        ; --- START PROC L131C ---
L131C:  XOR     A
        LD      B,98h
        CALL    ReturnInteger
        LD      HL,PrintString1
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
        CALL    M,FNegate
        XOR     A
        PUSH    AF
        CALL    L13E1
L1341:  LD      BC,9143h
        LD      DE,4FF8h
        CALL    FCompare
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
L135E:  CALL    FAddOneHalf
        INC     A
        CALL    FAsInteger
        CALL    FLoadFromBCDE
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
        CALL    FCopyToBCDE
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
        CALL    FLoadFromBCDE
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
        CALL    FCompare
        POP     HL
        JP      PO,L1355
        JP      (HL)

ONE_HALF:
        DB 0,0,0,80h		;Constant value 0.5, used by FRoundUp

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

		INCLUDE	"fnSqr.inc"

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
        CALL    FCopyToBCDE
        JP      P,L1437
        PUSH    DE
        PUSH    BC
        CALL    Int
        POP     BC
        POP     DE
        PUSH    AF
        CALL    FCompare
        POP     HL
        LD      A,H
        RRA
L1437:  POP     HL
        LD      (FACCUM+2),HL
        POP     HL
        LD      (FACCUM),HL
        CALL    C,L1405
        CALL    Z,FNegate
        PUSH    DE
        PUSH    BC
        CALL    Log
        POP     BC
        POP     DE
        CALL    L1050
Exp:	CALL    FPush
        LD      BC,8138h
        LD      DE,0AA38h
        CALL    L1050
        LD      A,(FACCUM+3)
        CP      88h
        JP      NC,L114C
        CALL    Int
        ADD     A,80h
        ADD     A,02h
        JP      C,L114C
        PUSH    AF
        LD      HL,1001h
        CALL    FAddFromMem
        CALL    L1047
        POP     AF
        POP     BC
        POP     DE
        PUSH    AF
        CALL    FSubBCDE
        CALL    FNegate
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
L14B0:  CALL    FPush
        LD      DE,104Eh
        PUSH    DE
        PUSH    HL
        CALL    FCopyToBCDE
        CALL    L1050
        POP     HL
        ; --- START PROC L14BF ---
L14BF:  CALL    FPush
        LD      A,(HL)
        INC     HL
        CALL    FLoadFromMem
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
        CALL    FLoadBCDEfromMem
        PUSH    HL
        CALL    FAddBCDE
        POP     HL
        JP      L14C7+1         ; reference not aligned to instruction

Rnd:	RST     FTestSign
        JP      M,L14FD
        LD      HL,206Dh
        CALL    FLoadFromMem
        RET     Z
        LD      BC,9835h
        LD      DE,447Ah
        CALL    L1050
        LD      BC,6828h
        LD      DE,0B146h
        CALL    FAddBCDE
L14FD:  CALL    FCopyToBCDE
        LD      A,E
        LD      E,C
        LD      C,A
        LD      (HL),80h
        DEC     HL
        LD      B,(HL)
        LD      (HL),80h
        CALL    L0F67
        LD      HL,206Dh
        JP      FCopyToMem

        ; --- START PROC Cos ---
Cos:	LD      HL,1558h
        CALL    FAddFromMem
        ; --- START PROC Sin ---
Sin:	CALL    FPush
        LD      BC,8349h
        LD      DE,0FDBh
        CALL    FLoadFromBCDE
        POP     BC
        POP     DE
        CALL    L10B2
        CALL    FPush
        CALL    Int
        POP     BC
        POP     DE
        CALL    FSubBCDE
        LD      HL,155Ch
        CALL    FSubFromMem
        RST     FTestSign
        SCF
        JP      P,L1544
        CALL    FAddOneHalf
        RST     FTestSign
        OR      A
L1544:  PUSH    AF
        CALL    P,FNegate
        LD      HL,155Ch
        CALL    FAddFromMem
        POP     AF
        CALL    NC,FNegate
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

		include	"fnTan.inc"

        ; --- START PROC Atn ---
Atn:	RST     FTestSign
        CALL    M,L1405
        CALL    M,FNegate
        LD      A,(FACCUM+3)
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

Init:   LD      HL,(INIT_PROGAM_BASE)
        LD      (PROGRAM_BASE),HL
        LD      HL,(Start+1)    ; reference not aligned to instruction
        DEC     HL
        LD      (MEMSIZ),HL
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
        LD      HL,szHello
        CALL    PrintString
        CALL    L0351
        RST     OutChar
        CP      'Y'             ; 'Y'
        CALL    New
        ; --- START PROC L1635 ---
L1635:  CALL    ResetStack
        JP      Main

        ; --- START PROC L163B ---
L163B:  EX      DE,HL
        CALL    PrintInt
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
        RST     OutChar
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
        RST     OutChar
        INC     HL
        INC     DE
        JP      L1679

Inkey:	CALL    0F81Bh
        OR      A
        LD      E,A
        JP      P,L0E33
        XOR     A
        CALL    L0C73
        JP      TempStringToPool

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
        LD      (MEMSIZ),HL
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
        JP      Z,Main
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
        LD      (VAR_ARRAY_BASE),HL
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
        LD      HL,(VAR_BASE)
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
L1859:  LD      HL,(VAR_ARRAY_BASE)
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
        LD      HL,(VAR_BASE)
        ADD     HL,BC
        LD      (VAR_BASE),HL
        LD      HL,(VAR_TOP)
        ADD     HL,BC
        LD      (VAR_ARRAY_BASE),HL
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
        CALL    TerminateInput
        LD      A,02h
        LD      (ControlChar),A
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
L18F7:  CALL    EvalByteExpression
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
		CALL    EvalByteExpression
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

Line:	CALL    EvalByteExpression
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
        JP      FLoadFromBCDE

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
        CALL    FTestPositiveIntegerExpression
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
        CALL    FTestPositiveIntegerExpression
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
L1AF2:  CALL    Puncher
        DEC     B
        JP      NZ,L1AF2
        DEC     E
        JP      NZ,L1AF0
        RET

        ; --- START PROC L1AFE ---
L1AFE:  CALL    Puncher
        DEC     E
        JP      NZ,L1AFE
        RET

Csave:  CALL    L1ABC
        CALL    L1AD0
        XOR     A
        LD      E,01h
        CALL    L1AF0
        LD      A,0E6h
        CALL    Puncher
        LD      A,0D3h
        LD      E,04h
        CALL    L1AFE
L1B1E:  INC     HL
        LD      A,(HL)
        CP      22h             ; '"'
        JP      Z,L1B2B
        CALL    Puncher
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
        CALL    Puncher
        LD      A,0D3h
        LD      E,03h
        CALL    L1AFE
        LD      HL,(PROGRAM_BASE)
        DEC     HL
L1B53:  LD      B,03h
L1B55:  LD      A,(HL)
        CALL    Puncher
        OR      A
        INC     HL
        JP      NZ,L1B53
        DEC     B
        JP      NZ,L1B55
        LD      HL,(2115h)
        LD      A,L
        CALL    Puncher
        LD      A,H
        CALL    Puncher
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
        CALL    CheckEnoughMem
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
L1BC3:  LD      (VAR_BASE),HL
        DEC     C
        RET     Z
L1BC8:  LD      A,01h
        LD      (ControlChar),A
        JP      UpdateLinkedList

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
        CALL    PrintString
        POP     HL
        PUSH    HL
        CALL    PrintString
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
        LD      HL,(VAR_BASE)
        DEC     HL
        DEC     HL
        LD      (PROGRAM_BASE),HL
        POP     HL
        CALL    L1B72
        LD      HL,(INIT_PROGAM_BASE)
        LD      (PROGRAM_BASE),HL
        JP      L1BC8

        ; --- START PROC L1C57 ---
L1C57:  RST     NextChar
        CALL    L0937
        PUSH    HL
        CALL    FPush
        CALL    FCopyToBCDE
        CALL    L1050
        LD      BC,8100h
        LD      D,C
        LD      E,C
        CALL    FSubBCDE
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
        CALL    FAddFromMem
        POP     HL
        RET

        ; --- START PROC L1C86 ---
L1C86:  CALL    L1C57
        PUSH    HL
        CALL    FNegate
        JP      L1C7E

        ; --- START PROC L1C90 ---
L1C90:  RST     NextChar
        CALL    L0937
        PUSH    HL
        CALL    Log
        CALL    FPush
        LD      BC,8213h
        LD      DE,5D8Eh
        CALL    FLoadFromBCDE
        POP     BC
        POP     DE
        CALL    L10B2
        POP     HL
        RET

Lprint:
		PUSH    AF
        LD      A,01h
        LD      (ControlChar),A
        POP     AF
        CALL    Print
        XOR     A
        LD      (ControlChar),A
        RET

Llist:  LD      A,01h
        LD      (ControlChar),A
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

        ; --- START PROC Puncher ---
Puncher:  LD      C,A
        JP      0F80Ch


; Сообщения об ошибках
ErrorMessages:
		DB		"NEXT bez FOR" ,0
        DB		"sintaksi~eskaq", 0
        DB		"RETURN bez GOSUB", 0
        DB		"malo dannyh pri DATA", 0
        DB		"newernyj argument", 0
        DB		"perepolnenie", 0
        DB		"malo ozu", 0
        DB		"net stroki", 0
        DB		"newernyj indeks", 0
        DB		"powtornoe opisanie", 0
        DB		"delenie na 0", 0
        DB		"tolxko w programme", 0
        DB		"nesootw.dannyh",0
        DB		"mal bufer",0
        DB		"X$>255",0
        DB		"slovno",0
        DB		"nelxzq",0
        DB		"net DEF", 0
szError:
        DB		" o{ibka", 0
szOK:
        DB		13,10, "vdu:",13,10, 0
szStop:	
		DB		13,10, "stop", 0
szIn:	
		DB		" w stroke ", 0
szHello:
		DB		1Fh, "BASIC *mikron*", 13,10, "NEW?",0
        DB		13,10,"programma:", 0
; Конец сообщений

TOKEN	MACRO	name
name	EQU	Q
Q	SET	Q+1
name_ADDR equ $
	ENDM

FIRST_TK	EQU	80H

KEYWORDS:
Q		SET	FIRST_TK
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
