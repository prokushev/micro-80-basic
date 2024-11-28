
; GetFlowPtr
; Sets HL to point to the appropriate flow struct on the stack. On entry, 
; if this was called by the NEXT keyword handler then DE is pointing to 
; the variable following the NEXT keyword.


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
