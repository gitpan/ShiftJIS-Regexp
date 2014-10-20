use strict;
use vars qw($loaded);

BEGIN { $| = 1; print "1..9\n"; }
END {print "not ok 1\n" unless $loaded;}
use ShiftJIS::Regexp qw(:split);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.
my %table = (
 '�@', ' ', '�^', '/', qw/
 �O 0 �P 1 �Q 2 �R 3 �S 4 �T 5 �U 6 �V 7 �W 8 �X 9
 �` A �a B �b C �c D �d E �e F �f G �g H �h I �i J �j K �k L �l M
 �m N �n O �o P �p Q �q R �r S �s T �t U �u V �v W �w X �x Y �y Z
 �� a �� b �� c �� d �� e �� f �� g �� h �� i �� j �� k �� l �� m
 �� n �� o �� p �� q �� r �� s �� t �� u �� v �� w �� x �� y �� z
 �� = �{ + �| - �H ? �I ! �� /, '#', qw/ �� $ �� % �� & �� @ �� * 
 �� < �� > �i ( �j ) �m [ �n ] �o { �p } /,
);

my $char = '(?:[\x00-\x7F\xA1-\xDF]|[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])';

sub printH2Z {
  my $str = shift;
  $str =~ s/($char)/exists $table{$1} ? $table{$1} : $1/geo;
  $str;
}

{
  my $str = '  This  is   a  TEST =@ ';
  my $zen = '�@ T��i���@ is�@ �@a  �s�dST�@��@ ';

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

print join('�[', jsplit ['��', 'j'], '01234�����������A�C�E�G�I')
	eq '01234�[���������[�C�E�G�I'
   && join('�[', jsplit ['(��)', 'j'], '01234�����������A�C�E�G�I')
	eq '01234�[���[���������[�A�[�C�E�G�I'
 ? "ok" : "not ok", " 9\n";
