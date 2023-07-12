@echo off
rem Стандартные бейсики

asw -lU -D RAM=12 basic80.asm > basic80-12kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\micro-80\basic80-12kb.bin
if errorlevel 1 goto error

asw -lU basic80.asm > basic80-16kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\micro-80\basic80-16kb.bin
if errorlevel 1 goto error

asw -lU -D RAM=32 basic80.asm > basic80-32kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\micro-80\basic80-32kb.bin
if errorlevel 1 goto error

asw -lU -D RAM=48 basic80.asm > basic80-48kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\micro-80\basic80-48kb.bin
if errorlevel 1 goto error

rem ------------------------------------------------------------

asw -lU -D RK86=1 basic80.asm > basic80-rk86-16kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\radio-86rk\basic80-rk86-16kb.bin
if errorlevel 1 goto error

asw -lU -D RK86=1 -D RAM=32 basic80.asm > basic80-rk86-32kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\radio-86rk\basic80-rk86-32kb.bin
if errorlevel 1 goto error

rem ------------------------------------------------------------

asw -lU -D UT88=1 -D RAM=12 basic80.asm > basic80-ut88-12kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\ut-88\basic80-ut88-12kb.bin
if errorlevel 1 goto error

asw -lU -D UT88=1 basic80.asm > basic80-ut88-16kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\ut-88\basic80-ut88-16kb.bin
if errorlevel 1 goto error

asw -lU -D UT88=1 -D RAM=32 basic80.asm > basic80-ut88-32kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\ut-88\basic80-ut88-32kb.bin
if errorlevel 1 goto error

asw -lU -D UT88=1 -D RAM=48 basic80.asm > basic80-ut88-48kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\ut-88\basic80-ut88-48kb.bin
if errorlevel 1 goto error

rem ------------------------------------------------------------

asw -lU ctrlbas.asm > ctrlbas.lst
if errorlevel 1 goto error
p2bin ctrlbas.p ctrlbas.bin
if errorlevel 1 goto error

rem Бейсик-Сервис

asw -lU -D SERVICE=1 -D RAM=12 basic80.asm > basic80-service-12kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\micro-80\basic80-service-12kb.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 basic80.asm > basic80-service-16kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\micro-80\basic80-service-16kb.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D RAM=32 basic80.asm > basic80-service-32kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\micro-80\basic80-service-32kb.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D RAM=48 basic80.asm > basic80-service-48kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\micro-80\basic80-service-48kb.bin
if errorlevel 1 goto error

rem ------------------------------------------------------------

asw -lU -D SERVICE=1 -D RK86=1 basic80.asm > basic80-rk86-service-16kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\radio-86rk\basic80-rk86-service-16kb.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D RK86=1 -D RAM=32 basic80.asm > basic80-rk86-service-32kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\radio-86rk\basic80-rk86-service-32kb.bin
if errorlevel 1 goto error

rem ------------------------------------------------------------

asw -lU -D SERVICE=1 -D UT88=1 -D RAM=12 basic80.asm > basic80-ut88-service-12kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\ut-88\basic80-ut88-service-12kb.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D UT88=1 basic80.asm > basic80-ut88-service-16kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\ut-88\basic80-ut88-service-16kb.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D UT88=1 -D RAM=32 basic80.asm > basic80-ut88-service-32kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\ut-88\basic80-ut88-service-32kb.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D UT88=1 -D RAM=48 basic80.asm > basic80-ut88-service-48kb.lst
if errorlevel 1 goto error
p2bin basic80.p bin\ut-88\basic80-ut88-service-48kb.bin
if errorlevel 1 goto error

rem Мои варианты

asw -lU -D BASICNEW=1 basic80.asm > basic80-new.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-new.bin
if errorlevel 1 goto error

bin2rk ctrlbas.bin $2800

bin2rk bin\micro-80\basic80-12kb.bin
bin2rk bin\micro-80\basic80-16kb.bin
bin2rk bin\micro-80\basic80-32kb.bin
bin2rk bin\micro-80\basic80-48kb.bin

bin2rk bin\radio-86rk\basic80-rk86-16kb.bin

bin2rk bin\ut-88\basic80-ut88-12kb.bin

:asw -lU basictest.asm > basictest.lst
:if errorlevel 1 goto error
:p2bin basictest.p bin\ut-88\basictest.bin
:if errorlevel 1 goto error
:bin2rk bin\ut-88\basictest.bin

:fpc ctrlbas
ctrlbas

goto exit

:error

echo Ошибка сборки

:exit
