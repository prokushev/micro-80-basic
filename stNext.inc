;1.16 NEXT Handler
;Next
;The NEXT keyword is followed by the name of the FOR variable, so firstly we get the address of that variable into DE.

Next:
        LD      DE,0000H
NextLoop:
		CALL    NZ,GetVar
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
        CALL    NextLoop

		;JP		EvalNumericExpression
		