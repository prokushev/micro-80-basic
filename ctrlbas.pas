{

Программа проверки контрольных сумм для программ:
 - Бейсик для Микро-80
 - Бейсик для Радио-86РК
 - Бейсик-Сервис для Радио-86РК
 - Бейсик-Микрон для Радио-86РК

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
// Опубликовано в журнале
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

// Опубликовано в журнале + дополнительные проверки
	micron32ksums: array of tsum = (
		(s:$0000; e:$000F; sum:$0700),
		(s:$0010; e:$001F; sum:$1e16),
		(s:$0020; e:$002F; sum:$7336),
		(s:$0030; e:$003F; sum:$2cED),
		(s:$0040; e:$004F; sum:$ED0B),
		(s:$0050; e:$005F; sum:$3D36),
		(s:$0060; e:$006F; sum:$e8A9),
		(s:$0070; e:$007F; sum:$2024),
		(s:$0080; e:$008F; sum:$a66D),
		(s:$0090; e:$009F; sum:$9409),
		(s:$00A0; e:$00AF; sum:$ffDB),
		(s:$00B0; e:$00BF; sum:$24E9),
		(s:$00C0; e:$00CF; sum:$2155),
		(s:$00D0; e:$00DF; sum:$a82F),
		(s:$00E0; e:$00EF; sum:$f107),
		(s:$00F0; e:$00FF; sum:$3852),
		(s:$0000; e:$00FF; sum:$A85E),

		(s:$0100; e:$010F; sum:$A4A5),
		(s:$0110; e:$011F; sum:$dcA7),
		(s:$0120; e:$012F; sum:$d4B7),
		(s:$0130; e:$013F; sum:$c002),
		(s:$0140; e:$014F; sum:$726B),
		(s:$0150; e:$015F; sum:$b0CB),
		(s:$0160; e:$016F; sum:$819F),
		(s:$0170; e:$017F; sum:$9eBB),
		(s:$0180; e:$018F; sum:$7f79),
		(s:$0190; e:$019F; sum:$567C),
		(s:$01A0; e:$01AF; sum:$6319),
		(s:$01B0; e:$01BF; sum:$b5E8),
		(s:$01C0; e:$01CF; sum:$3a58),
		(s:$01D0; e:$01DF; sum:$e2FC),
		(s:$01E0; e:$01EF; sum:$6527),
		(s:$01F0; e:$01FF; sum:$605D),
		(s:$0100; e:$01FF; sum:$C163),

{		(s:$0200; e:$020F; sum:$7973),
		(s:$0210; e:$021F; sum:$6B65),
		(s:$0220; e:$022F; sum:$FFFA),
		(s:$0230; e:$023F; sum:$2B23),
		(s:$0240; e:$024F; sum:$DDD7),
		(s:$0250; e:$025F; sum:$CCC7),
		(s:$0260; e:$026F; sum:$DDD6),
		(s:$0270; e:$027F; sum:$0602),
		(s:$0280; e:$028F; sum:$9189),
		(s:$0290; e:$029F; sum:$D7CF),
		(s:$02A0; e:$02AF; sum:$DFDA),
		(s:$02B0; e:$02BF; sum:$4E48),
		(s:$02C0; e:$02CF; sum:$F6F0),
		(s:$02D0; e:$02DF; sum:$E2D9),
		(s:$02E0; e:$02EF; sum:$120B),
		(s:$02F0; e:$02FF; sum:$02FD),}
		(s:$0200; e:$02FF; sum:$61B6),

{		(s:$0300; e:$030F; sum:$A098),
		(s:$0310; e:$031F; sum:$322D),
		(s:$0320; e:$032F; sum:$C2BD),
		(s:$0330; e:$033F; sum:$BFB9),
		(s:$0340; e:$034F; sum:$BAB2),
		(s:$0350; e:$035F; sum:$CBC5),
		(s:$0360; e:$036F; sum:$9791),
		(s:$0370; e:$037F; sum:$6C66),
		(s:$0380; e:$038F; sum:$776F),
		(s:$0390; e:$039F; sum:$544F),
		(s:$03A0; e:$03AF; sum:$F9F0),
		(s:$03B0; e:$03BF; sum:$AEA7),
		(s:$03C0; e:$03CF; sum:$C0B8),
		(s:$03D0; e:$03DF; sum:$3F35),
		(s:$03E0; e:$03EF; sum:$A39D),
		(s:$03F0; e:$03FF; sum:$9088),}
		(s:$0300; e:$03FF; sum:$5D10),

{		(s:$0400; e:$040F; sum:$8880),
		(s:$0410; e:$041F; sum:$F1EB),
		(s:$0420; e:$042F; sum:$938A),
		(s:$0430; e:$043F; sum:$9A94),
		(s:$0440; e:$044F; sum:$4E47),
		(s:$0450; e:$045F; sum:$5C56),
		(s:$0460; e:$046F; sum:$1D14),
		(s:$0470; e:$047F; sum:$9A95),
		(s:$0480; e:$048F; sum:$928B),
		(s:$0490; e:$049F; sum:$0901),
		(s:$04A0; e:$04AF; sum:$00FA),
		(s:$04B0; e:$04BF; sum:$665E),
		(s:$04C0; e:$04CF; sum:$807B),
		(s:$04D0; e:$04DF; sum:$C8C2),
		(s:$04E0; e:$04EF; sum:$0E08),
		(s:$04F0; e:$04FF; sum:$DAD1),}
		(s:$0400; e:$04FF; sum:$2BC9),

{		(s:$0500; e:$050F; sum:$9A96),
		(s:$0510; e:$051F; sum:$6862),
		(s:$0520; e:$052F; sum:$423B),
		(s:$0530; e:$053F; sum:$CCC6),
		(s:$0540; e:$054F; sum:$655E),
		(s:$0550; e:$055F; sum:$605B),
		(s:$0560; e:$056F; sum:$EEE8),
		(s:$0570; e:$057F; sum:$AFA8),
		(s:$0580; e:$058F; sum:$4B44),
		(s:$0590; e:$059F; sum:$E7E1),
		(s:$05A0; e:$05AF; sum:$CDC8),
		(s:$05B0; e:$05BF; sum:$DFDA),
		(s:$05C0; e:$05CF; sum:$3E37),
		(s:$05D0; e:$05DF; sum:$756D),
		(s:$05E0; e:$05EF; sum:$C6C0),
		(s:$05F0; e:$05FF; sum:$F5EE),}
		(s:$0500; e:$05FF; sum:$175B),

		{(s:$0600; e:$060F; sum:$D1C7),
		(s:$0610; e:$061F; sum:$E2DA),
		(s:$0620; e:$062F; sum:$F6F1),
		(s:$0630; e:$063F; sum:$7169),
		(s:$0640; e:$064F; sum:$8980),
		(s:$0650; e:$065F; sum:$9E97),
		(s:$0660; e:$066F; sum:$D7D0),
		(s:$0670; e:$067F; sum:$A099),
		(s:$0680; e:$068F; sum:$544E),
		(s:$0690; e:$069F; sum:$3E37),
		(s:$06A0; e:$06AF; sum:$7C75),
		(s:$06B0; e:$06BF; sum:$756E),
		(s:$06C0; e:$06CF; sum:$857F),
		(s:$06D0; e:$06DF; sum:$756F),
		(s:$06E0; e:$06EF; sum:$00FA),
		(s:$06F0; e:$06FF; sum:$908B),}
		(s:$0600; e:$06FF; sum:$C956),

		{(s:$0700; e:$070F; sum:$2F26),
		(s:$0710; e:$071F; sum:$2F26),
		(s:$0720; e:$072F; sum:$9B96),
		(s:$0730; e:$073F; sum:$4943),
		(s:$0740; e:$074F; sum:$0902),
		(s:$0750; e:$075F; sum:$E1D9),
		(s:$0760; e:$076F; sum:$2019),
		(s:$0770; e:$077F; sum:$0F08),
		(s:$0780; e:$078F; sum:$2018),
		(s:$0790; e:$079F; sum:$B1AB),
		(s:$07A0; e:$07AF; sum:$857E),
		(s:$07B0; e:$07BF; sum:$4C45),
		(s:$07C0; e:$07CF; sum:$423C),
		(s:$07D0; e:$07DF; sum:$EEE5),
		(s:$07E0; e:$07EF; sum:$8981),
		(s:$07F0; e:$07FF; sum:$5048),}
		(s:$0700; e:$07FF; sum:$5991),

		{(s:$0800; e:$080F; sum:$9A94),
		(s:$0810; e:$081F; sum:$6F67),
		(s:$0820; e:$082F; sum:$1914),
		(s:$0830; e:$083F; sum:$E0D7),
		(s:$0840; e:$084F; sum:$BEB5),
		(s:$0850; e:$085F; sum:$8C87),
		(s:$0860; e:$086F; sum:$C8C2),
		(s:$0870; e:$087F; sum:$9691),
		(s:$0880; e:$088F; sum:$BAB4),
		(s:$0890; e:$089F; sum:$4942),
		(s:$08A0; e:$08AF; sum:$D3CC),
		(s:$08B0; e:$08BF; sum:$C8C2),
		(s:$08C0; e:$08CF; sum:$948E),
		(s:$08D0; e:$08DF; sum:$ACA6),
		(s:$08E0; e:$08EF; sum:$605A),
		(s:$08F0; e:$08FF; sum:$CBC3),}
		(s:$0800; e:$08FF; sum:$AA4A),

		{(s:$0900; e:$090F; sum:$CDC5),
		(s:$0910; e:$091F; sum:$574D),
		(s:$0920; e:$092F; sum:$6056),
		(s:$0930; e:$093F; sum:$8E87),
		(s:$0940; e:$094F; sum:$948D),
		(s:$0950; e:$095F; sum:$130C),
		(s:$0960; e:$096F; sum:$E7E0),
		(s:$0970; e:$097F; sum:$BDB6),
		(s:$0980; e:$098F; sum:$1E15),
		(s:$0990; e:$099F; sum:$4C46),
		(s:$09A0; e:$09AF; sum:$BBB3),
		(s:$09B0; e:$09BF; sum:$04FC),
		(s:$09C0; e:$09CF; sum:$AEA6),
		(s:$09D0; e:$09DF; sum:$8680),
		(s:$09E0; e:$09EF; sum:$01FA),
		(s:$09F0; e:$09FF; sum:$261D),}
		(s:$0900; e:$09FF; sum:$1B65),

		{(s:$0A00; e:$0A0F; sum:$8B82),
		(s:$0A10; e:$0A1F; sum:$211C),
		(s:$0A20; e:$0A2F; sum:$1B13),
		(s:$0A30; e:$0A3F; sum:$5A54),
		(s:$0A40; e:$0A4F; sum:$C4BD),
		(s:$0A50; e:$0A5F; sum:$C9C3),
		(s:$0A60; e:$0A6F; sum:$C3BC),
		(s:$0A70; e:$0A7F; sum:$BEB9),
		(s:$0A80; e:$0A8F; sum:$F7F2),
		(s:$0A90; e:$0A9F; sum:$D2CB),
		(s:$0AA0; e:$0AAF; sum:$3B37),
		(s:$0AB0; e:$0ABF; sum:$FFFA),
		(s:$0AC0; e:$0ACF; sum:$3129),
		(s:$0AD0; e:$0ADF; sum:$140A),
		(s:$0AE0; e:$0AEF; sum:$5D57),
		(s:$0AF0; e:$0AFF; sum:$8A84),}
		(s:$0A00; e:$0AFF; sum:$E7F6),

		{(s:$0B00; e:$0B0F; sum:$03FE),
		(s:$0B10; e:$0B1F; sum:$857F),
		(s:$0B20; e:$0B2F; sum:$0904),
		(s:$0B30; e:$0B3F; sum:$3F3C),
		(s:$0B40; e:$0B4F; sum:$FFF9),
		(s:$0B50; e:$0B5F; sum:$9993),
		(s:$0B60; e:$0B6F; sum:$9C98),
		(s:$0B70; e:$0B7F; sum:$403B),
		(s:$0B80; e:$0B8F; sum:$D3CE),
		(s:$0B90; e:$0B9F; sum:$726C),
		(s:$0BA0; e:$0BAF; sum:$A9A4),
		(s:$0BB0; e:$0BBF; sum:$0C05),
		(s:$0BC0; e:$0BCF; sum:$E8E4),
		(s:$0BD0; e:$0BDF; sum:$9B95),
		(s:$0BE0; e:$0BEF; sum:$908A),
		(s:$0BF0; e:$0BFF; sum:$463F),}
		(s:$0B00; e:$0BFF; sum:$C941),

		{(s:$0C00; e:$0C0F; sum:$4940),
		(s:$0C10; e:$0C1F; sum:$3F37),
		(s:$0C20; e:$0C2F; sum:$E9E2),
		(s:$0C30; e:$0C3F; sum:$9D96),
		(s:$0C40; e:$0C4F; sum:$7E78),
		(s:$0C50; e:$0C5F; sum:$E8E2),
		(s:$0C60; e:$0C6F; sum:$CAC1),
		(s:$0C70; e:$0C7F; sum:$6C66),
		(s:$0C80; e:$0C8F; sum:$5952),
		(s:$0C90; e:$0C9F; sum:$433B),
		(s:$0CA0; e:$0CAF; sum:$C9C6),
		(s:$0CB0; e:$0CBF; sum:$E4DF),
		(s:$0CC0; e:$0CCF; sum:$2C25),
		(s:$0CD0; e:$0CDF; sum:$211A),
		(s:$0CE0; e:$0CEF; sum:$E4DE),
		(s:$0CF0; e:$0CFF; sum:$2D26),}
		(s:$0C00; e:$0CFF; sum:$37E5),

		{(s:$0D00; e:$0D0F; sum:$635F),
		(s:$0D10; e:$0D1F; sum:$4641),
		(s:$0D20; e:$0D2F; sum:$A09A),
		(s:$0D30; e:$0D3F; sum:$6961),
		(s:$0D40; e:$0D4F; sum:$DDD9),
		(s:$0D50; e:$0D5F; sum:$8A82),
		(s:$0D60; e:$0D6F; sum:$0900),
		(s:$0D70; e:$0D7F; sum:$6E62),
		(s:$0D80; e:$0D8F; sum:$1712),
		(s:$0D90; e:$0D9F; sum:$E2DD),
		(s:$0DA0; e:$0DAF; sum:$9992),
		(s:$0DB0; e:$0DBF; sum:$948D),
		(s:$0DC0; e:$0DCF; sum:$534A),
		(s:$0DD0; e:$0DDF; sum:$847B),
		(s:$0DE0; e:$0DEF; sum:$A19C),
		(s:$0DF0; e:$0DFF; sum:$746F),}
		(s:$0D00; e:$0DFF; sum:$D336),

		{(s:$0E00; e:$0E0F; sum:$1915),
		(s:$0E10; e:$0E1F; sum:$C6BF),
		(s:$0E20; e:$0E2F; sum:$B5AE),
		(s:$0E30; e:$0E3F; sum:$3932),
		(s:$0E40; e:$0E4F; sum:$837C),
		(s:$0E50; e:$0E5F; sum:$837D),
		(s:$0E60; e:$0E6F; sum:$1C14),
		(s:$0E70; e:$0E7F; sum:$322A),
		(s:$0E80; e:$0E8F; sum:$1209),
		(s:$0E90; e:$0E9F; sum:$0E07),
		(s:$0EA0; e:$0EAF; sum:$A59E),
		(s:$0EB0; e:$0EBF; sum:$6D67),
		(s:$0EC0; e:$0ECF; sum:$0A01),
		(s:$0ED0; e:$0EDF; sum:$A6A0),
		(s:$0EE0; e:$0EEF; sum:$918A),
		(s:$0EF0; e:$0EFF; sum:$C2BC),}
		(s:$0E00; e:$0EFF; sum:$49E7),

		{(s:$0F00; e:$0F0F; sum:$120A),
		(s:$0F10; e:$0F1F; sum:$00F9),
		(s:$0F20; e:$0F2F; sum:$746C),
		(s:$0F30; e:$0F3F; sum:$E1D9),
		(s:$0F40; e:$0F4F; sum:$8A84),
		(s:$0F50; e:$0F5F; sum:$D4CD),
		(s:$0F60; e:$0F6F; sum:$8F88),
		(s:$0F70; e:$0F7F; sum:$3A33),
		(s:$0F80; e:$0F8F; sum:$8E88),
		(s:$0F90; e:$0F9F; sum:$3933),
		(s:$0FA0; e:$0FAF; sum:$130B),
		(s:$0FB0; e:$0FBF; sum:$1A14),
		(s:$0FC0; e:$0FCF; sum:$302A),
		(s:$0FD0; e:$0FDF; sum:$3C35),
		(s:$0FE0; e:$0FEF; sum:$7D77),
		(s:$0FF0; e:$0FFF; sum:$5B55),}
		(s:$0F00; e:$0FFF; sum:$DC59),

		{(s:$1000; e:$100F; sum:$2924),
		(s:$1010; e:$101F; sum:$7F7A),
		(s:$1020; e:$102F; sum:$CFC8),
		(s:$1030; e:$103F; sum:$D5D2),
		(s:$1040; e:$104F; sum:$C4BE),
		(s:$1050; e:$105F; sum:$847F),
		(s:$1060; e:$106F; sum:$231E),
		(s:$1070; e:$107F; sum:$2B24),
		(s:$1080; e:$108F; sum:$DBD6),
		(s:$1090; e:$109F; sum:$120B),
		(s:$10A0; e:$10AF; sum:$7671),
		(s:$10B0; e:$10BF; sum:$7069),
		(s:$10C0; e:$10CF; sum:$3934),
		(s:$10D0; e:$10DF; sum:$B2AC),
		(s:$10E0; e:$10EF; sum:$645F),
		(s:$10F0; e:$10FF; sum:$1007),}
		(s:$1000; e:$10FF; sum:$38B8),

		{(s:$1100; e:$110F; sum:$3C37),
		(s:$1110; e:$111F; sum:$6A65),
		(s:$1120; e:$112F; sum:$D9D2),
		(s:$1130; e:$113F; sum:$4640),
		(s:$1140; e:$114F; sum:$06FE),
		(s:$1150; e:$115F; sum:$1910),
		(s:$1160; e:$116F; sum:$9E99),
		(s:$1170; e:$117F; sum:$CDC8),
		(s:$1180; e:$118F; sum:$605B),
		(s:$1190; e:$119F; sum:$1D15),
		(s:$11A0; e:$11AF; sum:$F3EC),
		(s:$11B0; e:$11BF; sum:$7874),
		(s:$11C0; e:$11CF; sum:$4E4A),
		(s:$11D0; e:$11DF; sum:$A7A3),
		(s:$11E0; e:$11EF; sum:$2019),
		(s:$11F0; e:$11FF; sum:$1C13),}
		(s:$1100; e:$11FF; sum:$AE06),

		{(s:$1200; e:$120F; sum:$B5AD),
		(s:$1210; e:$121F; sum:$A59D),
		(s:$1220; e:$122F; sum:$6B64),
		(s:$1230; e:$123F; sum:$140D),
		(s:$1240; e:$124F; sum:$5851),
		(s:$1250; e:$125F; sum:$A6A0),
		(s:$1260; e:$126F; sum:$CEC9),
		(s:$1270; e:$127F; sum:$FEF7),
		(s:$1280; e:$128F; sum:$928B),
		(s:$1290; e:$129F; sum:$E3DA),
		(s:$12A0; e:$12AF; sum:$4940),
		(s:$12B0; e:$12BF; sum:$B3AC),
		(s:$12C0; e:$12CF; sum:$877E),
		(s:$12D0; e:$12DF; sum:$4D43),
		(s:$12E0; e:$12EF; sum:$8F87),
		(s:$12F0; e:$12FF; sum:$EAE1),}
		(s:$1200; e:$12FF; sum:$9CE6),

		{(s:$1300; e:$130F; sum:$0802),
		(s:$1310; e:$131F; sum:$5148),
		(s:$1320; e:$132F; sum:$5E58),
		(s:$1330; e:$133F; sum:$7E76),
		(s:$1340; e:$134F; sum:$F4ED),
		(s:$1350; e:$135F; sum:$5B53),
		(s:$1360; e:$136F; sum:$BFBA),
		(s:$1370; e:$137F; sum:$5A54),
		(s:$1380; e:$138F; sum:$A69F),
		(s:$1390; e:$139F; sum:$ACA6),
		(s:$13A0; e:$13AF; sum:$FFF9),
		(s:$13B0; e:$13BF; sum:$B8B0),
		(s:$13C0; e:$13CF; sum:$6762),
		(s:$13D0; e:$13DF; sum:$716B),
		(s:$13E0; e:$13EF; sum:$D6CF),
		(s:$13F0; e:$13FF; sum:$3A37),}
		(s:$1300; e:$13FF; sum:$8C27),

		{(s:$1400; e:$140F; sum:$2924),
		(s:$1410; e:$141F; sum:$574E),
		(s:$1420; e:$142F; sum:$03FB),
		(s:$1430; e:$143F; sum:$F6EF),
		(s:$1440; e:$144F; sum:$A099),
		(s:$1450; e:$145F; sum:$B7B2),
		(s:$1460; e:$146F; sum:$A6A0),
		(s:$1470; e:$147F; sum:$E0D9),
		(s:$1480; e:$148F; sum:$C0BC),
		(s:$1490; e:$149F; sum:$7E78),
		(s:$14A0; e:$14AF; sum:$A6A0),
		(s:$14B0; e:$14BF; sum:$0F07),
		(s:$14C0; e:$14CF; sum:$EEE6),
		(s:$14D0; e:$14DF; sum:$E4DC),
		(s:$14E0; e:$14EF; sum:$514A),
		(s:$14F0; e:$14FF; sum:$908B),}
		(s:$1400; e:$14FF; sum:$F492),

		{(s:$1500; e:$150F; sum:$B9B4),
		(s:$1510; e:$151F; sum:$716C),
		(s:$1520; e:$152F; sum:$05FE),
		(s:$1530; e:$153F; sum:$7F79),
		(s:$1540; e:$154F; sum:$827B),
		(s:$1550; e:$155F; sum:$F3EF),
		(s:$1560; e:$156F; sum:$02FC),
		(s:$1570; e:$157F; sum:$E2D9),
		(s:$1580; e:$158F; sum:$3E36),
		(s:$1590; e:$159F; sum:$1810),
		(s:$15A0; e:$15AF; sum:$E3DF),
		(s:$15B0; e:$15BF; sum:$3A34),
		(s:$15C0; e:$15CF; sum:$1C14),
		(s:$15D0; e:$15DF; sum:$EBE5),
		(s:$15E0; e:$15EF; sum:$4942),
		(s:$15F0; e:$15FF; sum:$E1D9),}
		(s:$1500; e:$15FF; sum:$CA43),

		{(s:$1600; e:$160F; sum:$6B68),
		(s:$1610; e:$161F; sum:$3531),
		(s:$1620; e:$162F; sum:$706A),
		(s:$1630; e:$163F; sum:$2B23),
		(s:$1640; e:$164F; sum:$5C58),
		(s:$1650; e:$165F; sum:$150C),
		(s:$1660; e:$166F; sum:$645D),
		(s:$1670; e:$167F; sum:$05FE),
		(s:$1680; e:$168F; sum:$A7A0),
		(s:$1690; e:$169F; sum:$EEE9),
		(s:$16A0; e:$16AF; sum:$2E27),
		(s:$16B0; e:$16BF; sum:$A39A),
		(s:$16C0; e:$16CF; sum:$CDC7),
		(s:$16D0; e:$16DF; sum:$453E),
		(s:$16E0; e:$16EF; sum:$7E77),
		(s:$16F0; e:$16FF; sum:$0903),}
		(s:$1600; e:$16FF; sum:$2EAE),

		{(s:$1700; e:$170F; sum:$443E),
		(s:$1710; e:$171F; sum:$6962),
		(s:$1720; e:$172F; sum:$6159),
		(s:$1730; e:$173F; sum:$CFC6),
		(s:$1740; e:$174F; sum:$2017),
		(s:$1750; e:$175F; sum:$F6F1),
		(s:$1760; e:$176F; sum:$EEE7),
		(s:$1770; e:$177F; sum:$A29D),
		(s:$1780; e:$178F; sum:$9590),
		(s:$1790; e:$179F; sum:$00FA),
		(s:$17A0; e:$17AF; sum:$ABA6),
		(s:$17B0; e:$17BF; sum:$ECE5),
		(s:$17C0; e:$17CF; sum:$FDF6),
		(s:$17D0; e:$17DF; sum:$F3E9),
		(s:$17E0; e:$17EF; sum:$7D74),
		(s:$17F0; e:$17FF; sum:$6D66),}
		(s:$1700; e:$17FF; sum:$7B19),

		{(s:$1800; e:$180F; sum:$948D),
		(s:$1810; e:$181F; sum:$4138),
		(s:$1820; e:$182F; sum:$C2BE),
		(s:$1830; e:$183F; sum:$211A),
		(s:$1840; e:$184F; sum:$4A44),
		(s:$1850; e:$185F; sum:$D3CF),
		(s:$1860; e:$186F; sum:$9490),
		(s:$1870; e:$187F; sum:$0400),
		(s:$1880; e:$188F; sum:$968F),
		(s:$1890; e:$189F; sum:$B1AD),
		(s:$18A0; e:$18AF; sum:$433B),
		(s:$18B0; e:$18BF; sum:$433C),
		(s:$18C0; e:$18CF; sum:$0A00),
		(s:$18D0; e:$18DF; sum:$4F49),
		(s:$18E0; e:$18EF; sum:$514E),
		(s:$18F0; e:$18FF; sum:$A29B),}
		(s:$1800; e:$18FF; sum:$3C25),

		{(s:$1900; e:$190F; sum:$312A),
		(s:$1910; e:$191F; sum:$140D),
		(s:$1920; e:$192F; sum:$C5C0),
		(s:$1930; e:$193F; sum:$05FF),
		(s:$1940; e:$194F; sum:$8782),
		(s:$1950; e:$195F; sum:$5752),
		(s:$1960; e:$196F; sum:$4944),
		(s:$1970; e:$197F; sum:$948F),
		(s:$1980; e:$198F; sum:$4D47),
		(s:$1990; e:$199F; sum:$D1C9),
		(s:$19A0; e:$19AF; sum:$8581),
		(s:$19B0; e:$19BF; sum:$CCC9),
		(s:$19C0; e:$19CF; sum:$1D17),
		(s:$19D0; e:$19DF; sum:$645C),
		(s:$19E0; e:$19EF; sum:$9F9C),
		(s:$19F0; e:$19FF; sum:$9893),}
		(s:$1900; e:$19FF; sum:$7499),

		{(s:$1A00; e:$1A0F; sum:$EFEC),
		(s:$1A10; e:$1A1F; sum:$110B),
		(s:$1A20; e:$1A2F; sum:$908C),
		(s:$1A30; e:$1A3F; sum:$170D),
		(s:$1A40; e:$1A4F; sum:$F0E9),
		(s:$1A50; e:$1A5F; sum:$D5CF),
		(s:$1A60; e:$1A6F; sum:$7A73),
		(s:$1A70; e:$1A7F; sum:$342C),
		(s:$1A80; e:$1A8F; sum:$FDF8),
		(s:$1A90; e:$1A9F; sum:$DDD5),
		(s:$1AA0; e:$1AAF; sum:$7F7A),
		(s:$1AB0; e:$1ABF; sum:$2117),
		(s:$1AC0; e:$1ACF; sum:$8B83),
		(s:$1AD0; e:$1ADF; sum:$100C),
		(s:$1AE0; e:$1AEF; sum:$B9B2),
		(s:$1AF0; e:$1AFF; sum:$E6DF),}
		(s:$1A00; e:$1AFF; sum:$0665),

		{(s:$1B00; e:$1B0F; sum:$D8D1),
		(s:$1B10; e:$1B1F; sum:$A69F),
		(s:$1B20; e:$1B2F; sum:$F7F1),
		(s:$1B30; e:$1B3F; sum:$EAE4),
		(s:$1B40; e:$1B4F; sum:$FBF4),
		(s:$1B50; e:$1B5F; sum:$A49F),
		(s:$1B60; e:$1B6F; sum:$EAE4),
		(s:$1B70; e:$1B7F; sum:$756F),
		(s:$1B80; e:$1B8F; sum:$7872),
		(s:$1B90; e:$1B9F; sum:$2E27),
		(s:$1BA0; e:$1BAF; sum:$251C),
		(s:$1BB0; e:$1BBF; sum:$C1B9),
		(s:$1BC0; e:$1BCF; sum:$BEBA),
		(s:$1BD0; e:$1BDF; sum:$B4AD),
		(s:$1BE0; e:$1BEF; sum:$5B56),
		(s:$1BF0; e:$1BFF; sum:$00F8),}
		(s:$1B00; e:$1BFF; sum:$AA4E),

		{(s:$1C00; e:$1C0F; sum:$8F87),
		(s:$1C10; e:$1C1F; sum:$827B),
		(s:$1C20; e:$1C2F; sum:$6D68),
		(s:$1C30; e:$1C3F; sum:$C3BF),
		(s:$1C40; e:$1C4F; sum:$FAF6),
		(s:$1C50; e:$1C5F; sum:$3D36),
		(s:$1C60; e:$1C6F; sum:$F9F5),
		(s:$1C70; e:$1C7F; sum:$140B),
		(s:$1C80; e:$1C8F; sum:$9790),
		(s:$1C90; e:$1C9F; sum:$6761),
		(s:$1CA0; e:$1CAF; sum:$3129),
		(s:$1CB0; e:$1CBF; sum:$807B),
		(s:$1CC0; e:$1CCF; sum:$7F78),
		(s:$1CD0; e:$1CDF; sum:$736E),
		(s:$1CE0; e:$1CEF; sum:$514B),
		(s:$1CF0; e:$1CFF; sum:$938F),}
		(s:$1C00; e:$1CFF; sum:$11AA),

		{(s:$1D00; e:$1D0F; sum:$DBD6),
		(s:$1D10; e:$1D1F; sum:$847F),
		(s:$1D20; e:$1D2F; sum:$605A),
		(s:$1D30; e:$1D3F; sum:$AFAA),
		(s:$1D40; e:$1D4F; sum:$342E),
		(s:$1D50; e:$1D5F; sum:$2C26),
		(s:$1D60; e:$1D6F; sum:$EAE5),
		(s:$1D70; e:$1D7F; sum:$4A45),
		(s:$1D80; e:$1D8F; sum:$140E),
		(s:$1D90; e:$1D9F; sum:$D1CC),
		(s:$1DA0; e:$1DAF; sum:$C9C5),
		(s:$1DB0; e:$1DBF; sum:$4C47),
		(s:$1DC0; e:$1DCF; sum:$524E),
		(s:$1DD0; e:$1DDF; sum:$6A66),
		(s:$1DE0; e:$1DEF; sum:$726E),
		(s:$1DF0; e:$1DFF; sum:$1A16),}
		(s:$1D00; e:$1DFF; sum:$E3F5),

		{(s:$1E00; e:$1E0F; sum:$01FC),
		(s:$1E10; e:$1E1F; sum:$B6B0),
		(s:$1E20; e:$1E2F; sum:$5C55),
		(s:$1E30; e:$1E3F; sum:$726C),
		(s:$1E40; e:$1E4F; sum:$7F78),
		(s:$1E50; e:$1E5F; sum:$B0AA),
		(s:$1E60; e:$1E6F; sum:$3933),
		(s:$1E70; e:$1E7F; sum:$1C15),
		(s:$1E80; e:$1E8F; sum:$322B),
		(s:$1E90; e:$1E9F; sum:$ABA2),
		(s:$1EA0; e:$1EAF; sum:$564F),
		(s:$1EB0; e:$1EBF; sum:$645D),
		(s:$1EC0; e:$1ECF; sum:$4039),
		(s:$1ED0; e:$1EDF; sum:$F8F2),
		(s:$1EE0; e:$1EEF; sum:$BEB9),
		(s:$1EF0; e:$1EFF; sum:$1D17),}
		(s:$1E00; e:$1EFF; sum:$784B),

		{(s:$1F00; e:$1F0F; sum:$4A44),
		(s:$1F10; e:$1F1F; sum:$1C16),
		(s:$1F20; e:$1F2F; sum:$1C15),
		(s:$1F30; e:$1F3F; sum:$433C),
		(s:$1F40; e:$1F4F; sum:$B5B0),
		(s:$1F50; e:$1F5F; sum:$4441),
		(s:$1F60; e:$1F6F; sum:$2B27),
		(s:$1F70; e:$1F7F; sum:$332E),
		(s:$1F80; e:$1F8F; sum:$8380),
		(s:$1F90; e:$1F9F; sum:$241F),
		(s:$1FA0; e:$1FAF; sum:$4F4A),
		(s:$1FB0; e:$1FBF; sum:$F2EF),
		(s:$1FC0; e:$1FCF; sum:$FEFB),
		(s:$1FD0; e:$1FDF; sum:$DFDC),
		(s:$1FE0; e:$1FEF; sum:$3531),
		(s:$1FF0; e:$1FFF; sum:$5F5B),}
		(s:$1F00; e:$1FFF; sum:$422C),

		(s:$0000; e:$1FFF; sum:$55C1)
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
	CheckMicro80File('bin\micro-80\basic80-16kb.bin');
	CheckFile('bin\radio-86rk\basic80-rk86-16kb.bin', rk86sums);
	CheckFile('bin\radio-86rk\basic80-rk86-service-16kb.bin', servicesums2);
	CheckFile('bin\radio-86rk\basic80-rk86-service-16kb.bin', servicesums);
	CheckFile('bin\radio-86rk\basic-rk86-micron-32kb.bin', micron32ksums);
end.
