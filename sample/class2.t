#
#  USAGE: perl -MTest::Harness -e "runtests('class2.t')"
#
#  Test of \p{ .. }, \P{ .. }, etc.
#
#  This script uses ShiftJIS::String.
#
my $HARNESS = 0; # true

use ShiftJIS::String qw(mkrange);
use ShiftJIS::Regexp qw(re match);

my $time = time;

my $n  = 0;
my @NG;

my %char = (
 n => [ "\n" ],
 r => [ "\r", "\t", "\f" ],
 s => [ ' '  ],
 S => [ '�@' ],
 b => [ "\x7F" ],
 c => [ mkrange("\x00-\x08\x0b\x0e-\x1F") ],
 p => [ mkrange('!-/:-@[-^`{-~') ],
 q => [ '_' ],
 d => [ mkrange("0-9") ],
 u => [ mkrange("A-Z") ],
 l => [ mkrange("a-z") ],
 D => [ mkrange('�O-�X') ],
 U => [ mkrange('�`-�y') ],
 L => [ mkrange('��-��') ],
 G => [ mkrange('��-��') ],
 Q => [ mkrange('��-��') ],
 C => [ mkrange('�@-�`') ],
 R => [ mkrange('�p-��') ],
 H => [ mkrange('��-��J�K�T�U') ],
 K => [ mkrange('�@-���[�R�S')   ],
 h => [ mkrange('�-�') ],
 k => [ mkrange('�-�') ],
 J => [ mkrange('��-�r') ],
 Z => [ mkrange('��-�') ],
 Y => [ mkrange('�V-�Z') ],
 P => [ mkrange('�A-�I�L-�Q�\-����-����-�΁�-���-����') ],
 B => [ mkrange('��-��') ],
 N => [ mkrange("\x87\x40-\x87\x5D\x87\x5F-\x87\x75\x87\x7E-\x87\x9C"
	.	"\xED\x40-\xEE\xEC\xEE\xEF-\xEE\xFC") ],
 I => [ mkrange("\xFA\x40-\xFC\x4B") ],
 X => [ mkrange("\x81\xAD-\x81\xB7\x81\xC0-\x81\xC7\x81\xCF-\x81\xD9"
	.	"\x81\xE9-\x81\xEF\x81\xF8-\x81\xFB\x82\x40-\x82\x4E"
	.	"\x82\x59-\x82\x5F\x82\x7A-\x82\x80\x82\x9B-\x82\x9E"
	.	"\x82\xF2-\x82\xFC\x83\x97-\x83\x9E\x83\xB7-\x83\xBE"
	.	"\x83\xD7-\x83\xFC\x84\x61-\x84\x6F\x84\x92-\x84\x9E"
	.	"\x84\xBF-\x86\xFC\x88\x40-\x88\x9E\x98\x73-\x98\x9E"
	.	"\x87\x5E\x87\x76-\x87\x7D\x87\x9D-\x87\xFC"
	.	"\xEA\xA5-\xEC\xFC"
	.	"\xEE\xED-\xEE\xEE"
	. 	"\xFC\x4C-\xFC\xFC") ],
);

sub sp { grep /\w/, split '', shift }

my @cls =		   sp q(nrsSbc-pqdulDUL-GQCRHKhk-JZYPB-NIX);
my %res = (
 '\j'			=>[sp q(111111-11111111-11111111-11111-111)],
 '[\0-\x{fcfc}]'	=>[sp q(111111-11111111-11111111-11111-111)],
 '.'			=>[sp q(011111-11111111-11111111-11111-111)],
 '\J'			=>[sp q(011111-11111111-11111111-11111-111)],
 '[^\n]'		=>[sp q(011111-11111111-11111111-11111-111)],

 '\pD'			=>[sp q(000000-00100100-00000000-00000-000)],
 '\P^D'			=>[sp q(000000-00100100-00000000-00000-000)],
 '[\pD]'		=>[sp q(000000-00100100-00000000-00000-000)],
 '[^\p^D]'		=>[sp q(000000-00100100-00000000-00000-000)],
 '\PD'			=>[sp q(111111-11011011-11111111-11111-111)],
 '\p^D'			=>[sp q(111111-11011011-11111111-11111-111)],
 '[\PD]'		=>[sp q(111111-11011011-11111111-11111-111)],
 '[^\P^D]'		=>[sp q(111111-11011011-11111111-11111-111)],
 '\pU'			=>[sp q(000000-00010010-00000000-00000-000)],
 '\P^U'			=>[sp q(000000-00010010-00000000-00000-000)],
 '[\pU]'		=>[sp q(000000-00010010-00000000-00000-000)],
 '[^\p^U]'		=>[sp q(000000-00010010-00000000-00000-000)],
 '\PU'			=>[sp q(111111-11101101-11111111-11111-111)],
 '\p^U'			=>[sp q(111111-11101101-11111111-11111-111)],
 '[\PU]'		=>[sp q(111111-11101101-11111111-11111-111)],
 '[^\P^U]'		=>[sp q(111111-11101101-11111111-11111-111)],
 '\pL'			=>[sp q(000000-00001001-00000000-00000-000)],
 '\P^L'			=>[sp q(000000-00001001-00000000-00000-000)],
 '[\pL]'		=>[sp q(000000-00001001-00000000-00000-000)],
 '[^\p^L]'		=>[sp q(000000-00001001-00000000-00000-000)],
 '\PL'			=>[sp q(111111-11110110-11111111-11111-111)],
 '\p^L'			=>[sp q(111111-11110110-11111111-11111-111)],
 '[\PL]'		=>[sp q(111111-11110110-11111111-11111-111)],
 '[^\P^L]'		=>[sp q(111111-11110110-11111111-11111-111)],
 '\pA'			=>[sp q(000000-00011011-00000000-00000-000)],
 '\P^A'			=>[sp q(000000-00011011-00000000-00000-000)],
 '[\pA]'		=>[sp q(000000-00011011-00000000-00000-000)],
 '[^\p^A]'		=>[sp q(000000-00011011-00000000-00000-000)],
 '\PA'			=>[sp q(111111-11100100-11111111-11111-111)],
 '\p^A'			=>[sp q(111111-11100100-11111111-11111-111)],
 '[\PA]'		=>[sp q(111111-11100100-11111111-11111-111)],
 '[^\P^A]'		=>[sp q(111111-11100100-11111111-11111-111)],
 '[\pA\pD]'		=>[sp q(000000-00111111-00000000-00000-000)],
 '[\pA\p{Digit}]'	=>[sp q(000000-00111111-00000000-00000-000)],
 '[\p{Alpha}\pD]'	=>[sp q(000000-00111111-00000000-00000-000)],
 '[^\pA\pD]'		=>[sp q(111111-11000000-11111111-11111-111)],
 '[^\pA\p{Digit}]'	=>[sp q(111111-11000000-11111111-11111-111)],
 '[^\p{Alpha}\pD]'	=>[sp q(111111-11000000-11111111-11111-111)],
 '\pW'			=>[sp q(000000-01111111-11111101-11100-000)],
 '\P^W'			=>[sp q(000000-01111111-11111101-11100-000)],
 '[\pW]'		=>[sp q(000000-01111111-11111101-11100-000)],
 '[^\p^W]'		=>[sp q(000000-01111111-11111101-11100-000)],
 '\PW'			=>[sp q(111111-10000000-00000010-00011-111)],
 '\p^W'	 		=>[sp q(111111-10000000-00000010-00011-111)],
 '[\PW]'		=>[sp q(111111-10000000-00000010-00011-111)],
 '[^\P^W]'		=>[sp q(111111-10000000-00000010-00011-111)],
 '\pP'			=>[sp q(000000-11000000-00000010-00011-000)],
 '\P^P'			=>[sp q(000000-11000000-00000010-00011-000)],
 '\PP'			=>[sp q(111111-00111111-11111101-11100-111)],
 '\p^P'			=>[sp q(111111-00111111-11111101-11100-111)],
 '\pS'			=>[sp q(111100-00000000-00000000-00000-000)],
 '\P^S'			=>[sp q(111100-00000000-00000000-00000-000)],
 '[\pS]'		=>[sp q(111100-00000000-00000000-00000-000)],
 '[^\p^S]'		=>[sp q(111100-00000000-00000000-00000-000)],
 '\PS'			=>[sp q(000011-11111111-11111111-11111-111)],
 '\p^S'			=>[sp q(000011-11111111-11111111-11111-111)],
 '[\PS]'		=>[sp q(000011-11111111-11111111-11111-111)],
 '[^\pS]'		=>[sp q(000011-11111111-11111111-11111-111)],
 '\pG'			=>[sp q(000000-11111111-11111111-11111-111)],
 '\P^G'			=>[sp q(000000-11111111-11111111-11111-111)],
 '[\pG]'		=>[sp q(000000-11111111-11111111-11111-111)],
 '\PG'			=>[sp q(111111-00000000-00000000-00000-000)],
 '\p^G'			=>[sp q(111111-00000000-00000000-00000-000)],
 '[\PG]'		=>[sp q(111111-00000000-00000000-00000-000)],
 '[\pG\pS]'		=>[sp q(111100-11111111-11111111-11111-111)],
 '[\pS\pG]'		=>[sp q(111100-11111111-11111111-11111-111)],
 '[^\pG\pS]'		=>[sp q(000011-00000000-00000000-00000-000)],
 '[^\pS\pG]'		=>[sp q(000011-00000000-00000000-00000-000)],
 '\pc'			=>[sp q(110001-00000000-00000000-00000-000)],
 '\P^C'			=>[sp q(110001-00000000-00000000-00000-000)],
 '[\pC]'		=>[sp q(110001-00000000-00000000-00000-000)],
 '[^\p^c]'		=>[sp q(110001-00000000-00000000-00000-000)],
 '\PC'			=>[sp q(001110-11111111-11111111-11111-111)],
 '\p^c'			=>[sp q(001110-11111111-11111111-11111-111)],
 '[\Pc]'		=>[sp q(001110-11111111-11111111-11111-111)],
 '[^\P^C]'		=>[sp q(001110-11111111-11111111-11111-111)],

 '\p{Ascii}'		=>[sp q(111011-11111000-00000000-00000-000)],
 '\P{Ascii}'		=>[sp q(000100-00000111-11111111-11111-111)],
 '\p{Hankaku}'		=>[sp q(000000-00000000-00000011-00000-000)],
 '\P{Hankaku}'		=>[sp q(111111-11111111-11111100-11111-111)],
 '\p{Zenkaku}'		=>[sp q(000100-00000111-11111100-11111-111)],
 '\P{Zenkaku}'		=>[sp q(111011-11111000-00000011-00000-000)],

 '\p{X0201}'		=>[sp q(111011-11111000-00000011-00000-000)],
 '[[:x0201:]]'		=>[sp q(111011-11111000-00000011-00000-000)],
 '[^[:^x0201:]]'	=>[sp q(111011-11111000-00000011-00000-000)],
 '\P{X0201}'		=>[sp q(000100-00000111-11111100-11111-111)],
 '[[:^x0201:]]'		=>[sp q(000100-00000111-11111100-11111-111)],
 '[^[:x0201:]]'		=>[sp q(000100-00000111-11111100-11111-111)],
 '\p{X0208}'		=>[sp q(000100-00000111-11111100-11111-000)],
 '[[:x0208:]]'		=>[sp q(000100-00000111-11111100-11111-000)],
 '[^[:^x0208:]]'	=>[sp q(000100-00000111-11111100-11111-000)],
 '\P{X0208}'		=>[sp q(111011-11111000-00000011-00000-111)],
 '[[:^x0208:]]'		=>[sp q(111011-11111000-00000011-00000-111)],
 '[^[:x0208:]]'		=>[sp q(111011-11111000-00000011-00000-111)],

 '[[:x0201:][:x0208:]]' =>[sp q(111111-11111111-11111111-11111-000)],
 '[\p{X0201}\p{X0208}]' =>[sp q(111111-11111111-11111111-11111-000)],
 '[^[:x0201:][:x0208:]]'=>[sp q(000000-00000000-00000000-00000-111)],
 '[^\p{X0201}\p{X0208}]'=>[sp q(000000-00000000-00000000-00000-111)],
 '[\x20-\x7F\xA1-\xDF]' =>[sp q(001010-11111000-00000011-00000-000)],
 '[^\x20-\x7F\xA1-\xDF]'=>[sp q(110101-00000111-11111100-11111-111)],

 '\p{JIS}' 		=>[sp q(111111-11111111-11111111-11111-000)],
 '[\p{JIS}]' 		=>[sp q(111111-11111111-11111111-11111-000)],
 '[\P{^JIS}]' 		=>[sp q(111111-11111111-11111111-11111-000)],
 '\pJ'			=>[sp q(111111-11111111-11111111-11111-000)],
 '[\pJ]'		=>[sp q(111111-11111111-11111111-11111-000)],
 '[[:jis:]]'		=>[sp q(111111-11111111-11111111-11111-000)],
 '[^[:^jis:]]'		=>[sp q(111111-11111111-11111111-11111-000)],

 '\P{JIS}'		=>[sp q(000000-00000000-00000000-00000-111)],
 '[\P{JIS}]'		=>[sp q(000000-00000000-00000000-00000-111)],
 '[\p{^JIS}]'		=>[sp q(000000-00000000-00000000-00000-111)],
 '\PJ'			=>[sp q(000000-00000000-00000000-00000-111)],
 '[\PJ]'		=>[sp q(000000-00000000-00000000-00000-111)],
 '[[:^JIS:]]'		=>[sp q(000000-00000000-00000000-00000-111)],
 '[^[:jis:]]'		=>[sp q(000000-00000000-00000000-00000-111)],

 '\p{NEC}'		=>[sp q(000000-00000000-00000000-00000-100)],
 '[\p{NEC}]'		=>[sp q(000000-00000000-00000000-00000-100)],
 '[^\P{NEC}]'		=>[sp q(000000-00000000-00000000-00000-100)],
 '\pN'			=>[sp q(000000-00000000-00000000-00000-100)],
 '[\pN]'		=>[sp q(000000-00000000-00000000-00000-100)],
 '[[:NEC:]]'		=>[sp q(000000-00000000-00000000-00000-100)],
 '[^[:^NEC:]]'		=>[sp q(000000-00000000-00000000-00000-100)],

 '\P{NEC}' 		=>[sp q(111111-11111111-11111111-11111-011)],
 '[\P{NEC}]' 		=>[sp q(111111-11111111-11111111-11111-011)],
 '[^\p{NEC}]' 		=>[sp q(111111-11111111-11111111-11111-011)],
 '\PN'			=>[sp q(111111-11111111-11111111-11111-011)],
 '[\PN]'		=>[sp q(111111-11111111-11111111-11111-011)],
 '[[:^NEC:]]'		=>[sp q(111111-11111111-11111111-11111-011)],
 '[^[:NEC:]]'		=>[sp q(111111-11111111-11111111-11111-011)],

 '\p{IBM}'		=>[sp q(000000-00000000-00000000-00000-010)],
 '[\p{IBM}]'		=>[sp q(000000-00000000-00000000-00000-010)],
 '[^\P{IBM}]'		=>[sp q(000000-00000000-00000000-00000-010)],
 '\pI'			=>[sp q(000000-00000000-00000000-00000-010)],
 '[\pI]'		=>[sp q(000000-00000000-00000000-00000-010)],
 '[[:IBM:]]'		=>[sp q(000000-00000000-00000000-00000-010)],
 '[^[:^IBM:]]'		=>[sp q(000000-00000000-00000000-00000-010)],
 '[\x{fa40}-\x{fc4b}]'	=>[sp q(000000-00000000-00000000-00000-010)],

 '\P{IBM}' 		=>[sp q(111111-11111111-11111111-11111-101)],
 '[\P{IBM}]' 		=>[sp q(111111-11111111-11111111-11111-101)],
 '[^\p{IBM}]' 		=>[sp q(111111-11111111-11111111-11111-101)],
 '\PI'			=>[sp q(111111-11111111-11111111-11111-101)],
 '[\PI]'		=>[sp q(111111-11111111-11111111-11111-101)],
 '[[:^IBM:]]'		=>[sp q(111111-11111111-11111111-11111-101)],
 '[^[:IBM:]]'		=>[sp q(111111-11111111-11111111-11111-101)],
 '[^\x{fa40}-\x{fc4b}]'	=>[sp q(111111-11111111-11111111-11111-101)],

 '\p{Vendor}'		=>[sp q(000000-00000000-00000000-00000-110)],
 '[\p{Vendor}]'		=>[sp q(000000-00000000-00000000-00000-110)],
 '[^\P{Vendor}]'	=>[sp q(000000-00000000-00000000-00000-110)],
 '\pV'			=>[sp q(000000-00000000-00000000-00000-110)],
 '[\pV]'		=>[sp q(000000-00000000-00000000-00000-110)],
 '[[:vendor:]]'		=>[sp q(000000-00000000-00000000-00000-110)],
 '[^[:^vendor:]]'	=>[sp q(000000-00000000-00000000-00000-110)],

 '\P{Vendor}' 		=>[sp q(111111-11111111-11111111-11111-001)],
 '[\P{Vendor}]'		=>[sp q(111111-11111111-11111111-11111-001)],
 '[^\p{Vendor}]'	=>[sp q(111111-11111111-11111111-11111-001)],
 '\PV'			=>[sp q(111111-11111111-11111111-11111-001)],
 '[\PV]'		=>[sp q(111111-11111111-11111111-11111-001)],
 '[[:^vendor:]]'	=>[sp q(111111-11111111-11111111-11111-001)],
 '[^[:vendor:]]'	=>[sp q(111111-11111111-11111111-11111-001)],

 '\p{MSWin}' 		=>[sp q(111111-11111111-11111111-11111-110)],
 '[\p{MSWin}]' 		=>[sp q(111111-11111111-11111111-11111-110)],
 '[\P{^MSWin}]'		=>[sp q(111111-11111111-11111111-11111-110)],
 '\pM'			=>[sp q(111111-11111111-11111111-11111-110)],
 '[\pM]'		=>[sp q(111111-11111111-11111111-11111-110)],
 '[[:mswin:]]'		=>[sp q(111111-11111111-11111111-11111-110)],
 '[^[:^mswin:]]'	=>[sp q(111111-11111111-11111111-11111-110)],
 '[\pJ\pN\pI]' 		=>[sp q(111111-11111111-11111111-11111-110)],

 '\P{MSWin}'		=>[sp q(000000-00000000-00000000-00000-001)],
 '[\P{MSWin}]'		=>[sp q(000000-00000000-00000000-00000-001)],
 '[\p{^MSWin}]'		=>[sp q(000000-00000000-00000000-00000-001)],
 '\PM'			=>[sp q(000000-00000000-00000000-00000-001)],
 '[\PM]'		=>[sp q(000000-00000000-00000000-00000-001)],
 '[[:^mswin:]]'		=>[sp q(000000-00000000-00000000-00000-001)],
 '[^[:mswin:]]'		=>[sp q(000000-00000000-00000000-00000-001)],
 '[^\pJ\pN\pI]'		=>[sp q(000000-00000000-00000000-00000-001)],

 '\p{European}' 	=>[sp q(000000-00011011-11110000-00000-000)],
 '[\p{European}]' 	=>[sp q(000000-00011011-11110000-00000-000)],
 '[\P{^European}]'	=>[sp q(000000-00011011-11110000-00000-000)],
 '\pE'			=>[sp q(000000-00011011-11110000-00000-000)],
 '[\pE]'		=>[sp q(000000-00011011-11110000-00000-000)],
 '[[:european:]]'	=>[sp q(000000-00011011-11110000-00000-000)],
 '[^[:^european:]]'	=>[sp q(000000-00011011-11110000-00000-000)],

 '\P{European}'		=>[sp q(111111-11100100-00001111-11111-111)],
 '[\P{European}]'	=>[sp q(111111-11100100-00001111-11111-111)],
 '[\p{^European}]'	=>[sp q(111111-11100100-00001111-11111-111)],
 '\PE'			=>[sp q(111111-11100100-00001111-11111-111)],
 '[\PE]'		=>[sp q(111111-11100100-00001111-11111-111)],
 '[[:^european:]]'	=>[sp q(111111-11100100-00001111-11111-111)],
 '[^[:european:]]'	=>[sp q(111111-11100100-00001111-11111-111)],

 '\pH'			=>[sp q(000000-00000000-00001000-00000-000)],
 '\P^H'			=>[sp q(000000-00000000-00001000-00000-000)],
 '[\pH]'		=>[sp q(000000-00000000-00001000-00000-000)],
 '[^\PH]'		=>[sp q(000000-00000000-00001000-00000-000)],
 '\PH'			=>[sp q(111111-11111111-11110111-11111-111)],
 '\p^H'			=>[sp q(111111-11111111-11110111-11111-111)],
 '[\PH]'		=>[sp q(111111-11111111-11110111-11111-111)],
 '[^\pH]'		=>[sp q(111111-11111111-11110111-11111-111)],
 '\pK'			=>[sp q(000000-00000000-00000100-00000-000)],
 '\P^K'			=>[sp q(000000-00000000-00000100-00000-000)],
 '[\pK]'		=>[sp q(000000-00000000-00000100-00000-000)],
 '[^\PK]'		=>[sp q(000000-00000000-00000100-00000-000)],
 '\PK'			=>[sp q(111111-11111111-11111011-11111-111)],
 '\p^K'			=>[sp q(111111-11111111-11111011-11111-111)],
 '[\PK]'		=>[sp q(111111-11111111-11111011-11111-111)],
 '[^\pK]'		=>[sp q(111111-11111111-11111011-11111-111)],

 '[\pH\pK]'		=>[sp q(000000-00000000-00001100-00000-000)],
 '[^\pH\pK]'		=>[sp q(111111-11111111-11110011-11111-111)],
 '\p{Kana}'		=>[sp q(000000-00000000-00001101-00000-000)],
 '\P{Kana}'		=>[sp q(111111-11111111-11110010-11111-111)],

 '\p{kanji0}'		=>[sp q(000000-00000000-00000000-00100-000)],
 '\P{^kanji0}'		=>[sp q(000000-00000000-00000000-00100-000)],
 '[[:kanji0:]]'		=>[sp q(000000-00000000-00000000-00100-000)],
 '\p0'			=>[sp q(000000-00000000-00000000-00100-000)],
 '\P^0'			=>[sp q(000000-00000000-00000000-00100-000)],
 '[\p0]'		=>[sp q(000000-00000000-00000000-00100-000)],
 '[\P^0]'		=>[sp q(000000-00000000-00000000-00100-000)],
 '\P{kanji0}'		=>[sp q(111111-11111111-11111111-11011-111)],
 '\p{^Kanji0}'		=>[sp q(111111-11111111-11111111-11011-111)],
 '\P0'			=>[sp q(111111-11111111-11111111-11011-111)],
 '\p^0'			=>[sp q(111111-11111111-11111111-11011-111)],
 '[\P0]'		=>[sp q(111111-11111111-11111111-11011-111)],
 '[^\p0]'		=>[sp q(111111-11111111-11111111-11011-111)],

 '\p1'			=>[sp q(000000-00000000-00000000-10000-000)],
 '\P^1'			=>[sp q(000000-00000000-00000000-10000-000)],
 '[\p1]'		=>[sp q(000000-00000000-00000000-10000-000)],
 '[^\P1]'		=>[sp q(000000-00000000-00000000-10000-000)],
 '\P1'			=>[sp q(111111-11111111-11111111-01111-111)],
 '\p^1'			=>[sp q(111111-11111111-11111111-01111-111)],
 '[\P1]'		=>[sp q(111111-11111111-11111111-01111-111)],
 '[^\p1]'		=>[sp q(111111-11111111-11111111-01111-111)],
 '\p2'			=>[sp q(000000-00000000-00000000-01000-000)],
 '\P^2'			=>[sp q(000000-00000000-00000000-01000-000)],
 '[\p2]'		=>[sp q(000000-00000000-00000000-01000-000)],
 '[^\P2]'		=>[sp q(000000-00000000-00000000-01000-000)],
 '\P2'			=>[sp q(111111-11111111-11111111-10111-111)],
 '\p^2'			=>[sp q(111111-11111111-11111111-10111-111)],
 '[\P2]'		=>[sp q(111111-11111111-11111111-10111-111)],
 '[^\p2]'		=>[sp q(111111-11111111-11111111-10111-111)],
 '[\p0\p1\p2]'		=>[sp q(000000-00000000-00000000-11100-000)],
 '[^\p0\p1\p2]'		=>[sp q(111111-11111111-11111111-00011-111)],

 '\pB'			=>[sp q(000000-00000000-00000000-00001-000)],
 '\P^B'			=>[sp q(000000-00000000-00000000-00001-000)],
 '[\pB]'		=>[sp q(000000-00000000-00000000-00001-000)],
 '\PB'			=>[sp q(111111-11111111-11111111-11110-111)],
 '\p^B'			=>[sp q(111111-11111111-11111111-11110-111)],
 '[\PB]'		=>[sp q(111111-11111111-11111111-11110-111)],
);

printf "1..%d\n", keys(%res) * keys(%char);

my($mod,$OK,$r,$cl);
for $r (sort keys %res){
  print "$r\n" unless $HARNESS;

  my $re = "^$r\$";
  for $cl (0..$#cls){
    my $match = grep(match($_, $re, 'o'), @{ $char{ $cls[ $cl ] } });
    my $a = $match == @{ $char{ $cls[ $cl ] } } ? 1 : $match == 0 ? 0 : -1;

    my $msg = $a == $res{ $r }[$cl] ? "ok" : "not ok";
    ++$n;

    print "$msg $n\n";

    push @NG, "$n$r $cls[ $cl ]\n" if $msg ne 'ok';
  }
}

unless($HARNESS){
  printf "version: $]\ntime: %d\n", time - $time;
  print ! @NG
    ? "All tests successful.\n"
    : "Failed ".scalar(@NG).", tests.\n", @NG;
}

__END__
