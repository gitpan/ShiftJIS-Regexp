# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..9\n"; }
END {print "not ok 1\n" unless $loaded;}
use ShiftJIS::Regexp qw(:all);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

print !match("Perl", "perl")
   &&  match("PERL", '^(?i)perl$')
   &&  match("PErl", '^perl$', 'i')
   &&  match("Perl講習", '^perl講習$', 'i')
   &&  match("Perl講習", '^(?i:perl講習)$')
   && !match("Perl講縮", '^perl講習$', 'i')
   && !match("Perl講縮", '^(?i:perl講習)$')
   &&  match("運転免許", "運転")
   && !match("ヤカン", "ポット")
   && !match('＝@＝@ ==@', '　')
   &&  match('あ', '')
   &&  join('', match("あ\nい", '(^\j*)')) eq "あ\nい"
   &&  join('', match("あ\nい", '(^\J*)')) eq "あ"
   &&  join('', match("あ\nい", '(^\C\C{2})')) eq "あ\n"
   &&  join('', match("あABCD", '(^\J\C)')) eq "あA"
   &&  join('', match("\xffあ\xe0", '(^\C\J)')) eq "\xffあ"
   &&  match('Aaあアｱ亜', '^\j{6}$')
   &&  match('表示', <<'HERE', 'x')
^表 .$
HERE
    ? "ok 2\n" : "not ok 2\n";
print  match('\　', '　$')
   && !match('\　', '^　$')
   &&  match('　', '^\　$')
   &&  match('　', '^\x{8140}$')
   &&  match('あ', '^\x{82A0}$')
   &&  match('あ', '^[\x81\xfc-\x83\x40]$')
   &&  match(' ',  '^\x20$')
   &&  match('  ',  '^ \040	\ $	 ','x')
   && !match("a b",  'a b', 'x')
   &&  match("a b",  'a\ b', 'x')
   &&  match("a b",  'a[ ]b', 'x')
   &&  match("\0",  '^\0$')
    ? "ok 3\n" : "not ok 3\n";

print  match('--\\--', '\\\\')
   &&  match('あいううう', '^..う{3}$')
   &&  match('あいううう', '^あいう{3}$')
   &&  match('あいいううう', '^あい+う{3}$')
   &&  match('アイウウウ', '^アイウ{3}$')
   &&  match('アイウウウ', '^アイウ{3}$', 'i')
   && !match('アイCウウウ', '^アイcウ{3}$')
   && !match('', '^アイcウ{3}$')
   &&  match('アイCウウウ', '^アイcウ{3}$', 'i')
   &&  match("あいう09", '^\p{Hiragana}{3}\p{Digit}{2}$')
   &&  match("あお１２", '(?<=\p{InHiragana}{2})\p{IsDigit}{2}') 
    ? "ok 4\n" : "not ok 4\n";

my $str = "!あい--うえお00";

print "!＃＃--＃＃＃00" eq replace($str, '\p{Hiragana}', '\x{8194}', 'g')
   && "!＃い--うえお00" eq replace($str, '\p{InHiragana}', '＃')
   && "!あいあい--うえお00"
	 eq replace($str,'(\p{InHiragana}+)', '${1}${1}')
   && "あ\\0い\\0あい" eq replace("あ\0い\0あい",'\0', '\\\\0', 'g')
   && "あ\nい\nあい" eq replace("あ\0い\0あい",'\0', '\n', 'g')
   && "!あいあい--うえおうえお00"
	 eq replace($str,'(\p{InHiragana}+)', '${1}${1}', 'g')
   && "=マミ=" eq replace('{マミ}', '\{|\}', '=', 'g')
   && "#\n#\n#a\n#bb\n#\n#cc\n#dd"
	 eq replace("\n\na\nbb\n\ncc\ndd", '^', '#', 'mg')
   && "a bDC123" eq replace("a b\n123", '$ \j', "DC", 'mx')
   && "a bDC123" eq replace("a b\n123", '$\j', "DC", 'm')
   && 'ｌ' eq (match("Ｐｅｒｌ", '(\J)\Z'))[0]
   && 'ｌ' eq (match("Ｐｅｒｌ", '(\j)\z'))[0]
   && 'ｌ' eq (match("Ｐｅｒｌ\n", '(\J)\Z'))[0]
   && "\n" eq (match("Ｐｅｒｌ\n", '(\j)\z'))[0]
   && 'かい' eq (match('たかい　かいろう', '(\P{Space}+)\p{Space}*\1'))[0]
   && '試試試試E試試試試E' eq replace('試試試試E試試試試E', '殺', 'E', 'g')
   && 'ZアイウエZアZアイウZア泣A'
	 eq  replace('アイウエアアイウア泣A', '(?=ア)', 'Z', 'gz')
    ? "ok 5\n" : "not ok 5\n";

print 'あ:いう:えおメ^' eq join(':', jsplit('／', 'あ／いう／えおメ^'))
   && 'あ:いう＝@:えお　メ^' 
	eq join(':', jsplit('\p{IsSpace}+', 'あ  いう＝@　えお　メ^', 3))
   && join('-;-', jsplit('\|', '頭にポマード；キャ|ポポロ||ン アポロ'))
	eq '頭にポマード；キャ-;-ポポロ-;--;-ン アポロ'
   && join('-', jsplit('ポ+', '頭にポマード；キャ|ポポロン アポロ', 3))
	eq '頭に-マード；キャ|-ロン アポロ'
   && join('-:-', jsplit('(／)', 'Perl／プログラム／パスワード'))
	eq 'Perl-:-／-:-プログラム-:-／-:-パスワード'
    ? "ok 6\n" : "not ok 6\n";

{
  local $^W = 0;
  my($asc,$ng);
  $asc = "\0\x01\a\e\n\r\t\f"
	. q( !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ)
	. q([\]^_`abcdefghijklmnopqrstuvwxyz{|}~)."\x7F";

  for my $re('[\d]', '[^\s]', '[^!2]', '[^#-&]',
	'[^\/]', '[[-\\\\]', '[a-~]', '[\a-\e]',
	'[\a-\b]', '[\a-\v]', '[!-@[-^`{-~]',
	'[\C]', '[\j]', '[\J]',
  ){
    my $str = $asc;
    my $sjs = replace($str, $re, qw/ｶ g/);
    $str =~ s/$re/ｶ/g;
    $ng++ if $sjs ne $str;
  }

  if($] >= 5.006) {
    for my $re(qw/ [[:upper:]] [[:lower:]] [[:digit:]] [[:alpha:]] [[:alnum:]]      \C [[:punct:]] [[:graph:]] [[:print:]] [[:space:]] [[:cntrl:]] [[:ascii:]]/
    ){
      my $str = $asc;
      my $sjs = replace($str, $re, qw/ｶ g/);
      $str =~ s/$re/ｶ/g;
      $ng++ if $sjs ne $str;
      print $re,"\n" if $sjs ne $str;
    }
  }
  print !$ng ? "ok 7\n" : "not ok 7\n";
}

{
  my $str = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789+-=";
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
    ? "ok 8\n" : "not ok 8\n";
}

{
  use re 'eval';

  $::res = 0;
  $_ = 'ポ' x 8;

  my $regex = re(q/
       \j*?
       (?{ $cnt = 0 })
       (
         ポ (?{ local $cnt = $cnt + 1; })
       )*  
       ポポポ
       (?{ $::res = $cnt })
     /, 'x');

  /$regex/;
  print $::res == 5 ? "ok 9\n" : "not ok 9\n";
}
