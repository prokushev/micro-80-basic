; ════════════════════════════════════════════════════════════
;  БЕЙСИК для МИКРО-80/БЕЙСИК для РАДИО-86РК/БЕЙСИК для ЮТ-88
; ════════════════════════════════════════════════════════════
; Математический пакет
;
; 'Математический пакет' is a reasonably discrete block of
; code that provides floating-point arithmetic capability
; for the rest of BASIC. It also includes some math 
; functions, such as SQR (square root) and is probably the 
; hardest part of BASIC to understand. There are three general
; reasons for this:
; - You may have forgotten a lot of the maths you learnt at
;   school. This certainly applied to me : when I began
;   working on this section from first principles, I quickly
;   found myself floundering at the very idea of binary
;   fractions.
; - Unless you're a numerical analyst who has reason to
;   distrust conventional hardware/software floating-point
;   support, you probably never needed to think about how
;   floating point worked before now. Modern processors, 
;   compilers, and runtime libraries took the pain away
;   years ago, and quite right too.
; - Floating point is hard to code. Consider this : Bill Gates
;   is one of the brightest kids in America at the time, but
;   he and his equally brainy pal Paul Allen end up having to
;   hire a third wunderkind, Monte Davidoff, just to do
;   floating point. They needed a specialist to do 
;   specialist work, and Monte had done it before.
; ════════════════════════════════════════════════════════════
; Maths Refresher
; The Basics of Bases 
; Consider an everyday decimal number such as 317.25. The 
; digits that make up this and every other decimal number 
; represent multiples of powers of ten, all added together:
;
; 102	101	100	.	10-1	10-2
; 3	1	7	.	2	5
;
; So writing 317.25 is basically just shorthand for
; 3*102 + 1*101 + 7*100 + 2*10-1 + 5*10-2. The shorthand form
; is far more readable, and that's why everybody uses it. At 
; risk of labouring the point, the below table should clarify
; this.
;
; Digit Position	Digit Value for Position	Decimal Number	Digit value for this number
; 2	100	317.25	3 * 100	=	300
; 1	10	317.25	1 * 10	=	10
; 0	1	317.25	7 * 1	=	7
; -1	1/10	317.25	2 * .1	=	.2
; -2	1/100	317.25	5 * .01	=	.05
; Total:	=	317.25
;
; Now consider the same number in binary (base two). The 
; decimal number 317.25, expressed in binary, is :
;
;28	27	26	25	24	23	22	21	20	.	2-1	2-2
;1	0	0	1	1	1	1	0	1	.	0	1
;
; And here's a table like the decimal one above, which should
; make it completely clear (remember 'bit' is short for 
; 'binary digit') :
;
; Bit Position	Bit Value for Position	Binary Number	Bit value for this number
;8	256	100111101.01	1 * 256	=	256
;7	128	100111101.01	0 * 128	=	0
;6	64	100111101.01	0 * 64	=	0
;5	32	100111101.01	1 * 32	=	32
;4	16	100111101.01	1 * 16	=	16
;3	8	100111101.01	1 * 8	=	8
;2	4	100111101.01	1 * 4	=	4
;1	2	100111101.01	0 * 2	=	0
;0	1	100111101.01	1 * 1	=	1
;-1	1/2	100111101.01	0 * 1/2	=	0
;-2	1/4	100111101.01	1 * 1/4	=	0.25
;Total:	=	317.25
;
;Mantissas, Exponents, and Scientific Notation
;
; Now let's think about decimal numbers again. Another way of
; representing the number 317.25 is like this : 3.1725 * 102. 
; Yes we've split one number into two numbers - we've extracted
; the number's magnitude and written it seperately. Why is this
; useful? Well, consider a very small number such as
; 0.00000000000588. Looking at it now, precisely how small is
; that? That's a lot of zeros to work through. Also, let's 
; pretend we're using very small numbers like this one in a
; pen+paper calculation - something like 0.00000000000588 +
; 0.000000000000291. You'd better be sure you don't miss out
; a zero when you're working the problem through, or your
; answer will be off by a factor of 10. It's much easier 
; to have those numbers represented as 5.88 * 10-12 and
; 2.91* 10-13 (yes the second number had an extra zero - 
; did you spot that?). The same principle applies for very
; large numbers like 100000000 - it's just easier and less
; human error prone to keep the magnitudes seperated out when
; working with such numbers.
;
; It's the smallest of small steps to get from this form of
; number notation to proper scientific notation. The only
; difference is how the magnitude is written - in scientific
; notation we lose the magnitude's base and only write it's
; exponent part, thusly : 3.1725 E 2. The part that's left of
; the E, the 3.1725, is called the mantissa. The bit to the
; right of the E is the exponent.
;
; Mantissas and Exponents in Binary
;
; Let's go back to considering 317.25 in binary: 100111101.01.
; Using scientific notation, this is 1.0011110101 E 1000.
; Remember that both mantissa and exponent are written in
; binary that exponent value 1000 is a binary number, 8 in
; decimal.
;
; ════════════════════════════════════════════════════════════
; Why floating point?
;
; Consider the eternal problem of having a finite amount of
; computer memory. Not having infinate RAM means we cannot
; represent an infinite range of numbers. If we have eight
; bits of memory, we can represent the integers from 0 to 255
; only. If we have sixteen, we can raise our range from 0 to 
; 65535, and so on. The more bits we can play with, the larger
; the range of numbers we can represent. With fractional
; numbers there is a second problem : precision. Many
; fractions recur : eg one third in decimal is 0.33333
; recurring. Likewise, one tenth is 0.1 in decimal but
; 0.0001100110011 last four bits recurring in binary.
;
; So any method we choose for storing fractional numbers 
; has to take these two problems into consideration. Bearing 
; this in mind, consider the two possible approaches for 
; storing fractional numbers :
;
; Fixed point. Store the integer part in one field, and the
; fractional part in another field. It's called fixed point
; representation since the point (binary or decimal) is always
; in the same place - between the integer and fractional fields.
;
; Floating point. Store the mantissa in one field, and the
; exponent in another field. This way, the point wouldn't be
; fixed into place - it could be anywhere, as determined by 
; the binary exponent. It would, in fact be, a floating point.
; Why is floating point better than fixed point? Let's say we
; have 32 bits to play with. Let's use fixed point and assign
; 16 bits for the integer part and 16 for the fractional part.
; This allows a range of 0 to 65535.9999 or so, which isn't
; very good value, range-wise, for 32 bits. OK, lets increase
; the range - we'll change to using 20 bits for the integer
; and 12 for the fraction. This gives us a range of 0 to
; 1,048,575.999ish . Still not a huge range, and since
; we've only got 12 bits for the fraction we're losing
; precision - numbers stored this way will be rounded to
; the nearest 1/4096th.
;
; Now lets try floating point instead. Lets assign a whopping
; 24 bits for the mantissa and 8 bits for the exponent. 8 bits
; doesn't sound like much, but this is an exponent after all -
; with these 8 bits we get a range of -128 to +127 which is
; roughly 10-38 to to 1038. That's a nice big range! And we
; get 24 bits of precision too! It's clearly the better choice.
;
; Floating point is not a perfect solution though... adding a
; very small number to a very large number is likely to produce
; an erroneous result. For example, go to the BASIC emulator
; and try PRINT 10000+.1. You get 10000.1 as expected. Now
; try PRINT 10000+.01 or PRINT 100000+.1. See?
;
; ════════════════════════════════════════════════════════════
; Normalisation
; Normalisation is the process of shifting the mantissa until
; it is between 0.5 and 1 and adjusting the exponent to
; compensate. For example, these binary numbers are unnormalised:
;
;101.001
;0.0001
;0.011 E 101
;After normalisation these same binary numbers become :
;
;0.101001 E 11
;0.1 E -11
;0.11 E 100
;blah
;
; ════════════════════════════════════════════════════════════
;How Altair BASIC stored floating point numbers
;There was no industry standard for floating-point number representation back in 1975, so Monte had to roll his own. He decided that 32 bits would allow an adequate range, and defined his floating-point number format like this :
;
;Floating-point number representation in Altair BASIC
;
;The 8-bit exponent field had a bias of 128. This just meant that the stored exponent was stored as 'exponent+128'.
;
;Also, the mantissa was really 24 bits long, but squeezed into 23 bits. How did he save an extra bit of precision? By considering zero as a special case, indicated by exponent zero. Any non-zero number will always have a mantissa with a leading 1. And since the first bit is always going to be 1, why bother storing it?
;
;The intermediate storage of unpacked fp numbers is undefined and seems to be generally done on the fly.
;
;fixme: put example of normalising and denormalising.
;
;
;============================================================================


; 2.1 Вспомогательные функции

; Три небольшая вспомогательная функция

; FAddOneHalf
; Добаляет 0.5 к FACCUM.

FAddOneHalf:
	LD      HL,ONE_HALF

; FAddFromMrm
; Добавляет число из (HL) к FACCUM
FAddFromMem:
	CALL    FLoadBCDEfromMem
        JP      FAddBCDE

; FSubFromMrm
; Вычитает число из (HL) из FACCUM
FSubFromMem:
	CALL    FLoadBCDEfromMem
        DB	21h			;LD      HL,...
	
	CHK	107dh, "Сдвижка кода"

; 2.2 Сложение и вычитание

FSub:
	POP	BC			; Get lhs in BCDE.
	POP	DE
FSubBCDE:
	CALL    FNegate			; Negate rhs and slimily 
FAddBCDE:
;Special cases for when lhs or rhs are zero.
	LD      A,B			; If lhs==0 then we don't need
        OR      A			; to do anything and can just
        RET     Z			; exit.

        LD      A,(FACCUM+3)		; If rhs==0 then exit via a copy 
        OR      A			; of lhs to FACCUM.
        JP      Z,FLoadFromBCDE
; Get exponents' difference into A.
        SUB     B			; A=rhs.exponent-lhs.exponent.
        JP      NC,L109C		; If rhs' exponent >= lhs'exponent, jump ahead.
; Swap lhs and rhs if lhs exponent was more than rhs exponent.
        CPL				; Two's complement the exponent 
        INC     A			; Two's complement the exponent 
        EX      DE,HL
        CALL    FPush			; Push old rhs
        EX      DE,HL
        CALL    FLoadFromBCDE		; rhs = old lhs
        POP     BC			; lhs = old rhs.
        POP     DE
L109C:  CP      19H
        RET     NC
; Unpack the mantissas. This loses the signs of both numbers, but we do get back their relationship : the call to FUnpackMantissas leaves A +ve if the signs mismatched, or -ve if the signs were equal.
        PUSH    AF			; Preserve exponent diff
        CALL    FUnpackMantissas
        LD      H,A			; H=sign relationship
        POP     AF			; A=exponent diff.
; Align lhs with rhs.
        CALL    FMantissaRtMult		; Shift lhs mantissa right by (exponent diff) places.
; Decide whether to add or subtract the mantissas. We subtract if the signs were mismatched.
        OR      H			; A=0 after last call, so this tests
        LD      HL,FACCUM		; the sign relationship.
        JP      P,FSubMantissas		; Jump ahead if we need to subtract.
; Add the mantissas.
        CALL    FAddMantissas
        JP      NC,FRoundUp		; Jump ahead if that didn't overflow.
        INC     HL			; Flip the sign in FTEMP_SIGN.
        INC     (HL)
        JP      Z,Overflow		; Error out if exponent overflowed.
        LD      L,01H			
        CALL    L115F			; Shift mantissa one place right
        JP      FRoundUp		; Jump ahead.

;Subtract lhs mantissa from rhs mantissa.	
FSubMantissas:
	XOR     A			; B=0-B
        SUB     B
        LD      B,A
        LD      A,(HL)			; E=(FACCUM)-E
        SBC     A,E
        LD      E,A
        INC     HL
        LD      A,(HL)			; D=(FACCUM+1)-D
        SBC     A,D
        LD      D,A
        INC     HL
        LD      A,(HL)			; C=(FACCUM+2)-C
        SBC     A,C
        LD      C,A

;Fall into FNormalise

; 2.3 Mantissa Magic
; A group of functions for manipulating mantissas.
;
; 
;
;FNormalise
;Result mantissa in CDEB is normalised, rounded up to CDE, and stored in FACCUM.
;
;If carry set then negate the mantissa. Most users of this function call over this step.	

FNormalise:
	CALL    C,FNegateInt
FNormalise3:
	LD      L,B
        LD      H,E
        XOR     A
NormLoop:
	LD      B,A
        LD      A,C			; Test most-significant bit of mantissa
        OR      A			; and jump ahead if it's 1.
        JP      NZ,L10F5
        LD      C,D
        LD      D,H
        LD      H,L
        LD      L,A
        LD      A,B
        SUB     08H
        CP      0E0H			; If we've shifted 32 times, then the number is 0.
        JP      NZ,NormLoop

;FZero
;
;Sets FACCUM to zero. Zero is stored in a slightly special way : the exponent is zero'ed without bias.

FZero:  XOR     A			;
L10E9:  LD      (FACCUM+3),A
        RET     

L10ED:  DEC     B
        ADD     HL,HL
        LD      A,D
        RLA     
        LD      D,A
        LD      A,C
        ADC     A,A
        LD      C,A
L10F5:  JP      P,L10ED
        LD      A,B
        LD      E,H
        LD      B,L
        OR      A
        JP      Z,FRoundUp
        LD      HL,FACCUM+3
        ADD     A,(HL)
        LD      (HL),A
        JP      NC,FZero
        RET     Z

;Round up the extra mantissa byte.

FRoundUp:
	LD      A,B			; A=extra mantissa byte
L1109:  LD      HL,FACCUM+3
        OR      A			; If bit 7 of the extra mantissa byte
        CALL    M,FMantissaInc		; is set, then round up the mantissa.
;Set the sign and exit. The XRA C is interesting : remember that bit 7 of C is the most significant bit of the normalised mantissa, which is invariably 1. Also, we need to use this bit for the sign. Well, in FUnpackMantissas the temporary sign in FTEMP_SIGN was inverted, so an XOR with 1 will get back the correct sign.
        LD      B,(HL)			; B=exponent
        INC     HL
        LD      A,(HL)			; A=FTEMP_SIGN
        AND     80H
        XOR     C			; Bit 7 of C is always 1. Thi
        LD      C,A
        JP      FLoadFromBCDE		; Exit via copying BCDE to FACCUM.

;FMantissaInc
;Increments the mantissa in CDE and handles overflow.
FMantissaInc:
	INC     E
        RET     NZ

        INC     D
        RET     NZ

        INC     C
        RET     NZ

        LD      C,80H
        INC     (HL)
        RET     NZ

Overflow:
	LD      E,ERR_OV
        JP      Error

;FAddMantissas
;Adds the mantissa pointed to by HL to the one in CDE.

FAddMantissas:
	LD      A,(HL)
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

;FNegateInt
;Negate the 32-bit integer in CDEB by subtracting it from zero. Also flips the sign in FTEMP. Used by FAsInteger and FAdd.

FNegateInt:
	LD      HL,FTEMP
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

;FMantissaRtMult
;Shifts the mantissa in CDE right by A places. Note that lost bits end up in B, general practice so we can round up from something later should we need to.

FMantissaRtMult:
	LD      B,00H			;Initialise extra mantissa byte
L114B:  SUB     08H
        JP      C,L1158
        LD      B,E
        LD      E,D
        LD      D,C
        LD      C,00H
        JP      L114B
L1158:  ADD     A,09H
        LD      L,A
RtMultLoop:
	XOR     A
        DEC     L
        RET     Z

FMantissaRtOnce:
        LD      A,C
L115F:  RRA     
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
        JP      RtMultLoop

L116D:  NOP     
        NOP     
        NOP     
        ADD     A,C
L1171:        INC     BC
        XOR     D
        LD      D,(HL)
        ADD     HL,DE
        ADD     A,B
        POP     AF
        LD      (8076H),HL
        LD      B,L
        XOR     D
        db	38h, 82h
	CHK	117eh, "Сдвижка кода"
Log:
L117E:  RST     FTestSign
        JP      PE,FunctionCallError
        LD      HL,FACCUM+3
        LD      A,(HL)
        LD      BC,8035H
        LD      DE,04F3H
        SUB     B
        PUSH    AF
        LD      (HL),B
        PUSH    DE
        PUSH    BC
        CALL    FAddBCDE
        POP     BC
        POP     DE
        INC     B
        CALL    L121A
        LD      HL,L116D
        CALL    FSubFromMem
        LD      HL,L1171
        CALL    L15FA
        LD      BC,8080H
        LD      DE,0000H
        CALL    FAddBCDE
        POP     AF
        CALL    AddDigit
L11B3:  LD      BC,8031H
        LD      DE,7218H
        DB	21h		;LD      HL,...

;2.4 Multiplication & Division
;blah
;
; 
;
;FMul
;Multiplying two floating point numbers is theoretically simple. All we have to do is add the exponents, multiply the mantissas, and normalise the result. The only problem is that the 8080 didn't have a MUL instruction. Therefore the fundamental logic of multiplication (shift and add) is done by hand in this function. FMul's logic read something like this :
;
;Get lhs and rhs. Exit if rhs=0.
;Add lhs and rhs exponents
;Initialise result mantissa to 0.
;Get rightmost bit of rhs.
;If this bit is set then add the lhs mantissa to the result mantissa.
;Shift result mantissa right one bit.
;Get next bit of rhs mantissa. If not done all 24 bits, loop back to 5.
;Jump to FNormalise
;Alternatively, here's some C++ pseudo-code :
;
;float FMul(float lhs, float rhs)
;{
;  float result = 0;
;  for (int bit=0 ; bit<24 ; bit++) {
;    if (lhs.mantissa & (2^bit)) {
;      result.mantissa += rhs.mantissa;
;    }
;    result.mantissa>>=1;
;  }
;  return FNormalise(result);
;}
;
;(fixme: Show why this works)
	CHK	11BAh, "Сдвижка кода"
FMul:					
	POP	BC			; Get lhs in BCDE
	POP	DE
FMul2:	RST     FTestSign		; If rhs==0 then exit
        RET     Z
;Add the exponents. 
        LD      L,00H			; L=0 to signify exponent add
        CALL    FExponentAdd
;Store the lhs mantissa in the operands for FMulInnerLoop
        LD      A,C
        LD      (L11F3),A
        EX      DE,HL
        LD      (L11EE),HL
;Initialise result mantissa CDEB to 0.
        LD      BC,0000H
        LD      D,B
        LD      E,B
        LD      HL,FNormalise3
        PUSH    HL
        LD      HL,FMulOuterLoop
        PUSH    HL
        PUSH    HL
        LD      HL,FACCUM
FMulOuterLoop:
	LD      A,(HL)
        INC     HL
        OR      A
        JP      Z,L1207
        PUSH    HL
        EX      DE,HL
        LD      E,08H
FMulInnerLoop:
	RRA     
        LD      D,A
        LD      A,C
        JP      NC,L11F4
        PUSH    DE
L11EE:	EQU	$+1
        LD      DE,0000H	; <-- самомодифицирующийся код
        ADD     HL,DE
        POP     DE
L11F3:	EQU	$+1
        ADC     A,00H		; <-- самомодифицирующийся код
L11F4:  RRA     
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
        JP      NZ,FMulInnerLoop
        EX      DE,HL
	
PopHLandReturn:
	POP     HL
        RET     

L1207:  LD      B,E
        LD      E,D
        LD      D,C
        LD      C,A
        RET     

; FDivByTen
; Деление FACCUM на 10. Used in FOut to bring the number into range before printing.
FDivByTen:
	CALL    FPush
        LD      BC,8420H		; BCDE=(float)10;
        LD      DE,0000H
        CALL    FLoadFromBCDE
	
	CHK	1218H, "Сдвижка кода"
FDiv:
;Get lhs into BCDE.
	POP     BC
        POP     DE
L121A:  RST     FTestSign
        JP      Z,DivideByZero
        LD      L,0FFH
        CALL    FExponentAdd
        INC     (HL)
        INC     (HL)
        DEC     HL
        LD      A,(HL)
        LD      (L1249),A
        DEC     HL
        LD      A,(HL)
        LD      (L1245),A
        DEC     HL
        LD      A,(HL)
        LD      (L1241),A
        LD      B,C
        EX      DE,HL
        XOR     A
        LD      C,A
        LD      D,A
        LD      E,A
        LD      (L124C),A
FDivLoop:
	PUSH    HL
        PUSH    BC
        LD      A,L
L1241:	EQU	$+1
        SUB     00H			; Самомодифицирующийся код
        LD      L,A
        LD      A,H
L1245:	EQU	$+1
        SBC     A,00H			; Самомодифицирующийся код
        LD      H,A
        LD      A,B
L1249:	EQU	$+1
        SBC     A,00H			; Самомодифицирующийся код
        LD      B,A
L124C:	EQU	$+1
        LD      A,00H			; Самомодифицирующийся код
        SBC     A,00H
        CCF     
        JP      NC,L125A
        LD      (L124C),A
        POP     AF
        POP     AF
        SCF     
        DB	0D2H	;JP      NC,...
L125A:	POP	BC
	POP	HL
        LD      A,C
        INC     A
        DEC     A
        RRA     
        JP      M,L1109
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
        LD      A,(L124C)
        RLA     
        LD      (L124C),A
        LD      A,C
        OR      D
        OR      E
        JP      NZ,FDivLoop
        PUSH    HL
        LD      HL,FACCUM+3
        DEC     (HL)
        POP     HL
        JP      NZ,FDivLoop
        JP      Overflow
;FExponentAdd
;Here is code common to FMul and FDiv and is called by both of them. It's main job is to add (for FMul) or subtract (for FDiv) the binary exponents of the lhs and rhs arguments, for which on entry L=0 for addition or L=FF respectively.
;
;If BCDE is 0, then we don't need to do anything and can jump to the function exit.	
FExponentAdd:
	LD      A,B
        OR      A
        JP      Z,L12AC
        LD      A,L
        LD      HL,FACCUM+3
        XOR     (HL)
        ADD     A,B
        LD      B,A
        RRA     
        XOR     B
        LD      A,B
        JP      P,L12AB
        ADD     A,80H
        LD      (HL),A
        JP      Z,PopHLandReturn
        CALL    FUnpackMantissas
        LD      (HL),A
        DEC     HL
        RET     

L12A8:  RST     FTestSign
        CPL     
        POP     HL
L12AB:  OR      A
L12AC:  POP     HL
        JP      P,FZero
        JP      Overflow

;Multiplies FACCUM by 10. Seems to be here for speed reasons, since this could be done very simply with a call to FMul.
;
;Copy FACCUM to BCDE and return if it's 0.
FMulByTen:
	CALL    FCopyToBCDE
        LD      A,B
        OR      A
        RET     Z

        ADD     A,02H
        JP      C,Overflow
        LD      B,A
        CALL    FAddBCDE
        LD      HL,FACCUM+3
        INC     (HL)
        RET     NZ

        JP      Overflow

;2.5 Sign Magic

;A group of functions for testing and changing the sign of an fp number.

;FTestSign_tail
;When FACCUM is non-zero, RST FTestSign jumps here to get the sign as an integer : 0x01 for positive, 0xFF for negative.
	CHK	12cah, "Сдвижка кода"

FTestSign_tail:
	LD	A,(FACCUM+2)
	DB	0FEH	;CP	2FH

;InvSignToInt
;Inverts the sign byte in A before falling into SigntoInt.
;
;Simply invert A.
InvSignToInt:
	CPL

;SignToInt
;Converts the sign byte in A to 0x01 for positive, 0xFF for negative.


;Get bit 7 into carry flag and subtract from itself with carry. If A was +ve then it is now 0, whereas if A was -ve then A is now FF.
        RLA     
L12D0:  SBC     A,A
        RET     NZ

        INC     A
        RET     

;Sgn
;Returns an integer that indicates FACCUM's sign. We do this by a simple call to FTestSign which gets the answer in A, then fall into FCharToFloat to get that answer back into FACCUM.
;
;Get FACCUM's sign in A. A will be 0x01 for positive, 0 for zero, and 0xFF for negative.
	CHK	12D4H, "Сдвижка кода"

Sgn:	RST     FTestSign

;FCharToFloat
;Converts the signed byte in A to a floating-point number in FACCUM..

FCharToFloat:
	LD      B,88H
        LD      DE,0000H
L12DA:  LD      HL,FACCUM+3
        LD      C,A
        LD      (HL),B
        LD      B,00H
        INC     HL
        LD      (HL),80H
        RLA     
        JP      FNormalise

;Abs
;FACCUM = |FACCUM|.
;
;Return if FACCUM is already positive, otherwise fall into FNegate to make it positive.
	CHK	12e8h, "Сдвижка кода"
Abs:
        RST     FTestSign
        RET     P

FNegate:
	LD      HL,FACCUM+2	;024FH
        LD      A,(HL)
        XOR     80H
        LD      (HL),A
        RET     

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
	
;FCopyToBCDE and FLoadBCDE

FCopyToBCDE:
	LD      HL,FACCUM

FLoadBCDEfromMem:
	LD      E,(HL)
        INC     HL
        LD      D,(HL)
        INC     HL
        LD      C,(HL)
        INC     HL
        LD      B,(HL)
L1317:  INC     HL
        RET     

;FCopyToMem
;Copies FACCUM to another place in memory pointed to by HL.
FCopyToMem:
	LD      DE,FACCUM
L131C:  LD      B,04H
FCopyLoop:
	LD      A,(DE)
        LD      (HL),A
        INC     DE
        INC     HL
        DEC     B
        JP      NZ,FCopyLoop
        RET     

;2.7 Unpacking & Comparison
;Two functions : the first is for unpacking the mantissas of two floating-point numbers, the second is for comparing two floating-point numbers.
;
; 
;FUnpackMantissas
;Unpacks the mantissas of FACCUM and BCDE. This is simple enough - we just restore the missing most-significant bit, invariably a 1 (see tech note). Unfortunately, doing this loses the sign bits of both packed numbers.
;
;To compensate for this, a combination of both signs is returned. Duing the function FACC's sign is negated and later xor'ed with BCDE's sign, and returned in bit 7 of A. The effect of this is when the function returns, A is +ve if the signs mismatched, or -ve if the signs matched.
;
;FACC	Negated
;FACC	BCDE	Result
;after XOR
;+	-	+	-
;+	-	-	+
;-	+	+	+
;-	+	-	-


FUnpackMantissas:
	LD      HL,FACCUM+2
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

;FCompare
;Compares FACCUM to BCDE, with the result being returned in A as follows :

;FACCUM > BCDE, A = 0x01.
;FACCUM < BCDE, A = 0xFF.
;FACCUM = BCDE, A = 0.

;If BCDE is zero, then we don't need to compare and can just return via FTestSign.
FCompare:
	LD      A,B
        OR      A
        JP      Z, FTestSign
        LD      HL,InvSignToInt
        PUSH    HL
        RST     FTestSign
        LD      A,C
        RET     Z

        LD      HL,FACCUM+2
        XOR     (HL)
        LD      A,C
        RET     M

        CALL    FIsEqual
        RRA     
        XOR     C
        RET     

;Test for equality between BCDE and FACCUM.
FIsEqual:
	INC     HL
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

;2.8 Converting to Integer
;blah
;
; 
;FAsInteger
;Returns the integer part of FACCUM in CDE.
;
;Return with BCDE=0 if A=0.
FAsInteger:
	LD      B,A
        LD      C,A
        LD      D,A
        LD      E,A
        OR      A
        RET     Z

        PUSH    HL
        CALL    FCopyToBCDE
        CALL    FUnpackMantissas
        XOR     (HL)
        LD      H,A
        CALL    M,FMantissaDec
        LD      A,98H
        SUB     B
        CALL    FMantissaRtMult
        LD      A,H
        RLA     
        CALL    C,FMantissaInc
        LD      B,00H
        CALL    C,FNegateInt
        POP     HL
        RET     


FMantissaDec:
	DEC     DE
        LD      A,D
        AND     E
        INC     A
        RET     NZ

        DEC     C
        RET     

;Int
;Removes the fractional part of FACCUM.

;If FACCUM's exponent is >= 2^24, then it's too big to hold any fractional part - it is already an integer, so we just return.

	CHK	1392h, "Сдвижка кода"
Int:
	LD      HL,FACCUM+3
        LD      A,(HL)
        CP      98H
        LD      A,(FACCUM)
        RET     NC

        LD      A,(HL)
        CALL    FAsInteger
        LD      (HL),98H
        LD      A,E
        PUSH    AF
        LD      A,C
        RLA     
        CALL    FNormalise
        POP     AF
        RET     

L13AB:  LD      HL,0000H
        LD      A,B
        OR      C
        RET     Z

        LD      A,10H
L13B3:  ADD     HL,HL
        JP      C,L0BEE
        EX      DE,HL
        ADD     HL,HL
        EX      DE,HL
        JP      NC,L13C1
        ADD     HL,BC
        JP      C,L0BEE
L13C1:  DEC     A
        JP      NZ,L13B3
        RET     

;2.9 Reading Numbers
;Function that reads a floating-point number from ASCII text.

;FIn
;Reads a string and converts it to a floating point number in FACCUM.
;The first thing we do is some initialisation.
;
;Все регистры портятся
;
;На входе HL содержит указатель на строку.
;A содержит копию первого символа.
;C = 255 если точка не обнаружена, 0 если да
;B = число цифр после точки
;E = экспонента

FIn:	CP      '-'		; '-'
        PUSH    AF		; Сохраняем знак в стеке
        JP      Z,SkipSign
        CP      '+'		; '+'
        JP      Z,SkipSign
;Decrement string ptr so it points to just before the number, also set FACCUM to 0.
        DEC     HL
SkipSign:
	CALL    FZero
        LD      B,A
        LD      D,A
        LD      E,A
        CPL     		; C=decimal_point_done (0xFF for no, 0x00 for yes)
        LD      C,A

;This is the head of the loop that processes one character of ASCII text at a time.
;
;Get next ASCII character and if it's a digit (as determined by carry flag) then jump down to ProcessDigit.
FInLoop:
	RST     NextChar
        JP      C,ProcessDigit
        CP      '.'		; '.'
        JP      Z,PointFound
        CP      'E'		; 'E'
        JP      NZ,ScaleResult
        RST     NextChar
        PUSH    HL
        LD      HL,NextExponentDigit
        EX      (SP),HL
        DEC     D
        CP      TK_MINUS		; '-'
        RET     Z		; JP NextExponentDigit

        CP      '-'		; '-'
        RET     Z		; JP NextExponentDigit

        INC     D
        CP      '+'		; '+'
        RET     Z		; JP NextExponentDigit

        CP      TK_PLUS		; '+'
        RET     Z		; JP NextExponentDigit

        POP     AF
        DEC     HL
NextExponentDigit:
	RST     NextChar
        JP      C,DoExponentDigit
        INC     D
        JP      NZ,ScaleResult
        XOR     A
        SUB     E
        LD      E,A
        INC     C
PointFound:
	INC     C
        JP      Z,FInLoop
ScaleResult:
	PUSH    HL
        LD      A,E
        SUB     B
DecimalLoop:
	CALL    P,DecimalShiftUp
        JP      P,DecimalLoopEnd
        PUSH    AF
        CALL    FDivByTen
        POP     AF
        INC     A
DecimalLoopEnd:
	JP      NZ,DecimalLoop
        POP     DE
        POP     AF
        CALL    Z,FNegate
        EX      DE,HL
        RET     

; Helper function for shifting the result decimally up one place. We only do this if A !=0, and at the end we decrement A before returning.

DecimalShiftUp:
	RET     Z
L1428:  PUSH    AF
        CALL    FMulByTen
        POP     AF
        DEC     A
        RET     

ProcessDigit:
	PUSH    DE
        LD      D,A
        LD      A,B
        ADC     A,C
        LD      B,A
        PUSH    BC
        PUSH    HL
        PUSH    DE
        CALL    FMulByTen
        POP     AF
        SUB     '0'
        CALL    AddDigit
        POP     HL
        POP     BC
        POP     DE
        JP      FInLoop
	
AddDigit:
	CALL    FPush
        CALL    FCharToFloat
	
	CHK	144ch, "Сдвижка кода"
FAdd:
;The lhs is on the stack, the rhs is in FACCUM. The steps for adding the two numbers are :
;
;    Handle special cases where either side is 0.
;    Denormalise mantissas.
;    Align the two numbers. fixme: give Monte's decimal example.
;    Add (or subtract) mantissas.
;    Normalise result and store in FACCUM. 
        POP     BC
        POP     DE
        JP      FAddBCDE
	
DoExponentDigit:
	LD      A,E
        RLCA    
        RLCA    
        ADD     A,E
        RLCA    
        ADD     A,(HL)
        SUB     '0'
        LD      E,A
        JP      NextExponentDigit
	
;2.10 Printing Numbers
;Functions for printing floating-point numbers.

;PrintIN
;Prints "IN " and falls into PrintInt. Used by the error handling code to print stuff like "?SN ERROR IN 50".
	
		
PrintIN:
	PUSH    HL
        LD      HL,szIn
        CALL    PrintString
        POP     HL
		
;PrintInt
;Promotes the integer in HL to a floating-point number in FACC, sets the return address to PrintSz-1, and falls into FOut.
;The promotion from integer to float is interesting : the integer starts off by occupying the least significant bits of the
;mantissa CDE. The exponent in B is set to 24 (because, thus giving us an unnormalised but perfectly valid floating-point
;number in no time at all! Took me a while to see that...

PrintInt:
	EX      DE,HL			; DE=integer
        XOR     A			; A=0 (ends up in C)
        LD      B,98H			; B (ie exponent) = 24
        CALL    L12DA
        LD      HL,PrintString1	;0D92H
        PUSH    HL
;FOut
;Prints a floating point number to the terminal.
;
;Set HL to FBUFFER, which is where FACCUM gets printed to.	
FOut:	LD      HL,FBUFFER
        PUSH    HL
        RST     FTestSign
        LD      (HL), ' '
        JP      P,L147C
        LD      (HL), '-'
L147C:  INC     HL
        LD      (HL), '0'
        JP      Z,L1525
        PUSH    HL
        CALL    M,FNegate
        XOR     A
        PUSH    AF
        CALL    ToUnder1000000
L148B:  LD      BC,9143H
        LD      DE,4FF8H
        CALL    FCompare
        JP      PO,L14A8
        POP     AF
        CALL    L1428
        PUSH    AF
        JP      L148B
L149F:  CALL    FDivByTen
        POP     AF
        INC     A
        PUSH    AF
        CALL    ToUnder1000000
L14A8:  CALL    FAddOneHalf
        INC     A
        CALL    FAsInteger
        CALL    FLoadFromBCDE
        LD      BC,0206H
        POP     AF
        ADD     A,C
        JP      M,L14C3
        CP      07H
        JP      NC,L14C3
        INC     A
        LD      B,A
        LD      A,01H
L14C3:  DEC     A
        POP     HL
        PUSH    AF
        LD      DE,DECIMAL_POWERS
L14C9:  DEC     B
        LD      (HL), '.'
        CALL    Z,L1317
        PUSH    BC
        PUSH    HL
        PUSH    DE
        CALL    FCopyToBCDE
        POP     HL
        LD      B,'0'-1
L14D8:  INC     B
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
        JP      NC,L14D8
        CALL    FAddMantissas
        INC     HL
        CALL    FLoadFromBCDE
        EX      DE,HL
        POP     HL
        LD      (HL),B
        INC     HL
        POP     BC
        DEC     C
        JP      NZ,L14C9
        DEC     B
        JP      Z,L1509
L14FD:  DEC     HL
        LD      A,(HL)
        CP      '0'
        JP      Z,L14FD
        CP      '.'
        CALL    NZ,L1317
L1509:  POP     AF
        JP      Z,L1528
        LD      (HL),'E'
        INC     HL
        LD      (HL),'+'
        JP      P,L1519
        LD      (HL),'-'
        CPL     
        INC     A
L1519:  LD      B,'0'-1
L151B:  INC     B
        SUB     0AH
        JP      NC,L151B
        ADD     A,3AH
        INC     HL
        LD      (HL),B
L1525:  INC     HL
        LD      (HL),A
        INC     HL
L1528:  LD      (HL),C
        POP     HL
        RET     

;ToUnder1,000,000
;Divides FACCUM by ten until it's less than 1,000,000. This function is semi-recursive... if it needs to recurse (ie

ToUnder1000000:
	LD      BC,9474H
        LD      DE,23F7H
        CALL    FCompare
        POP     HL
        JP      PO,L149F
        JP      (HL)

ONE_HALF:
        DB 0,0,0,80h		;Constant value 0.5, used by FRoundUp

;DECIMAL_POWERS
;Table of powers of ten.

DECIMAL_POWERS:
	DB	0A0h, 86h, 01h		;DD 100000
	DB	010h, 27h, 00h        	;DD 10000
	DB	0E8h, 03h, 00h        	;DD 1000
	DB	064h, 00h, 00h        	;DD 100
	DB	00Ah, 00h, 00h        	;DD 10
	DB	001h, 00h, 00h        	;DD 1
	
	
L154F:  LD      HL,FNegate
        EX      (SP),HL
        JP      (HL)
	
	CHK	1554h, "Сдвижка кода"
Sqr:
        CALL    FPush
        LD      HL,1539H
        CALL    FLoadFromMem

	CHK	155dh, "Сдвижка кода"
FPower:
        POP     BC
        POP     DE
        RST     FTestSign
        JP      Z,L1599
        LD      A,B
        OR      A
        JP      Z,L10E9
        PUSH    DE
        PUSH    BC
        LD      A,C
        OR      7FH
        CALL    FCopyToBCDE
        JP      P,L1581
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
L1581:  POP     HL
        LD      (FACCUM+2),HL
        POP     HL
        LD      (FACCUM),HL
        CALL    C,L154F
        CALL    Z,FNegate
        PUSH    DE
        PUSH    BC
        CALL    L117E
        POP     BC
        POP     DE
        CALL    FMul2
	
	CHK	1599h, "Сдвижка кода"
Exp:
L1599:  CALL    FPush
        LD      BC,8138H
        LD      DE,0AA3BH
        CALL    FMul2
        LD      A,(FACCUM+3)
        CP      88H
        JP      NC,L12A8
        CALL    Int
        ADD     A,80H
        ADD     A,02H
        JP      C,L12A8
        PUSH    AF
        LD      HL,L116D
        CALL    FAddFromMem
        CALL    L11B3
        POP     AF
        POP     BC
        POP     DE
        PUSH    AF
        CALL    FSubBCDE
        CALL    FNegate
        LD      HL,L15D9
        CALL    L1609
        LD      DE,0000H
        POP     BC
        LD      C,D
        JP      FMul2
	
L15D9:	DB	08h
        LD      B,B
        LD      L,94H
        LD      (HL),H
        LD      (HL),B
        LD      C,A
        LD      L,77H
        LD      L,(HL)
        LD      (BC),A
        ADC     A,B
        LD      A,D
        AND     0A0H
        LD      HL,(507CH)
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
	CHK	15fah, "Сдвижка кода"
L15FA:  CALL    FPush
        LD      DE, FMul	;  11BAH
        PUSH    DE
        PUSH    HL
        CALL    FCopyToBCDE
        CALL    FMul2
        POP     HL
L1609:  CALL    FPush
        LD      A,(HL)
        INC     HL
        CALL    FLoadFromMem
        DB	06h		; LD      B,..
L1612:	POP	AF
        POP     BC
        POP     DE
        DEC     A
        RET     Z

        PUSH    DE
        PUSH    BC
        PUSH    AF
        PUSH    HL
        CALL    FMul2
        POP     HL
        CALL    FLoadBCDEfromMem
        PUSH    HL
        CALL    FAddBCDE
        POP     HL
        JP      L1612

;Rnd
;Generates a random number. This is a bit odd... like all inline functions it takes a numeric argument, but in RNDs case this argument is mostly ignored. If it's a negative number it skips a couple of stages of reseeding RND_SEED.

	CHK	162ah, "Сдвижка кода"
Rnd:
;If tghe argument in FACCUM is negative, then skip over the
	RST     FTestSign
        JP      M,L1647
;Load the seed into FACCUM.
        LD      HL,RND_SEED
        CALL    FLoadFromMem
        RET     Z
;Multiply seed by 11,879,546.
        LD      BC,9835H
        LD      DE,447AH
        CALL    FMul2
;Add 0.00000003927678
        LD      BC,6828H
        LD      DE,0B146H
        CALL    FAddBCDE
;Swap first and third mantissa bytes.
L1647:  CALL    FCopyToBCDE
        LD      A,E
        LD      E,C
        LD      C,A
;Set FTEMP_SIGN to 0x80 to indicate to FNormalise that it doesn't need to change the sign. Also set FACCUM's exponent to 0 so the result, when normalised, will be less than 1.        
	LD      (HL),80H
        DEC     HL
        LD      B,(HL)
        LD      (HL),80H
        CALL    FNormalise3
;Exit via a copy of the result to RND_SEED so it can be used for the next time RND is called.
        LD      HL,RND_SEED
        JP      FCopyToMem

;Seed for random number generation.
RND_SEED:	
	DB 052H, 0C7H, 04FH, 080H	; 0.811635
	
	CHK	1660H, "Сдвижка кода"
Cos:
	LD      HL,PI2
        CALL    FAddFromMem
	CHK	1666h, "Сдвижка кода"

;Divide x (in FACCUM) by 2p to get u. 

Sin:
	CALL    FPush
        LD      BC,8349H		; 2*PI
        LD      DE,0FDBH
        CALL    FLoadFromBCDE
        POP     BC
        POP     DE
        CALL    L121A
;Lose the integer part of u.
        CALL    FPush
        CALL    Int
        POP     BC
        POP     DE
        CALL    FSubBCDE
        LD      HL,C14
        CALL    FSubFromMem
        RST     FTestSign
        SCF     
        JP      P,NegateIfPositive
        CALL    FAddOneHalf
        RST     FTestSign
        OR      A

NegateIfPositive:
	PUSH    AF
        CALL    P,FNegate
        LD      HL,C14
        CALL    FAddFromMem
        POP     AF
        CALL    NC,FNegate
        LD      HL,SINETAB
        JP      L15FA

PI2:	DB	0DBH, 00FH, 049H, 081H	; PI/2
C14:	DB	0, 0, 0, 07FH		; 1/4
SINETAB:
        DB	5
TAYLOR_SERIES:
	DB	0BAH, 0D7H, 01EH, 086H	; 39.710670
	DB	064H, 026H, 099H, 087H	; -76.574982
	DB	058H, 034H, 023H, 087H	; 81.602234
	DB	0E0H, 05DH, 0A5H, 086H	; -41.341675
	DB	0DAH, 00FH, 049H, 083H	; 6.283185

	CHK	16c3h, "Сдвижка кода"
Tan:
        CALL    FPush
        CALL    Sin
        POP     BC
        POP     HL
        CALL    FPush
        EX      DE,HL
        CALL    FLoadFromBCDE
        CALL    Cos
        JP      FDiv

	CHK	16D8h, "Сдвижка кода"
Atn:
        RST     FTestSign
        CALL    M,L154F
        CALL    M,FNegate
        LD      A,(FACCUM+3)
        CP      81H
        JP      C,L16F3
        LD      BC,8100H
        LD      D,C
        LD      E,C
        CALL    L121A
        LD      HL,FSubFromMem
        PUSH    HL
L16F3:  LD      HL,ATNTAB
        CALL    L15FA
        LD      HL,PI2
        RET     

ATNTAB:
	DB	09H

	DB	04AH, 0D7H, 03BH, 078H			; .002866226
	DB	002H, 06EH, 084H, 07BH			; -.01616574
	DB	0FEH, 0C1H, 02FH, 07CH			; .04290961
	DB	074H, 031H, 09AH, 07DH			; -.07528964
	DB	084H, 03DH, 05AH, 07DH			; .1065626
	DB	0C8H, 07FH, 091H, 07EH			; -.142089
	DB	0E4H, 0BBH, 04CH, 07EH			; .1999355
	DB	06CH, 0AAH, 0AAH, 07FH			; -.3333315
	DB	000H, 000H, 000H, 081H			; 1.0

        NOP     
        NOP     
