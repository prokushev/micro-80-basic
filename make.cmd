@echo off
rem Стандартные бейсики

asw -lU basic80.asm > basic80.lst
if errorlevel 1 goto error
 p2bin basic80.p basic80.bin
if errorlevel 1 goto error

asw -lU -D RAM=12 basic80.asm > basic80-12.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-12.bin
if errorlevel 1 goto error

asw -lU -D RAM=32 basic80.asm > basic80-32.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-32.bin
if errorlevel 1 goto error

asw -lU -D RAM=48 basic80.asm > basic80-48.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-48.bin
if errorlevel 1 goto error

asw -lU -D RK86=1 basic80.asm > basic80-rk86.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-rk86.bin
if errorlevel 1 goto error

asw -lU -D RK86=1 -D RAM=32 basic80.asm > basic80-rk86-32.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-rk86-32.bin
if errorlevel 1 goto error

asw -lU -D UT88=1 basic80.asm > basic80-ut88.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-ut88.bin
if errorlevel 1 goto error

asw -lU -D UT88=1 -D RAM=12 basic80.asm > basic80-ut88-12.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-ut88-12.bin
if errorlevel 1 goto error

asw -lU -D UT88=1 -D RAM=32 basic80.asm > basic80-ut88-32.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-ut88-32.bin
if errorlevel 1 goto error

asw -lU -D UT88=1 -D RAM=48 basic80.asm > basic80-ut88-48.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-ut88-48.bin
if errorlevel 1 goto error

asw -lU ctrlbas.asm > ctrlbas.lst
if errorlevel 1 goto error
p2bin ctrlbas.p ctrlbas.bin
if errorlevel 1 goto error

rem Бейсик-Сервис

asw -lU -D SERVICE=1 basic80.asm > basic80-service.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-service.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D RAM=12 basic80.asm > basic80-service-12.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-service-12.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D RAM=32 basic80.asm > basic80-service-32.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-service-32.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D RAM=48 basic80.asm > basic80-service-48.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-service-48.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D RK86=1 basic80.asm > basic80-rk86-service.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-rk86-service.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D RK86=1 -D RAM=32 basic80.asm > basic80-rk86-service-32.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-rk86-service-32.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D UT88=1 basic80.asm > basic80-ut88-service.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-ut88-service.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D UT88=1 -D RAM=12 basic80.asm > basic80-ut88-service-12.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-ut88-service-12.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D UT88=1 -D RAM=32 basic80.asm > basic80-ut88-service-32.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-ut88-service-32.bin
if errorlevel 1 goto error

asw -lU -D SERVICE=1 -D UT88=1 -D RAM=48 basic80.asm > basic80-ut88-service-48.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-ut88-service-48.bin
if errorlevel 1 goto error

rem Мои варианты

asw -lU -D BASICNEW=1 basic80.asm > basic80-new.lst
if errorlevel 1 goto error
p2bin basic80.p basic80-new.bin
if errorlevel 1 goto error

bin2rk basic80.bin
bin2rk ctrlbas.bin $2800

fpc ctrlbas
ctrlbas

goto exit

:error

echo Ошибка сборки

:exit
