	CPU	8080
	Z80SYNTAX	EXCLUSIVE

	ORG	2800H

Stack	EQU	$+0f0h
        ld      sp,Stack
        ld      hl,szHello
        call    0f818h
        ld      hl,0000h
        ld      de,Sums
CalcSumBlock:
	xor     a
CalcSumLoop:
	add     a,(hl)
        inc     hl
        ld      b,a
        ld      a,l
        or      a
        ld      a,b
        jp      nz,CalcSumLoop
        ld      a,(de)
        cp      b
        call    nz,SumError
        inc     de
        ld      a,h
        cp      19h
        jp      nz,CalcSumBlock
        ld      hl,szEnd
        call    0f818h
        call    0f803h
        jp      0f800h

SumError:
	push    hl
        ld      hl,szError
        call    0f818h
        pop     hl
        push    hl
        push    de
        dec     h
        ld      a,h
        call    0f815h
        pop     de
        pop     hl
        ret

szHello:
	DB	01FH, "*mikro/80* programma prowerki", 0dh,0ah, 0
szEnd:
	DB	0dh, 0ah, "konec raboty.", 0dh,0ah
	DB	"dlq wozwrata w monitor navmite l`bu` klawi{u.", 0
szError:
	DB	0dh,0ah, "o{ibka w bloke - ",0

Sums:	DB	095h, 03Ah, 014h, 04Bh, 058h, 061h, 0E4h
	DB	090h, 038h, 0D6h, 0F4h, 06Ah, 074h, 0CBh
	DB	033h, 093h, 065h, 070h, 0BFh, 0D6h, 0A2h
	DB	0B4h, 03Dh, 01Ah, 06Ah
