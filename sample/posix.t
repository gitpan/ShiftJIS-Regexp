######################### We start with some black magic to print on failure.

use strict;
use vars qw($loaded);

BEGIN { $| = 1; print "1..1793\n"; }
END {print "not ok 1\n" unless $loaded;}
use ShiftJIS::Regexp qw(:re match replace);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# use perl 5.7.2 or later.

my($c, $posix);

for $c (0..127) {
  my $ch = chr $c;

  for $posix (
    qw/ word  lower upper alpha digit alnum xdigit
        punct graph print space blank cntrl ascii
      /
   ) {
      my $perl = $ch =~ /[[:$posix:]]/;
      my $sjis = match($ch, "[[:$posix:]]", 'o');
      print $perl eq $sjis ? "ok" : "not ok", " ", ++$loaded, "\n";
   }
}
