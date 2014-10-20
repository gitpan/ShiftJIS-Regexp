###############

use strict;
use vars qw($loaded);

BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use ShiftJIS::Regexp qw(:re replace);
$loaded = 1;
print "ok 1\n";

###############
{
  my($ng);
  my @c = map chr, 0..127;
  my($re,$rg,$n);
  for $n (0..127){
    $re = '[\c' . chr($n) . ']';
    $rg = re($re);
    for(@c){
      next  if !/$re/;
      $ng++ if !/$rg/;
      last;
    }
    $re = '\c' . chr($n);
    $rg = re($re);
    for(@c){
      next  if !/$rg/;
      $ng++ if !/$re/;
      last;
    }
  }
  print !$ng ? "ok" : "not ok", " 2\n";
}

{
  my($ng);
  my @c = map chr, 0..127;
  my($re,$n,$c);
  for $n (0..127){
    $c  = chr($n);
    $re = re("[[=$c=]]");
    $ng++ if $c !~ /^$re$/;
    $re = re("[[=\Q$c\E=]]");
    $ng++ if $c !~ /^$re$/;
    $re = re(sprintf '[[=\x%02x=]]', $n);
    $ng++ if $c !~ /^$re$/;
  }
  print !$ng ? "ok" : "not ok", " 3\n";
}

sub addcomma {
    my $str = shift;
    1 while replace(\$str, '(\pD)(\pD{3})(?!\pD)', '$1�C$2');
    return $str;
}

print addcomma('���O�~') eq '���O�~'
  ? "ok" : "not ok", " 4\n";
print addcomma('���U�V�W�~') eq '���U�V�W�~'
  ? "ok" : "not ok", " 5\n";
print addcomma('���P�T�R�O�O�O�O�~') eq '���P�C�T�R�O�C�O�O�O�~'
  ? "ok" : "not ok", " 6\n";
print addcomma('���P�Q�R�S�T�U�V�W�~') eq '���P�Q�C�R�S�T�C�U�V�W�~'
  ? "ok" : "not ok", " 7\n";
print addcomma('���P�Q�R�S�T�U�V�W�X�O�~') eq '���P�C�Q�R�S�C�T�U�V�C�W�X�O�~'
  ? "ok" : "not ok", " 8\n";
