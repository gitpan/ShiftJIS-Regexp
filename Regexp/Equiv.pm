package ShiftJIS::Regexp::Equiv;
use strict;
use Carp;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
$VERSION = '0.26';

require Exporter;
@ISA       = qw(Exporter);
@EXPORT    = qw();
@EXPORT_OK = qw(%Eq);

use vars qw(%Eq);

my $Open = 5.005 > $] ? '(?:' : '(?-i:';
my $Close = ')';

foreach(
['!', 'I'],
['#', ''],
['$', ''],
['%', ''],
['&', ''],
['(', 'i'],
[')', 'j'],
['*', ''],
['+', '{'],
[',', 'C'],
['.', 'D'],
['/', '^'],
['0', 'O'],
['1', 'P'],
['2', 'Q'],
['3', 'R'],
['4', 'S'],
['5', 'T'],
['6', 'U'],
['7', 'V'],
['8', 'W'],
['9', 'X'],
[':', 'F'],
[';', 'G'],
['<', ''],
['=', ''],
['>', ''],
['?', 'H'],
['@', ''],
['[', 'm'],
['\\',''],
[']', 'n'],
['^', 'O'],
['_', 'Q'],
['`', 'M'],
['{', 'o'],
['|', 'b'],
['}', 'p'],
['~', 'P'],
['B', '”'],
['u', '¢'],
['v', '£'],
['A', '¤'],
['E', '„'],
['[', '°'],
['a', '', 'A', '`'],
['b', '', 'B', 'a'],
['c', '', 'C', 'b'],
['d', '', 'D', 'c'],
['e', '', 'E', 'd'],
['f', '', 'F', 'e'],
['g', '', 'G', 'f'],
['h', '', 'H', 'g'],
['i', '', 'I', 'h'],
['j', '', 'J', 'i'],
['k', '', 'K', 'j'],
['l', '', 'L', 'k'],
['m', '', 'M', 'l'],
['n', '', 'N', 'm'],
['o', '', 'O', 'n'],
['p', '', 'P', 'o'],
['q', '', 'Q', 'p'],
['r', '', 'R', 'q'],
['s', '', 'S', 'r'],
['t', '', 'T', 's'],
['u', '', 'U', 't'],
['v', '', 'V', 'u'],
['w', '', 'W', 'v'],
['x', '', 'X', 'w'],
['y', '', 'Y', 'x'],
['z', '', 'Z', 'y'],
[qw/ @ §   A ± /],
[qw/” B Ø ¢ C ² /],
[qw/£ D © ¤ E  ³Ž ³ /],
[qw/„ F Ŗ ¦ G “ /],
[qw/§ H « Ø I µ /],
[qw/Ŗ K ¶Ž © J ¶ /],
[qw/¬ M ·Ž « L · /],
[qw/® O øŽ ­ N ø /],
[qw/° Q ¹Ž Æ P ¹  /],
[qw/² S ŗŽ ± R ŗ /],
[qw/“ U »Ž ³ T » /],
[qw/¶ W ¼Ž µ V ¼ /],
[qw/ø Y ½Ž · X ½ /],
[qw/ŗ [ ¾Ž ¹ Z ¾ /],
[qw/¼ ] æŽ » \ æ /],
[qw/¾ _ ĄŽ ½ ^ Ą /],
[qw/Ą a ĮŽ æ ` Į /],
[qw/Ć d ĀŽ Ā c Ā Į b Æ/],
[qw/Å f ĆŽ Ä e Ć /],
[qw/Ē h ÄŽ Ę g Ä /],
[qw/Č i Å /],
[qw/É j Ę /],
[qw/Ź k Ē /],
[qw/Ė l Č /],
[qw/Ģ m É /],
[qw/Ī o ŹŽ Ļ p Źß Ķ n Ź /],
[qw/Ń r ĖŽ Ņ s Ėß Š q Ė /],
[qw/Ō u ĢŽ Õ v Ģß Ó t Ģ /],
[qw/× x ĶŽ Ų y Ķß Ö w Ķ /],
[qw/Ś { ĪŽ Ū | Īß Ł z Ī /],
[qw/Ü } Ļ /],
[qw/Ż ~ Š /],
[qw/Ž  Ń /],
[qw/ß  Ņ /],
[qw/ą  Ó /],
[qw/į  ¬ ā  Ō /],
[qw/ć  ­ ä  Õ /],
[qw/å  ® ę  Ö /],
[qw/ē  × /],
[qw/č  Ų /],
[qw/é  Ł /],
[qw/ź  Ś /],
[qw/ė  Ū /],
[qw/ķ  Ü ģ  /],
[qw/ī  /],
[qw/ļ  /],
[qw/š  ¦ /],
[qw/ń  Ż /],
[qw/T R U S /],
[qw/J K Ž  ß  /],
) {
    my $arr = $_;
    my $re = $Open.join('|', map {
	length($_) == 1
	    ? sprintf('\x%02x', ord $_)
	    : sprintf('\x%02x\x%02x', unpack 'C2', $_)
	} @$arr) .$Close;
    @Eq{@$arr} = ($re) x @$arr;
}

1;
__END__
