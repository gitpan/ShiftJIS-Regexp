use strict;
use vars qw($loaded);

BEGIN { $| = 1; print "1..13\n"; }
END {print "not ok 1\n" unless $loaded;}
use ShiftJIS::Regexp qw(:split);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.
my %table = (
 '　', ' ', '／', '/', qw/
 ０ 0 １ 1 ２ 2 ３ 3 ４ 4 ５ 5 ６ 6 ７ 7 ８ 8 ９ 9
 Ａ A Ｂ B Ｃ C Ｄ D Ｅ E Ｆ F Ｇ G Ｈ H Ｉ I Ｊ J Ｋ K Ｌ L Ｍ M
 Ｎ N Ｏ O Ｐ P Ｑ Q Ｒ R Ｓ S Ｔ T Ｕ U Ｖ V Ｗ W Ｘ X Ｙ Y Ｚ Z
 ａ a ｂ b ｃ c ｄ d ｅ e ｆ f ｇ g ｈ h ｉ i ｊ j ｋ k ｌ l ｍ m
 ｎ n ｏ o ｐ p ｑ q ｒ r ｓ s ｔ t ｕ u ｖ v ｗ w ｘ x ｙ y ｚ z
 ＝ = ＋ + − - ？ ? ！ ! ＃ /, '#', qw/ ＄ $ ％ % ＆ & ＠ @ ＊ * 
 ＜ < ＞ > （ ( ） ) ［ [ ］ ] ｛ { ｝ } /,
);

my $char = '(?:[\x00-\x7F\xA1-\xDF]|[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])';

sub printH2Z {
  my $str = shift;
  $str =~ s/($char)/exists $table{$1} ? $table{$1} : $1/geo;
  $str;
}

sub listtostr {
  my @a = @_;
  return @a ? join('', map "<$_>", @a) : '';
}

{
  my $str = '  This  is   a  TEST =@ ';
  my $zen = '　 Tｈiｓ　 is　 　a  ＴＥST　＝@ ';

  my($n, $NG);

# splitchar in scalar context
  $NG = 0;
  for $n (-1..20){
    my $core  = @{[ split(//, $str, $n) ]};
    my $sjsp  = jsplit('',$zen,$n);
    my $sjsc  = splitchar($zen,$n);

    ++$NG unless $core == $sjsp && $core == $sjsc;
  }
  print !$NG ? "ok" : "not ok", " 2\n";

# splitchar in list context
  $NG = 0;
  for $n (-1..20){
    my $core = join ':', split //, $str, $n;
    my $sjsp = join ':', jsplit('',$zen,$n);
    my $sjsc = join ':', splitchar($zen,$n);
    ++$NG unless $core eq printH2Z($sjsp) && $core eq printH2Z($sjsc);
  }
  print !$NG ? "ok" : "not ok", " 3\n";

# splitspace in scalar context
  $NG = 0;
  for $n (-1..5){
    my $core = @{[ split ' ', $str, $n ]};
    my $sjsp = splitspace($zen,$n);
    ++$NG unless $core eq printH2Z($sjsp);
  }
  print !$NG ? "ok" : "not ok", " 4\n";

# splitspace in list context
  $NG = 0;
  for $n (-1..5){
    my $core = join ':', split(' ', $str, $n);
    my $sjsp = join ':', splitspace($zen,$n);
    ++$NG unless $core eq printH2Z($sjsp);
  }
  print !$NG ? "ok" : "not ok", " 5\n";

# split / / in list context
  $NG = 0;
  for $n (-1..5){
    my $core = join ':', split(/ /, $str, $n);
    my $sjsp = join ':', jsplit(' ',$str,$n);
    ++$NG unless $core eq $sjsp;
  }
  print !$NG ? "ok" : "not ok", " 6\n";

# split /\\s+/ in list context
  $NG = 0;
  for $n (-1..5){
    my $core = join ':', split(/\s+/, $str, $n);
    my $sjsp = join ':', jsplit('\p{IsSpace}+',$zen,$n);
    ++$NG unless $core eq printH2Z($sjsp);
  }
  print !$NG ? "ok" : "not ok", " 7\n";

# split /\s*,\s*/ in list context
  $NG = 0;
  for $n (-1..5){
    my $core = join ":", split /\s*,\s*/, " , abc, efg , hij, , , ", $n;
    my $sjsp = join ":", jsplit('\s*,\s*', " , abc, efg , hij, , , ", $n);
    ++$NG unless $core eq $sjsp;
  }
  print !$NG ? "ok" : "not ok", " 8\n";
}

print join('ー', jsplit ['あ', 'j'], '01234あいうえおアイウエオ')
	eq '01234ーいうえおーイウエオ'
   && join('ー', jsplit ['(あ)', 'j'], '01234あいうえおアイウエオ')
	eq '01234ーあーいうえおーアーイウエオ'
 ? "ok" : "not ok", " 9\n";


{ # split of empty string
  my($NG, $n);

# splitchar in scalar context
  $NG = 0;
  for $n (-1..20){
    my $core = @{[ split(//, '', $n) ]};
    my $mbcs = jsplit('','',$n);
    ++$NG unless $core == $mbcs;
  }
  print !$NG ? "ok" : "not ok", " 10\n";

# splitchar in list context
  $NG = 0;
  for $n (-1..20){
    my $core = listtostr( split //, '', $n);
    my $mbcs = listtostr( jsplit('','',$n));
    ++$NG unless $core eq $mbcs;
  }
  print !$NG ? "ok" : "not ok", " 11\n";

# split(/ /, '') in list context
  $NG = 0;
  for $n (-1..5){
    my $core = listtostr( split(/ /, '', $n) );
    my $mbcs = listtostr( jsplit(' ', '', $n) );
    ++$NG unless $core eq $mbcs;
  }
  print !$NG ? "ok" : "not ok", " 12\n";

# splitspace('') in list context
  $NG = 0;
  for $n (-1..5){
    my $core = listtostr( split(' ', '', $n) );
    my $mbcs = listtostr( splitspace('', $n) );
    ++$NG unless $core eq $mbcs;
  }
  print !$NG ? "ok" : "not ok", " 13\n";
}

