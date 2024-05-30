;1.7 LIST Handler
;List
;Lists the program. As the stored program is in tokenised form 
;(ie keywords are represented with single byte numeric IDs) LIST
; is more complex than a simple memory dump. When it meets a 
;keyword ID it looks it up in the keywords table and prints it.

List:
;Get the line number argument into DE and error back if a non-numeric argument was given.
        CALL    LineNumberFromStr
        RET     NZ

        POP     BC			; ?why get return address?
;From the line number in DE, get the address of the starting program line onto the stack.
        CALL    FindProgramLine
        PUSH    BC
ListNextLine:
;Pop the current program line address into HL, and get the address of the *next* program line into BC.. 
		POP     HL
        RST     PushNextWord
		POP     BC
;If we've reached the null line at the end of the program, then exit. 
        LD      A,B
        OR      C
        JP      Z,Main
;Allow user a chance to stop the program listing.
        CALL    TestBreakKey
        PUSH    BC
        CALL    NewLine
;Get current program line number into HL, and push current program line ptr onto the stack.
        RST     PushNextWord
        EX      (SP),HL
;Print the line number and prepare to print a space..
        CALL    PrintInt
        LD      A,' '
;Restore current line ptr to HL, print current character, advance current line ptr and 
ListChar1:
		POP     HL
ListChar:
		RST     OutChar
        LD      A,(HL)
        OR      A
        INC     HL
        JP      Z,ListNextLine
        JP      P,ListChar
;Bit 7 of A is set, indicating a keyword ID. So we need to look the keyword up in the table and print it. 
        SUB     7FH			; A is now keyword index + 1.
        LD      C,A
        PUSH    HL
        LD      DE, KEYWORDS
ToNextKeyword1:
		PUSH    DE
ToNextKeyword:
;Find the start of the next keyword.
		LD      A,(DE)
        INC     DE
        OR      A
        JP      P,ToNextKeyword
;Decrement keyword index and restore start of previous keyword to HL. If this is not yet the keyword we want, then loop back.
        DEC     C
        POP     HL
        JP      NZ,ToNextKeyword1
PrintKeyword:
;Print the keyword. Note that printing of the last character is deferred to ListChar in the main loop.
		LD      A,(HL)
        OR      A
        JP      M,ListChar1
        RST     OutChar
        INC     HL
        JP      PrintKeyword
