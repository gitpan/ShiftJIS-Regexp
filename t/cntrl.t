######################### We start with some black magic to print on failure.

use strict;
use vars qw($loaded);

BEGIN { $| = 1; print "1..4\n"; }
END {print "not ok 1\n" unless $loaded;}
use ShiftJIS::Regexp qw(:re replace);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.
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

sub add_comma {
    my $str = shift;
    1 while replace(\$str, '(\pD)(\pD{3})(?!\pD)', '$1ÅC$2');
    return $str;
}

print 1
 && add_comma('ã‡ÇOâ~') eq 'ã‡ÇOâ~'
 && add_comma('ã‡ÇUÇVÇWâ~') eq 'ã‡ÇUÇVÇWâ~'
 && add_comma('ã‡ÇPÇTÇRÇOÇOÇOÇOâ~') eq 'ã‡ÇPÅCÇTÇRÇOÅCÇOÇOÇOâ~'
 && add_comma('ã‡ÇPÇQÇRÇSÇTÇUÇVÇWâ~') eq 'ã‡ÇPÇQÅCÇRÇSÇTÅCÇUÇVÇWâ~'
 && add_comma('ã‡ÇPÇQÇRÇSÇTÇUÇVÇWÇXÇOâ~') eq 'ã‡ÇPÅCÇQÇRÇSÅCÇTÇUÇVÅCÇWÇXÇOâ~'
  ? "ok" : "not ok", " 4\n";
