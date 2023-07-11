{

Программа проверки контрольных сумм для программ:
 - Бейсик для Микро-80
 - Бейсик для Радио-86РК
 - Бейсик-Сервис для Радио-86РК

}
Uses sysutils, dos;

type
	tsum=record
		s: word;
		e: word;
		sum: word;
	end;

var
  datFile    : File of Byte;
  chrContent : Byte;
  sum: word;
  csum: word;
  i: word;
  j: byte;
  b: word;
const
   max  = $18;
   micro80sums: array[0..max] of byte = (
$095, $03A, $014, $04B, $058, $061, $0E4,
$090, $038, $0D6, $0F4, $06A, $074, $0CB,
$033, $093, $065, $070, $0BF, $0D6, $0A2,
$0B4, $03D, $01A, $06A
);
	servicesums: array of tsum = (
		(s:$0000; e:$19FF; sum:$BDED),
		(s:$1A00; e:$1CFF; sum:$802D),
		(s:$0000; e:$1CFF; sum:$421A)
	);
	rk86sums: array of tsum = (
		(s:$0000; e:$19FF; sum:$1242),
		(s:$0000; e:$00ff; sum:$036f),
		(s:$0100; e:$01ff; sum:$37e3),
		(s:$0200; e:$02ff; sum:$26f1),
		(s:$0300; e:$03ff; sum:$714B),
		(s:$0400; e:$04ff; sum:$C51e),
		(s:$0500; e:$05ff; sum:$D061),
		(s:$0600; e:$06ff; sum:$D4E4),
		(s:$0700; e:$07ff; sum:$3190),
		(s:$0800; e:$08ff; sum:$E638),
		(s:$0900; e:$09ff; sum:$7CD6),
		(s:$0a00; e:$0aff; sum:$07F4),
		(s:$0b00; e:$0bff; sum:$246A),
		(s:$0c00; e:$0cff; sum:$6774),
		(s:$0d00; e:$0dff; sum:$64CB),
		(s:$0e00; e:$0eff; sum:$C533),
		(s:$0f00; e:$0fff; sum:$FD93),
		(s:$1000; e:$10ff; sum:$A455),
		(s:$1100; e:$11ff; sum:$B570),
		(s:$1200; e:$12ff; sum:$59BF),
		(s:$1300; e:$13ff; sum:$6BD6),
		(s:$1400; e:$14ff; sum:$18A2),
		(s:$1500; e:$15ff; sum:$11B4),
		(s:$1600; e:$16ff; sum:$DB3D),
		(s:$1700; e:$17ff; sum:$1274),
		(s:$1800; e:$18ff; sum:$3Cf0),
		(s:$1900; e:$19ff; sum:$57ff)
	);

Procedure CheckFile(filename: string; fsums: array of tsum);
begin
	WriteLn('Файл: ', filename);
	Assign(datFile, filename);
	Reset(datFile);

	for j:=low(fsums) to high(fsums) do
	begin
		Seek(datFile, fsums[j].s);
		i:=fsums[j].s;
		sum:=0;
		csum:=0;
		while (not eof(datFile)) and (i<=fsums[j].e) do
		begin
			read(datFile, chrContent);
			sum:=sum+chrContent;
			if i<fsums[j].e then csum:=csum+chrContent+(chrContent shl 8);
			i:=i+1;
		end;
		sum:=byte(sum);
		write('Блок ', IntToHex(fsums[j].s,4), '-', IntToHex(fsums[j].e,4), ' Сумма ', IntToHex(byte(csum shr 8),2), IntToHex(sum,2),' ');
		if (fsums[j].sum=sum+byte(csum shr 8) shl 8) then WriteLn('OK') else WriteLn('ОШИБКА');
		b:=b+1;      
		sum:=0;
		csum:=0;
	end;

	Close(datFile);
end;

Procedure CheckMicro80File(filename: string);
begin
	WriteLn('Файл: ', filename);
	Assign(datFile, filename);
	Reset(datFile);
	i:=0;
	sum:=0;
	b:=0;
	while not eof(datFile)
		do begin
		read(datFile, chrContent);
		sum:=sum+chrContent;
		i:=i+1;
		if i=256 then
		begin
			write('Блок ', IntToHex(b,2),'00-', IntToHex(b,2), 'FF Сумма ', IntToHex(byte(sum),2),' ');
			if micro80sums[b]=byte(sum) then WriteLn('OK') else WriteLn('ОШИБКА');
			b:=b+1;      
			sum:=0;
			csum:=0;
			i:=0;
			if b=max+1 then break;
		end;
	end;

	Close(datFile);
end;

begin
	CheckMicro80File('basic80.bin');
	CheckFile('basic80-rk86.bin', rk86sums);
	CheckFile('basic80-rk86-service.bin', servicesums);
end.
