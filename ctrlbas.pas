{$DEFINE RK86}
Uses sysutils, dos;

 var
   datFile    : File of Byte;
   chrContent : Byte;
   sum: byte;
   i: word;
   b: word;
 const
{$IFDEF RK86}
   max  = $19;
{$ELSE}
   max  = $18;
{$ENDIF}
   sums: array[0..max] of byte = (
{$IFDEF RK86}
$06f, $0e3, $0f1, $04B, $01e, $061, $0E4,
$090, $038, $0D6, $0F4, $06A, $074, $0CB,
$033, $093, $055, $070, $0BF, $0D6, $0A2,
$0B4, $03D, $074, $0f0, $0ff
{$ELSE}
$095, $03A, $014, $04B, $058, $061, $0E4,
$090, $038, $0D6, $0F4, $06A, $074, $0CB,
$033, $093, $065, $070, $0BF, $0D6, $0A2,
$0B4, $03D, $01A, $06A
{$ENDIF}
);

 begin
   Assign(datFile, 'basic80-rk86.bin');
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
           write('Å´Æ™ ', IntToHex(b,1), ' ë„¨¨† ', IntToHex(sum,1),' ');
		if sums[b]=sum then WriteLn('OK') else WriteLn('éòàÅäÄ');
	b:=b+1;      
		sum:=0;
		i:=0;
		if b=max+1 then break;
	end;
     end;

   Close(datFile);
 end.
