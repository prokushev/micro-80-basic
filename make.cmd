rem Стандартные бейсики

asw -lU basic80.asm > basic80.lst
p2bin basic80.p basic80.bin

asw -lU -D RAM=12 basic80.asm > basic80-12.lst
p2bin basic80.p basic80-12.bin

asw -lU -D RAM=32 basic80.asm > basic80-32.lst
p2bin basic80.p basic80-32.bin

asw -lU -D RAM=48 basic80.asm > basic80-48.lst
p2bin basic80.p basic80-48.bin

asw -lU -D RK86=1 basic80.asm > basic80-rk86.lst
p2bin basic80.p basic80-rk86.bin

asw -lU -D RK86=1 -D RAM=32 basic80.asm > basic80-rk86-32.lst
p2bin basic80.p basic80-rk86-32.bin

asw -lU -D UT88=1 basic80.asm > basic80-ut88.lst
p2bin basic80.p basic80-ut88.bin

asw -lU -D UT88=1 -D RAM=12 basic80.asm > basic80-ut88-12.lst
p2bin basic80.p basic80-ut88-12.bin

asw -lU -D UT88=1 -D RAM=32 basic80.asm > basic80-ut88-32.lst
p2bin basic80.p basic80-ut88-32.bin

asw -lU -D UT88=1 -D RAM=48 basic80.asm > basic80-ut88-48.lst
p2bin basic80.p basic80-ut88-48.bin

asw -lU ctrlbas.asm > ctrlbas.lst
p2bin ctrlbas.p ctrlbas.bin

rem Бейсик-Сервис

asw -lU -D SERVICE=1 basic80.asm > basic80-service.lst
p2bin basic80.p basic80-service.bin

asw -lU -D SERVICE=1 -D RAM=12 basic80.asm > basic80-service-12.lst
p2bin basic80.p basic80-service-12.bin

asw -lU -D SERVICE=1 -D RAM=32 basic80.asm > basic80-service-32.lst
p2bin basic80.p basic80-service-32.bin

asw -lU -D SERVICE=1 -D RAM=48 basic80.asm > basic80-service-48.lst
p2bin basic80.p basic80-service-48.bin

asw -lU -D SERVICE=1 -D RK86=1 basic80.asm > basic80-rk86-service.lst
p2bin basic80.p basic80-rk86-service.bin

asw -lU -D SERVICE=1 -D RK86=1 -D RAM=32 basic80.asm > basic80-rk86-service-32.lst
p2bin basic80.p basic80-rk86-service-32.bin

asw -lU -D SERVICE=1 -D UT88=1 basic80.asm > basic80-ut88-service.lst
p2bin basic80.p basic80-ut88-service.bin

asw -lU -D SERVICE=1 -D UT88=1 -D RAM=12 basic80.asm > basic80-ut88-service-12.lst
p2bin basic80.p basic80-ut88-service-12.bin

asw -lU -D SERVICE=1 -D UT88=1 -D RAM=32 basic80.asm > basic80-ut88-service-32.lst
p2bin basic80.p basic80-ut88-service-32.bin

asw -lU -D SERVICE=1 -D UT88=1 -D RAM=48 basic80.asm > basic80-ut88-service-48.lst
p2bin basic80.p basic80-ut88-service-48.bin

rem Мои варианты

asw -lU -D BASICNEW=1 basic80.asm > basic80-new.lst
p2bin basic80.p basic80-new.bin

bin2rk basic80.bin
bin2rk ctrlbas.bin $2800

ctrlbas

