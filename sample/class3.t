#
#  USAGE: perl -MTest::Harness -e "runtests('class2.t');"
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

my @sjischar  = mkrange("\x00-\xfc\xfc");

my %res = (
  'xdigit'	=> '0-9A-Fa-f',
  'digit'	=> '0-9‚O-‚X',
  'lower'	=> 'a-z‚-‚š',
  'upper'	=> 'A-Z‚`-‚y',
  'alpha'	=> 'A-Z‚`-‚ya-z‚-‚š',
  'alnum'	=> 'A-Z‚`-‚ya-z‚-‚š0-9‚O-‚X',
  'word'	=> '0-9A-Z_a-z‚O-‚X‚`-‚y‚-‚šƒŸ-ƒ¶ƒ¿-ƒÖ„@-„`„p-„‘'
		 . '¦-ß‚Ÿ-‚ñƒ@-ƒ–JK[TURSˆŸ-˜r˜Ÿ-ê¤',
  'punct'	=> '!-/:-@[-`{-~¡-¥A-IL-Q\-¬¸-¿È-ÎÚ-èð-÷ü„Ÿ-„¾',
  'graph'	=> '0-9A-Za-z‚O-‚X‚`-‚y‚-‚šƒŸ-ƒ¶ƒ¿-ƒÖ„@-„`„p-„‘'
		 . '¦-ß‚Ÿ-‚ñƒ@-ƒ–JK[TURSˆŸ-˜r˜Ÿ-ê¤'
		 . '!-/:-@[-`{-~¡-¥A-IL-Q\-¬¸-¿È-ÎÚ-èð-÷ü„Ÿ-„¾',
  'print'	=> "\x20\x81\x40"
		 . '0-9A-Za-z‚O-‚X‚`-‚y‚-‚šƒŸ-ƒ¶ƒ¿-ƒÖ„@-„`„p-„‘'
		 . '¦-ß‚Ÿ-‚ñƒ@-ƒ–JK[TURSˆŸ-˜r˜Ÿ-ê¤'
		 . '!-/:-@[-`{-~¡-¥A-IL-Q\-¬¸-¿È-ÎÚ-èð-÷ü„Ÿ-„¾',
  'space'	=> "\x20\x81\x40\x09-\x0D",
  'blank'	=> "\t\x20\x81\x40",
  'cntrl'	=> "\x00-\x1F\x7F",
  'roman'	=> "\x00-\x7F",
  'ascii'	=> "\x00-\x7F",
  'hankaku'	=> "\xA1-\xDF",
  'zenkaku'	=> "\x81\x40-\xFC\xFC",
  'halfwidth'	=> '!#$%&()*+,./0-9:;<=>?@A-Z[\]^_`a-z{|}~',
  'fullwidth'	=> 'I”“•ij–{CD^‚O-‚XFGƒ„H—‚`-‚y'
		 . 'mnOQM‚-‚šobpP',

   'x0201'	=> "\x00-\x7F\xA1-\xDF",
   'x0208'	=> '@-¬¸-¿È-ÎÚ-èð-÷ü‚O-‚X‚`-‚y‚-‚š'
		 . '‚Ÿ-‚ñƒ@-ƒ–ƒŸ-ƒ¶ƒ¿-ƒÖ„@-„`„p-„‘„Ÿ-„¾ˆŸ-˜r˜Ÿ-ê¤',
   'JIS'	=> "\x00-\x7F\xA1-\xDF".'@-¬¸-¿È-ÎÚ-èð-÷ü'
		 . '‚O-‚X‚`-‚y‚-‚š‚Ÿ-‚ñƒ@-ƒ–ƒŸ-ƒ¶ƒ¿-ƒÖ„@-„`„p-„‘„Ÿ-„¾'
		 . 'ˆŸ-˜r˜Ÿ-ê¤',
   'NEC'	=> "\x87\x40-\x87\x5D\x87\x5f-\x87\x75\x87\x7E-\x87\x9c"
		 . "\xed\x40-\xee\xec\xee\xef-\xee\xfc",
   'IBM'	=> "\xfa\x40-\xfc\x4b",
   'vendor'	=> "\x87\x40-\x87\x5D\x87\x5f-\x87\x75\x87\x7E-\x87\x9c"
		 . "\xed\x40-\xee\xec\xee\xef-\xee\xfc\xfa\x40-\xfc\x4b",
   'MSWin'	=> "\x00-\x7F\xA1-\xDF".'@-¬¸-¿È-ÎÚ-èð-÷ü'
		 . '‚O-‚X‚`-‚y‚-‚š‚Ÿ-‚ñƒ@-ƒ–ƒŸ-ƒ¶ƒ¿-ƒÖ„@-„`„p-„‘„Ÿ-„¾'
		 . 'ˆŸ-˜r˜Ÿ-ê¤'
		 . "\x87\x40-\x87\x5D\x87\x5f-\x87\x75\x87\x7E-\x87\x9c"
		 . "\xed\x40-\xee\xec\xee\xef-\xee\xfc\xfa\x40-\xfc\x4b",
  'latin'	=> 'A-Za-z',
  'fulllatin'	=> '‚`-‚y‚-‚š',
  'greek'	=> 'ƒŸ-ƒ¶ƒ¿-ƒÖ',
  'cyrillic'	=> '„@-„`„p-„‘',
  'european'	=> 'A-Za-z‚`-‚y‚-‚šƒŸ-ƒ¶ƒ¿-ƒÖ„@-„`„p-„‘',
  'halfkana'	=> '¦-ß',
  'hiragana'	=> '‚Ÿ-‚ñJKTU',
  'katakana'	=> 'ƒ@-ƒ–[RS',
  'fullkana'	=> '‚Ÿ-‚ñƒ@-ƒ–JK[TURS',
  'kana'	=> '¦-ß‚Ÿ-‚ñƒ@-ƒ–JK[TURS',
  'kanji0'	=> 'V-Z',
  'kanji1'	=> 'ˆŸ-˜r',
  'kanji2'	=> '˜Ÿ-ê¤',
  'kanji'	=> 'V-ZˆŸ-˜r˜Ÿ-ê¤',
  'boxdrawing'	=> '„Ÿ-„¾',
);

printf "1..%d\n", scalar keys %res;

my($OK,$r);
for $r (sort keys %res){
#  print "$r\t" if ! $HARNESS;

  my($msg, $ch);
  my $ng = 0;

  $yesp = re("^\\p{$r}\$");
  $nop  = re("^\\p{^$r}\$");
  $yesP = re("^\\P{^$r}\$");
  $noP  = re("^\\P{$r}\$");
  $yesC = re("^[[:$r:]]\$");
  $noC  = re("^[[:^$r:]]\$");

  for $ch (mkrange($res{$r})){
    $ng++ unless $ch =~ /$yesp/ && $ch =~ /$yesP/ && $ch =~ /$yesC/;
  }
  for $ch (@sjischar){
    my $p = ($ch =~ /$yesp/) ^ ($ch =~ /$nop/);
    my $P = ($ch =~ /$yesP/) ^ ($ch =~ /$noP/);
    my $C = ($ch =~ /$yesC/) ^ ($ch =~ /$noC/);
    $ng++ unless $p && $P && $C;
  }

  $msg = $ng == 0 ? "ok" : "not ok";

  ++$n;
  print "$msg $n\n";
  push @NG, "$r\n" if ! $HARNESS and $msg ne 'ok';
}

if(! $HARNESS){
  printf "version: $]\ntime: %d\n", time - $time;
  print ! @NG
    ? "All tests successful.\n"
    : "Failed ".scalar(@NG).", tests.\n", @NG;
}

__END__
