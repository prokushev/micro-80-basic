{$DEFINE RK86}
Uses sysutils, dos;

 var
   datFile    : File of Byte;
   chrContent : Byte;
   sum: word;
   csum: word;
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
$06f,
$0e3, 
$0f1, 
$04B, 
$01e, 
$061, 
$0E4,
$090, 
$038, 
$0D6, 
$0F4, 
$06A, 
$074, 
$0CB,
$033, 
$093, 
$055, 
$070, 
$0BF, 
$0D6, 
$0A2,
$0B4, 
$03D, 
$074, 
$0f0, 
$0ff
{$ELSE}
$095, $03A, $014, $04B, $058, $061, $0E4,
$090, $038, $0D6, $0F4, $06A, $074, $0CB,
$033, $093, $065, $070, $0BF, $0D6, $0A2,
$0B4, $03D, $01A, $06A
{$ENDIF}
);
{$IFDEF RK86}
   csums: array[0..max] of byte = (
$03,
$37,
$26,
$71,
$C5,
$D0,
$D4,
$31,
$E6,
$7C,
$07,
$24,
$67,
$64,
$C5,
$FD,
$A4,
$B5,
$59,
$6B,
$18,
$11,
$DB,
$12,
$3C,
$57
);
{$ENDIF}

 begin
{$IFDEF RK86}
   Assign(datFile, 'basic80-rk86.bin');
{$ELSE}
   Assign(datFile, 'basic80.bin');
{$ENDIF}
   Reset(datFile);
   i:=0;
   sum:=0;   
   csum:=0;   
   b:=0;
   while not eof(datFile)           // keep reading as long as there is data to read
     do begin
       read(datFile, chrContent);   // reads a single character into chrContent variable
       sum:=sum+chrContent;
{$IFDEF RK86}
		if i<255 then csum:=csum+chrContent+(chrContent shl 8);
{$ENDIF}
		i:=i+1;
		if i=256 then
		begin
{$IFDEF RK86}
			sum:=byte(sum);
			write('«®ª ', IntToHex(b,1), ' ‘ã¬¬  ', IntToHex(byte(csum shr 8),2), IntToHex(sum,2),' ');
			if (sums[b]=sum) and (csums[b]=byte(csum shr 8)) then WriteLn('OK') else WriteLn('Ž˜ˆŠ€');
{$ELSE}
			write('«®ª ', IntToHex(b,2), ' ‘ã¬¬  ', IntToHex(sum,2),' ');
			if sums[b]=sum then WriteLn('OK') else WriteLn('Ž˜ˆŠ€');
{$ENDIF}
		b:=b+1;      
		sum:=0;
		csum:=0;
		i:=0;
		if b=max+1 then break;
	end;
end;

   Close(datFile);
 end.
