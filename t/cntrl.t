######################### We start with some black magic to print on failure.

use strict;
use vars qw($loaded);

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use ShiftJIS::Regexp qw(:re);
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

