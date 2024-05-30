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
