	CPU	8080
	Z80SYNTAX	EXCLUSIVE

        ORG     0000h

L0000:  LD      SP,75FFh
        JP      L1600

L0006:  NOP
        NOP
        LD      A,(HL)
        EX      (SP),HL
        CP      (HL)
        INC     HL
        EX      (SP),HL
        JP      NZ,L009B
        INC     HL
        LD      A,(HL)
        CP      3Ah             ; ':'
        RET     NC
        JP      L048B

L0018:  PUSH    BC
        PUSH    HL
        PUSH    AF
        LD      C,A
        JP      L0367

L001F:  NOP
        LD      A,H
        SUB     D
        RET     NZ
        LD      A,L
        SUB     E
        RET

L0026:  LD      BC,3A22h
        LD      D,B
        LD      HL,0C2B7h
        LD      L,(HL)
        LD      DE,4EC9h
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

        ; --- START PROC L0045 ---
L0045:  LD      HL,0004h
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
        RST     20H
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
L006C:  RST     20H
        LD      A,(HL)
        LD      (BC),A
        RET     Z
        DEC     BC
        DEC     HL
        JP      L006C

        ; --- START PROC L0075 ---
L0075:  EX      (SP),HL
        LD      C,(HL)
        INC     HL
        EX      (SP),HL
        ; --- START PROC L0079 ---
L0079:  PUSH    HL
        LD      HL,(2149h)
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
        RST     20H
        EX      DE,HL
        POP     DE
        RET     NC
L0090:  LD      E,0Ch
        JP      L00A7

L0095:  LD      HL,(2133h)
        LD      (213Bh),HL
        ; --- START PROC L009B ---
L009B:  LD      E,02h
        XOR     A
        LD      (2078h),A
L00A1:  LD      BC,141Eh
L00A4:  LD      BC,001Eh
        ; --- START PROC L00A7 ---
L00A7:  CALL    L01D6
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
        LD      HL,(213Bh)
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
        LD      (213Bh),HL
        LD      (2078h),HL
        ; --- START PROC L0100 ---
L0100:  XOR     A
        LD      (2117h),A
        LD      (2090h),A
        LD      (2063h),A
        CALL    L0279
        ; --- START PROC L010D ---
L010D:  CALL    L06DA
        ; --- START PROC L0110 ---
L0110:  RST     10H
        INC     A
        DEC     A
        JP      Z,L0100
        PUSH    AF
        CALL    L0519
        PUSH    DE
        CALL    L01F1
        LD      B,A
        POP     DE
        POP     AF
        JP      NC,L0461
        PUSH    DE
        PUSH    BC
        RST     10H
        PUSH    AF
        CALL    L0197
        PUSH    BC
        JP      NC,L0141
        EX      DE,HL
        LD      HL,(2145h)
L0133:  LD      A,(DE)
        LD      (BC),A
        INC     BC
        INC     DE
        RST     20H
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
        LD      DE,2090h
L0160:  LD      A,(DE)
        LD      (HL),A
        INC     HL
        INC     DE
        OR      A
        JP      NZ,L0160
        ; --- START PROC L0168 ---
L0168:  CALL    L01BB
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

        ; --- START PROC L0197 ---
L0197:  LD      HL,(2143h)
        ; --- START PROC L019A ---
L019A:  LD      B,H
        LD      C,L
        LD      A,(HL)
        INC     HL
        OR      (HL)
        DEC     HL
        RET     Z
        PUSH    BC
        RST     30H
        RST     30H
        POP     HL
        RST     20H
        POP     HL
        POP     BC
        CCF
        RET     Z
        CCF
        RET     NC
        JP      L019A

        ; --- START PROC L01AF ---
L01AF:  RET     NZ
        LD      HL,(2143h)
        XOR     A
        LD      (HL),A
        INC     HL
        LD      (HL),A
        INC     HL
        LD      (2145h),HL
        ; --- START PROC L01BB ---
L01BB:  LD      HL,(2143h)
        DEC     HL
        LD      (HL),00h
        ; --- START PROC L01C1 ---
L01C1:  LD      (2137h),HL
        LD      HL,(211Bh)
        LD      (212Fh),HL
        CALL    L04A5
        ; --- START PROC L01CD ---
L01CD:  LD      HL,(2145h)
        LD      (2147h),HL
        LD      (2149h),HL
        ; --- START PROC L01D6 ---
L01D6:  POP     BC
        LD      HL,(2141h)
        LD      SP,HL
        LD      HL,211Fh
        LD      (211Dh),HL
        LD      HL,0000h
        PUSH    HL
        LD      (213Fh),HL
        LD      HL,(2137h)
        XOR     A
        LD      (2135h),A
        PUSH    BC
        RET

        ; --- START PROC L01F1 ---
L01F1:  XOR     A
        ; --- START PROC L01F2 ---
L01F2:  LD      (211Ah),A
        LD      C,05h
        LD      DE,2090h
L01FA:  LD      A,(HL)
        CP      20h             ; ' '
        JP      Z,L023C
        LD      B,A
        CP      22h             ; '"'
        JP      Z,L025C
        OR      A
        JP      Z,L0270
        LD      A,(211Ah)
        OR      A
        LD      B,A
        LD      A,(HL)
        JP      NZ,L023C
        CP      30h             ; '0'
        JP      C,L021D
        CP      3Ch             ; '<'
        JP      C,L023C
L021D:  PUSH    DE
        LD      DE,1E06h
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
L024A:  LD      (211Ah),A
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
L0279:  LD      DE,2090h
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
L02A9:  LD      A,(2063h)
        INC     A
        RET     M
        LD      (2063h),A
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
        RST     20H
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
L02DF:  RST     20H
        RET     Z
        INC     HL
        JP      0F809h

        ; --- START PROC L02E5 ---
L02E5:  RST     20H
        RET     Z
        LD      A,(2063h)
        DEC     A
        RET     M
        LD      (2063h),A
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
        LD      HL,1E07h
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
        LD      A,(2063h)
        OR      A
        CALL    M,L06DF
        INC     A
        LD      (2063h),A
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
L0397:  CALL    L03B6
        RET     NZ
        POP     BC
        CALL    L0197
        LD      H,B
        LD      L,C
L03A1:  RST     30H
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
L03B6:  CALL    L0519
        RET     Z
        RST     08H
        INC     L
        PUSH    DE
        CALL    L0519
        POP     HL
        RET     NZ
        EX      DE,HL
        LD      A,H
        OR      L
        SCF
        RET     Z
        RST     20H
        JP      C,L009B
        XOR     A
        SCF
        LD      (2078h),HL
        RET

        ; --- START PROC L03D1 ---
L03D1:  RST     30H
        DEC     HL
        EX      (SP),HL
        EX      DE,HL
        LD      HL,(2078h)
        RST     20H
        POP     BC
        RET     C
        PUSH    BC
        CALL    L06DF
        JP      L163B

L03E2:  LD      A,64h           ; 'd'
        LD      (2135h),A
        CALL    L05C8
        EX      (SP),HL
        CALL    L0045
        POP     DE
        JP      NZ,L03F4
        ADD     HL,BC
        LD      SP,HL
L03F4:  EX      DE,HL
        CALL    L0075
        DB	08h
        PUSH    HL
        CALL    L05B1
        EX      (SP),HL
        PUSH    HL
        LD      HL,(213Bh)
        EX      (SP),HL
        CALL    L086C
        RST     08H
        SBC     A,(HL)
        CALL    L0869
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
        RST     10H
        CALL    L0869
        PUSH    HL
        CALL    L11B1
        POP     HL
        RST     28H
L0429:  PUSH    BC
        PUSH    DE
        PUSH    AF
        INC     SP
        PUSH    HL
        LD      HL,(2137h)
        EX      (SP),HL
        ; --- START PROC L0432 ---
L0432:  LD      B,81h
        PUSH    BC
        INC     SP
        ; --- START PROC L0436 ---
L0436:  CALL    L04AF
        LD      (2137h),HL
        LD      A,(HL)
        EX      DE,HL
        LD      HL,208Dh
        INC     (HL)
        OR      A
        JP      Z,L044F
        CP      3Ah             ; ':'
        JP      NZ,L009B
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
        LD      (213Bh),HL
        EX      DE,HL
        ; --- START PROC L0461 ---
L0461:  RST     10H
        LD      DE,0436h
        PUSH    DE
L0466:  RET     Z
L0467:  SUB     80h
        JP      C,L05C8
        CP      1Dh
        JP      C,L0478
        CP      4Ah             ; 'J'
        JP      C,L009B
        SUB     2Dh             ; '-'
L0478:  RLCA
        LD      C,A
        LD      B,00h
        EX      DE,HL
        LD      HL,1F4Ah
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

L0496:  JP      Z,L04A5
        CALL    L0519
        RET     NZ
        PUSH    HL
        CALL    L0582
        POP     DE
        JP      L04AA

        ; --- START PROC L04A5 ---
L04A5:  EX      DE,HL
        LD      HL,(2143h)
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
        RET     NZ
        OR      0C0h
        LD      (2137h),HL
        POP     BC
        ; --- START PROC L04C0 ---
L04C0:  PUSH    AF
        LD      HL,(213Bh)
        LD      A,L
        AND     H
        INC     A
        JP      Z,L04D3
        LD      (213Dh),HL
        LD      HL,(2137h)
        LD      (213Fh),HL
L04D3:  POP     AF
        LD      HL,1DD2h
        JP      NZ,L00CB
        JP      L00F1

L04DD:  RET     NZ
        LD      E,20h           ; ' '
        LD      HL,(213Fh)
        LD      A,H
        OR      L
        JP      Z,L00A7
        EX      DE,HL
        LD      HL,(213Dh)
        LD      (213Bh),HL
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
L04F9:  RST     10H
        ; --- START PROC L04FA ---
L04FA:  CALL    L0869
        ; --- START PROC L04FD ---
L04FD:  RST     28H
        JP      M,L0514
        ; --- START PROC L0501 ---
L0501:  LD      A,(2150h)
        CP      91h
        JP      C,L120B
        LD      BC,8001h
        LD      DE,0000h
        CALL    L11E0
        LD      D,C
        RET     Z
        ; --- START PROC L0514 ---
L0514:  LD      E,08h
        JP      L00A7

        ; --- START PROC L0519 ---
L0519:  DEC     HL
        ; --- START PROC L051A ---
L051A:  LD      DE,0000h
L051D:  RST     10H
        RET     NC
        PUSH    HL
        PUSH    AF
        LD      HL,1998h
        RST     20H
        JP      C,L009B
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

L053A:  JP      Z,L01C1
        CALL    L04FA
        DEC     HL
        RST     10H
        RET     NZ
        PUSH    HL
        LD      HL,(211Bh)
        LD      A,L
        SUB     E
        LD      E,A
        LD      A,H
        SBC     A,D
        LD      D,A
        JP      C,L009B
        LD      HL,(2145h)
        LD      BC,0028h
        ADD     HL,BC
        RST     20H
        JP      NC,L0090
        EX      DE,HL
        LD      (2141h),HL
        POP     HL
        JP      L01C1

L0563:  JP      Z,L01BB
        CALL    L01C1
        LD      BC,0436h
        JP      L057E

L056F:  CALL    L0075
        INC     BC
        POP     BC
        PUSH    HL
        PUSH    HL
        LD      HL,(213Bh)
        EX      (SP),HL
        LD      D,8Ch
        PUSH    DE
        INC     SP
L057E:  PUSH    BC
L057F:  CALL    L0519
        ; --- START PROC L0582 ---
L0582:  CALL    L05B1+2         ; reference not aligned to instruction
        PUSH    HL
        LD      HL,(213Bh)
        RST     20H
        POP     HL
        INC     HL
        CALL    C,L019A
        CALL    NC,L0197
        LD      H,B
        LD      L,C
        DEC     HL
        RET     C
        LD      E,0Eh
        JP      L00A7

L059B:  RET     NZ
        LD      D,0FFh
        CALL    L0045
        LD      SP,HL
        CP      8Ch
        LD      E,04h
        JP      NZ,L00A7
        POP     HL
        LD      (213Bh),HL
        LD      HL,0436h
        EX      (SP),HL
        ; --- START PROC L05B1 ---
L05B1:  LD      BC,0E3Ah
        NOP
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
        RST     08H
        XOR     H
        LD      A,(2119h)
        PUSH    AF
        PUSH    DE
        CALL    L0878
        EX      (SP),HL
        LD      (2137h),HL
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
        RST     30H
        POP     DE
        LD      HL,(2141h)
        RST     20H
        POP     DE
        JP      NC,L05FD
        LD      HL,(2145h)
        RST     20H
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

L0614:  CALL    L0EDC
        LD      A,(HL)
        LD      B,A
        CP      8Ch
        JP      Z,L0621
        RST     08H
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

L0630:  CALL    L0878
        LD      A,(HL)
        CP      88h
        JP      Z,L063C
        RST     08H
        AND     C
        DEC     HL
L063C:  RST     28H
        JP      Z,L05B1+2       ; reference not aligned to instruction
        RST     10H
        JP      C,L057F
        JP      L0466

        ; --- START PROC L0647 ---
L0647:  RST     10H
        ; --- START PROC L0648 ---
L0648:  JP      Z,L06DF
        ; --- START PROC L064B ---
L064B:  RET     Z
        CP      27h             ; '''
        CALL    Z,L06DF
        JP      Z,L0708
        CP      9Dh
        JP      Z,L070C
        CP      9Fh
        JP      Z,L070C
        CP      0C8h
        JP      NZ,L066B
        RST     10H
        CALL    L1920
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
        LD      A,(2119h)
        OR      A
        JP      NZ,L06A1
        CALL    L1326
        CALL    L0C7F
        LD      HL,(214Dh)
        LD      A,(2063h)
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
        CALL    L0869
        DEC     HL
        PUSH    HL
        CALL    L0501
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
        LD      (2063h),A
        RET

        ; --- START PROC L06EA ---
L06EA:  LD      A,(2063h)
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
L0708:  RST     10H
        JP      L064B

        ; --- START PROC L070C ---
L070C:  PUSH    AF
        CALL    L0EDA+1         ; reference not aligned to instruction
        RST     08H
        ADD     HL,HL
        DEC     HL
        POP     AF
        CP      9Fh
        PUSH    HL
        LD      A,E
        JP      Z,L06FC
        CP      40h             ; '@'
        JP      P,L0514
        LD      HL,2063h
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

L0740:  CP      22h             ; '"'
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
        JP      NZ,L009B
L0759:  RST     10H
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
        LD      A,(2119h)
        CALL    L01F2
        JP      L0798+1         ; reference not aligned to instruction

        ; --- START PROC L0777 ---
L0777:  LD      A,3Fh           ; '?'
        JP      Z,L077D
        LD      A,C
        ; --- START PROC L077D ---
L077D:  RST     18H
        LD      DE,2090h
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

L0794:  PUSH    HL
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
L07B9:  LD      A,(2119h)
        OR      A
        JP      Z,L07D9
        RST     10H
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

L07D9:  RST     10H
        CALL    L126A
        EX      (SP),HL
        CALL    L11BD
        POP     HL
        DEC     HL
        RST     10H
        JP      Z,L07EC
        CP      2Ch             ; ','
        JP      NZ,L0736
L07EC:  EX      (SP),HL
        DEC     HL
        RST     10H
        JP      NZ,L079E+1      ; reference not aligned to instruction
        POP     DE
        LD      A,(2136h)
        OR      A
        JP      Z,L06DF
        EX      DE,HL
        JP      L04AA

L07FE:  CALL    L05B1
        OR      A
        JP      NZ,L0817
        INC     HL
        RST     30H
        LD      A,C
        OR      B
        LD      E,06h
        JP      Z,L00A7
        POP     BC
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        EX      DE,HL
        LD      (2133h),HL
        EX      DE,HL
L0817:  RST     10H
        CP      83h
        JP      NZ,L07FE
        JP      L07B9

L0820:  LD      DE,0000h
        ; --- START PROC L0823 ---
L0823:  CALL    NZ,L0A48+1      ; reference not aligned to instruction
        LD      (2137h),HL
        CALL    L0045
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
        LD      (213Bh),HL
        LD      L,C
        LD      H,B
        JP      L0432

L085B:  LD      SP,HL
        LD      HL,(2137h)
        LD      A,(HL)
        CP      2Ch             ; ','
        JP      NZ,L0436
        RST     10H
        CALL    L0823
        ; --- START PROC L0869 ---
L0869:  CALL    L0878
        ; --- START PROC L086C ---
L086C:  OR      37h             ; '7'
        ; --- START PROC L086E ---
L086E:  LD      A,(2119h)
        ADC     A,A
        RET     PE
L0873:  LD      E,18h
        JP      L00A7

        ; --- START PROC L0878 ---
L0878:  DEC     HL
        LD      D,00h
        ; --- START PROC L087B ---
L087B:  PUSH    DE
        CALL    L0075
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
        JP      C,L009B
        LD      (2131h),HL
        RST     10H
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
        LD      A,(2119h)
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
        RST     30H
        LD      HL,(2131h)
        JP      L087B

        ; --- START PROC L08E8 ---
L08E8:  XOR     A
        LD      (2119h),A
        RST     10H
        JP      C,L1272
        CALL    L04F1
        JP      NC,L0950
        CP      0A4h
        JP      Z,L08E8
        CP      2Eh             ; '.'
        JP      Z,L1272
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
        JP      Z,L009B
        CP      0D9h
        JP      Z,L1C90
        SUB     0AEh
        JP      NC,L0961
        ; --- START PROC L0937 ---
L0937:  RST     08H
        DB	28H, 0CDH
        LD      A,B
        DB	08H
        RST     08H
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
        LD      A,(2119h)
        OR      A
        CALL    Z,L11A3
        POP     HL
        RET

        ; --- START PROC L0961 ---
L0961:  LD      B,00h
        RLCA
        LD      C,A
        PUSH    BC
        RST     10H
        LD      A,C
        CP      29h             ; ')'
        JP      C,L0994
        CP      30h             ; '0'
        JP      C,L097B
        CP      38h             ; '8'
        JP      NC,L009B
        EX      (SP),HL
        JP      L099C

L097B:  RST     08H
        JR      Z,L094B
        LD      A,B
        EX      AF,AF'
        RST     08H
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
L099C:  LD      BC,1FA8h
        ADD     HL,BC
        LD      C,(HL)
        INC     HL
        LD      H,(HL)
        LD      L,C
        JP      (HL)

L09A5:  OR      0AFh
        PUSH    AF
        CALL    L086C
        CALL    L0501
        POP     AF
        EX      DE,HL
        POP     BC
        EX      (SP),HL
        EX      DE,HL
        CALL    L11A6
        PUSH    AF
        CALL    L0501
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
        LD      A,(2119h)
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
        LD      (2119h),A
        PUSH    DE
        CALL    L0DEC
        POP     DE
        RST     30H
        RST     30H
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
        CALL    L0501
        LD      A,E
        CPL
        LD      C,A
        LD      A,D
        CPL
        CALL    L0BCA
        POP     BC
        JP      L0886

L0A3F:  DEC     HL
        RST     10H
        RET     Z
        RST     08H
        INC     L
        LD      BC,0A3Fh
        PUSH    BC
L0A48:  OR      0AFh
        LD      (2118h),A
        LD      B,(HL)
        ; --- START PROC L0A4E ---
L0A4E:  CALL    L04F1
        JP      C,L009B
        XOR     A
        LD      C,A
        LD      (2119h),A
        RST     10H
        JP      C,L0A63
        CALL    L04F1
        JP      C,L0A6E
L0A63:  LD      C,A
L0A64:  RST     10H
        JP      C,L0A64
        CALL    L04F1
        JP      NC,L0A64
L0A6E:  SUB     24h             ; '$'
        JP      NZ,L0A7B
        INC     A
        LD      (2119h),A
        RRCA
        ADD     A,C
        LD      C,A
        RST     10H
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
L0A90:  RST     20H
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
        LD      HL,(2149h)
        PUSH    HL
        ADD     HL,BC
        POP     BC
        PUSH    HL
        CALL    L0066
        POP     HL
        LD      (2149h),HL
        LD      H,B
        LD      L,C
        LD      (2147h),HL
L0ABE:  DEC     HL
        LD      (HL),00h
        RST     20H
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
        RST     08H
        ADD     HL,HL
        LD      (2139h),HL
        POP     HL
        LD      (2118h),HL
        PUSH    DE
        LD      HL,(2147h)
L0AF4:  LD      A,19h
        EX      DE,HL
        LD      HL,(2149h)
        EX      DE,HL
        RST     20H
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
        JP      NZ,L00A7
        POP     AF
        CP      (HL)
        JP      Z,L0B81
        ; --- START PROC L0B1D ---
L0B1D:  LD      E,10h
        JP      L00A7

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
        LD      (2149h),HL
L0B63:  DEC     HL
        LD      (HL),00h
        RST     20H
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
        RST     20H
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
        RST     10H
        RET

L0BA9:  LD      HL,(2149h)
        EX      DE,HL
        LD      HL,0000h
        ADD     HL,SP
        LD      A,(2119h)
        OR      A
        JP      Z,L0BC5
L0BB8:  CALL    L0DEC
        CALL    L0CFD
        LD      HL,(2141h)
        EX      DE,HL
        LD      HL,(212Fh)
L0BC5:  LD      A,L
        SUB     E
        LD      C,A
        LD      A,H
        SBC     A,D
        ; --- START PROC L0BCA ---
L0BCA:  LD      B,C
L0BCB:  LD      D,B
        LD      E,00h
        LD      HL,2119h
        LD      (HL),E
        LD      B,90h
        JP      L117E

L0BD7:  LD      A,(2063h)
L0BDA:  LD      B,A
        XOR     A
        JP      L0BCB

L0BDF:  CALL    L0C3F
        LD      BC,05B1h
        PUSH    BC
        PUSH    DE
        CALL    L0C31
        RST     08H
        JR      Z,L0BB8+2       ; reference not aligned to instruction
        LD      C,C
        LD      A,(BC)
        CALL    L086C
        RST     08H
        ADD     HL,HL
        RST     08H
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
        RST     30H
        POP     DE
        RST     30H
        POP     HL
        RST     30H
        RST     30H
        DEC     HL
        DEC     HL
        DEC     HL
        DEC     HL
        PUSH    HL
        RST     20H
        PUSH    DE
        LD      E,22h           ; '"'
        JP      Z,L00A7
        CALL    L11BD
        POP     HL
        CALL    L0869
        DEC     HL
        RST     10H
        JP      NZ,L009B
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
        LD      HL,(213Bh)
        INC     HL
        LD      A,H
        OR      L
        POP     HL
        RET     NZ
        LD      E,16h
        JP      L00A7

        ; --- START PROC L0C3F ---
L0C3F:  RST     08H
        AND     B
        LD      A,80h
        LD      (2135h),A
        OR      (HL)
        LD      B,A
        CALL    L0A4E
        JP      L086C

L0C4E:  CALL    L086C
        CALL    L1326
        CALL    L0C7F
        CALL    L0DEC
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
        RST     30H
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
        RST     20H
        CALL    NC,L0C5F
        ; --- START PROC L0CA5 ---
L0CA5:  LD      DE,212Bh
        LD      HL,(211Dh)
        LD      (214Dh),HL
        LD      A,01h
        LD      (2119h),A
        CALL    L11C0
        RST     20H
        LD      E,1Eh
        JP      Z,L00A7
        LD      (211Dh),HL
        POP     HL
        LD      A,(HL)
        RET

L0CC2:  INC     HL
        CALL    L0C7F
        ; --- START PROC L0CC6 ---
L0CC6:  CALL    L0DEC
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
        LD      HL,(2141h)
        EX      DE,HL
        LD      HL,(212Fh)
        CPL
        LD      C,A
        LD      B,0FFh
        ADD     HL,BC
        INC     HL
        RST     20H
        JP      C,L0CF1
        LD      (212Fh),HL
        INC     HL
        EX      DE,HL
        POP     AF
        RET

L0CF1:  POP     AF
        LD      E,1Ah
        JP      Z,L00A7
        CP      A
        PUSH    AF
        LD      BC,0CD7h
        PUSH    BC
        ; --- START PROC L0CFD ---
L0CFD:  LD      HL,(211Bh)
        ; --- START PROC L0D00 ---
L0D00:  LD      (212Fh),HL
        LD      HL,0000h
        PUSH    HL
        LD      HL,(2141h)
        PUSH    HL
        LD      HL,211Fh
        EX      DE,HL
        LD      HL,(211Dh)
        EX      DE,HL
        RST     20H
        LD      BC,0D0Eh
        JP      NZ,L0D5A
        LD      HL,(2145h)
L0D1D:  EX      DE,HL
        LD      HL,(2147h)
        EX      DE,HL
        RST     20H
        JP      Z,L0D31
        LD      A,(HL)
        INC     HL
        INC     HL
        OR      A
        CALL    L0D5D
        JP      L0D1D

L0D30:  POP     BC
L0D31:  EX      DE,HL
        LD      HL,(2149h)
        EX      DE,HL
        RST     20H
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
        RST     20H
        JP      Z,L0D31
        LD      BC,0D4Eh
L0D5A:  PUSH    BC
        OR      80h
        ; --- START PROC L0D5D ---
L0D5D:  RST     30H
        RST     30H
        POP     DE
        POP     BC
        RET     P
        LD      A,C
        OR      A
        RET     Z
        LD      B,H
        LD      C,L
        LD      HL,(212Fh)
        RST     20H
        LD      H,B
        LD      L,C
        RET     C
        POP     HL
        EX      (SP),HL
        RST     20H
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
        LD      HL,(212Fh)
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
        JP      C,L00A7
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
        RST     30H
        RST     30H
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

        ; --- START PROC L0DE9 ---
L0DE9:  CALL    L086C+1         ; reference not aligned to instruction
        ; --- START PROC L0DEC ---
L0DEC:  LD      HL,(214Dh)
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
        RST     20H
        EX      DE,HL
        RET     NZ
        LD      (211Dh),HL
        PUSH    DE
        LD      D,B
        LD      E,C
        DEC     DE
        LD      C,(HL)
        LD      HL,(212Fh)
        RST     20H
        JP      NZ,L0E10
        LD      B,A
        ADD     HL,BC
        LD      (212Fh),HL
L0E10:  POP     HL
        RET

L0E12:  LD      BC,0BDAh
        PUSH    BC
        ; --- START PROC L0E16 ---
L0E16:  CALL    L0DE9
        XOR     A
        LD      D,A
        LD      (2119h),A
        LD      A,(HL)
        OR      A
        RET

L0E21:  CALL    L0E16
        JP      Z,L0514
        INC     HL
        INC     HL
        RST     30H
        POP     HL
        LD      A,(HL)
        JP      L0BDA

L0E2F:  CALL    L0EDF
        POP     BC
L0E33:  LD      A,01h
        PUSH    DE
        CALL    L0C73
        POP     DE
        LD      HL,(212Dh)
        LD      (HL),E
        JP      L0CA5

L0E41:  CALL    L0ECB
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

L0E71:  CALL    L0ECB
        POP     DE
        PUSH    DE
        LD      A,(DE)
        SUB     B
        JP      L0E45

L0E7B:  EX      DE,HL
        LD      A,(HL)
        CALL    L0ECE
        PUSH    BC
        LD      E,0FFh
        CP      29h             ; ')'
        JP      Z,L0E8D
        RST     08H
        INC     L
        CALL    L0EDC
L0E8D:  RST     08H
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

L0EA2:  JP      L009B

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

L0EBD:  JP      L009B

L0EC0:  LD      A,0D3h
        CALL    L0EAE
        CALL    L0ED8
        JP      205Ch

        ; --- START PROC L0ECB ---
L0ECB:  EX      DE,HL
        RST     08H
        ADD     HL,HL
        ; --- START PROC L0ECE ---
L0ECE:  POP     BC
        POP     DE
        PUSH    BC
        LD      B,E
        INC     B
        DEC     B
        JP      Z,L0514
        RET

        ; --- START PROC L0ED8 ---
L0ED8:  RST     08H
        INC     L
L0EDA:  LD      B,0D7h
        ; --- START PROC L0EDC ---
L0EDC:  CALL    L0869
        ; --- START PROC L0EDF ---
L0EDF:  CALL    L04FD
        LD      A,D
        OR      A
        JP      NZ,L0514
        DEC     HL
        RST     10H
        LD      A,E
        RET

L0EEB:  CALL    L0E16
        JP      Z,L0F7C
        LD      E,A
        INC     HL
        INC     HL
        RST     30H
        LD      H,B
        LD      L,C
        ADD     HL,DE
        LD      B,(HL)
        LD      (HL),D
        EX      (SP),HL
        PUSH    BC
        LD      A,(HL)
        CALL    L1272
        POP     BC
        POP     HL
        LD      (HL),B
        RET

        ; --- START PROC L0F04 ---
L0F04:  LD      HL,13EFh
        ; --- START PROC L0F07 ---
L0F07:  CALL    L11B4
        JP      L0F16

        ; --- START PROC L0F0D ---
L0F0D:  CALL    L11B4
        LD      HL,0D1C1h
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
        ; --- START PROC L0F7C ---
L0F7C:  XOR     A
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
        JP      NC,L0F7C
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
        JP      L00A7

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
        JR      C,L0F93+1       ; reference not aligned to instruction
        ; --- START PROC L1012 ---
L1012:  RST     28H
        JP      PE,L0514
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
        LD      HL,0D1C1h
        ; --- START PROC L1050 ---
L1050:  RST     28H
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
L10B0:  POP     BC
        POP     DE
        ; --- START PROC L10B2 ---
L10B2:  RST     28H
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
L114C:  RST     28H
        CPL
        POP     HL
L114F:  OR      A
L1150:  POP     HL
        JP      P,L0F7C
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

L116E:  LD      A,(214Fh)
        CP      2Fh             ; '/'
        RLA
L1174:  SBC     A,A
        RET     NZ
        INC     A
        RET

L1178:  RST     28H
        ; --- START PROC L1179 ---
L1179:  LD      B,88h
        LD      DE,0000h
        ; --- START PROC L117E ---
L117E:  LD      HL,2150h
        LD      C,A
        LD      (HL),B
        LD      B,00h
        INC     HL
        LD      (HL),80h
        RLA
        JP      L0F64

L118C:  RST     28H
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
        JP      Z,L0026+2       ; reference not aligned to instruction
        LD      HL,1172h
        PUSH    HL
        RST     28H
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

        ; --- START PROC L1236 ---
L1236:  LD      HL,2150h
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
        JP      Z,L0869
        LD      A,(HL)
        ; --- START PROC L1272 ---
L1272:  CP      2Dh             ; '-'
        PUSH    AF
        JP      Z,L127E
        CP      2Bh             ; '+'
        JP      Z,L127E
        DEC     HL
L127E:  CALL    L0F7C
        LD      B,A
        LD      D,A
        LD      E,A
        CPL
        LD      C,A
        ; --- START PROC L1286 ---
L1286:  RST     10H
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
        RST     10H
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
L12B4:  RST     10H
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
        CALL    L117E
        LD      HL,0CC2h
        PUSH    HL
        ; --- START PROC L1326 ---
L1326:  LD      HL,2152h
        PUSH    HL
        RST     28H
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

        ; --- START PROC L140A ---
L140A:  CALL    L1196
        LD      HL,13EFh
        CALL    L11A3
        POP     BC
        POP     DE
        ; --- START PROC L1415 ---
L1415:  RST     28H
        JP      Z,L144F
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
        CALL    L1236
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
        CALL    L1012
        POP     BC
        POP     DE
        CALL    L1050
L144F:  CALL    L1196
        LD      BC,8138h
        LD      DE,0AA38h
        CALL    L1050
        LD      A,(2150h)
        CP      88h
        JP      NC,L114C
        CALL    L1236
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

L148F:  EX      AF,AF'
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

L14E0:  RST     28H
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

        ; --- START PROC L1512 ---
L1512:  LD      HL,1558h
        CALL    L0F07
        ; --- START PROC L1518 ---
L1518:  CALL    L1196
        LD      BC,8349h
        LD      DE,0FDBh
        CALL    L11A6
        POP     BC
        POP     DE
        CALL    L10B2
        CALL    L1196
        CALL    L1236
        POP     BC
        POP     DE
        CALL    L0F13
        LD      HL,155Ch
        CALL    L0F0D
        RST     28H
        SCF
        JP      P,L1544
        CALL    L0F04
        RST     28H
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
        RST     10H
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
        CALL    L1196
        CALL    L1518
        POP     BC
        POP     HL
        CALL    L1196
        EX      DE,HL
        CALL    L11A6
        CALL    L1512
        JP      L10B0

        ; --- START PROC L1592 ---
L1592:  RST     28H
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
        RST     10H
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
        RST     28H
        CALL    L0501
        LD      A,(DE)
        JP      L0BDA

L15E6:  CALL    L0869
        RST     28H
        CALL    L0501
        PUSH    DE
        CALL    L0ED8
        POP     DE
        LD      (DE),A
        RET

L15F4:  RST     28H
        CALL    L0501
        EX      DE,HL
        CALL    L15FF
        JP      L0BDA

        ; --- START PROC L15FF ---
L15FF:  JP      (HL)

L1600:  LD      HL,(L0026)
        LD      (2143h),HL
        LD      HL,(L0000+1)    ; reference not aligned to instruction
        DEC     HL
        LD      (211Bh),HL
        LD      DE,0FFCEh
        ADD     HL,DE
        LD      (2141h),HL
        XOR     A
        LD      (2063h),A
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
        CALL    L01AF
        ; --- START PROC L1635 ---
L1635:  CALL    L01D6
        JP      L00F1

        ; --- START PROC L163B ---
L163B:  EX      DE,HL
        CALL    L131B
        LD      DE,2090h
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
        LD      DE,1E07h
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

L1685:  CALL    0F81Bh
        OR      A
        LD      E,A
        JP      P,L0E33
        XOR     A
        CALL    L0C73
        JP      L0CA5

L1694:  LD      C,1Fh
        JP      0F809h

L1699:  CALL    L1A5F
        ; --- START PROC L169C ---
L169C:  LD      C,55h           ; 'U'
L169E:  DEC     C
        JP      NZ,L169E
        DEC     DE
        LD      A,D
        OR      E
        JP      NZ,L169C
        RET

L16A9:  POP     HL
        DEC     HL
        ; --- START PROC L16AB ---
L16AB:  LD      DE,0000h
L16AE:  RST     10H
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
        CALL    L117E
        POP     HL
        RET

L16E7:  CALL    L0869
        CALL    L0501
        DEC     HL
        RST     10H
        RET     NZ
        PUSH    HL
        LD      HL,(2149h)
        LD      BC,0400h
        ADD     HL,BC
        EX      DE,HL
        RST     20H
L16FA:  LD      E,20h           ; ' '
        JP      C,L00A7
        EX      DE,HL
        LD      HL,(L0000+1)    ; reference not aligned to instruction
        RST     20H
        JP      C,L16FA
        EX      DE,HL
        LD      (211Bh),HL
        LD      BC,0FFCEh
        ADD     HL,BC
        LD      (2141h),HL
        POP     HL
        JP      L01C1

L1716:  CALL    L0519
        RET     NZ
        POP     BC
        ; --- START PROC L171B ---
L171B:  CALL    L0197
        LD      H,B
        LD      L,C
        RST     30H
        POP     BC
        LD      A,B
        OR      C
        JP      Z,L00F1
        CALL    L03D1
        CALL    L027C
        JP      L010D

L1730:  CALL    L03B6
        JP      NC,L009B
        POP     BC
        CALL    L0197
        PUSH    BC
        PUSH    BC
L173C:  POP     HL
        RST     30H
        POP     DE
        LD      A,D
        OR      E
        JP      Z,L1752
        PUSH    DE
        RST     30H
        POP     DE
        PUSH    HL
        LD      HL,(2078h)
        RST     20H
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

L1768:  EX      DE,HL
        CALL    L01CD
        EX      DE,HL
        CALL    L189A
        PUSH    DE
        LD      A,(207Ah)
        LD      C,A
        LD      B,00h
        LD      HL,(2149h)
        EX      DE,HL
        LD      HL,(2143h)
L177E:  PUSH    BC
        CALL    L0075
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
        LD      (2149h),HL
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
        LD      HL,(2143h)
L17BB:  LD      A,(HL)
        INC     HL
        OR      (HL)
        JP      Z,L1BC8
        INC     HL
        INC     HL
L17C3:  RST     10H
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
        RST     10H
        POP     HL
        JP      NC,L17C3
        INC     HL
        PUSH    HL
        CALL    L0519
        PUSH    HL
        PUSH    DE
        LD      HL,(2145h)
        EX      DE,HL
L17F7:  LD      HL,(2149h)
        EX      DE,HL
        RST     20H
        POP     DE
        JP      Z,L1813
        LD      A,(HL)
        INC     HL
        LD      B,(HL)
        INC     HL
        PUSH    HL
        LD      L,A
        LD      H,B
        RST     20H
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
        CALL    L117E
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
L1851:  RST     20H
        LD      A,(HL)
        LD      (BC),A
        INC     HL
        INC     BC
        JP      NZ,L1851
L1859:  LD      HL,(2147h)
        LD      (2149h),HL
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
        LD      HL,(2149h)
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
        LD      HL,(2149h)
L188F:  RST     20H
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
        CALL    L0519
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

L18C8:  EX      DE,HL
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
        JP      NC,L0514
        LD      C,A
        PUSH    BC
        CALL    L0ED8
        POP     BC
        LD      B,A
        CP      19h
L1908:  JP      NC,L0514
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

        ; --- START PROC L1920 ---
L1920:  CALL    L18F7
        LD      (7600h),HL
        LD      A,1Bh
        SUB     B
        LD      H,A
        LD      A,C
        LD      (2063h),A
        ADD     A,08h
        LD      L,A
        LD      (7602h),HL
        EX      DE,HL
        RET

L1936:  CALL    L0EDC
        LD      (2054h),A
        CALL    L0ED8
        LD      (2055h),A
        CALL    L0ED8
        LD      (2056h),A
        ; --- START PROC L1948 ---
L1948:  LD      A,(2054h)
        OR      A
        JP      M,L0514
        LD      A,(2055h)
        CP      32h             ; '2'
        JP      NC,L0514
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

L199E:  CALL    L0EDC
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

L1A39:  POP     HL
        CALL    L18F7
        EX      DE,HL
        RST     08H
        ADD     HL,HL
        EX      DE,HL
        PUSH    DE
        LD      E,(HL)
        JP      L0E33

        ; --- START PROC L1A46 ---
L1A46:  RST     10H
        RST     08H
        JR      Z,L1A17
        LD      C,C
        LD      A,(BC)
        RST     08H
        ADD     HL,HL
        XOR     A
        LD      (2119h),A
        JP      L16D7

        ; --- START PROC L1A55 ---
L1A55:  RST     10H
        LD      BC,8249h
        LD      DE,0FDBh
        JP      L11A6

        ; --- START PROC L1A5F ---
L1A5F:  CALL    L0869
        RST     28H
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

L1A77:  CALL    L1A5F
        PUSH    DE
        RST     08H
        INC     L
        CALL    L0869
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
        JP      NZ,L009B
L1AC3:  INC     HL
        LD      A,(HL)
        OR      A
        JP      Z,L009B
        CP      22h             ; '"'
        JP      NZ,L1AC3
        POP     HL
        RET

        ; --- START PROC L1AD0 ---
L1AD0:  PUSH    HL
        LD      HL,(2143h)
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

L1B06:  CALL    L1ABC
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
        LD      HL,(2143h)
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

L1B6F:  LD      BC,0000h
        ; --- START PROC L1B72 ---
L1B72:  OR      A
        PUSH    AF
        PUSH    BC
        CALL    NZ,L1BD5
        POP     BC
        LD      E,03h
        CALL    L1C12
        LD      HL,(2143h)
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
        RST     20H
L1BB8:  PUSH    AF
L1BB9:  CALL    0F82Dh
        POP     AF
        LD      E,18h
        JP      NZ,L00A7
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
        JP      NZ,L009B
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

L1C35:  LD      BC,0100h
        JP      L1B72

L1C3B:  LD      BC,0001h
        CALL    NZ,L1ABC
        PUSH    HL
        LD      HL,(2145h)
        DEC     HL
        DEC     HL
        LD      (2143h),HL
        POP     HL
        CALL    L1B72
        LD      HL,(L0026)
        LD      (2143h),HL
        JP      L1BC8

        ; --- START PROC L1C57 ---
L1C57:  RST     10H
        CALL    L0937
        PUSH    HL
        CALL    L1196
        CALL    L11B1
        CALL    L1050
        LD      BC,8100h
        LD      D,C
        LD      E,C
        CALL    L0F13
        CALL    L140A
        POP     BC
        POP     DE
        RST     28H
        JP      Z,L1C7E
        CALL    L10B2
        CALL    L1592
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
L1C90:  RST     10H
        CALL    L0937
        PUSH    HL
        CALL    L1012
        CALL    L1196
        LD      BC,8213h
        LD      DE,5D8Eh
        CALL    L11A6
        POP     BC
        POP     DE
        CALL    L10B2
        POP     HL
        RET

L1CAB:  PUSH    AF
        LD      A,01h
        LD      (2117h),A
        POP     AF
        CALL    L0648
        XOR     A
        LD      (2117h),A
        RET

L1CBA:  LD      A,01h
        LD      (2117h),A
        JP      L0397

L1CC2:  LD      DE,76D0h
L1CC5:  XOR     A
        LD      (DE),A
        INC     DE
        LD      A,D
        CP      80h
        RET     Z
        JP      L1CC5

        ; --- START PROC L1CCF ---
L1CCF:  LD      C,A
        JP      0F80Ch

L1CD3:  LD      C,(HL)
        LD      B,L
        LD      E,B
        LD      D,H
        JR      NZ,L1D3B
        LD      H,L
        LD      A,D
        JR      NZ,L1D23
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
        JR      NZ,L1D59
        LD      H,L
        LD      A,D
        JR      NZ,L1D42
        LD      C,A
        LD      D,E
        LD      D,L
        LD      B,D
        NOP
        LD      L,L
        LD      H,C
        LD      L,H
        LD      L,A
        JR      NZ,L1D6A
        LD      H,C
        LD      L,(HL)
        LD      L,(HL)
        LD      A,C
        LD      L,B
        JR      NZ,L1D7D
        LD      (HL),D
        LD      L,C
        JR      NZ,L1D55
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
        JR      NZ,L1D80
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
        JR      NZ,L1DA9
        LD      A,D
L1D3B:  LD      (HL),L
        NOP
        LD      L,(HL)
        LD      H,L
        LD      (HL),H
        JR      NZ,L1DB5
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
        JR      NZ,L1DBB
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
        JR      NZ,L1DD2
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
        JR      NZ,L1DE2
        LD      H,C
        JR      NZ,L1DA6+1      ; reference not aligned to instruction
        NOP
        LD      (HL),H
        LD      L,A
        LD      L,H
        LD      A,B
        LD      L,E
L1D7D:  LD      L,A
        JR      NZ,L1DF7
L1D80:  JR      NZ,L1DF2
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
        JR      NZ,L1E01
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
        JR      NZ,L1E02
        LD      B,L
        LD      B,(HL)
        NOP
        JR      NZ,L1E32
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
        JR      NZ,L1E52
        JR      NZ,L1E4E+2      ; reference not aligned to instruction
        LD      (HL),H
        LD      (HL),D
        LD      L,A
        LD      L,E
        LD      H,L
L1DE2:  JR      NZ,L1DE4
L1DE4:  RRA
        LD      B,D
        LD      B,C
        LD      D,E
        LD      C,C
        LD      B,E
        JR      NZ,L1E16
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
        LD      A,(4300h)
        LD      C,H
        OUT     (46h),A         ; 'F'
        LD      C,A
        JP      NC,454Eh
        LD      E,B
        CALL    NC,4144h
        LD      D,H
        POP     BC
        LD      C,C
L1E16:  LD      C,(HL)
        LD      D,B
        LD      D,L
        CALL    NC,4944h
        CALL    4552h
        LD      B,C
        CALL    NZ,5543h
        JP      NC,4F47h
        LD      D,H
        RST     08H
        LD      D,D
        LD      D,L
        ADC     A,49h           ; 'I'
        ADD     A,52h           ; 'R'
        LD      B,L
        LD      D,E
        LD      D,H
        LD      C,A
L1E32:  LD      D,D
        PUSH    BC
        LD      B,A
        LD      C,A
        LD      D,E
        LD      D,L
        JP      NZ,4552h
        LD      D,H
        LD      D,L
        LD      D,D
        ADC     A,52h           ; 'R'
        LD      B,L
        CALL    5453h
        LD      C,A
        RET     NC
        LD      C,A
        LD      D,L
        CALL    NC,0CE4Fh
        LD      D,B
        LD      C,H
        LD      C,A
L1E4E:  CALL    NC,494Ch
        LD      C,(HL)
L1E52:  PUSH    BC
        LD      D,B
        LD      C,A
        LD      C,E
        PUSH    BC
        LD      D,B
        LD      D,D
        LD      C,C
        LD      C,(HL)
        CALL    NC,4544h
        ADD     A,43h           ; 'C'
        LD      C,A
        LD      C,(HL)
        CALL    NC,494Ch
        LD      D,E
        CALL    NC,4C43h
        LD      B,L
        LD      B,C
        JP      NC,4C43h
        LD      C,A
        LD      B,C
        CALL    NZ,5343h
        LD      B,C
        LD      D,(HL)
        PUSH    BC
        LD      C,(HL)
        LD      B,L
        RST     10H
        LD      D,H
        LD      B,C
        LD      B,D
        XOR     B
        LD      D,H
        RST     08H
        LD      D,E
        LD      D,B
        LD      B,E
        XOR     B
        LD      B,(HL)
        ADC     A,54h           ; 'T'
        LD      C,B
        LD      B,L
        ADC     A,4Eh           ; 'N'
        LD      C,A
        CALL    NC,5453h
        LD      B,L
        RET     NC
        XOR     E
        XOR     L
        XOR     D
        XOR     A
        SBC     A,41h           ; 'A'
        LD      C,(HL)
        CALL    NZ,0D24Fh
        CP      (HL)
        CP      L
        CP      H
        LD      D,E
        LD      B,A
        ADC     A,49h           ; 'I'
        LD      C,(HL)
        CALL    NC,4241h
        OUT     (55h),A         ; 'U'
        LD      D,E
        JP      NC,5246h
        PUSH    BC
        LD      C,C
        LD      C,(HL)
        RET     NC
        LD      D,B
        LD      C,A
        OUT     (53h),A         ; 'S'
        LD      D,C
        JP      NC,4E52h
        CALL    NZ,4F4Ch
        RST     00H
        LD      B,L
        LD      E,B
        RET     NC
        LD      B,E
        LD      C,A
        OUT     (53h),A         ; 'S'
        LD      C,C
        ADC     A,54h           ; 'T'
        LD      B,C
        ADC     A,41h           ; 'A'
        LD      D,H
        ADC     A,50h           ; 'P'
        LD      B,L
        LD      B,L
        BIT     1,H
        LD      B,L
        ADC     A,53h           ; 'S'
        LD      D,H
        LD      D,D
        AND     H
        LD      D,(HL)
        LD      B,C
        CALL    Z,5341h
        JP      4843h

L1EDD:  LD      D,D
        AND     H
        LD      C,H
        LD      B,L
        LD      B,(HL)
        LD      D,H
        AND     H
        LD      D,D
        LD      C,C
        LD      B,A
        LD      C,B
        LD      D,H
        AND     H
        LD      C,L
        LD      C,C
        LD      B,H
        AND     H
        LD      D,E
        LD      B,E
        LD      D,D
        LD      B,L
        LD      B,L
        LD      C,(HL)
        INC     H
        XOR     B
        LD      C,C
        LD      C,(HL)
        LD      C,E
        LD      B,L
        LD      E,C
        AND     H
        LD      B,C
        CALL    NC,42A6h
        LD      B,L
        LD      B,L
        RET     NC
        LD      D,B
        LD      B,C
        LD      D,L
        LD      D,E
        PUSH    BC
        LD      D,(HL)
        LD      B,L
        LD      D,D
        LD      C,C
        LD      B,(HL)
        EXX
        LD      C,B
        LD      C,A
        LD      C,L
        PUSH    BC
        LD      B,L
        LD      B,H
        LD      C,C
        CALL    NC,4544h
        LD      C,H
        LD      B,L
        LD      D,H
        PUSH    BC
        LD      C,L
        LD      B,L
        LD      D,D
        LD      B,A
        PUSH    BC
        LD      B,C
        LD      D,L
        LD      D,H
        RST     08H
        LD      C,B
        LD      C,C
        LD      C,L
        LD      B,L
        CALL    41C0h
        LD      D,E
        ADC     A,41h           ; 'A'
        LD      B,H
        LD      B,H
        JP      NC,0C950h
        LD      D,D
        LD      B,L
        LD      C,(HL)
        LD      D,L
        CALL    4341h
        OUT     (4Ch),A         ; 'L'
        RST     00H
        LD      C,H
        LD      D,B
        LD      D,D
        LD      C,C
        LD      C,(HL)
        CALL    NC,4C4Ch
        LD      C,C
        LD      D,E
        CALL    NC,0C200h
        INC     E
        JP      PO,L2002+1      ; reference not aligned to instruction
        EX      AF,AF'
        OR      C
        DEC     B
        LD      B,B
        RLCA
        LD      B,H
        LD      A,(BC)
        SUB     H
        RLCA
        JR      NZ,L1F72+1      ; reference not aligned to instruction
        LD      A,A
        DEC     B
        LD      H,E
        DEC     B
        JR      NC,L1F66
        SUB     (HL)
        INC     B
        LD      L,A
        DEC     B
        SBC     A,E
        DEC     B
L1F66:  OR      E
        DEC     B
        CP      C
        INC     B
        SBC     A,E
        NOP
        INC     D
        LD      B,36h           ; '6'
        ADD     HL,DE
        SBC     A,(HL)
        ADD     HL,DE
L1F72:  AND     15h
        LD      C,B
        LD      B,0DFh
        DEC     BC
        INC     B
        SUB     A
        INC     BC
L1F7C:  LD      A,(6F05h)
        DEC     DE
        LD      B,1Bh
        XOR     A
        LD      BC,1A77h
        SBC     A,C
        LD      D,35h           ; '5'
        INC     E
        SUB     H
        LD      D,16h
        RLA
        JR      NC,L1FA7
        DEC     SP
        INC     E
        RET     Z
        JR      L1F7C

L1F95:  LD      D,9Bh
        NOP
        SBC     A,E
        NOP
        SBC     A,E
        NOP
        SBC     A,E
        NOP
        LD      L,B
        RLA
        SBC     A,E
        NOP
        SBC     A,E
        NOP
        XOR     E
        INC     E
        CP      D
L1FA7:  INC     E
        LD      A,B
        LD      DE,1236h
        ADC     A,H
        LD      DE,15F4h
        XOR     C
        DEC     BC
        SBC     A,E
        NOP
        RST     10H
        DEC     BC
        LD      A,(BC)
        INC     D
        RET     PO
        INC     D
        LD      (DE),A
        DJNZ    200Ch
        INC     D
        LD      (DE),A
        DEC     D
        JR      L1FD7

L1FC2:  LD      A,L
        DEC     D
        SUB     D
        DEC     D
        SBC     A,15h
        LD      (DE),A
        LD      C,4Eh           ; 'N'
        INC     C
        EX      DE,HL
        LD      C,21h           ; '!'
        LD      C,2Fh           ; '/'
        LD      C,41h           ; 'A'
        LD      C,71h           ; 'q'
        LD      C,7Bh           ; '{'
L1FD7:  LD      C,39h           ; '9'
        LD      A,(DE)
        ADD     A,L
        LD      D,9Bh
        NOP
        XOR     C
        LD      D,79h           ; 'y'
        LD      (BC),A
        INC     DE
        LD      A,C
        LD      DE,7B0Fh
        LD      C,(HL)
        DJNZ    2065h
        OR      B
        DJNZ    206Ch
        INC     DE
        INC     D
        LD      D,B
        AND     (HL)
        ADD     HL,BC
        LD      B,(HL)
        AND     L
        ADD     HL,BC
        LD      C,L
        LD      C,C
        JR      Z,203Ch
        ADD     HL,HL
        LD      D,D
        LD      C,A
        LD      C,(HL)
        CPL
        JR      C,2038h
        AND     55h             ; 'U'
L2002:  POP     BC
