######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

use strict;
use vars qw($loaded);

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use ShiftJIS::Regexp qw(:all);
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

