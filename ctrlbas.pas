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
// Опубликовано в журнале
	servicesums: array of tsum = (
		(s:$0000; e:$19FF; sum:$BDED),
		(s:$1A00; e:$1CFF; sum:$802D),
		(s:$0000; e:$1CFF; sum:$421A)
	);
// Сгенерировано заново, более подробно
	servicesums2: array of tsum = (
		(s:$1A00; e:$1A0F; sum:$4506),
		(s:$1A10; e:$1A1F; sum:$354b),
		(s:$1A20; e:$1A2F; sum:$7724),
		(s:$1A30; e:$1A3F; sum:$C5BB),
		(s:$1A40; e:$1A4F; sum:$F344),
		(s:$1A50; e:$1A5F; sum:$F0B0),
		(s:$1A60; e:$1A6F; sum:$5F67),
		(s:$1A70; e:$1A7F; sum:$A9C1),
		(s:$1A80; e:$1A8F; sum:$AFD0),
		(s:$1A90; e:$1A9F; sum:$3C33),
		(s:$1AA0; e:$1AAF; sum:$97D8),
		(s:$1AB0; e:$1ABF; sum:$E8A9),
		(s:$1AC0; e:$1ACF; sum:$06C9),
		(s:$1AD0; e:$1ADF; sum:$37FE),
		(s:$1AE0; e:$1AEF; sum:$F870),
		(s:$1AF0; e:$1AFF; sum:$4347),

		(s:$1B00; e:$1B0F; sum:$BABD),
		(s:$1B10; e:$1B1F; sum:$BDD4),
		(s:$1B20; e:$1B2F; sum:$0C22),
		(s:$1B30; e:$1B3F; sum:$3E15),
		(s:$1B40; e:$1B4F; sum:$ACA9),
		(s:$1B50; e:$1B5F; sum:$6028),
		(s:$1B60; e:$1B6F; sum:$EDAA),
		(s:$1B70; e:$1B7F; sum:$6966),
		(s:$1B80; e:$1B8F; sum:$DC8F),
		(s:$1B90; e:$1B9F; sum:$7F29),
		(s:$1BA0; e:$1BAF; sum:$69A8),
		(s:$1BB0; e:$1BBF; sum:$310f),
		(s:$1BC0; e:$1BCF; sum:$B79c),
		(s:$1BD0; e:$1BDF; sum:$8786),
		(s:$1BE0; e:$1BEF; sum:$8BB8),
		(s:$1BF0; e:$1BFF; sum:$8097),

		(s:$1C00; e:$1C0F; sum:$01D7),
		(s:$1C10; e:$1C1F; sum:$6AE8),
		(s:$1C20; e:$1C2F; sum:$FD13),
		(s:$1C30; e:$1C3F; sum:$2516),
		(s:$1C40; e:$1C4F; sum:$74A5),
		(s:$1C50; e:$1C5F; sum:$29ED),
		(s:$1C60; e:$1C6F; sum:$9991),
		(s:$1C70; e:$1C7F; sum:$9515),
		(s:$1C80; e:$1C8F; sum:$6DFD),
		(s:$1C90; e:$1C9F; sum:$7412),
		(s:$1CA0; e:$1CAF; sum:$DEF3),
		(s:$1CB0; e:$1CBF; sum:$7629),
		(s:$1CC0; e:$1CCF; sum:$E1F6),
		(s:$1CD0; e:$1CDF; sum:$E1E0),
		(s:$1CE0; e:$1CEF; sum:$4F54),
		(s:$1CF0; e:$1CFF; sum:$E3E1)
	);
// Опубликовано в журнале
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
		
		if not (fsums[j].sum=sum+byte(csum shr 8) shl 8) then
		begin
			write('Блок ', IntToHex(fsums[j].s,4), '-', IntToHex(fsums[j].e,4), ' Сумма ', IntToHex(byte(csum shr 8),2), IntToHex(sum,2),' ');
			WriteLn('ОШИБКА');
			Halt(255);
		end;
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
			if not (micro80sums[b]=byte(sum)) then
			begin
				write('Блок ', IntToHex(b,2),'00-', IntToHex(b,2), 'FF Сумма ', IntToHex(byte(sum),2),' ');
				WriteLn('ОШИБКА');
				Halt(255);
			end;
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
	CheckFile('basic80-rk86-service.bin', servicesums2);
	CheckFile('basic80-rk86-service.bin', servicesums);
end.
