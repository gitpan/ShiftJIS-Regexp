# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use ShiftJIS::Regexp qw(:all);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

print !match("Perl", "perl")
   &&  match("PERL", '^(?i)perl$')
   &&  match("PErl", '^perl$', 'i')
   &&  match("PerluK", '^perluK$', 'i')
   && !match("Perluk", '^perluK$', 'i')
   &&
 ( $] < 5.005 || 
       match("PerluK", '^(?i:perluK)$')
   && !match("Perluk", '^(?i:perluK)$')
 )
   &&  match("^]ฦ", "^]")
   && !match("J", "|bg")
   && !match("J", "โ[ฉ]๑")
   &&  match("J", "โ[ฉ]๑", 'j')
   &&  match("็ญพ{", "ญพ", 'j')
   &&  match("ฉU่ฮ", "JS", 'j')
   &&  match("ฑ๊อo", "", 'I')
   &&  match("ฎรฏษ", "ฮรฯษ", 'I')
   &&  match('ภW\ฆ', qw/\\ /)
   && !match('@@ ==@', '@')
   &&  match(' ', '')
   &&  join('', match(" \nข", '(^\j*)')) eq " \nข"
   &&  join('', match(" \nข", '(^\J*)')) eq " "
   &&  join('', match(" \nข", '(^\C\C{2})')) eq " \n"
   &&  join('', match(" ABCD", '(^\J\C)')) eq " A"
   &&  join('', match("\xff \xe0", '(^\C\J)')) eq "\xff "
   &&  match('Aa Aฑ', '^\j{6}$')
   &&  match('\ฆ', <<'HERE', 'x')
^\ .$
HERE
    ? "ok 2\n" : "not ok 2\n";
print  match('\@', '@$')
   && !match('\@', '^@$')
   &&  match('@', '^\@$')
   &&  match('@', '^\x{8140}$')
   &&  match(' ', '^\x{82A0}$')
   &&  match(' ', '^[\x81\xfc-\x83\x40]$')
   &&  match(' ',  '^\x20$')
   &&  match('  ',  '^ \040	\ $	 ','x')
   && !match("a b",  'a b', 'x')
   &&  match("a b",  'a\ b', 'x')
   &&  match("a b",  'a[ ]b', 'x')
   &&  match("\0",  '^\0$')
    ? "ok 3\n" : "not ok 3\n";

print  match('--\\--', '\\\\')
   &&  match(' ขคคค', '^..ค{3}$')
   &&  match(' ขคคค', '^ ขค{3}$')
   &&  match(' ขขคคค', '^ ข+ค{3}$')
   &&  match('ACEEE', '^ACE{3}$')
   &&  match('ACEEE', '^ACE{3}$', 'i')
   && !match('ACCEEE', '^ACcE{3}$')
   && !match('', '^ACcE{3}$')
   &&  match("aaa\x1Caaa", '[\c\]')
   &&  match('ACCEEE', '^ACcE{3}$', 'i')
   &&  match(" ขค09", '^\p{Hiragana}{3}\p{Digit}{2}$')
   &&
 ( $] < 5.005 || match " จPQ", '(?<=\p{InHiragana}{2})\p{IsDigit}{2}') 
    ? "ok 4\n" : "not ok 4\n";

my $str = "! ข--คฆจ00";

print "!--00" eq replace($str, '\p{Hiragana}', '\x{8194}', 'g')
   && "!ข--คฆจ00" eq replace($str, '\p{InHiragana}', '')
   && " \\0ข\\0 ข" eq replace(" \0ข\0 ข",'\0', '\\\\0', 'g')
   && "! ข ข--คฆจคฆจ00"
	 eq replace($str,'(\p{InHiragana}+)', '${1}${1}', 'g')
   && "! ข ข--คฆจ00"
	 eq replace($str,'(\p{InHiragana}+)', '${1}${1}')
   && "=}~=" eq replace('{}~}', '\{|\}', '=', 'g')
   && " \nข\n ข" eq replace(" \0ข\0 ข",'\0', '\n', 'g')
   && '' eq (match("o",   '(\J)\Z'))[0]
   && '' eq (match("o\n", '(\J)\Z'))[0]
   && "\n" eq (match("o\n", '(\j)\z'))[0]
   && '' eq (match("o",   '(\j)\z'))[0]
   && 'ฉข' eq (match('ฝฉข@ฉข๋ค', '(\P{Space}+)\p{Space}*\1'))[0]
   && 'EE' eq replace('EE', 'E', 'E', 'g')
   && "a bDC123" eq replace("a b\n123", '$ \j', "DC", 'mx')
   && "a bDC123" eq replace("a b\n123", '$\j', "DC", 'm')
   && 
 ( $] < 5.005 || 
      "#\n#\n#a\n#bb\n#\n#cc\n#dd"
	 eq replace("\n\na\nbb\n\ncc\ndd", '^', '#', 'mg')
   && 'ZACEGZAZACEZAA'
	 eq  replace('ACEGAACEAA', '(?=A)', 'Z', 'gz')
 )
    ? "ok 5\n" : "not ok 5\n";

print ' :ขค:ฆจ^' eq join(':', jsplit('^', ' ^ขค^ฆจ^'))
   && ' :ขค@:ฆจ@^' 
	eq join(':', jsplit('\p{IsSpace}+', '   ขค@@ฆจ@^', 3))
   && join('-;-', jsplit('\|', 'ชษ|}[hGL||||| A|'))
	eq 'ชษ|}[hGL-;-||-;--;- A|'
   && join('-', jsplit('|+', 'ชษ|}[hGL||| A|', 3))
	eq 'ชษ-}[hGL|- A|'
   && join('-:-', jsplit('(^)', 'Perl^vO^pX[h'))
	eq 'Perl-:-^-:-vO-:-^-:-pX[h'
    ? "ok 6\n" : "not ok 6\n";

{
  local $^W = 0;
  my($asc,$ng,$re);
  $asc = "\0\x01\a\e\n\r\t\f"
	. q( !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ)
	. q([\]^_`abcdefghijklmnopqrstuvwxyz{|}~)."\x7F";

  for $re('[\d]', '[^\s]', '[^!2]', '[^#-&]',
	'[^\/]', '[[-\\\\]', '[a-~]', '[\a-\e]',
	'[\a-\b]', '[\a-\v]', '[!-@[-^`{-~]',
	'[\C]', '[\j]', '[\J]',
  ){
    my $str = $asc;
    my $sjs = replace($str, $re, qw/ถ g/);
    $str =~ s/$re/ถ/g;
    $ng++ if $sjs ne $str;
  }
  if($] >= 5.006) {
    for $re(qw/ [[:upper:]] [[:lower:]] [[:digit:]] [[:alpha:]] [[:alnum:]]
 \C [[:punct:]] [[:graph:]] [[:print:]] [[:space:]] [[:cntrl:]] [[:ascii:]]/
    ){
      my $str = $asc;
      my $sjs = replace($str, $re, qw/ถ g/);
      $str =~ s/$re/ถ/g;
      $ng++ if $sjs ne $str;
      print $re,"\n" if $sjs ne $str;
    }
  }
  print !$ng ? "ok 7\n" : "not ok 7\n";
}

{
  my $str = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789+-=";
  my $zen = "`abcdefghiOPQRS";
  my $jpn = " ขคฆจฉซญฏฑACEGIJLNPROPQRS";
  my $perl = "odqkperlPERLฯ ้pA";
 print 1
   && "**CDEFGHIJKLMNO****TUVWXY***cdefghijklmno****tuvwxy*123456789+-="
       eq replace($str, '[abp-sz]', '*', 'ig')
   && "***DEFGHIJKLMNOPQRSTUVWXYZ***defghijklmnopqrstuvwxyz123456789+-="
       eq replace($str, '[abc]', '*', 'ig')
   && "**CDEFGHIJKLMNOPQRSTUVW*****cdefghijklmnopqrstuvw***123456789+-="
       eq replace($str, '[a-a_b-bx-z]', '*', 'ig')
   && "ABCDEFGHI*KLMNOPQRSTUVWXYZabcdefghi*klmnopqrstuvwxyz123456789+-="
       eq replace($str, '\c*', '*', 'ig')
   && "*BCDEFGHIJKLMNOPQRSTUVWXYZ*bcdefghijklmnopqrstuvwxyz*********+-*"
       eq replace($str, '[0-A]', '*', 'ig')
   && "*************************************************************+-*"
       eq replace($str, '[0-a]', '*', 'ig')
   && "****E******L***P*R************e******l***p*r********************"
       eq replace($str, '[^perl]', '*', 'ig')
   && " ฆจซญฏฑAGILNPROPQRS"
       eq replace($jpn, '[คฉข]', '', 'jg')
   && "dqprlPRLฯ้p"
       eq replace($perl, '[e k]', '', 'iIjg')
   && "odqprlPRLฯ้p"
       eq replace($perl, '[e k]', '', 'ijg')
    ? "ok 8\n" : "not ok 8\n";
}

