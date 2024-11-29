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
	CALL    0F818h
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
		CALL    NZ, PrintIN

;
; Main
; Here's where a BASIC programmer in 1975 spent most of their time : typing at an "OK" prompt, one line at a time. A line of input would either be exec'd immediately (eg "PRINT 2+2"), or it would be a line of a program to be RUN later. Program lines would be prefixed with a line number. The code below looks for that line number, and jumps ahead to Exec if it's not there.
;

Main:
		XOR		A
		LD		(ControlChar),A		; Включаем вывод на экран (не управляющий символ)

		LD		HL,0FFFFH			; Сбрасываем текущую выполняемую строку
		LD		(CURRENT_LINE),HL

		LD		HL,szOK				; Выводим приглашение
		CALL		PrintString

GetNonBlankLine:
L030E:	EQU	$+1
		CALL	InputLine			; Самомодифицирующийся код. Считываем строку с клавиатуры

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
        JP      Z,GetNonBlankLine
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

		INCLUDE	"spFindProgramLine.inc"


	CHK	039Dh, "Сдвижка кода"

	INCLUDE	"stNew.inc"




;InputLineWith'?'
;Gets a line of input at a '? ' prompt.

InputLineWithQ:
		LD      A, '?'
        RST     OutChar
        LD      A, ' '
        RST     OutChar
        JP      InputLine
	


	
; Tokenize
;
; Токенизирует строку в буфере LINE_BUFFER, заменяя ключевые слова кодом токена.
; На выходе C содержит длину токенизированной строки плюс несколько байт
; для завершения строки программы.

Tokenize:
		XOR     A

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
	RST	NextChar		; Get next input char
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
        JP      Z,L0447
        CP      TK_DATA-':'
        JP      NZ,L044A
L0447:  LD      (DATA_STM),A
L044A:  SUB     TK_REM-':'
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

Backspace:
	IF	SERVICE
		DEC	HL
		DEC	HL
		DEC	B
		DEC	B
		JP	P, L04B1
L047D:	CALL	Z, NewLine
	ELSE	; SERVICE
		DEC     B			; Char count--;
        DEC     HL			; Input ptr--;
        RST     OutChar			; Print backspace char.
        JP      NZ,InputNext		; 
ResetInput:
		RST     OutChar
L047D:	CALL    NewLine
	ENDIF	; SERVICE
InputLine:
		LD      HL,LINE_BUFFER
        LD      B,01H

; Get a character and jump out of here if user has pressed 'Enter'. 
InputNext:
		CALL    InputChar
;Deal with backspace.

L0488:	CP      08H
        JP      Z,Backspace
        CP      0DH
        JP      Z,TerminateInput

	IF	SERVICE
	IF	RK86
		CP	0AH
	ELSE    ; RK86
		CP	1AH
	ENDIF	; RK86
L0495:	EQU	$+1
		JP	Z, L047D		; Самомодифицирующийся код
		CP	01FH
		JP	Z, L1BE4
		CP	07FH
	IF	RK86
		JP	Z, L1995
	ELSE	; RK86
		JP	NC, InputNext
	ENDIF	; RK86
		LD	C,A
		LD	A, B
		CP	72
	IF	BASICNEW
	ELSE
		NOP
		NOP
	ENDIF
		JP	NC, L1CD8
		LD	A, C
		CP	" "
		JP	C, L1BFB
L04B0:	LD	(HL), C
L04B1:	INC	HL
		RST	OutChar
		INC	B
		JP	InputNext

	ELSE	; SERVICE

;Deal with line-abort..
        CP      18H
        JP      Z,ResetInput
;If user has not given a printable character, then loop back until they do.
        CP      7FH
	IF	RK86
		JP	Z, L1995
		CP	03H
		JP	C, L1967
		CP	1BH
		JP	Z, L1959			; Обработка Esc-последовательности
	ELSE	; RK86
        JP      NC,InputNext
        CP      01H
        JP      C,InputNext
	IF	BASICNEW
	ELSE
        NOP     
        NOP     
        NOP     
        NOP     
		NOP
	ENDIF
	ENDIF	; RK86
;A normal character has been pressed. Here we store it in LINE_BUFFER, only we don't if the terminal width has been exceeded. If the terminal width is exceeded then we ring the bell (ie print ASCII code 7) and ignore the char. Finally we loop back for the next input character.
        LD      C,A
        LD      A,B
        CP      72			; Длина LINE_BUFFER
        LD      A,07H
        JP      NC,IgnoreChar
        LD      A,C			; Write char to LINE_BUFFER.
		LD      (HL),C
L04B1:	INC     HL
        INC     B
IgnoreChar:
		RST     OutChar
        JP      InputNext

	ENDIF	; SERVICE

	IF	BASICNEW
; OutChar (RST 3)
; Печать символа на терминал.

OutChar:
		PUSH	AF
		LD	A,(ControlChar)
		OR	A
	ENDIF

OutChar_tail:
		JP      NZ,POPAFRET
        POP     AF
        PUSH    AF
L04BD:	EQU	$+1
        CP      ' '			; Самомодифицирующийся код в Бейсик-Сервис
        JP      C,L04CD
        LD      A,(TERMINAL_X)
;;

;1.6 Terminal I/O
;OutChar_tail
;Prints a character to the terminal. On entry, the char to be printed is on the stack and A holds TERMINAL_X. 
;If the current line is up to the maximum width then we print a new line and update the terminal position.
; Then we print the character - to do this we loop until the device is ready to receive a char and then write it out.

	IF	SERVICE
	IF	BASICNEW
	ELSE
		NOP
		NOP
		NOP
		NOP
		NOP
	ENDIF
L04C9:	SCF				; Самомодифицирующийся код
		CALL	C, L1B50
	ELSE	; SERVICE
		CP      72
		CALL    Z,NewLine
		INC     A
        LD      (TERMINAL_X),A
	ENDIF	; SERVICE

L04CD:	POP     AF
	PUSH    BC
	LD      C,A
	PUSH    AF
	IF	RK86
	CALL	L19C0
	ELSE
	IF	UT88
	CALL	L1959
	ELSE
	CALL	0F809h
	ENDIF
	ENDIF
	POP	AF
	POP	BC
	IF	BASICNEW
	ELSE
	NOP
	ENDIF
	RET

; InputChar
;
; Получение одного символа от пользователя.

InputChar:
	CALL	0F803H
	IF	SERVICE
	CP	05H
	ELSE
	CP	1FH
	ENDIF

	IF	RK86
	JP	Z, L1049
	CP	0FH
	CALL	Z, L19A0
	CP	04H		; F5
	CALL	Z, L19A8
	RET

	if	BASICNEW
	else
		NOP
		NOP
	include "prnflag.inc"
	endif

	ELSE	; RK86

        JP      Z,0F800h
	if	BASICNEW
	else
        NOP     
	endif
        AND     7FH
        CP      0FH
        RET     NZ

        LD      A,(ControlChar)
        CPL     
        LD      (ControlChar),A
        RET     
	ENDIF	; ENDIF

	CHK	04EEH, "Сдвижка кода"
	INCLUDE "stList.inc"


	CHK	0535H, "Сдвижка кода"

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
        CP      ':'
        JP      Z,Exec

; Если это не ':', то должен быть нулевой байт, завершающий строку. В противном случае у нас синтаксическая ошибка.
        OR      A
        JP      NZ, SyntaxError

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
	JP	C,Let
; Если это не основное слово, то это синтаксическая ошибка.
        CP      TKCOUNT
        JP      NC,SyntaxError

; Вычисляем адрес обработчика команды в таблице обработчиков в HL, сохранив текущий указатель программы в DE.

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

	CHK	05DBh, "Сдвижка кода"

	INCLUDE	"stRestore.inc"

; TestBreakKey
; Apparently the Altair had a 'break' key, to break program execution. 
; This little function tests to see if the terminal input device is ready,
; and returns if it isn't. If it is ready (ie user has pressed a key) 
; then it reads the char from the device, compares it to the code for
; the break key (0x03) and jumps to Stop. Since the first instruction 
; at Stop is RNZ, this will return at once if the user pressed some other key.

TestBreakKey:
	CALL    0F812h
	IF	BASICNEW
	ELSE
        NOP
	ENDIF
        RET     Z

CheckBreak:
	CALL    InputChar
        CP      03H

	CHK	05efh, "Сдвижка кода"

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

	JP      Z,L0609			; Если да, то это прерывание в операторе INPUT
	LD      (OLD_LINE),HL		; Сохраняем номер строки останова
	LD      HL,(PROG_PTR_TEMP)	; Сохранаяем адрес останова из временной переменной
	LD      (OLD_TEXT),HL		; для последующего восстановления по CONT

L0609:
	XOR     A
        LD      (ControlChar),A

        POP     AF
        LD      HL, szStop		; Сообщение "СТОП"
        JP      NZ, PrintInLine		; Если флаг "STOP", то печатаем сообщение
        JP      Main			; Иначе уходим в диалоговый режим

	CHK	0617H, "Сдвижка кода"

	INCLUDE	"stCont.inc"

	INCLUDE	"stNull.inc"

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
        CP      90H
        JP      C,FAsInteger
        LD      BC,9080H
        LD      DE,0000H
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

	INCLUDE	"stLet.inc"


	CHK	075Ch, "Сдвижка кода"
	
	INCLUDE	"stOn.inc"

	CHK	0778h, "Сдвижка кода"

	INCLUDE "stIf.inc"
		
;1.14 Printing
;Print
;Prints something! It can be an empty line, a single expression/literal, 
;or multiple expressions/literals seperated by tabulation directives 
;(comma, semi-colon, or the TAB keyword).

	IF	BASICNEW
	ELSE
; Похоже, это мертвый код
        DEC     HL
	ENDIF

PrintLoop:
		RST     NextChar

		CHK	0791H, "Сдвижка кода"

Print:
        JP      Z,NewLine

L0794:  RET     Z
        CP      TK_TAB
        JP      Z,Tab
        CP      TK_SPC
        JP      Z,Tab
        PUSH    HL
        CP      ','
        JP      Z,ToNextTabBreak
        CP      ';'
        JP      Z,ExitTab
        POP     BC

        CALL    EvalExpression
        DEC     HL
        PUSH    HL
        LD      A,(VALTYP)
        OR      A
        JP      NZ,L07D0
        CALL    FOut
        CALL    L0D4F
        LD      HL,(FACCUM)
        LD      A,(TERMINAL_X)
        ADD     A,(HL)
        CP      '@'
        CALL    NC,NewLine
        CALL    L0D96
        LD      A, ' '
        RST     OutChar
        XOR     A
L07D0:  CALL    NZ,L0D96
        POP     HL
        JP      PrintLoop
	

	
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

	IF	BASICNEW
	ELSE
        LD      (TERMINAL_X),A
	ENDIF

        RST     OutChar
        LD      A,0AH
        RST     OutChar
	IF	BASICNEW
	RET
	ELSE
PrintNull:
	IF	BASICNEW

	XOR	A
        LD      (TERMINAL_X),A
	ENDIF
	LD      A,(NULLS)
PrintNullLoop:
	DEC     A
	IF	BASICNEW
	ELSE
        LD      (TERMINAL_X),A
	ENDIF
        RET     Z
        PUSH    AF
        XOR     A
        RST     OutChar
        POP     AF
        JP      PrintNullLoop
	ENDIF

;ToNextTabBreak
;Calculate how many spaces are needed to get us to the next tab-break then jump to PrintSpaces to do it.

ToNextTabBreak:
		LD      A,(TERMINAL_X)
        CP      30H
        CALL    NC,NewLine
        JP      NC,ExitTab
CalcSpaceCount:
		SUB     0EH
        JP      NC,CalcSpaceCount
        CPL     
        JP      PrintSpaces

;Tab и Spc
;Tabulation. The TAB keyword takes an integer argument denoting the absolute column to print spaces up to.
		
Tab:
	PUSH    AF
        CALL    L0FB8
        RST     SyntaxCheck
        DB	')'
        DEC     HL
        POP     AF
        CP      TK_SPC
        PUSH    HL
        LD      A,E
        JP      Z,Spc
        LD      A,(TERMINAL_X)
        CPL     
        ADD     A,E
        JP      NC,ExitTab
PrintSpaces:
		INC     A
Spc:	
		LD      B,A
        LD      A, ' '
PrintSpaceLoop:
		RST     OutChar
        DEC     B
        JP      NZ,PrintSpaceLoop
ExitTab:
		POP     HL
        RST     NextChar
        JP      L0794

	IF	BASICNEW
	ELSE
	include "szrepeat.inc"
	ENDIF

		
L0840:  LD      A, (INPUT_OR_READ)
        OR      A
        JP      NZ, DATASyntaxError
        POP     BC
        LD      HL, szRepeat
        CALL    PrintString
        LD      HL,(PROG_PTR_TEMP)
        RET     

	CHK	0852h, "Сдвижка кода"
Input:
        CP      '"'				; 22H
        LD      A,00H
        LD      (ControlChar),A
        JP      NZ,NoPrompt
        CALL    GetStringConstant
        RST     SyntaxCheck
        DB		';'
        PUSH    HL
        CALL    L0D96
        POP     HL
NoPrompt:
		PUSH    HL
        CALL    L0D02
        CALL    InputLineWithQ
        INC     HL
        LD      A,(HL)
        OR      A
        DEC     HL
        POP     BC
        JP      Z,InputBreak
        PUSH    BC
        JP      ReadParse

	CHK	0879h, "Сдвижка кода"

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

        LD      A, '?'
        RST     OutChar
        CALL    InputLineWithQ

; Restore variable address, advance the data ptr so it points to the start of the next data item, and assign the data item to the variable. 
GotDataItem:
		LD      A,(VALTYP)
        OR      A
        JP      Z,L08BE
        RST     NextChar
        LD      D,A
        LD      B,A
        CP      '"'				; 22H
        JP      Z,L08B2
        LD      D,':'
        LD      B,','
        DEC     HL
L08B2:  CALL    L0D53
        EX      DE,HL
        LD      HL,L08C7
        EX      (SP),HL
        PUSH    DE
        JP      L072B
		
L08BE:  RST     NextChar
        CALL    FIn
        EX      (SP),HL
        CALL    FCopyToMem
        POP     HL
L08C7:
		DEC     HL
        RST     NextChar
        JP      Z,L08D1
        CP      ','
        JP      NZ,L0840
L08D1:  EX      (SP),HL
        DEC     HL
        RST     NextChar
        JP      NZ, ReadNext
        POP     DE
        LD      A,(INPUT_OR_READ)
        OR      A
        EX      DE,HL
        JP      NZ, SetDataPtr			; L05E0
        OR      (HL)
        LD      HL, szOverflow
        PUSH    DE
        CALL    NZ,PrintString
        POP     HL
        RET     

	IF	BASICNEW
	ELSE
	include "szoverflow.inc"
	ENDIF


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


	LD      E,ERR_TM
        JP      Error

;1.17 Expression Evaluation
;EvalExpression
;Evaluates an expression, returning with the result in FACCUM. An expression is a combination of terms and operators.

EvalExpression:
		DEC     HL
        LD      D,00H

L0978:
	PUSH    DE
;Check we've got enough space for one floating-point number.
        CALL    CheckEnoughVarSpace2
		DB	01h
;Evaluate term and store prog ptr in 015f
		CALL	EvalTerm
        LD      (PROG_PTR_TEMP2),HL
ArithParse:
		LD      HL,(PROG_PTR_TEMP2)
L0986:	POP     BC
        LD      A,B
        CP      78H
        CALL    NC,IsNumeric
;Get byte following sub-expression. This is where we deal with arithmetic operators. If the byte is less than KWID_+ then return.
        LD      A,(HL)
        LD      D,00H
L0990:  SUB     0ABH
        JP      C,L09AA
        CP      03H
        JP      NC,L09AA
        CP      01H
        RLA
        XOR     D
        CP      D
        LD      D,A
        JP      C,SyntaxError
        LD      (CUR_TOKEN_ADR),HL
        RST     NextChar
        JP      L0990

L09AA:  LD      A,D
        OR      A
        JP      NZ,L0A9E
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
        JP      Z,L0E77
        RLCA
        ADD     A,E
        LD      E,A
        LD      HL,0073H
        ADD     HL,DE
        LD      A,B
        LD      D,(HL)
        CP      D
        RET     NC

        INC     HL
        CALL    IsNumeric
;Push counter and address of ArithParse onto the stack (the latter so we return to it after the arith fn runs)

L09D2:  PUSH    BC
        LD      BC,ArithParse
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
        JP      L0978
	
;EvalTerm

;Evaluates a term in an expression. This can be a numeric constant, a variable, an inline function call taking a full expression as an argument, or a bracketed expression.
;Get first character of term, and if it's a digit (as indicated by the carry flag) then jump to FIn

EvalTerm:
		XOR     A
L09E6:  LD      (VALTYP),A
        RST     NextChar
        JP      C,FIn
;If the character is alphabetic then we have a variable, so jump ahead to get it.
        CALL    CharIsAlpha
        JP      NC,EvalVarTerm
;If the character is a leading '+' then simply ignore it and jump back to EvalTerm.
        CP      TK_PLUS			;0A4H
        JP      Z,EvalTerm
;If the character is a leading '.' then that's a decimal point, so jump to FIn
        CP      '.'			;2EH
        JP      Z,FIn
;If the character is a leading '-' then jump head to EvalMinusTerm
        CP      TK_MINUS		;0A5H
        JP      Z,EvalMinusTerm		; L0A1E
        CP      '"'			; 22H
        JP      Z,GetStringConstant
        CP      TK_NOT			; 0A2H
        JP      Z,L0AF9
        CP      TK_FN			; 0A0H
        JP      Z,L0CCD
; Если символ является ключевым словом, то это встроенная функция, тогда обрабатываем ее.
        SUB     TK_SGN			; 0AEH
        JP      NC,EvalInlineFn
;The only possibility left is a bracketed expression. Here we check for an opening bracket, recurse into EvalExpression, and return.
L0A16:  RST     SyntaxCheck
        DB	'('
		CALL	EvalExpression
        RST     SyntaxCheck
L0A1C:  DB	')'
        RET     

EvalMinusTerm:
L0A1E:  LD      D,7DH
        CALL    L0978
        LD      HL,(PROG_PTR_TEMP2)
        PUSH    HL
        CALL    FNegate
L0A2A:	CALL    IsNumeric
        POP     HL
        RET     

;Evaluate a variable. The call to GetVar returns the address of the variable's value in DE, which is then moved to HL then the call to FLoadFromMem loads FACCUM with the variable's value.
EvalVarTerm:
	CALL    GetVar
        PUSH    HL
        EX      DE,HL
        LD      (FACCUM),HL
        LD      A,(VALTYP)
        OR      A
        CALL    Z,FLoadFromMem
        POP     HL
        RET

; Evaluate an inline function. First we get the offset into the KW_INLINE_FNS table into BC and stick it on the stack.
EvalInlineFn:
		LD      B,00H
		RLCA    
		LD      C,A
		PUSH    BC
;Evaluate function argument
		RST     NextChar
		LD      A,C
        CP      2*(TK_LEFTS-TK_SGN)-1		; Это строковые функции fn$ с несколькими параметрами?
        JP      C,L0A65				; Нет, обычная

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
        JP      L0A6D

L0A65:	
	IF	BASICNEW
	LD      A,C
	CP	2*(TK_ERL-TK_SGN)	; Это значение ERL?
	JP	Z, SkipFnArgs
	CP	2*(TK_ERR-TK_SGN)	; Это значение ERR?
	JP	Z, SkipFnArgs
	CP	2*(TK_PI-TK_SGN)	; Это значение PI?
	CALL    NZ, L0A16		; Нет, значит ожидаем параметры
SkipFnArgs:
	ELSE
	CALL    L0A16
	ENDIF

        EX      (SP),HL
        LD      DE,L0A2A
        PUSH    DE
L0A6D:  LD      BC, KW_INLINE_FNS	; 0043H
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
        LD      HL,WordFromACToFACCUM
        JP      NZ,L0A99
        AND     E
        LD      C,A
        LD      A,B
        AND     D
        JP      (HL)

L0A99:  OR      E
        LD      C,A
        LD      A,B
        OR      D
        JP      (HL)

L0A9E:  LD      HL,L0AB0
        LD      A,(VALTYP)
        RRA
        LD      A,D
        RLA
        LD      E,A
        LD      D,64H
        LD      A,B
        CP      D
        RET     NC
        JP      L09D2

L0AB0:	OR      D
        LD      A,(BC)
        LD      A,C
        OR      A
        RRA
        POP     BC
        POP     DE
        PUSH    AF
        CALL    CheckType
        LD      HL,L0AEF
        PUSH    HL
        JP      Z,FCompare
        XOR     A
        LD      (VALTYP),A
        PUSH    DE
        CALL    EvalCurrentString
        POP     DE
        RST     PushNextWord
        RST     PushNextWord
        CALL    L0EC5
        CALL    FLoadBCDEfromMem
        POP     HL
        EX      (SP),HL
        LD      D,L
        POP     HL
L0AD7:  LD      A,E
        OR      D
        RET     Z

        LD      A,D
        OR      A
        CPL
        RET     Z

        XOR     A
        CP      E
        INC     A
        RET     NC

        DEC     D
        DEC     E
        LD      A,(BC)
        CP      (HL)
        INC     HL
        INC     BC
        JP      Z,L0AD7
        CCF
        JP      L12D0
	
L0AEF:	INC     A
        ADC     A,A
        POP     BC
        AND     B
        ADD     A,0FFH
        SBC     A,A
        JP      FCharToFloat
	
L0AF9:  LD      D,5AH
        CALL    L0978
        CALL    IsNumeric
        CALL    FTestIntegerExpression
        LD      A,E
        CPL
        LD      C,A
        LD      A,D
        CPL
        CALL    WordFromACToFACCUM
        POP     BC
        JP      ArithParse

;1.18 Variable Management
;Dim
;Declares an array. Note that the start of this function handler is some way down in the block (at 0B15).

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
L0B1F:  CALL    CharIsAlpha
        JP      C,SyntaxError
        XOR     A
        LD      C,A
        LD      (VALTYP),A		; A=0, т.е. числовая переменная
        RST     NextChar
        JP      C,L0B34
        CALL    CharIsAlpha
        JP      C,L0B3F
L0B34:  LD      C,A
L0B35:  RST     NextChar
        JP      C,L0B35
        CALL    CharIsAlpha
        JP      NC,L0B35
L0B3F:  SUB     '$'			; 24H
        JP      NZ,L0B4C
        INC     A			; A=1, т.е. строковая переменная
        LD      (VALTYP),A
        RRCA    
        ADD     A,C
        LD      C,A
        RST     NextChar
L0B4C:  LD      A,(NO_ARRAY)
        ADD     A,(HL)
        CP      '('			;28H
        JP      Z,GetArrayVar
        XOR     A
        LD      (NO_ARRAY),A
;Preserve program ptr on stack, and get VAR_ARRAY_BASE into DE and VAR_BASE into HL. This is where we iterate through the stored variables (ie from VAR_BASE to VAR_ARRAY_BASE) to see if the variable has already been declared. 
        PUSH    HL
        LD      HL,(VAR_ARRAY_BASE)
        EX      DE,HL
        LD      HL,(VAR_BASE)

;Loop to find the variable if it's already been allocated. If HL==DE then we've reached VAR_ARRAY_BASE without finding it, and so can jump ahead to allocate a new variable.
FindVarLoop:
		RST     CompareHLDE
		JP      Z,AllocNewVar
        LD      A,C
        SUB     (HL)
        INC     HL
        JP      NZ,L0B6D
        LD      A,B
        SUB     (HL)
L0B6D:  INC     HL
        JP      Z,L0B9B
        INC     HL
        INC     HL
        INC     HL
        INC     HL
        JP      FindVarLoop

AllocNewVar:
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
InitVarLoop:
	DEC     HL
        LD      (HL),00H
        RST     CompareHLDE
        JP      NZ,InitVarLoop
;Restore variable name to DE and write it to the first 2 bytes of the variable's storage.
        POP     DE
        LD      (HL),E
        INC     HL
        LD      (HL),D
        INC     HL
;Swap HL and DE so that DE points to the variable value, then restore the prog ptr to HL and return
L0B9B:  EX      DE,HL
        POP     HL
        RET


;Accesses or allocates an array variable. The contents of DIM_OR_EVAL indicate whether we're dealing with an array declaration (ie a DIM statement) or whether an array element is being accessed. In the former case DIM_OR_EVAL is 0xEF, otherwise it is 0. 
GetArrayVar:
	PUSH    HL
        LD      HL,(DIM_OR_EVAL)
        EX      (SP),HL
        LD      D,00H
L0BA5:  PUSH    DE
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
        CP      2CH
        JP      Z,L0BA5
        RST     SyntaxCheck
        DB	')'
        LD      (PROG_PTR_TEMP2),HL
        POP     HL
        LD      (DIM_OR_EVAL),HL
        PUSH    DE
        LD      HL,(VAR_ARRAY_BASE)
        DB	3EH			;LD      A,..
L0BC6:	ADD	HL, DE
        EX      DE,HL
        LD      HL,(VAR_TOP)
        EX      DE,HL
        RST     CompareHLDE
        JP      Z,L0BF3
        LD      A,(HL)
        CP      C
        INC     HL
        JP      NZ,L0BD8
        LD      A,(HL)
        CP      B
L0BD8:  INC     HL
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        INC     HL
        JP      NZ,L0BC6
        LD      A,(DIM_OR_EVAL)
        OR      A
        LD      E,ERR_DD
        JP      NZ,Error
        POP     AF
        CP      (HL)
        JP      Z,L0C52
BadSubscriptError:
	LD      E,ERR_BS
        JP      Error

L0BF3:  LD      DE,0004H
        LD      (HL),C
        INC     HL
        LD      (HL),B
        INC     HL
        POP     AF
        LD      (VarSize),A
        CALL    CheckEnoughVarSpace2
VarSize:
        DB	0e9h			; Самомодифицирующийся код
        LD      (CUR_TOKEN_ADR),HL
        INC     HL
        INC     HL
        LD      B,C
        LD      (HL),B
        INC     HL
L0C0A:  LD      A,(DIM_OR_EVAL)
        OR      A
        LD      A,B
        LD      BC,000BH
        JP      Z,L0C17
        POP     BC
        INC     BC
L0C17:  LD      (HL),C
        INC     HL
        LD      (HL),B
        INC     HL
        PUSH    AF
        PUSH    HL
        CALL    L13AB
        EX      DE,HL
        POP     HL
        POP     BC
        DEC     B
        JP      NZ,L0C0A
        LD      B,D
        LD      C,E
        EX      DE,HL
        ADD     HL,DE
        JP      C,BadSubscriptError
        CALL    CheckEnoughMem
        LD      (VAR_TOP),HL
L0C34:  DEC     HL
        LD      (HL),00H
        RST     CompareHLDE
        JP      NZ,L0C34
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
        JP      NZ,L0C74
L0C52:  INC     HL
        LD      BC,0000H
	DB	16H		; LD D,...
L0C57:	POP	HL
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        INC     HL
        EX      (SP),HL
        PUSH    AF
        RST     CompareHLDE
        JP      NC,BadSubscriptError
        PUSH    HL
        CALL    L13AB
        POP     DE
        ADD     HL,DE
        POP     AF
        DEC     A
        LD      B,H
        LD      C,L
        JP      NZ,L0C57
        ADD     HL,HL
        ADD     HL,HL
        POP     BC
        ADD     HL,BC
        EX      DE,HL
L0C74:  LD      HL,(PROG_PTR_TEMP2)
        DEC     HL
        RST     NextChar
        RET     

	IF	BASICNEW
Pi:
	LD	HL, PiConst
	CALL	FLoadFromMem
	RET
	
PiConst:
	DB	0DAh, 0Fh, 49h, 82h

Erl:
	LD	HL, (ErrorLine)
WordFromHLToFACCUM:
	LD	A, H
	LD	B, L
	JP	WordFromABToFACCUM

Err:
	LD	A, (ErrorCode)
	JP	ByteFromAToFACCUM

	ENDIF

	CHK	0C7Ah, "Сдвижка кода"

	INCLUDE	"fnFre.inc"

	CHK	0CA8h, "Сдвижка кода"

	INCLUDE	"fnPos.inc"
	
	CHK	0CB0h, "Сдвижка кода"
Def:
        CALL    L0D10
        LD      BC,FindNextStatement
        PUSH    BC
        PUSH    DE
        CALL    L0D02
        RST     SyntaxCheck
	DB	'('
	CALL	GetVar
        CALL    IsNumeric
        RST     SyntaxCheck
        DB	')'
        RST     SyntaxCheck
        DB	TK_EQ
        LD      B,H
        LD      C,L
        EX      (SP),HL
        JP      L0CF9
	
L0CCD:  CALL    L0D10
        PUSH    DE
        CALL    L0A16
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
        LD      E,ERR_UF
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
L0CF9:  LD      (HL),C
        INC     HL
        LD      (HL),B
L0CFC:  INC     HL
        LD      (HL),E
        INC     HL
        LD      (HL),D
        POP     HL
        RET     

L0D02:  PUSH    HL
        LD      HL,(CURRENT_LINE)
        INC     HL
        LD      A,H
        OR      L
        POP     HL
        RET     NZ

        LD      E,ERR_ID
        JP      Error

L0D10:  RST     SyntaxCheck
        DB	TK_FN
        LD      A,80H
        LD      (NO_ARRAY),A
        OR      (HL)
        LD      B,A
        CALL    L0B1F
        JP      IsNumeric
	
	CHK	0d1fh, "Сдвижка кода"
Str:
        CALL    IsNumeric
        CALL    FOut
        CALL    L0D4F
        CALL    EvalCurrentString
        LD      BC,ToPool
        PUSH    BC
L0D2F:  LD      A,(HL)
        INC     HL
        INC     HL
        PUSH    HL
        CALL    L0DAA
        POP     HL
        RST     PushNextWord
        POP     BC
        CALL    L0D46
        PUSH    HL
        LD      L,A
        CALL    L0EB4
        POP     DE
        RET     

MakeTempString:
	CALL    L0DAA
L0D46:  LD      HL,TMPSTR
        PUSH    HL
        LD      (HL),A
        INC     HL
        JP      L0CFC

L0D4F:  DEC     HL
GetStringConstant:
	LD      B,'"'
        LD      D,B
L0D53:  PUSH    HL
        LD      C,0FFH
L0D56:  INC     HL
        LD      A,(HL)
        INC     C
        OR      A
        JP      Z,L0D65
        CP      D
        JP      Z,L0D65
        CP      B
        JP      NZ,L0D56
L0D65:  CP      '"'			;22H
        CALL    Z,NextChar2
        EX      (SP),HL
        INC     HL
        EX      DE,HL
        LD      A,C
        CALL    L0D46
        RST     CompareHLDE
        CALL    NC,L0D2F
TempStringToPool:
	LD      DE,TMPSTR
        LD      HL,(TEMPPT)		;021DH
        LD      (FACCUM),HL
        LD      A,01H
        LD      (VALTYP),A
        CALL    L131C
        RST     CompareHLDE
        LD      E,ERR_ST
        JP      Z,Error
        LD      (TEMPPT),HL		; 021DH
        POP     HL
        LD      A,(HL)
        RET     

PrintString1:
        INC     HL
PrintString:
		CALL    L0D4F
L0D96:  CALL    EvalCurrentString
        CALL    FLoadBCDEfromMem
        INC     E
PrintStringLoop:
		DEC     E
        RET     Z

        LD      A,(BC)
        RST     OutChar
        CP      0DH
	IF	BASICNEW
	ELSE
        CALL    Z,PrintNull
	ENDIF
        INC     BC
        JP      PrintStringLoop
		
L0DAA:  OR      A
	DB	0EH			; LD C,...
L0DAC:	POP	AF
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
        JP      C,L0DC6
        LD      (STR_TOP),HL
        INC     HL
        EX      DE,HL
POPAFRET:
	POP     AF
        RET     

L0DC6:  POP     AF
        LD      E,ERR_SO
        JP      Z,Error
        CP      A
        PUSH    AF
        LD      BC,L0DAC
        PUSH    BC
; Сборка мусора
GarbageCollection:
	LD      HL,(MEMSIZ)
L0DD5:  LD      (STR_TOP),HL
        LD      HL,0000H
        PUSH    HL
        LD      HL,(STACK_TOP)
        PUSH    HL
        LD      HL,TMPST		;021FH
L0DE3:	EX      DE,HL
        LD      HL,(TEMPPT)		;021DH
        EX      DE,HL
        RST     CompareHLDE
        LD      BC,L0DE3
        JP      NZ,L0E2F
        LD      HL,(VAR_BASE)
L0DF2:  EX      DE,HL
        LD      HL,(VAR_ARRAY_BASE)
        EX      DE,HL
        RST     CompareHLDE
        JP      Z,L0E06
        LD      A,(HL)
        INC     HL
        INC     HL
        OR      A
        CALL    L0E32
        JP      L0DF2

L0E05:  POP     BC
L0E06:  EX      DE,HL
        LD      HL,(VAR_TOP)
        EX      DE,HL
        RST     CompareHLDE
        JP      Z,L0E52
        CALL    FLoadBCDEfromMem
        LD      A,E
        PUSH    HL
        ADD     HL,BC
        OR      A
        JP      P,L0E05
        LD      (CUR_TOKEN_ADR),HL
        POP     HL
        LD      C,(HL)
        LD      B,00H
        ADD     HL,BC
        ADD     HL,BC
        INC     HL
L0E23:	EX      DE,HL
        LD      HL,(CUR_TOKEN_ADR)
        EX      DE,HL
        RST     CompareHLDE
        JP      Z,L0E06
        LD      BC,L0E23
L0E2F:  PUSH    BC
        OR      80H
L0E32:  RST     PushNextWord
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

L0E52:  POP     DE
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
        JP      L0DD5
	
L0E77:  PUSH    BC
        PUSH    HL
        LD      HL,(FACCUM)
        EX      (SP),HL
        CALL    EvalTerm
        EX      (SP),HL
        CALL    IsString
        LD      A,(HL)
        PUSH    HL
        LD      HL,(FACCUM)
        PUSH    HL
        ADD     A,(HL)
        LD      E,ERR_LS
        JP      C,Error
        CALL    MakeTempString
        POP     DE
        CALL    L0EC5
        EX      (SP),HL
        CALL    L0EC4
        PUSH    HL
        LD      HL,(TMPSTR+2)
        EX      DE,HL
        CALL    L0EAE
        CALL    L0EAE
        LD      HL,L0986
        EX      (SP),HL
        PUSH    HL
        JP      TempStringToPool

L0EAE:  POP     HL
        EX      (SP),HL
        RST     PushNextWord
        RST     PushNextWord
        POP     BC
        POP     HL
L0EB4:  INC     L
L0EB5:  DEC     L
        RET     Z

        LD      A,(BC)
        LD      (DE),A
        INC     BC
        INC     DE
        JP      L0EB5

EvalString:
	CALL    IsString
EvalCurrentString:
	LD      HL,(FACCUM)
L0EC4:  EX      DE,HL
L0EC5:  LD      HL,(TEMPPT)		;021DH
        DEC     HL
        LD      B,(HL)
        DEC     HL
        LD      C,(HL)
        DEC     HL
        DEC     HL
        RST     CompareHLDE
        EX      DE,HL
        RET     NZ

        LD      (TEMPPT),HL		; 021DH
        PUSH    DE
        LD      D,B
        LD      E,C
        DEC     DE
        LD      C,(HL)
        LD      HL,(STR_TOP)
        RST     CompareHLDE
        JP      NZ,POPHLRET2
        LD      B,A
        ADD     HL,BC
        LD      (STR_TOP),HL
POPHLRET2:
	POP     HL
        RET

	CHK	0EE7h, "Сдвижка кода"

	INCLUDE	"fnLen.inc"

	CHK	0ef6h, "Сдвижка кода"

	INCLUDE	"fnAsc.inc"

	CHK	0f04h, "Сдвижка кода"
Chr:
        LD      A,01H
        CALL    MakeTempString
        CALL    EvalIntegerExpression
        LD      HL,(TMPSTR+2)
        LD      (HL),E
ToPool:	POP     BC
        JP      TempStringToPool

	CHK	0f14h, "Сдвижка кода"
Left:
        CALL    L0F9F
        XOR     A
RightCont:
		EX      (SP),HL
        LD      C,A
MidCont:
		PUSH    HL
        LD      A,(HL)
        CP      B
        JP      C,L0F22
        LD      A,B
        DB		11H		;LD      DE,000EH
L0F22:	LD		C, 0
        PUSH    BC
        CALL    L0DAA
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
        CALL    L0D46
        LD      L,A
        CALL    L0EB4
        POP     DE
        CALL    L0EC5
        JP      TempStringToPool

	CHK	0f44h, "Сдвижка кода"
Right:
        CALL    L0F9F
        POP     DE
        PUSH    DE
        LD      A,(DE)
        SUB     B
        JP      RightCont

	CHK	0f4eh, "Сдвижка кода"
Mid:
	EX      DE,HL
        LD      A,(HL)
        CALL    L0FA2
        PUSH    BC
        LD      E,0FFH
        CP      ')'
        JP      Z,L0F60
        RST     SyntaxCheck
        DB	','
        CALL    EvalByteExpression
L0F60:  RST     SyntaxCheck
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

	CHK	0f75h, "Сдвижка кода"
Inp:
        CALL    EvalIntegerExpression
        LD      (InpD),A		;0F7CH
InpD:	EQU	$+1
        IN      A,(00H)			; Self-modified code
        JP      ByteFromAToFACCUM

	CHK	0F80h, "Сдвижка кода"
Out:
        CALL    L0FAC
OutD:	EQU	$+1
        OUT     (00H),A			; Self-modified code
        RET     

;----Похоже, код не используется
        CALL    L0FAC
        PUSH    AF
        LD      E,00H
        DEC     HL
        RST     NextChar
        JP      Z,L0F96
        RST     SyntaxCheck
        DB	','
        CALL    EvalByteExpression
L0F96:  POP     BC
InD:	EQU	$+1
L0F97:  IN      A,(00H)			; Self-modified code
        XOR     E
        AND     B
        JP      Z,L0F97
        RET     
;--------------------------------------------------

L0F9F:  EX      DE,HL
        RST     SyntaxCheck
        DB	')'
L0FA2:  POP     BC
        POP     DE
        PUSH    BC
        LD      B,E
        INC     B
        DEC     B
        JP      Z,FunctionCallError
        RET

L0FAC:  CALL    EvalByteExpression
        LD      (InD),A			; 0F98H
        LD      (OutD),A		; 0F84H
        RST     SyntaxCheck
        DB	','
        DB	06h			; LD B,..
L0FB8:	RST	NextChar
EvalByteExpression:
	CALL    EvalNumericExpression
EvalIntegerExpression:
	CALL    FTestPositiveIntegerExpression
        LD      A,D
        OR      A
        JP      NZ,FunctionCallError
        DEC     HL
        RST     NextChar
        LD      A,E
        RET

	CHK	0Fc8H, "Сдвижка кода"

	INCLUDE	"fnVal.inc"

; Подпрогрмамма ввода с READER. В нашем случае - с магнитофона
	CHK	0FE1H, "Сдвижка кода"
Reader:
	IF	BASICNEW
	JP	0F806h
	ELSE
	CALL    0F806h
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        RET
	ENDIF

; Подпрограмма вывода на PUNCHER. В нашем случае - на магнитофон
Puncher2:
	CALL    Puncher
Puncher:
	PUSH    AF
        POP     AF
        PUSH    BC
        LD      C,A
        PUSH    AF
        CALL    0F80CH
        POP     AF
        POP     BC
	IF	BASICNEW
	ELSE
        NOP
	ENDIF
        RET

	IF	BASICNEW
	; Ниже указанный код нигде не вызывается...
	ELSE
L0FFA:	PUSH    HL
        LD      A,0D3H
	ENDIF

L0FFD:  CALL    Puncher
        CALL    Puncher2
        LD      A,(HL)
        CALL    Puncher
        LD      HL,(PROGRAM_BASE)
        EX      DE,HL
        LD      HL,(VAR_BASE)
L100E:  LD      A,(DE)
        INC     DE
	CALL	Puncher
	RST	CompareHLDE
	JP	NZ, L100E
        CALL    Puncher2
        POP     HL

	IF	RK86
	JP	0F82DH

ContInit:
	IF	MIKROSHA
	LD	HL, MEM_TOP
	DB	12 DUP (0)
	ELSE
	LD	HL, (VAR_BASE)
	INC	H
	EX	DE, HL
	CALL	0F830H
	RST	CompareHLDE
	JP	C, L1041
	CALL	0F830H
	ENDIF
	LD	(MEMSIZ), HL		;021bh
	LD	(STR_TOP), HL
	LD	SP, HL
	LD	HL, 0FFCEH		; -50
	ADD	HL, SP
	LD	(STACK_TOP), HL		;0241h
	IF	MIKROSHA
	NOP
	NOP
	NOP
	ELSE
	CALL	L19B8
	ENDIF
	JP	Main

L1041:	LD	A, D
	CALL	0F815h
	LD	A, E
	CALL	0F815h
L1049:
	IF	MIKROSHA
	JP	0F89DH
	ELSE
	JP	0F86Ch
	ENDIF

	IF	BASICNEW
	ELSE
	NOP
	NOP
	ENDIF

	ELSE
        RST     NextChar
        RET     

	IF	BASICNEW
	ELSE
; Предположительно, это две строчки - мертвый код
        LD      (FACCUM),A
        CALL    New2
	ENDIF

L1023:  LD      B,03H
L1025:  CALL    Reader
        CP      0D3H
        JP      NZ,L1023
        DEC     B
        JP      NZ,L1025
        LD      HL,FACCUM
        CALL    Reader
        CP      (HL)
        JP      NZ,L1023
        LD      HL,(PROGRAM_BASE)
L103E:  LD      B,04H
L1040:  CALL    Reader
        LD      (HL),A
        CALL    CheckEnoughMem
        LD      A,(HL)
        OR      A
        INC     HL
        JP      NZ,L103E
        DEC     B
        JP      NZ,L1040
	ENDIF

L1051:
	IF	RK86
	CALL	0F82DH
	ENDIF
	LD      (VAR_BASE),HL
        LD      HL,szOK
        CALL    PrintString
        JP      UpdateLinkedList

	IF	BASICNEW
; В МИКРО-80/ЮТ-88 нет "теплого" старта
Monitor:
	IF	RK86
	RET	NZ
	JP	L1049
	ENDIF
Reset:
; Команда не поддерживает аргументов.
	RET     NZ
	JP	0F800H

Home:
; Команда не поддерживает аргументов.
	RET     NZ
	LD	C, 1FH
	JP	0F809H
	ELSE
; Какой-то мертвый код..., похоже на другую реализацию PEEK
        CALL    FTestPositiveIntegerExpression
        LD      A,(DE)
        JP      ByteFromAToFACCUM

; Тоже мертвый код, , похоже на другую реализацию POKE
        CALL    EvalPositiveNumericExpression

	ENDIF

	IF	BASICNEW
	ELSE
PokeCont:
	PUSH    DE
        RST     SyntaxCheck
        DB	','
        CALL    EvalByteExpression
        POP     DE
        LD      (DE),A
        RET     
	ENDIF

	INCLUDE	"MATH.INC"
	
	CHK	1724h, "Сдвижка кода"
	INCLUDE	"fnPeek.inc"
	
	CHK	172CH, "Сдвижка кода"
Poke:
        CALL    EvalNumericExpression
        RST     FTestSign
        CALL    FTestIntegerExpression
	IF	BASICNEW
	PUSH    DE
        RST     SyntaxCheck
        DB	','
        CALL    EvalByteExpression
        POP     DE
        LD      (DE),A
        RET     
	ELSE
        JP      PokeCont
	ENDIF
	
	CHK	1736h, "Сдвижка кода"
	INCLUDE	"fnUsr.inc"

CallHL:	JP      (HL)

; Начальная инициализация.
; =======================
; В отличие от Altair BASIC, в данной версии конфигурация памяти не настраивается
; динамически, а статично вбита в код.
;
; Выставляем маркер конца программы (по описанию должно быть 2 байта...)
Init:	XOR     A

        LD      (PROGRAM_BASE_INIT),A

        LD      HL, szHello

	IF	RK86

		CALL	0F818H
		JP		ContInit

	IF	BASICNEW
	ELSE
	include "szHello.inc"
	ENDIF

Cls:	PUSH	HL
		CALL	0F81EH
		LD		BC, 01D18H
		ADD		HL, BC
		LD		(POSX), HL		; 01957H
		POP		HL
		LD		C, 1FH
		CALL	0F809H
		JP		SetCurPos

Cur:	CALL	EvalByteExpression
	CP	40H
	JP	NC, FunctionCallError
	ADD	A, 20H
	LD	(POSX), A		; 01957H

	RST	SyntaxCheck
	DB	','
	CALL	EvalByteExpression

	CP	19H
	JP	NC, FunctionCallError
	LD	C,A
	LD	A, 38H
	SUB	C
	LD	(POSY), A		; 01958H

SetCurPos:
	LD	C, 01BH
	CALL	0F809H
	LD	C, 59H
	CALL	0F809H
	LD	A, (POSY)		; 01958H
	LD	C, A
	CALL	0F809H
	LD	A, (POSX)		; 01957H
	LD	C, A
	JP	0F809H

Plot:
	CALL	EvalByteExpression
	LD		(GPOSX), A		; 01954H
	RST		SyntaxCheck
	DB		','

	CALL	EvalByteExpression
	LD		(GPOSY), A		; 01955H
	RST		SyntaxCheck
	DB		','

	CALL	EvalByteExpression
	LD		(GFILL), A		; 01956H

L17C5:	LD	A, (GPOSX)		; 01954H
	CP	80H
	JP	NC, FunctionCallError
	LD	A, (GPOSY)		; 01955H
	CP	32H
	JP	NC, FunctionCallError
	LD	D, A
	LD	A, 31H
	SUB	D
	LD	(GPOSY), A		; 01955H
	PUSH	HL
	XOR	A
	LD	A, (GPOSX)		; 01954H
	RRA
	LD	E, A
	LD	A, C
	RRA
	LD	C, A
	LD	A, (GPOSY)		; 01955H
	RRA
	LD	D, A
	LD	A, C
	RLA
	RLA
	LD	C, A
	LD	HL, SCRADDR
	LD	DE, 004EH
	LD	A, (GPOSY)		; 01955H
	RRA
	OR	A
	JP	Z, L1802
L17FD:	ADD	HL, DE
	DEC	A
	JP	NZ, L17FD
L1802:	LD	A, (GPOSX)		; 01954H
	RRA
	LD	E, A
	ADD	HL, DE
	LD	A, C
	AND	03H
	CP	0
	LD	B, 01H
	JP	Z, L1822
	CP	1
	LD	B, 2
	JP	Z, L1822
	CP	2
	LD	B, 010H
	JP	Z, L1822
	LD	B, 4
L1822:	LD	A, (GFILL)		; 01956H
	RRA
	LD	A, B
	JP	C, L1839
	CPL
	LD	B, A
	LD	A, (HL)
	CP	018H
	JP	C, L1834
	LD	(HL), 0
L1834:	LD	A, B
	AND	(HL)
	JP	L1844

L1839:	LD	B, A
	LD	A, (HL)
	CP	018H
	JP	C, L1842
	LD	(HL), 0
L1842:	LD	A, B
	OR	(HL)
L1844:
	ELSE	

	; Приветственное сообщение. Неясно, почему не использована функция МОНИТОРа...
	IF	BASICNEW
	CALL	0F818H
	JP	Main
	ELSE
InitLoop:
	LD      A,(HL)
        OR      A			; CP 0
        JP      Z,Main
        LD      C,(HL)
        INC     HL
        CALL    0F809h
        JP      InitLoop
	ENDIF

	IF	BASICNEW
	ELSE
	include "szHello.inc"
	ENDIF

	CHK	176ah, "Сдвижка кода"
Cur:
	CALL    EvalByteExpression
        LD      (POSX),A		; 1957H
        RST     SyntaxCheck
        DB	','
        CALL    EvalByteExpression
	IF	UT88
	CP	1CH
	JP	NC, FunctionCallError
	LD	C,A
	LD	A, 3BH
	SUB	C
        LD      (POSY),A		; 1958H
	ELSE
        LD      (POSY),A		; 1958H
        CP      20H
        JP      NC,FunctionCallError
	ENDIF
        LD      A,(POSX)		; 1957H
        CP      40H
        JP      NC,FunctionCallError
	IF	UT88
SetCurPos:
	LD	C, 01BH
	CALL	0F809H
	LD	C, 59H
	CALL	0F809H
	LD	A, (POSY)		; 01958H
	LD	C, A
	CALL	0F809H
	LD	A, (POSX)		; 01957H
	ADD	A,20H
	LD	C, A
	JP	0F809H
	DB	16 DUP (0)
	ELSE
        PUSH    HL
	; Гасим курсор
        LD      HL,(0F75AH)		; Адрес курсора в МИКРО-80
        LD      DE,0F801H		; -7FFH
        ADD     HL,DE
        LD      (HL),00H
	; ????
        LD      HL,0EFC0H
L1792:  LD      DE,0FFC0H
        LD      A,(POSY)		; 1958H
        OR      A
L1799:  JP      Z,L17A1
        ADD     HL,DE
        DEC     A
        JP      L1799
L17A1:  LD      D,00H
        LD      A,(POSX)		; 1957H
        LD      E,A
        ADD     HL,DE
        LD      (0F75AH),HL		; Адрес курсора в МИКРО-80
        LD      DE,0F801H		; -7FFH
        ADD     HL,DE
        LD      (HL),80H
        POP     HL
        RET     
	ENDIF

	CHK	17B3H, "Сдвижка кода"
Cls:

; Здесь можно было бы просто вывести 01fH через МОНИТОР и было бы портабельно...
; Но МИКРО-80/ЮТ-80 не умеет получать и сохранять координаты курсора.

        PUSH    HL
        LD      HL,0E800H
        LD      DE,SCRBUF
ClsLoop:
	XOR     A
        LD      (HL),A
        INC     HL
        LD      (DE),A
        INC     DE
        LD      A,D
        CP      (PROGRAM_BASE_INIT & 0FF00H)>>8; Это адрес конца буфера экрана TODO Привязать не к началу программы, а к началу буфера и его размеру
        JP      NZ, ClsLoop
        POP     HL
        RET

	CHK	17C7H, "Сдвижка кода"
Plot:
        CALL    EvalByteExpression
        LD      (GPOSX),A		; 1954H
        RST     SyntaxCheck
        DB	','
        CALL    EvalByteExpression
        LD      (GPOSY),A		; 1955H
        RST     SyntaxCheck
        DB	','
        CALL    EvalByteExpression
        LD      (GFILL),A		; 1956H

L17DD:  LD      A,(GPOSX)		; 1954H
        CP      80H
        JP      NC,FunctionCallError
        LD      A,(GPOSY)		; 1955H
        CP      40H
        JP      NC,FunctionCallError
        LD      D,A
        LD      A,3FH
        SUB     D
        LD      (GPOSY),A		; 1955H
        PUSH    HL
        XOR     A
        LD      A,(GPOSX)		; 1954H
        RRA     
        LD      E,A
        LD      A,C
        RRA
        LD      C,A
        LD      A,(GPOSY)		; 1955H
        RRA     
        LD      D,A
        LD      A,C
        RLA     
        RLA     
        LD      C,A
        LD      A,D
        RRCA    
        RRCA    
        LD      D,A
        AND     0C0H
        OR      E
        LD      E,A
        LD      A,D
        AND     07H
        LD      D,A
        LD      HL,SCRBUF
        ADD     HL,DE
        LD      A,C
        AND     03H
        CP      00H
        LD      B,01H
        JP      Z,L1831
        CP      01H
        LD      B,02H
        JP      Z,L1831
        CP      02H
        LD      B,10H
        JP      Z,L1831
        LD      B,04H
L1831:  LD      A,(GFILL)		; 1956H
        RRA     
        LD      A,B
        JP      C,L183E
        CPL     
        AND     (HL)
        JP      L183F
	
L183E:  OR      (HL)
L183F:  LD      (HL),A
        LD      HL,0E800H
        ADD     HL,DE

	ENDIF

	LD	(HL), A
POPHLRET:
	POP     HL
        RET     

Line:
        CALL    EvalByteExpression
        LD      (GPOSX2),A		; 1952H
        RST     SyntaxCheck
        DB	','
        CALL    EvalByteExpression
        LD      (GPOSY2),A		; 1953H
        PUSH    HL
        LD      HL,0100H
        LD      (L194E),HL
        LD      HL,0001H
        LD      (L1950),HL
        LD      HL,(GPOSX)		; 1954H
	IF	RK86
	LD	A,31h
	ELSE
        LD      A,3FH
	ENDIF
        SUB     H
        LD      H,A
        LD      A,(GPOSX2)		; 1952H
        SUB     L
        LD      E,A
        OR      A
        JP      P,L187B
        CPL     
        ADD     A,01H
        LD      E,A
        LD      A,0FFH
        LD      (L1950),A
L187B:  LD      A,(GPOSY2)		; 1953H
        SUB     H
        LD      D,A
        OR      A
        JP      P,L188D
        CPL     
        ADD     A,01H
        LD      D,A
        LD      A,0FFH
        LD      (L194F),A
L188D:  LD      A,E
        CP      D
        JP      P,L18A8
        LD      B,E
        LD      E,D
        LD      D,B
        LD      A,(L1950)
        LD      (L194E),A
        LD      A,(L194F)
        LD      (L1951),A
        XOR     A
        LD      (L1950),A
        LD      (L194F),A
L18A8:  LD      A,E
        RRA     
        LD      C,A
        LD      B,01H
L18AD:  LD      A,E
        CP      B
        JP      M,POPHLRET
        LD      HL,(GPOSX)		; 1954H
	IF	RK86
        LD      A,31H
	ELSE
        LD      A,3FH
	ENDIF
        SUB     H
        LD      H,A
        LD      A,(L1950)
        ADD     A,L
        LD      (GPOSX),A		; 1954H
        LD      A,(L1951)
        ADD     A,H
        LD      (GPOSY),A		; 1955H
        LD      A,D
        ADD     A,C
        LD      C,A
        INC     B
        LD      A,E
        CP      C
        JP      P,L18E4
        LD      A,C
        SUB     E
        LD      C,A
        LD      HL,(GPOSX)		; 1954H
        LD      A,(L194E)
        ADD     A,L
        LD      (GPOSX),A		; 1954H
        LD      A,(L194F)
        ADD     A,H
        LD      (GPOSY),A		; 1955H
L18E4:  PUSH    BC
        PUSH    DE
	IF	RK86
        CALL    L17C5
	ELSE
        CALL    L17DD
	ENDIF
        POP     DE
        POP     BC
        JP      L18AD

	CHK	18EEh, "Сдвижка кода"
Msave:
        PUSH    HL
        LD      L,00H
        XOR     A
L18F2:  CALL    Puncher			; Вывод пилот-тона,256 нулей
        DEC     L
        JP      NZ,L18F2
        POP     HL
        PUSH    HL
        LD      A,0E6H			; Синхро-байт
        CALL    Puncher
        LD      A,0D3H			; Опознаватель BASIC-программы
        JP      L0FFD

	CHK	1905H, "Сдвижка кода"
Mload:
        LD      (FACCUM),A
        CALL    New2
        LD      B,03H
        LD      A,0FFH
        CALL    Reader
        CP      0D3H
        JP      Z,L1923
L1917:  LD      B,03H
L1919:  LD      A,08H
        CALL    Reader
        CP      0D3H
        JP      NZ,L1917
L1923:  DEC     B
        JP      NZ,L1919
        LD      HL,FACCUM
        LD      A,08H
        CALL    Reader
        CP      (HL)
        JP      NZ,L1917
        LD      HL,(PROGRAM_BASE)
L1936:  LD      B,03H
L1938:  LD      A,08H
        CALL    Reader
        LD      (HL),A
        CALL    CheckEnoughMem
        LD      A,(HL)
        OR      A
        INC     HL
        JP      NZ,L1936
        DEC     B
        JP      NZ,L1938
        JP      L1051

	if	BASICNEW
	ELSE
	include "tmpvars.inc"
	ENDIF
	IF	RK86

L1959:	CALL	InputChar
L195C:	CP	003H
	JP	NC, InputNext
	LD	DE, L1985
	JP	L196A

L1967:	LD	DE, L198F
L196A:	OR	A
L196B:	JP	Z, L197A
	LD	C, A
L196F:	LD	A, (DE)
	INC	DE
	OR	A
	JP	NZ, L196F
	LD	A, C
	DEC	A
	JP	L196B

L197A:	LD	A, (DE)			; Загрузка программ FN-keys
	LD	(HL), A
	INC	DE
	INC	HL
	OR	A
	JP	NZ, L197A
	JP	TerminateInput2

L1985:	DB	TK_MLOAD, 000H
	DB	TK_PRINT, TK_FRE, "(0)", 000H
	DB	TK_CONT, 000H
L198F:	DB	TK_MSAVE, 000H
	DB	TK_LIST, 000H
	DB	TK_RUN, 000H

L1995:
	IF	SERVICE
	DEC	B
	JP	Z, InputLine
	DEC	HL
	LD	A, 08H
	RST	OutChar
	JP	L19EE
	ELSE	; SERVICE
	LD	A, 08H
	RST	OutChar
	LD	A, ' '
	RST	OutChar
	LD	A, 08H
	JP	Backspace
	ENDIF	; SERVICE
L19A0:	LD	A, (ControlChar)
	CPL
	LD	(ControlChar), A
	RET

L19A8:	LD	A, (PRNDUP)
	OR	A
	LD	A, 0FFH
	JP	Z, L19B2
	XOR	A
L19B2:	LD	(PRNDUP), A
	LD	A, 07FH
	RET

L19B8:	LD	HL, 0A003H
	LD	(HL), 091H
	LD	(HL), 00FH
	RET

L19C0:	LD	A, 07FH
	AND	C
	LD	C, A
	CALL	0F809H
	LD	A, (PRNDUP)
	OR	A
	RET	Z
	LD	A, C
	OR	A
	JP	PO, L19D3
	OR	080H
L19D3:	LD	C, A
	PUSH	HL
	LD	HL, 0A003H
L19D8:	LD	A, (HL)
	RRA
	JP	NC, L19D8
	DEC	HL
	DEC	HL
	LD	(HL),C
	INC	HL
	INC	HL
	LD	(HL), 0EH
	DEC	HL
L19E5:	LD	A,(HL)
	RLA
	JP	NC, L19E5
	LD	(HL), 0FH
	POP	HL
	RET
	ELSE	; RK86
	IF	UT88
L1959:	PUSH	AF
	AND	07FH
	LD	C, A
	CALL	0F809H
	POP	AF
	RET
	DB	31 DUP (0)
	ELSE
	DB	40 DUP (0)
	ENDIF
	DB	0CH
	IF	SERVICE
	DB	19 DUP (0)
L1995:	DEC	B
	JP	Z, InputLine
	DEC	HL
	LD	A, 08H
	RST	OutChar
	JP	L19EE
	DB	32 DUP (0)
	ELSE	; SERVICE
	DB	62 DUP (0)
	ENDIF	; SERVICE
	CHK	19c0h, "Сдвижка кода"
	DB 72h, 61h, 7Ah, 72h, 61h, 62h, 6Fh, 74h,  41h, 4Eh, 4Fh, 20h, 44h, 4Ch, 71h, 20h	; "РАЗРАБОТANO DLЯ "
	DB 76h, 75h, 72h, 6Eh, 61h, 6Ch, 61h, 20h,  72h, 61h, 64h, 69h, 6Fh, 20h, 60h, 6Fh	; "ЖУРНАЛА РАДИО МО"
	DB 73h, 6Bh, 77h, 61h, 20h, 31h, 39h, 38h,  34h, 20h, 67h, 6Fh, 64h, 22h		; "СКВА 1984 ГОД""
	ENDIF
	IF	SERVICE
L19EE:	LD	A, (L04BD)
	CP	01H
	JP	Z, L0488
	LD	A, " "
	INC	HL
	INC	B
	RST	OutChar
	LD	A, 08H
	JP	Backspace
	ELSE
	DB	18 DUP (0)
	ENDIF

	IF	SERVICE

last_tk_addr	SET	0ffffh

MAP	MACRO   key, token
	IF	last_tk_addr <> ((token_ADDR & 0FF00H) >> 8)
	LD	DE, token_ADDR
	ELSE
	LD	E, token_ADDR & 0FFH
	ENDIF
last_tk_addr	SET	(token_ADDR & 0FF00H) >> 8
	CP	key
	RET	Z
	ENDM

L1A00:	MAP	"2", TK_CLS
	MAP	"F", TK_FOR
	MAP	"N", TK_NEXT
	MAP	"D", TK_DATA
	MAP	"I", TK_INPUT
	MAP	"1", TK_DIM
	MAP	"Q", TK_READ
	MAP	"C", TK_CUR
	MAP	"J", TK_GOTO
	MAP	"G", TK_GOSUB
	MAP	"R", TK_RETURN
	MAP	";", TK_REM
	MAP	"3", TK_STOP
	MAP	"P", TK_PLOT
	MAP	"L", TK_LINE
	MAP	"Y", TK_POKE
	MAP	" ", TK_PRINT
	MAP	"4", TK_DEF
	MAP	"K", TK_CLEAR
	MAP	"@", TK_MLOAD
	MAP	"O", TK_MSAVE
	MAP	"B", TK_TAB
	MAP	"Z", TK_SPC
	MAP	"T", TK_THEN
	MAP	"S", TK_STEP
	MAP	"6", TK_AND
	MAP	"5", TK_INT
	MAP	"7", TK_ABS
	MAP	"U", TK_USR
	MAP	"8", TK_SQR
	MAP	"W", TK_RND
	MAP	"9", TK_EXP
	MAP	"X", TK_PEEK
	MAP	"V", TK_VAL
	MAP	"H", TK_CHRS
	MAP	"[", TK_LEFTS
	MAP	"]", TK_RIGHTS
	MAP	"M", TK_MIDS
	POP	DE
	JP	L0488

L1AC4:	LD	A, C
	CP	03H
	IF	RK86
	JP	C, L1967
	ELSE
	JP	C, InputNext
	ENDIF
	CALL	0F803H
	CP	"E"
	JP	Z, L1B72
	CP	"A"
	JP	Z, L1B2C
	CP	" "
	IF	RK86
	JP	C, L195C
	ELSE
	JP	C, InputNext
	ENDIF
L1ADC:	CALL	L1A00
	CALL	L1AE8
	JP	NC, L1CD8
	JP	InputNext
L1AE8:	LD	A, B
	CP	72
	RET	NC
	LD	A, (DE)
	LD	C, A
	AND	07FH
	LD	(HL),A
	INC	HL
	INC	B
	RST	OutChar
	INC	DE
	CP	C
	JP	Z, L1AE8
	RET

L1AFA:	LD	HL, (L0227)
	EX	DE, HL
	LD	HL, 000AH
	ADD	HL, DE
	LD	(L0227), HL
	RET

L1B06:	LD	HL, (L0227)
L1B09:	CALL	PrintInt
	LD	HL, LINE_BUFFER
	LD	B, 1
	LD	DE, FBUFFER+1
L1B14:	LD	A, (DE)
	CP	0
	JP	Z, L1B25
	LD	(HL), A
	INC	HL
	LD	A, B
	CALL	L1B51
	INC	B
	INC	DE
	JP	L1B14

L1B25:	LD	A, 20H
	LD	(HL), A
	INC	HL
	INC	B
	RST	OutChar
	RET

L1B2C:	POP	HL
	LD	HL, L1B58
	LD	(L030E), HL
	IF	BASICNEW
	LD	HL, L1B3E
	ELSE
	LD	L, L1B3E & 0FFH
	ENDIF
	LD	(L0495), HL
	LD	HL, szAuto
	CALL	0F818H
L1B3E:	CALL	NewLine
	JP	L1B5C

L1B44:	IF	BASICNEW
	LD	HL, L047D
	ELSE
	LD	L, L047D & 0FFH
	ENDIF
	LD	(L0495), HL
	LD	HL, (MEMSIZ)
	LD	SP, HL
	JP	Main

L1B50:	INC	A
L1B51:	LD	(TERMINAL_X),A
	LD	(L0229),HL
	RET

L1B58:	POP	HL
	CALL	L1AFA
L1B5C:	CALL	L1B06
	CALL	InputNext
	RST	NextChar
	PUSH	AF
	CALL	LineNumberFromStr
	EX	DE, HL
	LD	(L0227), HL
	EX	DE, HL
	JP	Z, L1B58
	JP	0031AH
L1B72:	LD	HL, szEdit
	CALL	0F818H
	LD	HL, L1B93
	LD	(L030E), HL
	LD	A, 1
	LD	(L04BD), A
	CALL	InputLine
	CALL	L1C55
	LD	A, 0C9H			; RET
	LD	(TerminateInput), A
	LD	A, 0B8H			; CP B
	LD	(L04C9), A
L1B93:	LD	HL, (L0039)
	EX	DE, HL
	CALL	FindProgramLine
	PUSH	BC
L1B9B:	POP	HL
	RST	PushNextWord
	POP	BC
	LD	A, B
	OR	C
	JP	Z, L1BE4
	PUSH	BC
	CALL	NewLine
	RST	PushNextWord
	EX	(SP), HL
	CALL	L1B09
L1BAC:	POP	HL
	LD	A, B
	CP	48H
	LD	A, (HL)
	INC	HL
	JP	NC, L1C3A
	OR	A
	JP	Z, L1C3A
	JP	P, L1BD9
	SUB	07FH
	LD	C, A
	PUSH	HL
	LD	DE, KEYWORDS
L1BC3:	PUSH	DE
L1BC4:	LD	A, (DE)
	INC	DE
	OR	A
	JP	P, L1BC4
	DEC	C
	POP	HL
	JP	NZ, L1BC3
	EX	DE, HL
	LD	HL, (L0229)
	CALL	L1AE8
	JP	L1BAC

L1BD9:	PUSH	HL
	LD	HL, (L0229)
	LD	(HL), A
	INC	HL
	INC	B
	RST	OutChar
	JP	L1BAC

L1BE4:	LD	A, 036H				; LD (HL),...
	LD	(TerminateInput), A
	INC	A				; SCF
	LD	(L04C9), A
	LD	A, 20H
	LD	(L04BD), A
	LD	HL, InputLine
	LD	(L030E), HL
	JP	L1B44

L1BFB:	CP	018H
	JP	Z, L1CE0
	LD	A, (L030E)
	CP	80H
	JP	Z, L1AC4
	JP	NC, L1C11
	CALL	0F803H
	JP	L1ADC

L1C11:	LD	A, C
	OR	02H
	CP	03H
	JP	Z, L1C60
L1C19:	CALL	0F803H
	CP	01H
	JP	Z, InputNext
	CP	03H
	JP	Z, L1CC7
	CP	0dH
	JP	Z, L1C4F
	IF	RK86
	CP	00AH
	ELSE
	CP	01AH
	ENDIF
	JP	Z, L1C33
	JP	L1ADC

L1C33:	CALL	L1C55
	EX	DE, HL
	JP	L1C4F

L1C3A:	CALL	L1C55
	CALL	0F803H
	CP	0DH
	JP	Z, L1B9B
	POP	HL
	LD	HL, (L0229)
	CALL	L0488
	LD	HL, (L0229)
L1C4F:	LD	(HL), 0
	LD	HL, LINE_BUFFER-1
	RET

L1C55:	LD	HL, LINE_BUFFER
	CALL	LineNumberFromStr
	EX	DE, HL
	LD	(L0039), HL
	RET

L1C60:	LD	A, (TERMINAL_X)
	CP	B
	JP	C, L1CD8
	LD	E, A
	LD	A, C
	CP	001H
	JP	Z, L1C74
	LD	A, E
	CP	047H
	JP	NC, L1CD8
L1C74:	LD	D, B
	LD	B, E
	LD	HL, (L0229)
	DEC	HL
L1C7A:	LD	A, (HL)
	PUSH	AF
	LD	A, D
	CP	B
	JP	Z, L1C86
	DEC	HL
	DEC	B
	JP	L1C7A

L1C86:	LD	A, C
	CP	01H
	JP	Z, L1CA1
	CP	03H
	JP	NZ, L1C96
	LD	A, 20H
	JP	L1C99

L1C96:	LD	C, 0FFH
	INC	D
L1C99:	LD	(HL), A
	INC	HL
	INC	B
	RST	OutChar
	INC	E
	JP	L1CA3

L1CA1:	POP	AF
	DEC	E
L1CA3:	LD	A, E
	CP	B
	JP	C, L1CB0
	POP	AF
	LD	(HL), A
	INC	HL
	INC	B
	RST	OutChar
	JP	L1CA3

L1CB0:	DEC	A
	CALL	L1B51
	XOR	A
	LD	(HL), A
	INC	HL
	INC	B
	RST	OutChar
L1CB9:	DEC	B
	DEC	HL
	LD	A, 08H
	RST	OutChar
	LD	A, D
	CP	B
	JP	NZ, L1CB9
	ADD	A, C
	JP	NC, InputNext
L1CC7:	CALL	0F803H
	LD	C, A
	CP	20H
	JP	NC, L1C60
	CP	01BH
	JP	Z, L1C19
	JP	L0488

L1CD8:	DEC	B
	LD	A, 07H
	RST	OutChar
	INC	B
	JP	InputNext

L1CE0:	LD	A, (TERMINAL_X)
	CP	B
	LD	A, C
	JP	NC, L04B1
	LD	A, 20H
	LD	C, A
	JP	L04B0

szEdit:	DB	00DH, 00AH, "EDIT*", 00DH, 00AH, 000H
szAuto:	DB	00DH, 00AH, "AUTO*", 000H
	ENDIF
	; Блок данных
	IF	BASICNEW
	include "data.inc"
	ENDIF
