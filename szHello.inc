szHello:
	IF	RK86

	IF	MIKROSHA
	DB	01FH,"*mikro{a* BASIC   ", 0DH, 0AH, 0
	ELSE
	DB	01FH,"*radio-86rk* BASIC", 0DH, 0AH, 0
	ENDIF

	ELSE

	IF	UT88
	DB		1Fh, "*UT-88* BASIC   ", 0Dh, 0Ah, 0
	ELSE
	DB		1Fh, 0Dh, 0Ah, "*MikrO/80* BASIC", 0
	ENDIF

	ENDIF
