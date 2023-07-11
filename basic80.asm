; ═════════════════════════════════════════════════════════════════════════════════
;  БЕЙСИК для МИКРО-80/БЕЙСИК для РАДИО-86РК/БЕЙСИК для ЮТ-88
;  БЕЙСИК-СЕРВИС для МИКРО-80/БЕЙСИК-СЕРВИС для РАДИО-86РК/БЕЙСИК-СЕРВИС для ЮТ-88
; ═════════════════════════════════════════════════════════════════════════════════
;
; Это дизассемблер Бейсика для "МИКРО-80" и Бейсика для "Радио-86РК".
; Гипотетически Бейсик для МИКРО-80=Бейсик для ЮТ-88, но это пока не проверялось.
; Имена меток взяты с дизассемблера Altair BASIC 3.2 (4K)
; По ходу разбора встречаются мысли и хотелки.
;
; Общие хотелки:
; !?Добавить обратно поддержку LET
; !?Добавить обратно поддержку END
; !!Добавить поддержку каналов и потоков, как в Sinclair Basic, не забывая совместимость с ECMA стандартом
; !!Отвязаться от RST и пересобрать с адреса 100h. Вначале добавить CP/M адаптер. При наличии поддержки дисковых фунок - адаптер не цепляем. 
; !!Добавить OPTION BASE для управления индеском массива (Совместимость ANSI)
; !!Автонастройка памяти (сейчас жестко задано в коде)
; !!GO TO=GOTO, GO SUB=GOSUB (учесть в токенизаторе)
; ??ГОСТ расширение основных средств уровень 1 и 2 не могут быть реализованы из-за усеченного знакогенератора. Нет строчных букв.
; !!Развернутые сообщения об ошибках
; !!Отвязать по максимуму от работы в ОЗУ (версия для ROM-диска? Мысль интересная, т.к можно высвободить гору ОЗУ. 
;   Больше актуально не для М-80/ЮТ-88, а для РК-86. При этом для самого интерпретатора можно заполучить 32Кб
;   для стандартного ROM-диска).
; !?Добавить обратно NULL
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
; +-------------------------------+ E800H (МИКРО-80/ЮТ-88)
; !         ОЗУ  курсора          !
; +-------------------------------+ E000H (МИКРО-80/ЮТ-88)
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
; символ должен быть букврй (латинской), а второй (опциональный) символ - число.
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
; In both FOR and GOSUB cases, the stack is used to store specific information about the program line to return to.
;
	CPU	8080
	Z80SYNTAX	EXCLUSIVE

; Конфигурация

	IFNDEF	RAM
RAM	EQU	16
	ENDIF

; Верхний адрес доступной памяти. В МИКРО-80 задано жестко, 
; а в РК-86 настраивается при инициализации
	IF	RAM=12
MEM_TOP	EQU	02FFFH
	ELSEIF	RAM=16
MEM_TOP	EQU	03FFFH
	ELSEIF	RAM=32
MEM_TOP	EQU	07FFFH
	ELSEIF	RAM=48
MEM_TOP	EQU	0BFFFH
	ENDIF

	ifndef RK86
RK86	EQU	0	; Модификации для "Бейсик для Радио-86РК"
	endif
	ifndef UT88
UT88	EQU	0	; Модификации для "Бейсик для ЮТ-88"
	endif
	ifndef SERVICE
SERVICE	EQU	0	; Модификации для Бейсик-Сервис
	endif
	ifndef BASICNEW
BASICNEW	EQU	0	; Включить мои изменения в коде
	endif
ANSI	EQU	0	; Включить поддержку совместимости с ANSI Minimal Basic
GOST	EQU	0	; Включить поддержку совместимости с ГОСТ 27787-88

	IF	BASICNEW
	IF	ANSI
OPTION	EQU	1	; Поддержка команды OPTION
LET	EQU	1	; Поддержка команды LET
RANDOMIZE EQU	1	; Поддержка команды RANDOMIZE
END	EQU	1	; Поддержка команды END
	ELSE
	IF	GOST
OPTION	EQU	1	; Поддержка команды OPTION
LET	EQU	1	; Поддержка команды LET
RANDOMIZE EQU	1	; Поддержка команды RANDOMIZE
END	EQU	1	; Поддержка команды END
	ELSE	; BASICNEW
OPTION	EQU	0	; Поддержка команды OPTION
LET	EQU	1	; Поддержка команды LET
RANDOMIZE EQU	0	; Поддержка команды RANDOMIZE
END	EQU	1	; Поддержка команды END
	ENDIF
	ENDIF
	ELSE	; NOT BASICNEW
OPTION	EQU	0	; Поддержка команды OPTION
LET	EQU	0	; Поддержка команды LET
RANDOMIZE EQU	0	; Поддержка команды RANDOMIZE
END	EQU	0	; Поддержка команды END
	ENDIF

	IF	BASICNEW
CHK	MACRO	adr, msg
	ENDM
	ELSE
CHK	MACRO	adr, msg
		IF	adr-$
			ERROR	msg
		ENDIF
	ENDM
	ENDIF

	IF	RK86
	IF SERVICE
PROGRAM_BASE_INIT	EQU	1D00H
	ELSE
PROGRAM_BASE_INIT	EQU	1B00H
	ENDIF


	IF RAM=16
SCRADDR	EQU	037c2H
	ELSE		; 32kb
SCRADDR	EQU	077c2H
	ENDIF

	ELSE

	IF SERVICE
SCRBUF			EQU	1D00H
PROGRAM_BASE_INIT	EQU	2500H
	ELSE
SCRBUF			EQU	1A00H
PROGRAM_BASE_INIT	EQU	2200H
	ENDIF

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

; Начало (RST 0)

; Запуск интерпретатора осуществляется с адреса 0. Проводится инициализация стека и
; переход на код инициализации.

	IF	BASICNEW
	ORG	0
;	ORG	100H
;RST	MACRO	adr
;	CALL	adr
;	ENDM
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
	INC	HL
	EX	(SP),HL

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

;NextChar (RST 2)
;
; Возвращает следующий введенный символ из буфера по адресу HL, пропуская символы пробелов.
; The Carry flag is set if the returned character is not alphanumeric,
; also the zero flag is set if a null character has been reached.

NextChar:
	INC	HL
	LD	A,(HL)
	CP	':'			; 3AH
	RET	NC			; End of statement or bigger
	JP	NextChar_tail

;OutChar (RST 3)
;Prints a character to the terminal.

OutChar:
	PUSH	AF
	LD	A,(ControlChar)
	OR	A
	JP	OutChar_tail

; CompareHLDE (RST 4)
; Сравниает HL и DE с таким же логическим результатом (флаги C и Z), что и стандартное 8-мибитное сравнение.

CompareHLDE:
	LD	A,H
	SUB	D
	RET	NZ
	LD	A,L
	SUB	E
	RET

;

NULLS:	DB	01	; Число нолей-1, которое надо вывести после перевода строки (это было нужно для терминалов)
TERMINAL_X:	DB		00	; Variable controlling the current X positions of terminal output

;
;FTestSign (RST 5)
;Tests the state of FACCUM. This part returns with A=0 and zero set if FACCUM==0, the tail of the function sets the sign flag and A accordingly (0xFF is negative, 0x01 if positive) before returning.

FTestSign:
	LD	A,(FACCUM+3)
	OR	A
	JP	NZ,FTestSign_tail
	RET  
;
;PushNextWord (RST 6)
;Effectively PUSH (HL). First we write the return address to the JMP instruction at the end of the function; then we read the word at (HL) into BC and push it onto the stack; lastly jumping to the return address.
;
PushNextWord:
	EX	(SP),HL
	LD	(RST6RET),HL
	POP	HL
	JP	RST6_CONT		; Отличие от Altair - место для обработчика RST 7
;
;
;
RST7:
	RET
	NOP
	NOP

RST6_CONT:
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	PUSH    BC
RST6RET:	EQU	$+1
	JP	04F9H		; Это самомодифицирующийся код, см. PushNextWord.

	; Блок данных
	include "data.inc"

;=========================
;= 1.4 Utility Functions =
;=========================

; Some useful functions.
; GetFlowPtr
; Sets HL to point to the appropriate flow struct on the stack. On entry, 
; if this was called by the NEXT keyword handler then DE is pointing to 
; the variable following the NEXT keyword.

	CHK 027ah, "Сдвижка кода"


; The first four bytes on the stack are (or rather, should be) two return addresses.
; We're not interested in them, so the first thing to do is set HL to point to SP+4.

GetFlowPtr:		
	LD      HL,0004H
        ADD     HL,SP

; Get the keyword ID, the byte that precedes the flow struct. Then we increment HL
; so it points to (what should be) the flow struct, and return if the keyword ID is not 'FOR'.

GetFlowLoop:
	LD      A,(HL)
	INC     HL
	CP      TK_FOR
	RET     NZ

; Special treatment for FOR flow structs. Here we check that we've got the right one,
; ie the one required by the NEXT statement which called us. When we're called by NEXT,
; it sets DE to point to the variable in the NEXT statement. So here we get the first
; word of the FOR flow struct which is the address of the FOR variable, and compare
; it to the one we've been given in DE. If they match, then we've found the flow 
;struct wanted and we can safely return. If not then we jump 13 bytes up the 
;stack - 13 bytes is the size of the FOR flow struct - and loop back to try again.

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
        JP      Z,NoVar			; NEXT без переменной (возвращаем первый попавшийся FOR)
        EX      DE,HL
        RST     CompareHLDE
NoVar:  LD      BC,000DH		; Размер структуры FOR
        POP     HL
        RET     Z

        ADD     HL,BC
        JP      GetFlowLoop

;
; CopyMemoryUp
;
; Copies a block of memory from BC to HL. Copying is done backwards, 
; down to and including the point where BC==DE. It goes backwards 
; because this function is used to move blocks of memory forward by
; as little as a couple of bytes. If it copied forwards then the
; block of memory would overwrite itself.

CopyMemoryUp:
	CALL    CheckEnoughMem
;Exchange BC with HL, so HL now points to the source and BC points to destination.
CopyMemoryUpNoCheck:
	PUSH    BC
        EX      (SP),HL
        POP     BC
CopyMemLoop:
	RST     CompareHLDE
        LD      A,(HL)
        LD      (BC),A
        RET     Z

        DEC     BC
        DEC     HL
        JP      CopyMemLoop

; CheckEnoughVarSpace2
; То же, что и ниже, но C берется из следующей ячейки, откуда вызвана подпрограмма.
; Более эффективно, чем в Altair Basic
CheckEnoughVarSpace2:
	EX      (SP),HL
        LD      C,(HL)
        INC     HL
        EX      (SP),HL

; CheckEnoughVarSpace
; Checks that there is enough room for C*4 bytes on top of (VAR_TOP) before it 
; intrudes on the stack. Probably varspace.

        PUSH    HL
        LD      HL,(VAR_TOP)
        LD      B,00H			;BC=C*4
        ADD     HL,BC
        ADD     HL,BC
        CALL    CheckEnoughMem
        POP     HL
        RET     

; CheckEnoughMem
; Checks that HL is more than 32 bytes away from the stack pointer. If HL is within 32 bytes
; of the stack pointer then this function falls into OutOfMemory.

CheckEnoughMem:
	PUSH    DE
        EX      DE,HL
        LD      HL,0FFDAH		; HL=-34 (extra 2 bytes for return address)
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
	DB		01				; LD BC,...
DivideByZero:
	LD      E, ERR_DZ
	DB		01				; LD BC,...
WithoutFOR:
	LD      E, ERR_NF

;Error
;Resets the stack, prints an error code (offset into error codes table is given in E), and stops program execution.
Error:
	CALL    ResetStack
        XOR     A
        LD      (ControlChar),A
        CALL    NewLine
        LD      HL,ERROR_CODES
        LD      D,A
        LD      A,'?'
        RST     OutChar
        ADD     HL,DE
        LD      A,(HL)
        RST     OutChar
        RST     NextChar
        RST     OutChar
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
	XOR	A
	LD	(ControlChar),A			; Включаем вывод на экран (не управляющий символ)
	LD	HL,0FFFFH			; Сбрасываем текущую выполняемую строку
	LD	(CURRENT_LINE),HL

	LD	HL,szOK				; Выводим приглашение
	CALL	PrintString

GetNonBlankLine:
	CALL	InputLine			; Считываем строку с клавиатуры
	RST	NextChar			; Считываем первый символ из буфера. Флаг переноса =1, если это цифра
	INC	A				; Проверяем на пустую строку. Инкремент/декремент не сбрасывает флаг переноса.
	DEC	A
	JP	Z, GetNonBlankLine		; Снова вводим строку, если пустая

	PUSH	AF				; Сохраняем флаг переноса
	CALL	LineNumberFromStr		; Получаем номер строки в DE
	PUSH	DE				; Запоминаем номер строки
	CALL	Tokenize			; Запускаем токенизатор. В C возвращается длина токенизированной строки, а в А = 0
	LD	B,A				; Теперь BC=длина строки
	POP	DE				; Восстанавливаем номер строки
	POP	AF				; Восстанавлливаем флаг переноса
	JP	NC, Exec			; Если у нас строка без номера, то сразу исполняем

; StoreProgramLine
; Here's where a program line has been typed, which we now need to store in program memory.

StoreProgramLine:
        PUSH    DE
        PUSH    BC
        RST     NextChar
        PUSH    AF
        CALL    FindProgramLine
        PUSH    BC
        JP      NC,InsertProgramLine

;Carry was set by the call to FindProgramLine, meaning that the line already exists.
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

;FindProgramLine
;Given a line number in DE, this function returns the address of that progam line in BC.
; If the line doesn't exist, then BC points to the next line's address, ie where the 
;line could be inserted. Carry flag is set if the line exists, otherwise carry reset.
		
FindProgramLine:
	LD      HL,(PROGRAM_BASE)
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
		
; New
; Команда NEW. Записывает нулевой номер строки в конец области программ (т.е. пустая программа),
; обновляет указатель на область переменных и переходит в ResetAll.

	CHK	039Dh, "Сдвижка кода"
New:
; Команд не поддерживает аргументов.
	RET     NZ

New2:
; Записывает два нулевых байта как признак окончание программы в начало области программы.
	LD      HL,(PROGRAM_BASE)
        XOR     A
        LD      (HL),A
        INC     HL
        LD      (HL),A
        INC     HL
; И устанавливаем область переменных сразу за концом программы.
        LD      (VAR_BASE),HL

; ResetAll
; Очищает все.
		
ResetAll:
; Set PROG_PTR_TEMP to just before the start of the program.
	LD      HL,(PROGRAM_BASE)
        DEC     HL
ClearAll:
	LD      (PROG_PTR_TEMP),HL
        LD      HL,(MEMSIZ)
        LD      (STR_TOP),HL
;Reset the data pointer
        CALL    Restore
;Reset variable pointers
        LD      HL,(VAR_BASE)
        LD      (VAR_ARRAY_BASE),HL
        LD      (VAR_TOP),HL
;Get return address in BC and reset the stack pointer to it's top. 
ResetStack:
	POP     BC
        LD      HL,(STACK_TOP)
        LD      SP,HL

        LD      HL,TMPST	;021FH
        LD      (TEMPPT),HL	;021DH

        LD      HL,0000H
        PUSH    HL

        LD      (OLD_TEXT),HL

        LD      HL,(PROG_PTR_TEMP)
        XOR     A
        LD      (NO_ARRAY),A
        PUSH    BC
        RET     

;InputLineWith'?'
;Gets a line of input at a '? ' prompt.

InputLineWithQ:
	LD      A, '?'
        RST     OutChar
        LD      A, ' '
        RST     OutChar
        JP      InputLine
		
;Tokenize
;Tokenises LINE_BUFFER, replacing keywords with their IDs. On exit, C holds the length of the tokenised line plus a few bytes to make it a 
;complete program line.

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
        LD      A,(HL)			; Восстанавливаем введенноый символа
        JP      NZ,WriteChar

; Обработка ?
        CP      '?'
        LD      A, TK_PRINT		; Замена ? на PRINT
        JP      Z, WriteChar

	IF	BASICNEW
; Обработка '
        LD      A,(HL)			; Восстанавливаем введенноый символа
        CP      "'"
        LD      A, TK_REM		; Замена ' на REM
        JP      Z, WriteChar
	ENDIF

;
        LD      A,(HL)			; Восстанавливаем введенноый символа
        CP      '0'			; Меньше '0'?
        JP      C,L041A			; Ищем ключевое слово
        CP      ';'+1			; 0123456789:;
        JP      C,WriteChar

; Here's where we start to see if we've got a keyword. B здесь содержит 0 (см. код выше где OR A; LD B,A)

L041A:  PUSH    DE			; Preserve output ptr.
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
        POP     DE			; Restore output ptr
WriteChar:
	INC     HL			; Advance input ptr
        LD      (DE),A			; Store output char
        INC     DE			; Advance output ptr
        INC     C			; C++ (arf!).
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

;Get a character and jump out of here if user has pressed 'Enter'. 
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
	ELSE
	CP	1AH
	ENDIF
	JP	Z, L047D
	CP	01FH
	JP	Z, 01BE4H
	CP	07FH
	IF	RK86
	JP	Z, L1995
	ELSE
	JP	NC, InputNext
	ENDIF
	LD	C,A
	LD	A, B
	CP	72
	NOP
	NOP
	JP	NC, 01CD8H
	LD	A, C
	CP	" "
	JP	C, 01BFBH
	LD	(HL), C
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
	ELSE
        JP      NC,InputNext
        CP      01H
        JP      C,InputNext
        NOP     
        NOP     
        NOP     
        NOP     
	NOP
	ENDIF	; SERVICE
;A normal character has been pressed. Here we store it in LINE_BUFFER, only we don't if the terminal width has been exceeded. If the terminal width is exceeded then we ring the bell (ie print ASCII code 7) and ignore the char. Finally we loop back for the next input character.
        LD      C,A
        LD      A,B
        CP      72			; Длина LINE_BUFFER
        LD      A,07H
        JP      NC,IgnoreChar
        LD      A,C			; Write char to LINE_BUFFER.
        LD      (HL),C
        INC     HL
        INC     B
IgnoreChar:
	RST     OutChar
        JP      InputNext

	ENDIF	; SERVICE


OutChar_tail:
	JP      NZ,L0DC4
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
	NOP
	NOP
	NOP
	NOP
	NOP
	SCF
	CALL	C, 01B50H
	ELSE	; SERVICE
        CP      48H
        CALL    Z,NewLine
        INC     A
        LD      (TERMINAL_X),A
	ENDIF	; SERVICE

L04CD:  POP     AF
        PUSH    BC
        LD      C,A
        PUSH    AF
	IF	RK86
	CALL	L19C0
	ELSE
        CALL    0F809h
	ENDIF
        POP     AF
        POP     BC
        NOP     
        RET     

;InputChar
;Gets one char of input from the user.		

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

	ELSE

        JP      Z,0F800h
        NOP     
        AND     7FH
        CP      0FH
        RET     NZ

        LD      A,(ControlChar)
        CPL     
        LD      (ControlChar),A
        RET     
	ENDIF

;1.7 LIST Handler
;List
;Lists the program. As the stored program is in tokenised form 
;(ie keywords are represented with single byte numeric IDs) LIST
; is more complex than a simple memory dump. When it meets a 
;keyword ID it looks it up in the keywords table and prints it.

	CHK	04EEH, "Сдвижка кода"
List:
        CALL    LineNumberFromStr
        RET     NZ

        POP     BC
        CALL    FindProgramLine
        PUSH    BC
ListNextLine:
	POP     HL
        RST     PushNextWord
	POP     BC
        LD      A,B
        OR      C
        JP      Z,Main
        CALL    TestBreakKey
        PUSH    BC
        CALL    NewLine
        RST     PushNextWord
        EX      (SP),HL
        CALL    PrintInt
        LD      A,' '
L050D:  POP     HL
ListChar:
	RST     OutChar
        LD      A,(HL)
        OR      A
        INC     HL
        JP      Z,ListNextLine
        JP      P,ListChar
        SUB     7FH
        LD      C,A
        PUSH    HL
        LD      DE, KEYWORDS
L051F:  PUSH    DE
ToNextKeyword:
	LD      A,(DE)
        INC     DE
        OR      A
        JP      P,ToNextKeyword
        DEC     C
        POP     HL
        JP      NZ,L051F
PrintKeyword:
	LD      A,(HL)
        OR      A
        JP      M,L050D
        RST     OutChar
        INC     HL
        JP      PrintKeyword

;1.8 FOR Handler
;For
;Although FOR indicates the beginning of a program loop, the handler only gets 
;called the once. Subsequent iterations of the loop return to the following
;statement or program line, not the FOR statement itself.

	CHK	0535H, "Сдвижка кода"
For:		
        LD      A,64H
        LD      (NO_ARRAY),A
; First we call LET to assign the initial value to the variable. On return, HL points to the next bit of program (the TO clause with any luck)
        CALL    Let
;Stick program ptr onto stack. We lose the return address, since we don't need it as this function conveniently falls into ExecNext by itself.
        EX      (SP),HL
        CALL    GetFlowPtr
;Get program ptr into DE.
        POP     DE
        JP      NZ,L0547
        ADD     HL,BC
        LD      SP,HL
;HL=prog ptr, DE=stack. Here we check we've at least 8*4 bytes of space to use for the flow struct.
L0547:  EX      DE,HL
        CALL    CheckEnoughVarSpace2
        DB	08H
;Get pointer to end of statement (or end of program line) onto stack. This is the prog ptr that NEXT will return to.
        PUSH    HL
        CALL    FindNextStatement
        EX      (SP),HL
;Push current line number onto stack.
        PUSH    HL
        LD      HL,(CURRENT_LINE)
        EX      (SP),HL
        CALL    L0969		; Is Numeric
;Syntax check that TO clause is next.
        RST     SyntaxCheck
        DB	TK_TO
;Evaluate expression following 'TO', and push the result of that expression (a floating point number of course) on the stack
        CALL    EvalNumericExpression		; Eval numeric expression
        PUSH    HL
        CALL    FCopyToBCDE
        POP     HL
        PUSH    BC
        PUSH    DE
;Initialise the STEP value in BCDE to 1.
        LD      BC,8100H
        LD      D,C
        LD      E,D
;If a STEP clause has not been given, skip ahead with the direction byte (in A) as 0x01.
        LD      A,(HL)
        CP      TK_STEP
        LD      A,01H
        JP      NZ,PushStepValue
;STEP clause has been given so we evaluate it and get it into BCDE. The sign of this value becomes the direction byte (0x01 for fowards, 0xFF for backwards).
        RST     NextChar
        CALL    EvalNumericExpression		; Eval numeric expression
        PUSH    HL
        CALL    FCopyToBCDE
        POP     HL
        RST     FTestSign
;Initialise the STEP value in BCDE to 1.
PushStepValue:
	PUSH    BC
        PUSH    DE
;Push A onto stack. (A=1 if no step clause, else ???)
        PUSH    AF
        INC     SP
        
;Push the prog ptr to the end of the FOR statement (kept on PROG_PTR_TEMP) on the stack.
	PUSH    HL
	
	
        LD      HL,(PROG_PTR_TEMP)
        EX      (SP),HL
;Push TK_FOR onto the stack, and fall into ExecNext
EndOfForHandler:
	LD      B,TK_FOR
        PUSH    BC
        INC     SP

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
	CALL    0F812h			;---------------
        NOP				; !! Этот блок можно заменить одним вызовом CALL TestBreakKey
        CALL    NZ,CheckBreak		;---------------
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
	SUB     80H
        JP      C,Let
; Если это не основное слово, то это синтаксическая ошибка.
        CP      TKCOUNT
        JP      NC,SyntaxError
; Вычисляем адрес обработчика команды в таблице обработчиков в HL, сохранив текущий указатель программы в DE.
        RLCA    			;	BC = A*2
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

; Обработчик команды Restore
; Сбрасываем указатель данных на адрес перед началом программы.

Restore:
	EX      DE,HL
        LD      HL,(PROGRAM_BASE)
        DEC     HL
SetDataPtr:
L05E0:  LD      (DATA_PROG_PTR),HL
        EX      DE,HL
        RET     

;TestBreakKey
;Apparently the Altair had a 'break' key, to break program execution. 
;This little function tests to see if the terminal input device is ready,
; and returns if it isn't. If it is ready (ie user has pressed a key) 
;then it reads the char from the device, compares it to the code for
; the break key (0x03) and jumps to Stop. Since the first instruction 
;at Stop is RNZ, this will return at once if the user pressed some other key.

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

;STOP / END
;
; The keywords STOP and END are synonymous.
; Но по STOP мы запоминаем адрес останова для последующего
; восстановления по CONT
; We don't need to do anything other than lose the return address and fall into Main.

Stop:
	RET	NZ		; Syntax Error if args
	DB	0F6H            ; Устанавливаем флаг "STOP" и пропускаем RET NZ ; OR 0C0H
End:	RET     NZ		; Syntax Error if args
	LD      (PROG_PTR_TEMP),HL	; Сохраняем адрес останова во временную переменную
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
L0609:  XOR     A
        LD      (ControlChar),A
        POP     AF
        LD      HL, szStop		; Сообщение "СТОП"
        JP      NZ, PrintInLine		; Если флаг "STOP", то печатаем сообщение
        JP      Main			; Иначе уходим в диалоговый режим

	CHK	0617H, "Сдвижка кода"
Cont:	
	RET     NZ			; Ощибка, если есть аргументы
	LD      E,ERR_CN		; Подготавливаем номер ошибки
	LD      HL,(OLD_TEXT)		; Восстанавливаем адрес останова
	LD      A,H
	OR      L
	JP      Z,Error			; Если он нулевой, то ошибка
	EX      DE,HL
	LD      HL,(OLD_LINE)		; Восстанавливаем номер строки
	LD      (CURRENT_LINE),HL
	EX      DE,HL			; HL=Адрес, DE=Строка
	RET				; Продолжаем выполнение со места останова

; Похоже, что мертвый код. В оригинале это реализация команды NULL,
; которая определяла, сколько нулей выводить после конца строки.

Null:
	IF	BASICNEW
	RET				; К следующей команде
	ELSE
	CALL    EvalByteExpression	; Парсим байт
        RET     NZ			; Общибка, если не байт

        INC     A
        CP      48H			; Проверяем максимум
        JP      NC,FunctionCallError
        LD      (NULLS),A		; Сохраняем, сколько выводить нулей
        RET				; К следующей команде
	ENDIF
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
L0642:  CALL    EvalNumericExpression

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
Clear:
        JP      Z,ClearAll
        CALL    L0642
        DEC     HL
        RST     NextChar
        RET     NZ

        PUSH    HL
        LD      HL,(MEMSIZ)
        LD      A,L
        SUB     E
        LD      E,A
        LD      A,H
        SBC     A,D
        LD      D,A
        JP      C,SyntaxError
        LD      HL,(VAR_BASE)
        LD      BC,0028H
        ADD     HL,BC
        RST     CompareHLDE
        JP      NC,OutOfMemory
        EX      DE,HL
        LD      (STACK_TOP),HL
        POP     HL
        JP      ClearAll

	CHK	06ABH, "Сдвижка кода"
Run:
        JP      Z,ResetAll
        CALL    ClearAll
        LD      BC,ExecNext
        JP      GosubBC
	
;Gosub
;Gosub sets up a flow struct on the stack and then falls into Goto. The flow struct is KWID_GOSUB, preceded by the line number of the gosub statement, in turn preceded by prog ptr to just after the gosub statement.
	
	CHK	06B7H, "Сдвижка кода"
Gosub:
        CALL    CheckEnoughVarSpace2
        DB	03h
        POP     BC
        PUSH    HL
        PUSH    HL
        LD      HL,(CURRENT_LINE)
        EX      (SP),HL
        LD      D,TK_GOSUB
        PUSH    DE
        INC     SP
;Push return address preserved in BC, and fall into GOTO.
GosubBC:  PUSH    BC

;Goto
;Sets program execution to continue from the line number argument.

;Get line number argument in DE and return NZ indicating syntax error if the argument was a non-number .
	CHK	06C7H, "Сдвижка кода"
Goto:
	CALL    LineNumberFromStr
        CALL    Rem
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

        LD      E,ERR_US
        JP      Error
		
		
; Return
; Returns program execution to the statement following the last GOSUB. Information about where to return to is kept on the stack in a flow struct (see notes).

	CHK	06e3h, "Сдвижка кода"
Return:
        RET     NZ		;No arguments allowed.
        LD      D,0FFH
        CALL    GetFlowPtr
        LD      SP,HL
        CP      TK_GOSUB
        LD      E,ERR_RG
        JP      NZ,Error
        POP     HL
        LD      (CURRENT_LINE),HL
        LD      HL,ExecNext
        EX      (SP),HL

;Safe to fall into FindNextStatement, since we're already at the end of the line!...

;FindNextStatement
; Finds the end of the statement or the end of the program line.

; Rem is jumped to in two places - it is the REM handler, and also when an 
; IF statement's condition evals to false and the rest of the line needs
; to be skipped. Luckily in both these cases, C just happens to be
; loaded with a byte that cannot occur in the program so the null 
; byte marking the end of the line is found as expected.

Data:
FindNextStatement:
	DB	01H, ":"	;LD BC,..3AH эмулирует LD C, ":"
Rem:	LD	C, 0
	LD      B,00H
ExcludeQuote:
	LD      A,C
        LD      C,B
        LD      B,A
FindNextStatementLoop:
	LD      A,(HL)
        OR      A
        RET     Z

        CP      B
        RET     Z

        INC     HL
        CP      '"'
        JP      Z,ExcludeQuote
        JP      FindNextStatementLoop

;1.12 Assigning Variables
;Let
;Assigns a value to a variable.

Let:	CALL    GetVar
        RST     SyntaxCheck
        DB	TK_EQ			; '='
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
        CALL    L096B
        JP      Z,CopyNumeric
L072B:  PUSH    HL
        LD      HL,(FACCUM)
        PUSH    HL
        INC     HL
        INC     HL
        RST     PushNextWord
        POP     DE
        LD      HL,(STACK_TOP)
        RST     CompareHLDE
        POP     DE
        JP      NC,L0745
        LD      HL,(VAR_BASE)
        RST     CompareHLDE
        LD      L,E
        LD      H,D
        CALL    C,L0D2F
L0745:  LD      A,(DE)
        PUSH    AF
        XOR     A
        LD      (DE),A
        CALL    L0EC5
        POP     AF
        LD      (HL),A
        EX      DE,HL
        POP     HL
        CALL    L131C
        POP     HL
        RET     

CopyNumeric:
	PUSH    HL
        CALL    FCopyToMem
        POP     DE
        POP     HL
        RET     

; Обработчик ON x GOTO/ON x GOSUB

	CHK	075Ch, "Сдвижка кода"
On:
        CALL    EvalByteExpression
        LD      A,(HL)
        LD      B,A
        CP      TK_GOSUB
        JP      Z,OkToken
        RST     SyntaxCheck
        DB	TK_GOTO
        DEC     HL
OkToken:
	LD      C,E
OnLoop:
	DEC     C
        LD      A,B
        JP      Z, ExecA
        CALL    LineNumberFromStr2
        CP      ','
        RET     NZ

        JP      OnLoop

;1.13 IF Keyword Handler
;If
;Evaluates a condition. A condition has three mandatory parts : a left-hand side expression, a comparison operator, and a right-hand side expression. Examples are 'A=2', 'B<=4' and so on.

;The comparison operator is one or more of the three operators '>', '=', and '<'. Since these three operators can appear more than once, and in any order, the code does something rather clever to convert them to a single 'comparison operator value'. This value has bit 0 set if '>' is present, bit 1 for '=', and bit 2 for '<'. Thus the comparison operators '<=' and '=<' are both 6, likewise '>=' and '=>' are both 3, and '<>' is 5

;You can therefore get away with stupid operators such as '>>>>>' (value 1, the same as a single '>') and '>=<' (value 7), the latter being particularly dense as it causes the condition to always evaluate to true.

	CHK	0778h, "Сдвижка кода"
If:
        CALL    EvalExpression
        LD      A,(HL)
        CP      TK_GOTO			; !!Добавить IF x GOSUB
        JP      Z, NoThen
        RST     SyntaxCheck
        DB	TK_THEN
        DEC     HL
NoThen:
	RST     FTestSign
        JP      Z,Rem

;Condition evaluated to True. Here we get the first character of the THEN statement,
; and if it's a digit then we jump to GOTO's handler as it's an implicit GOTO. 
;Otherwise we jump to near the top of Exec to run the THEN statement.
	
        RST     NextChar
        JP      C,Goto			; Если число, то это GOTO
        JP      ExecANotZero		; Если конец строки, то возврат, иначе исполняем команду
		
;1.14 Printing
;Print
;Prints something! It can be an empty line, a single expression/literal, 
;or multiple expressions/literals seperated by tabulation directives 
;(comma, semi-colon, or the TAB keyword).

; Похоже, это мертвый код
        DEC     HL

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
        JP      Z,L07F4
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
	LD      (HL),00H
TerminateInput2:
        LD      HL,LINE_BUFFER-1
		
;NewLine
;Prints carriage return + line feed, plus a series of nulls which was probably due to some peculiarity of the teletypes of the day.

NewLine:
	LD      A,0DH
        LD      (TERMINAL_X),A
        RST     OutChar
        LD      A,0AH
        RST     OutChar
L07E5:  LD      A,(NULLS)
PrintNullLoop:
	DEC     A
        LD      (TERMINAL_X),A
        RET     Z

        PUSH    AF
        XOR     A
        RST     OutChar
        POP     AF
        JP      PrintNullLoop

;ToNextTabBreak
;Calculate how many spaces are needed to get us to the next tab-break then jump to PrintSpaces to do it.

L07F4:  LD      A,(TERMINAL_X)
        CP      30H
        CALL    NC,NewLine
        JP      NC,ExitTab
L07FF:  SUB     0EH
        JP      NC,L07FF
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
        JP      NZ,L0866
        CALL    L0D50
        RST     SyntaxCheck
        DB	';'
        PUSH    HL
        CALL    L0D96
        POP     HL
L0866:  PUSH    HL
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
        CP	','
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
        LD      D,':'				; 3AH
        LD      B,','				; 2CH
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
        CP      ','				; 2CH
        JP      NZ,L0840
L08D1:  EX      (SP),HL
        DEC     HL
        RST     NextChar
        JP      NZ, ReadNext			;0884h
;
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
	CALL    FindNextStatement
        OR      A
        JP      NZ,L0914
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
L0914:  RST     NextChar
        CP      TK_DATA			; 83H
        JP      NZ,ReadError
        JP      GotDataItem

;1.16 NEXT Handler
;Next
;The NEXT keyword is followed by the name of the FOR variable, so firstly we get the address of that variable into DE.

	CHK	091Dh, "Сдвижка кода"
Next:
        LD      DE,0000H
L0920:  CALL    NZ,GetVar
;Save the prog ptr in HL to PROG_PTR_TEMP. This currently points to the end of the NEXT statement, and we need to get it back later in case we find that the FOR loop has completed.
        LD      (PROG_PTR_TEMP),HL
;GetFlowPtr to get access to the FOR flow struct on the stack.
        CALL    GetFlowPtr
        JP      NZ,WithoutFOR
        LD      SP,HL
;Push address of FOR variable
        PUSH    DE
;Load A with first byte of struct (0x01), advance HL, and preserve A. 
        LD      A,(HL)
        INC     HL
        PUSH    AF
;Push address of FOR variable again.
        PUSH    DE
;The next 4 bytes of the flow struct are the STEP number. We load this into FACCUM here.
        CALL    FLoadFromMem
;Get FOR variable address into HL and push the struct ptr 
        EX      (SP),HL
;Add the FOR variable to the STEP number and update the FOR variable with the result.
        PUSH    HL
        CALL    FAddFromMem
        POP     HL
        CALL    FCopyToMem
;Restore struct ptr to HL. This now points to the TO number, which we load into BCDE.
        POP     HL
        CALL    FLoadBCDEfromMem
;Compare the updated FOR variable (in FACCUM) with the TO number (in BCDE). The result of the compare is in A and will be 0xFF if FOR var is less than the TO number, 0x00 if equal, and 0x01 if the FOR variable is greater than the TO number.
        PUSH    HL
        CALL    FCompare
        POP     HL
;Restore the direction byte to B. Remember this is 0x01 for forward iteration, 0xFF for backwards (when there is a -ve STEP number).
        POP     BC
;This is marvellous! By subtracting the direction byte from the result of FCompare we can tell if the FOR loop has completed (the result of the subtraction will be zero) with the minimum of fuss. Read the two above comments and it should make sense.
        SUB     B
;NOT loading a floating point number, this is just a handy way of getting the last four bytes of the struct. BC is loaded with the prog ptr to just beyond the FOR statement, and DE is loaded with the line number of the FOR statement.
        CALL    FLoadBCDEfromMem
;If FOR loop is complete (see two comments up) then jump ahead.
        JP      Z,ForLoopIsComplete
;FOR loop is not yet complete. Here we save the line number of the FOR statement to the CURRENT_LINE variable, load HL with the prog ptr to the end of the FOR statement, and jump to EndOfForHandler which pushes the last byte of the for_struct on the stack and falls into ExecNext.
        EX      DE,HL
        LD      (CURRENT_LINE),HL
        LD      L,C
        LD      H,B
        JP      EndOfForHandler
	
;The FOR loop is complete. Therefore we don't need the for_struct on the stack any more, and since HL points just past it we can load the stack pointer from HL to reclaim that bit of stack space.
ForLoopIsComplete:
	LD      SP,HL
        LD      HL,(PROG_PTR_TEMP)
        LD      A,(HL)
        CP      ','			;2CH
        JP      NZ,ExecNext
        RST     NextChar
        CALL    L0920

; Evalute expression and check is it value is Numeric
EvalNumericExpression:
	CALL    EvalExpression
L0969:  DB	0F6H			;OR 37H - это сброс флага CY
L096A:	SCF				;37H
L096B:  LD      A,(VALTYP)
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
L0978:  PUSH    DE
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
        CALL    NC,L0969
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
        CALL    L0969
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
        JP      Z,L0D50
        CP      TK_NOT			; 0A2H
        JP      Z,L0AF9
        CP      TK_FN			; 0A0H
        JP      Z,L0CCD
;If the character is the keyword ID of an inline function them jump ahead to deal with that.
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
L0A2A:	CALL    L0969
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

;Evaluate an inline function. First we get the offset into the KW_INLINE_FNS table into BC and stick it on the stack.
EvalInlineFn:
	LD      B,00H
        RLCA    
        LD      C,A
        PUSH    BC
        RST     NextChar
        LD      A,C
        CP      ')'
        JP      C,L0A65
        RST     SyntaxCheck
	DB	'('
	CALL	EvalExpression

        RST     SyntaxCheck
        DB	','
        CALL    L096A
        EX      DE,HL
        LD      HL,(FACCUM)
        EX      (SP),HL
        PUSH    HL
        EX      DE,HL
        CALL    EvalByteExpression
        EX      DE,HL
        EX      (SP),HL
        JP      L0A6D

L0A65:  CALL    L0A16
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
        CALL    L0969
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
        CALL    L096B
        LD      HL,L0AEF
        PUSH    HL
        JP      Z,FCompare
        XOR     A
        LD      (VALTYP),A
        PUSH    DE
        CALL    L0EC1
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
        CALL    L0969
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
        LD      (VALTYP),A		; A=0
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
        INC     A			; A=1
        LD      (VALTYP),A
        RRCA    
        ADD     A,C
        LD      C,A
        RST     NextChar
L0B4C:  LD      A,(NO_ARRAY)
        ADD     A,(HL)
        CP      28H
        JP      Z,L0B9E
        XOR     A
        LD      (NO_ARRAY),A
        PUSH    HL
        LD      HL,(VAR_ARRAY_BASE)
        EX      DE,HL
        LD      HL,(VAR_BASE)

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
L0B8F:  DEC     HL
        LD      (HL),00H
        RST     CompareHLDE
        JP      NZ,L0B8F
        POP     DE
        LD      (HL),E
        INC     HL
        LD      (HL),D
        INC     HL
L0B9B:  EX      DE,HL
        POP     HL
        RET     


L0B9E:  PUSH    HL
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
L0BEE:  LD      E,ERR_BS
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
        DB	0e9h
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
        JP      C,L0BEE
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
        JP      NC,L0BEE
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

	CHK	0C7Ah, "Сдвижка кода"
Fre:
        LD      HL,(VAR_TOP)
        EX      DE,HL
        LD      HL,0000H
        ADD     HL,SP
        LD      A,(VALTYP)
        OR      A
        JP      Z,L0C96
        CALL    L0EC1
        CALL    GarbageCollection
        LD      HL,(STACK_TOP)
        EX      DE,HL
        LD      HL,(STR_TOP)
L0C96:  LD      A,L
        SUB     E
        LD      C,A
        LD      A,H
        SBC     A,D
WordFromACToFACCUM:
	LD      B,C
WordFromABToFACCUM:
	LD      D,B
        LD      E,00H
        LD      HL,VALTYP
        LD      (HL),E
        LD      B,90H
        JP      L12DA

	CHK	0CA8h, "Сдвижка кода"
Pos:
        LD      A,(TERMINAL_X)

; Преобразует байт из A в число с плавающей точкой в FACCUM
ByteFromAToFACCUM:
	LD      B,A
        XOR     A
        JP      WordFromABToFACCUM
	
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
        CALL    L0969
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
        CALL    L0969
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
        JP      L0969
	
	CHK	0d1fh, "Сдвижка кода"
Str:
        CALL    L0969
        CALL    FOut
        CALL    L0D4F
        CALL    L0EC1
        LD      BC,L0F10
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

L0D43:  CALL    L0DAA
L0D46:  LD      HL,022BH
        PUSH    HL
        LD      (HL),A
        INC     HL
        JP      L0CFC
L0D4F:  DEC     HL
L0D50:  LD      B,22H
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
L0D65:  CP      22H
        CALL    Z,NextChar2
        EX      (SP),HL
        INC     HL
        EX      DE,HL
        LD      A,C
        CALL    L0D46
        RST     CompareHLDE
        CALL    NC,L0D2F
L0D75:  LD      DE,022BH
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
L0D96:  CALL    L0EC1
        CALL    FLoadBCDEfromMem
        INC     E
L0D9D:  DEC     E
        RET     Z

        LD      A,(BC)
        RST     OutChar
        CP      0DH
        CALL    Z,L07E5
        INC     BC
        JP      L0D9D
		
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
L0DC4:  POP     AF
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
        CALL    L096A
        LD      A,(HL)
        PUSH    HL
        LD      HL,(FACCUM)
        PUSH    HL
        ADD     A,(HL)
        LD      E,ERR_LS
        JP      C,Error
        CALL    L0D43
        POP     DE
        CALL    L0EC5
        EX      (SP),HL
        CALL    L0EC4
        PUSH    HL
        LD      HL,(022DH)
        EX      DE,HL
        CALL    L0EAE
        CALL    L0EAE
        LD      HL,L0986
        EX      (SP),HL
        PUSH    HL
        JP      L0D75

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

L0EBE:  CALL    L096A
L0EC1:  LD      HL,(FACCUM)
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
        JP      NZ,L0EE5
        LD      B,A
        ADD     HL,BC
        LD      (STR_TOP),HL
L0EE5:  POP     HL
        RET     

	CHK	0EE7h, "Сдвижка кода"
Len:
        LD      BC,ByteFromAToFACCUM
        PUSH    BC
L0EEB:  CALL    L0EBE
        XOR     A
        LD      D,A
        LD      (VALTYP),A
        LD      A,(HL)
        OR      A
        RET     

	CHK	0ef6h, "Сдвижка кода"
Asc:
        CALL    L0EEB
        JP      Z,FunctionCallError
        INC     HL
        INC     HL
        RST     PushNextWord
        POP     HL
        LD      A,(HL)
        JP      ByteFromAToFACCUM

	CHK	0f04h, "Сдвижка кода"
Chr:
        LD      A,01H
        CALL    L0D43
        CALL    L0FBC
        LD      HL,(022DH)
        LD      (HL),E
L0F10:	POP     BC
        JP      L0D75

	CHK	0f14h, "Сдвижка кода"
Left:
        CALL    L0F9F
        XOR     A
L0F18:  EX      (SP),HL
        LD      C,A
L0F1A:	PUSH    HL
	LD      A,(HL)
        CP      B
        JP      C,L0F22
        LD      A,B
        DB	11H		;LD      DE,000EH
L0F22:	LD	C, 0
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
        JP      L0D75

	CHK	0f44h, "Сдвижка кода"
Right:
        CALL    L0F9F
        POP     DE
        PUSH    DE
        LD      A,(DE)
        SUB     B
        JP      L0F18

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
        LD      BC,L0F1A
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
        CALL    L0FBC
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
L0FBC:  CALL    FTestPositiveIntegerExpression
        LD      A,D
        OR      A
        JP      NZ,FunctionCallError
        DEC     HL
        RST     NextChar
        LD      A,E
        RET

	CHK	0Fc8H, "Сдвижка кода"
Val:
        CALL    L0EEB
        JP      Z,FZero
        LD      E,A
        INC     HL
        INC     HL
        RST     PushNextWord
        LD      H,B
        LD      L,C
        ADD     HL,DE
        LD      B,(HL)
        LD      (HL),D
        EX      (SP),HL
        PUSH    BC
        LD      A,(HL)
        CALL    FIn
        POP     BC
        POP     HL
        LD      (HL),B
        RET     

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
	LD	HL, (VAR_BASE)
	INC	H
	EX	DE, HL
	CALL	0F830H
	RST	CompareHLDE
	JP	C, L1041
	CALL	0F830H
	LD	(MEMSIZ), HL		;021bh
	LD	(STR_TOP), HL
	LD	SP, HL
	LD	HL, 0FFCEH		; -50
	ADD	HL, SP
	LD	(STACK_TOP), HL		;0241h
	CALL	L19B8
	JP	Main

L1041:	LD	A, D
	CALL	0F815h
	LD	A, E
	CALL	0F815h
L1049:	JP	0F86Ch

	IF	BASICNEW
	ELSE
	NOP
	NOP
	ENDIF

	ELSE
        RST     NextChar
        RET     

; Предположительно, это две строчки - мертвый код
        LD      (FACCUM),A
        CALL    New2

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

; Какой-то мертвый код..., похоже на другую реализацию PEEK
        CALL    FTestPositiveIntegerExpression
        LD      A,(DE)
        JP      ByteFromAToFACCUM

; Тоже мертвый код, , похоже на другую реализацию POKE
        CALL    L0642

L1067:  PUSH    DE
        RST     SyntaxCheck
        DB	','
        CALL    EvalByteExpression
        POP     DE
        LD      (DE),A
        RET     

	INCLUDE	"MATH.INC"
	
	CHK	1724h, "Сдвижка кода"
Peek:	
        RST     FTestSign
        CALL    FTestIntegerExpression
        LD      A,(DE)
        JP      ByteFromAToFACCUM
	
	CHK	172CH, "Сдвижка кода"
Poke:
        CALL    EvalNumericExpression
        RST     FTestSign
        CALL    FTestIntegerExpression
        JP      L1067
	
	CHK	1736h, "Сдвижка кода"
Usr:
        RST     FTestSign
        CALL    FTestIntegerExpression
        EX      DE,HL
        CALL    CallHL
	JP	ByteFromAToFACCUM

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
	JP	ContInit

szHello:
	DB	01FH,"*radio-86rk* BASIC", 0DH, 0AH, 0

Cls:	PUSH	HL
	CALL	0F81EH
	LD	BC, 01D18H
	ADD	HL, BC
	LD	(POSX), HL		; 01957H
	POP	HL
	LD	C, 1FH
	CALL	0F809H
	JP	SetCurPos

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

Plot:	CALL	EvalByteExpression
	LD	(GPOSX), A		; 01954H
	RST	SyntaxCheck
	DB	','

	CALL	EvalByteExpression
	LD	(GPOSY), A		; 01955H
	RST	SyntaxCheck
	DB	','

	CALL	EvalByteExpression
	LD	(GFILL), A		; 01956H

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

szHello:
	IF	UT88
	DB		1Fh, 0Dh, 0Ah, "* UT-88 *  BASIC", 0
	ELSE
	DB		1Fh, 0Dh, 0Ah, "*MikrO/80* BASIC", 0
	ENDIF

	CHK	176ah, "Сдвижка кода"
Cur:
	CALL    EvalByteExpression
        LD      (POSX),A		; 1957H
        RST     SyntaxCheck
        DB	','
        CALL    EvalByteExpression
        LD      (POSY),A		; 1958H
        CP      20H
        JP      NC,FunctionCallError
        LD      A,(POSX)		; 1957H
        CP      40H
        JP      NC,FunctionCallError
        PUSH    HL
        LD      HL,(0F75AH)		; Адрес курсора в МИКРО-80 и ЮТ-88
        LD      DE,0F801H		; -7FFH
        ADD     HL,DE
        LD      (HL),00H
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
        LD      (0F75AH),HL		; Адрес курсора в МИКРО-80 и ЮТ-88
        LD      DE,0F801H		; -7FFH
        ADD     HL,DE
        LD      (HL),80H
        POP     HL
        RET     

	CHK	17B3H, "Сдвижка кода"
Cls:
; Здесь можно было бы просто вывести 01fH через МОНИТОР и было бы портабельно...
; Но МИКРО-80 не умеет получать и сохранять координаты курсора.

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
	ELSE
	LD	A, 08H
	RST	OutChar
	LD	A, ' '
	RST	OutChar
	LD	A, 08H
	JP	Backspace
	ENDIF
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
	ELSE
	DB	40 DUP (0)
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
	ELSE
	DB	62 DUP (0)
	ENDIF
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
L1A00:	LD	DE, TK_CLS+KEYWORDS-80H
	CP	"2"
	RET	Z
	LD	E, 8BH
	CP	46H
	RET	Z
	LD	E, 8EH
	CP	4EH
	RET	Z
	LD	E, 92H
	CP	44H
	RET	Z
	LD	E, 96H
	CP	49H
	RET	Z
	LD	E, 09BH
	CP	031H
	RET	Z
	LD	E, 09EH
	CP	051H
	RET	Z
	LD	E, 0A2H
	CP	043H
	RET	Z
	LD	E, 0A5H
	CP	04AH
	RET	Z
	LD	E, 0B5H
	CP	047H
	RET	Z
	LD	E, 0BAH
	CP	052H
	RET	Z
	LD	E, 0C0H
	CP	03BH
	RET	Z
	LD	E, 0C3H
	CP	033H
	RET	Z
	LD	E, 0CCH
	CP	050H
	RET	Z
	LD	E, 0D0H
	CP	04CH
	RET	Z
	LD	E, 0D4H
	CP	059H
	RET	Z
	LD	E, 0D8H
	CP	020H
	RET	Z
	LD	E, 0DDH
	CP	034H
	RET	Z
	LD	E, 0E8H
	CP	04BH
	RET	Z
	LD	E, 0EDH
	CP	040H
	RET	Z
	LD	E, 0F2H
	CP	04FH
	RET	Z
	LD	E, 0FAH
	CP	042H
	RET	Z
	LD	DE, 0100H
	CP	05AH
	RET	Z
	LD	E, 006H
	CP	054H
	RET	Z
	LD	E, 00DH
	CP	053H
	RET	Z
	LD	E, 016H
	CP	036H
	RET	Z
	LD	E, 021H
	CP	035H
	RET	Z
	LD	E, 024H
	CP	037H
	RET	Z
	LD	E, 027H
	CP	055H
	RET	Z
	LD	E, 033H
	CP	038H
	RET	Z
	LD	E, 036H
	CP	057H
	RET	Z
	LD	E, 03CH
	CP	039H
	RET	Z
	LD	E, 04BH
	CP	058H
	RET	Z
	LD	E, 056H
	CP	056H
	RET	Z
	LD	E, 05CH
	CP	048H
	RET	Z
	LD	E, 060H
	CP	05BH
	RET	Z
	LD	E, 065H
	CP	05DH
	RET	Z
	LD	E, 06BH
	CP	04DH
	RET	Z
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
	CP	45H
	JP	Z, 01B72H
	CP	41H
	JP	Z, 01B2CH
	CP	" "
	IF	RK86
	JP	C, L195C
	ELSE
	JP	C, InputNext
	ENDIF
	CALL	L1A00
	CALL	L1AE8
	JP	NC, 01CD8H
	JP	InputNext
L1AE8:	LD	A, B
	CP	48H
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

L1AFA:	LD	HL, (0227H)
	EX	DE, HL
	LD	HL, 000AH
	Add	HL, DE
	LD	(0227H), HL
	RET

L1B06:	LD	HL, (0227H)
	CALL	01465H
	LD	HL, 01CFH
	LD	B, 1
	LD	DE, 0253H
	LD	A, (DE)
	CP	0
	JP	Z, 01B25H
	LD	(HL), A
	INC	HL
	LD	A, B
	CALL	01B51H
	INC	B
	INC	DE
	JP	01B14H

	LD	A, 20H
	LD	(HL), A
	INC	HL
	INC	B
	RST	OutChar
	RET

	POP	HL
	LD	HL, 01B58H
	LD	(030EH), HL
	LD	L, 3EH
	LD	(0495H), HL
	LD	HL, 01CF8H
	CALL	0F818H
	CALL	007DCH
	JP	01B5CH

	LD	L, 07DH
	LD	(0495H), HL
	LD	HL, (021BH)
	LD	SP, HL
	JP	02FDH

	INC	A
	LD	(0027H),A
	LD	(0229H),HL
	RET

	POP	HL
	CALL	01AFAH
	CALL	01B06H
	CALL	00485H
	RST	NextChar
	PUSH	AF
	CALL	00661H
	EX	DE, HL
	LD	(00227H), HL
	EX	DE, HL
	JP	Z, 01B58H
	JP	0031AH
	LD	HL, 01CEEH
	CALL	0F818H
	LD	HL, 01B93H
	LD	(0030EH), HL
	LD	A, 1
	LD	(004BDH), A
	CALL	00480H
	CALL	01C55H
	LD	A, 0C9H
	LD	(007D7H), A
	LD	A, 0B8H
	LD	(004C9H), A
	LD	HL, (00039H)
	EX	DE, HL
	CALL	00385H
	PUSH	BC
	POP	HL
	RST	PushNextWord
	POP	BC
	LD	A, B
	OR	C
	JP	Z, 01BE4H
	PUSH	BC
	CALL	007DCH
	RST	PushNextWord
	EX	(SP), HL
	CALL	01B09H
	POP	HL
	LD	A, B
	CP	48H
	LD	A, (HL)
	INC	HL
	JP	NC, 01C3AH
	OR	A
	JP	Z, 01C3AH
	JP	P, 01BD9H
	SUB	07FH
	LD	C, A
	PUSH	HL
	LD	DE, 00088H
	PUSH	DE
	LD	A, (DE)
	INC	DE
	OR	A
	JP	P, 01BC4H
	DEC	C
	POP	HL
	JP	NZ, 01BC3H
	EX	DE, HL
	LD	HL, (0229H)
	CALL	01AE8H
	JP	01BACH

	PUSH	HL
	LD	HL, (00229H)
	LD	(HL), A
	INC	HL
	INC	B
	RST	OutChar
	JP	01BACH

	LD	A, 036H
	LD	(007D7H), A
	INC	A
	LD	(004C9H), A
	LD	A, 20H
	LD	(004BDH), A
	LD	HL, 00480H
	LD	(0030EH), HL
	JP	01B44H

	CP	018H
	JP	Z, 01CE0H
	LD	A, (0030EH)
	CP	80H
	JP	Z, 01AC4H
	JP	NC, 01C11H
	CALL	0F803H
	JP	01ADCH

	LD	A, C
	OR	02H
	CP	03H
	JP	Z, 01C60H
	CALL	0F803H
	CP	01H
	JP	Z, 00485H
	CP	03H
	JP	Z, 01CC7H
	CP	0dH
	JP	Z, 01C4FH
	IF	RK86
	CP	00AH
	ELSE
	CP	01AH
	ENDIF
	JP	Z, 01C33H
	JP	01ADCH

	CALL	01C55H
	EX	DE, DL
	JP	01C4FH

	CALL	01C55H
	CALL	0F803H
	CP	0DH
	JP	Z, 01B9BH
	POP	HL
	LD	HL, (00229H)
	CALL	00488H
	LD	HL, (00229H)
	LD	(HL), 0
	LD	HL, 001CEH
	RET

	LD	HL, 001CFH
	CALL	00661H
	EX	DE, HL
	LD	(00039H), HL
	RET

	LD	A, (00027H)
	CP	B
	JP	C, 01CD8H
	LD	E, A
	LD	A, C
	CP	001H
	JP	Z, 01C74H
	LD	A, E
	CP	047H
	JP	NC, 01CD8H
	LD	H, B
	LD	B, E
	LD	HL, (00229H)
	DEC	HL
	LD	A, (HL)
	PUSH	AF
	LD	A, D
	CP	B
	JP	Z, 01C86H
	DEC	HL
	DEC	B
	JP	01C7AH

	LD	A, C
	CP	01H
	JP	Z, 01CA1H
	CP	03H
	JP	NZ, 01C96H
	LD	A, 20H
	JP	01C99H

	LD	C, 0FFH
	INC	D
	LD	(HL), A
	INC	HL
	INC	B
	RST	OutChar
	INC	E
	JP	01CA3H

	POP	AF
	DEC	E
	LD	A, E
	CP	B
	JP	C, 01CB0H
	POP	AF
	LD	(HL), A
	INC	HL
	INC	B
	RST	OutChar
	JP	01CA3H

	DEC	A
	CALL	01B51H
	XOR	A
	LD	(HL), A
	INC	HL
	INC	B
	RST	OurChar
	DEC	B
	DEC	HL
	LD	A, 08H
	RST	OutChar
	LD	A, D
	CP	B
	JP	NZ, 01CB9H
	ADD	A, C
	JP	NC, 00485H
	CALL	0F803H
	LD	C, A
	CP	20H
	JP	NC, 01C60H
	CP	01BH
	JP	Z, 01C19H
	JP	00488H

	ADC	A, B
	INC	B
	DEC	B
	LD	A, 07H
	RST	OutChar
	INC	B
	JP	00485H

	LD	A, (00027H)
	CP	B
	LD	A, C
	JP	NC, 004B1H
	LD	A, 20H
	LD	C, A
	JP	004B0H

	DB	00DH, 00AH, "EDIT*", 00DH, 00AH, 000H
	DB	00DH, 00AH, "AUTO*", 000H
	ENDIF
