#
#  USAGE: perl -MTest::Harness -e "runtests('class1.t');"
#
#  Test of \p{ .. }, \P{ .. }, etc.
#
#  This script uses ShiftJIS::String.
#
$::HARNESS = $] > 5.004; # true (please change it if this is FALSE.)

use ShiftJIS::String qw(mkrange);
use ShiftJIS::Regexp qw(re match);

my $time = time;

my $n  = 0;
my @NG;

my %char = (
 n => [ "\n" ],
 r => [ "\r" ],
 t => [ "\t" ],
 f => [ "\f" ],
 v => [ "\x0b" ],
 s => [ ' '  ],
 S => [ '�@' ],
 b => [ "\x7F" ],
 c => [ mkrange("\x00-\x08\x0e-\x1F") ],
 p => [ mkrange('!-/:-@[-^`{-~') ],
 q => [ '_' ],
 d => [ mkrange("0-9") ],
 0 => [ mkrange("A-F") ],
 1 => [ mkrange("a-f") ],
 u => [ mkrange("G-Z") ],
 l => [ mkrange("g-z") ],
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
	.	"\xEA\xA5-\xEC\xFC") ],
);

sub sp { grep /\w/, split '', shift }

my @cls =		   sp q(nrtfvsSbc-pqd01ulDUL-GQCRHKhk-JZYPB-NIX);
my %res = (
 '\j'			=>[sp q(111111111-1111111111-11111111-11111-111)],
 '[\0-\x{fcfc}]'	=>[sp q(111111111-1111111111-11111111-11111-111)],
 '.'			=>[sp q(011111111-1111111111-11111111-11111-111)],
 '\J'			=>[sp q(011111111-1111111111-11111111-11111-111)],
 '[^\n]'		=>[sp q(011111111-1111111111-11111111-11111-111)],
 '\d'			=>[sp q(000000000-0010000000-00000000-00000-000)],
 '[\d]'			=>[sp q(000000000-0010000000-00000000-00000-000)],
 '\D'			=>[sp q(111111111-1101111111-11111111-11111-111)],
 '[\D]'			=>[sp q(111111111-1101111111-11111111-11111-111)],
 '\w'			=>[sp q(000000000-0111111000-00000000-00000-000)],
 '[\w]'			=>[sp q(000000000-0111111000-00000000-00000-000)],
 '\W'			=>[sp q(111111111-1000000111-11111111-11111-111)],
 '[\W]'			=>[sp q(111111111-1000000111-11111111-11111-111)],
 '\s'			=>[sp q(111101000-0000000000-00000000-00000-000)],
 '[\s]'			=>[sp q(111101000-0000000000-00000000-00000-000)],
 '\S'			=>[sp q(000010111-1111111111-11111111-11111-111)],
 '[\S]'			=>[sp q(000010111-1111111111-11111111-11111-111)],

 '\p{Xdigit}'		=>[sp q(000000000-0011100000-00000000-00000-000)],
 '[[:xdigit:]]'		=>[sp q(000000000-0011100000-00000000-00000-000)],
 '\pX'			=>[sp q(000000000-0011100000-00000000-00000-000)],
 '\P^X'			=>[sp q(000000000-0011100000-00000000-00000-000)],
 '[\pX]'		=>[sp q(000000000-0011100000-00000000-00000-000)],
 '[0-9A-Fa-f]'		=>[sp q(000000000-0011100000-00000000-00000-000)],
 '\P{Xdigit}'		=>[sp q(111111111-1100011111-11111111-11111-111)],
 '[[:^xdigit:]]'	=>[sp q(111111111-1100011111-11111111-11111-111)],
 '\PX'			=>[sp q(111111111-1100011111-11111111-11111-111)],
 '\p^X'			=>[sp q(111111111-1100011111-11111111-11111-111)],
 '[^\pX]'		=>[sp q(111111111-1100011111-11111111-11111-111)],
 '[^0-9A-Fa-f]'		=>[sp q(111111111-1100011111-11111111-11111-111)],
 '\p{Digit}'		=>[sp q(000000000-0010000100-00000000-00000-000)],
 '\pD'			=>[sp q(000000000-0010000100-00000000-00000-000)],
 '[0-9�O-�X]'		=>[sp q(000000000-0010000100-00000000-00000-000)],
 '\P{Digit}'		=>[sp q(111111111-1101111011-11111111-11111-111)],
 '\PD'			=>[sp q(111111111-1101111011-11111111-11111-111)],
 '[^0-9�O-�X]'		=>[sp q(111111111-1101111011-11111111-11111-111)],
 '\p{Upper}'		=>[sp q(000000000-0001010010-00000000-00000-000)],
 '\pU'			=>[sp q(000000000-0001010010-00000000-00000-000)],
 '[A-Z�`-�y]'		=>[sp q(000000000-0001010010-00000000-00000-000)],
 '\P{Upper}'		=>[sp q(111111111-1110101101-11111111-11111-111)],
 '\PU'			=>[sp q(111111111-1110101101-11111111-11111-111)],
 '[^A-Z�`-�y]'		=>[sp q(111111111-1110101101-11111111-11111-111)],
 '\p{Lower}'		=>[sp q(000000000-0000101001-00000000-00000-000)],
 '\pL'			=>[sp q(000000000-0000101001-00000000-00000-000)],
 '[a-z��-��]'		=>[sp q(000000000-0000101001-00000000-00000-000)],
 '\P{Lower}'		=>[sp q(111111111-1111010110-11111111-11111-111)],
 '\PL'			=>[sp q(111111111-1111010110-11111111-11111-111)],
 '[^a-z��-��]'		=>[sp q(111111111-1111010110-11111111-11111-111)],
 '(?i)[A-Z�`-�y]'	=>[sp q(000000000-0001111010-00000000-00000-000)],
 '(?i)[^A-Z�`-�y]'	=>[sp q(111111111-1110000101-11111111-11111-111)],
 '(?i)[a-z��-��]'	=>[sp q(000000000-0001111001-00000000-00000-000)],
 '(?i)[^a-z��-��]'	=>[sp q(111111111-1110000110-11111111-11111-111)],
 '\p{Alpha}'		=>[sp q(000000000-0001111011-00000000-00000-000)],
 '\pA'			=>[sp q(000000000-0001111011-00000000-00000-000)],
 '\P{Alpha}'		=>[sp q(111111111-1110000100-11111111-11111-111)],
 '\PA'			=>[sp q(111111111-1110000100-11111111-11111-111)],
 '\p{Alnum}'		=>[sp q(000000000-0011111111-00000000-00000-000)],
 '\pQ'			=>[sp q(000000000-0011111111-00000000-00000-000)],
 '[\p{Alpha}\p{Digit}]'	=>[sp q(000000000-0011111111-00000000-00000-000)],
 '[\pA\pD]'		=>[sp q(000000000-0011111111-00000000-00000-000)],
 '[\pA\p{Digit}]'	=>[sp q(000000000-0011111111-00000000-00000-000)],
 '\P{Alnum}'		=>[sp q(111111111-1100000000-11111111-11111-111)],
 '\PQ'			=>[sp q(111111111-1100000000-11111111-11111-111)],
 '[^\p{Alpha}\p{Digit}]'=>[sp q(111111111-1100000000-11111111-11111-111)],
 '[^\pA\pD]'		=>[sp q(111111111-1100000000-11111111-11111-111)],
 '[^\pA\p{Digit}]'	=>[sp q(111111111-1100000000-11111111-11111-111)],
 '\p{Word}'		=>[sp q(000000000-0111111111-11111101-11100-000)],
 '\pW'			=>[sp q(000000000-0111111111-11111101-11100-000)],
 '\P{Word}'		=>[sp q(111111111-1000000000-00000010-00011-111)],
 '\PW'			=>[sp q(111111111-1000000000-00000010-00011-111)],
 '\p{Punct}'		=>[sp q(000000000-1100000000-00000010-00011-000)],
 '\pP'			=>[sp q(000000000-1100000000-00000010-00011-000)],
 '\P{Punct}'		=>[sp q(111111111-0011111111-11111101-11100-111)],
 '\PP'			=>[sp q(111111111-0011111111-11111101-11100-111)],
 '\p{Blank}'		=>[sp q(001001100-0000000000-00000000-00000-000)],
 '\pB'			=>[sp q(001001100-0000000000-00000000-00000-000)],
 '\P{Blank}'		=>[sp q(110110011-1111111111-11111111-11111-111)],
 '\PB'			=>[sp q(110110011-1111111111-11111111-11111-111)],
 '\p{Space}'		=>[sp q(111111100-0000000000-00000000-00000-000)],
 '\pS'			=>[sp q(111111100-0000000000-00000000-00000-000)],
 '[\p{Blank}\x09-\x0D]'	=>[sp q(111111100-0000000000-00000000-00000-000)],
 '[\x09-\x0D\pB]'	=>[sp q(111111100-0000000000-00000000-00000-000)],
 '\P{Space}'		=>[sp q(000000011-1111111111-11111111-11111-111)],
 '\PS'			=>[sp q(000000011-1111111111-11111111-11111-111)],
 '[^\p{Blank}\x09-\x0D]'=>[sp q(000000011-1111111111-11111111-11111-111)],
 '[^\x09-\x0D\pB]'	=>[sp q(000000011-1111111111-11111111-11111-111)],
 '[\s\x{8140}]'		=>[sp q(111101100-0000000000-00000000-00000-000)],
 '[^\s\x{8140}]'	=>[sp q(000010011-1111111111-11111111-11111-111)],
 '\p{Graph}'		=>[sp q(000000000-1111111111-11111111-11111-000)],
 '\pG'			=>[sp q(000000000-1111111111-11111111-11111-000)],
 '[\pW\pP]'		=>[sp q(000000000-1111111111-11111111-11111-000)],
 '[\p{word}\p{punct}]'	=>[sp q(000000000-1111111111-11111111-11111-000)],
 '\P{Graph}'		=>[sp q(111111111-0000000000-00000000-00000-111)],
 '\PG'			=>[sp q(111111111-0000000000-00000000-00000-111)],
 '[^\pW\pP]'		=>[sp q(111111111-0000000000-00000000-00000-111)],
 '[^\p{word}\p{punct}]'	=>[sp q(111111111-0000000000-00000000-00000-111)],
 '\p{Print}'		=>[sp q(000001100-1111111111-11111111-11111-000)],
 '\pT'			=>[sp q(000001100-1111111111-11111111-11111-000)],
 '\P{Print}'		=>[sp q(111110011-0000000000-00000000-00000-111)],
 '\PT'			=>[sp q(111110011-0000000000-00000000-00000-111)],
 '[\pB\pG]'		=>[sp q(001001100-1111111111-11111111-11111-000)],
 '[\p{graph}\p{blank}]'	=>[sp q(001001100-1111111111-11111111-11111-000)],
 '[^\pB\pG]'		=>[sp q(110110011-0000000000-00000000-00000-111)],
 '[^\p{graph}\p{blank}]'=>[sp q(110110011-0000000000-00000000-00000-111)],
 '\p{Cntrl}'		=>[sp q(111110011-0000000000-00000000-00000-000)],
 '\pC'			=>[sp q(111110011-0000000000-00000000-00000-000)],
 '\P{Cntrl}'		=>[sp q(000001100-1111111111-11111111-11111-111)],
 '\PC'			=>[sp q(000001100-1111111111-11111111-11111-111)],
 '\p{ASCII}'		=>[sp q(111111011-1111111000-00000000-00000-000)],
 '[\0-\c?]'		=>[sp q(111111011-1111111000-00000000-00000-000)],
 '\P{ASCII}'		=>[sp q(000000100-0000000111-11111111-11111-111)],
 '[^\0-\c?]'		=>[sp q(000000100-0000000111-11111111-11111-111)],
);

printf "1..%d\n", keys(%res) * keys(%char);

my($mod,$OK,$r,$cl);
for $r (sort keys %res){
  print "$r\n" if ! $HARNESS;

  my $re = "^$r\$";
  for $cl (0..$#cls){
    my $match = grep(match($_, $re, 'o'), @{ $char{ $cls[ $cl ] } });
    my $a = $match == @{ $char{ $cls[ $cl ] } } ? 1 : $match == 0 ? 0 : -1;

    my $msg = $a == $res{ $r }[$cl] ? "ok" : "not ok";
    ++$n;

    print "$msg $n\n";

    push @NG, "$n$r $cls[ $cl ]\n" if ! $HARNESS and $msg ne 'ok';
  }
}

if(! $HARNESS){
  printf "version: $]\ntime: %d\n", time - $time;
  print ! @NG
    ? "All tests successful.\n"
    : "Failed ".scalar(@NG).", tests.\n", @NG;
}

__END__
