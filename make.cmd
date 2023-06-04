asw -lU basic80.asm > basic80.lst
p2bin basic80.p basic80.bin

asw -lU ctrlbas.asm > ctrlbas.lst
p2bin ctrlbas.p ctrlbas.bin

bin2rk basic80.bin
bin2rk ctrlbas.bin

ctrlbas
