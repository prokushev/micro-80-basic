Uses sysutils, dos;

 var
   datFile    : File of Byte;
   chrContent : Byte;
   sum: byte;
   i: word;
   b: word;
 const
   sums: array[0..$18] of byte = (
$095, $03A, $014, $04B, $058, $061, $0E4,
$090, $038, $0D6, $0F4, $06A, $074, $0CB,
$033, $093, $065, $070, $0BF, $0D6, $0A2,
$0B4, $03D, $01A, $06A);

 begin
   Assign(datFile, 'basic80.bin');
   Reset(datFile);
  i:=0;
sum:=0;   
b:=0;
   while not eof(datFile)           // keep reading as long as there is data to read
     do begin
       read(datFile, chrContent);   // reads a single character into chrContent variable
       sum:=sum+chrContent;
	i:=i+1;
	if i=256 then
        begin
           write('«®ª ', IntToHex(b,1), ' ‘ã¬¬  ', IntToHex(sum,1),' ');
		if sums[b]=sum then WriteLn('OK') else WriteLn('˜ˆŠ€');
	b:=b+1;      
		sum:=0;
		i:=0;
		if b=$19 then break;
	end;
     end;

   Close(datFile);
 end.
