######################### We start with some black magic to print on failure.

use strict;
use vars qw($loaded);

BEGIN { $| = 1; print "1..15\n"; }
END {print "not ok 1\n" unless $loaded;}
use ShiftJIS::Regexp qw(:all);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

print !match("Perl", "perl")
   &&  match("PERL", '^(?i)perl$')
   &&  match("PErl", '^perl$', 'i')
   &&  match("Perl講習", '^perl講習$', 'i')
   && !match("Perl講縮", '^perl講習$', 'i')
   && !match('エ', 'ト', 'i')
   && !match('エ', '(?i)ト')
   &&
 ( $] < 5.005 || 
       match("Perl講習", '^(?i:perl講習)$')
   && !match("Perl講縮", '^(?i:perl講習)$')
 )
   &&  match("運転免許", "運転")
   && !match("ヤカン", "ポット")
   && !match("ヤカン", "や[か]ん")
   &&  match("ヤカン", "や[か]ん", 'j')
   &&  match('らくだ本', 'ラくだ', 'j')
   &&  match('らくだ本', '(?j)ラくだ')
   &&  match('らくだ本', '^(?j)ラくだ')
   &&  match('らくだ本', '\A(?j)ラくだ')
   &&  match('らくだ本', '\G(?j)ラくだ')
   &&  match("かゞり火", "カヾ", 'j')
   &&  match("かゞり火", "(?j)カヾ")
   &&  match("これはＰｅｒｌ", "ｐｅｒｌ", 'I')
   &&  match("ΠεΡλ", "περλ", 'I')
   &&  match("ΠεΡλ", "(?I)περλ", 'j')
   &&  match('座標表示', (qw/表 /)[0] )
   && !match('Y座標', (qw/表 /)[0])
   && !match('＝@＝@ ==@', '　')
   &&  match('あ', '')
   &&  join('', match("あ\nい", '(^\j*)')) eq "あ\nい"
   &&  join('', match("あ\nい", '(^\J*)')) eq "あ"
   &&  join('', match("あ\nい", '(^\C\C{2})')) eq "あ\n"
   &&  join('', match("あABCD", '(^\J\C)')) eq "あA"
   &&  join('', match("\xffあ\xe0", '(^\C\J)')) eq "\xffあ"
   &&  match('Aaあアｱ亜', '^\j{6}$')
   &&  match('Aaあアｱ亜', '^\j{6}$', 's')
   &&  match('Aaあアｱ亜', '^\j{6}$', 'm')
   &&  match('Aaあアｱ亜'."\n", '^\j{6}$')
   &&  match('Aaあアｱ亜'."\n", '^\j{6}$', 's')
   &&  match('Aaあアｱ亜'."\n", '^\j{6}$', 'm')
   &&  match('表示', <<'HERE', 'x')
^表 .$
HERE
    ? "ok" : "not ok", " 2\n";

print  match('\　', '　$')
   && !match('\　', '^　$')
   &&  match('　', '^\　$')
   &&  match('　', '^\x{8140}$')
   &&  match('あ', '^\x{82A0}$')
   &&  match('あ', '^[\x{81fc}-\x{8340}]$')
   &&  match(' ',  '^\x20$')
   &&  match('  ',  '^ \040	\ $	 ','x')
   && !match("a b",  'a b', 'x')
   &&  match("ab",  'a b', 'x')
   &&  match("ab",  '(?iIjx)  a  b  ')
   &&  match("a b",  'a\ b', 'x')
   &&  match("a b",  'a[ ]b', 'x')
   &&  match("\0",  '^\0$')
    ? "ok" : "not ok", " 3\n";

print  match('--\\--', '\\\\')
   &&  match('あいううう', '^..う{3}$')
   &&  match('あいううう', '^あいう{3}$')
   &&  match('あいいううう', '^あい+う{3}$')
   &&  match('アイウウウ', '^アイウ{3}$')
   &&  match('アイウウウ', '^アイウ{3}$', 'i')
   && !match('アイCウウウ', '^アイcウ{3}$')
   && !match('', '^アイcウ{3}$')
   &&  match("aaa\x1Caaa", '[\c\]')
   &&  match('アイCウウウ', '^アイcウ{3}$', 'i')
   &&  match("あいう09", '^\pH{3}\pD{2}$')
   &&
 ( $] < 5.005 || match "あお１２", '(?<=\pH{2})\pD{2}') 
    ? "ok" : "not ok", " 4\n";

{
    my $aiu = "!あい--うえお00";
print 1
   && "!＃＃--＃＃＃00" eq replace($aiu, '[\pH]', '\x{8194}', 'g')
   && "!＃＃--＃＃＃00" eq replace($aiu, '[\p{Hiragana}]', '\x{8194}', 'g')
   && "!＃い--うえお00" eq replace($aiu, '\p{Hiragana}', '＃')
   && "!あいあい--うえおうえお00" eq replace($aiu, '(\pH+)', '${1}${1}', 'g')
   && "!あいあい--うえお00" eq replace($aiu, '(\pH+)', '${1}${1}')
    ? "ok" : "not ok", " 5\n";
}

print 1
   && "あ\\0い\\0あい" eq replace("あ\0い\0あい",'\0', '\\\\0', 'g')
   && "=マミ=" eq replace('{マミ}', '\{|\}', '=', 'g')
   && "あ\nい\nあい" eq replace("あ\0い\0あい",'\0', '\n', 'g')
   && 'ｌ' eq (match("Ｐｅｒｌ",   '(\J)\Z'))[0]
   && 'ｌ' eq (match("Ｐｅｒｌ\n", '(\J)\Z'))[0]
   && "\n" eq (match("Ｐｅｒｌ\n", '(\j)\z'))[0]
   && 'ｌ' eq (match("Ｐｅｒｌ",   '(\j)\z'))[0]
   && 'チ' eq (match("マッチ",   '(\j)\z'))[0]
   && 'かい' eq (match('たかい　かいろう', '(\PS+)\pS*\1'))[0]
   && '試試試試E試試試試E' eq replace('試試試試E試試試試E', '殺', 'E', 'g')
   && "a bDC123" eq replace("a b\n123", '$ \j', "DC", 'mx')
   && "a bDC123" eq replace("a b\n123", '$\j', "DC", 'm')
    ? "ok" : "not ok", " 6\n";

print 'あ:いう:えおメ^' eq join(':', jsplit('／', 'あ／いう／えおメ^'))
   && 'あ:いう＝@:えお　メ^' 
	eq join(':', jsplit('\pS+', 'あ  いう＝@　えお　メ^', 3))
   && join('-;-', jsplit('\|', '頭にポマード；キャ|ポポロ||ン アポロ'))
	eq '頭にポマード；キャ-;-ポポロ-;--;-ン アポロ'
   && join('-', jsplit('ポ+', '頭にポマード；キャ|ポポロン アポロ', 3))
	eq '頭に-マード；キャ|-ロン アポロ'
   && join('-:-', jsplit('(／)', 'Perl／プログラム／パスワード'))
	eq 'Perl-:-／-:-プログラム-:-／-:-パスワード'
   && join('-:-', jsplit('(?j)(マツ)', 'まつしまやああまつしまやまつしまや'))
	eq '-:-まつ-:-しまやああ-:-まつ-:-しまや-:-まつ-:-しまや'
   && join('-:-', jsplit('(?j)ヲ+', 'をを、これをみろ'))
	eq '-:-、これ-:-みろ'
    ? "ok" : "not ok", " 7\n";

{
  local $^W = 0;
  my($asc,$ng,$re);
  $asc = "\0\x01\a\e\n\r\t\f"
	. q( !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ)
	. q([\]^_`abcdefghijklmnopqrstuvwxyz{|}~)."\x7F";

  for $re('[\d]', '[^\s]', '[^!2]', '[^#-&]',
	'[^\/]', '[[-\\\\]', '[a-~]', '[\a-\e]',
	'[\a-\b]', '[\a-v]', '[!-@[-^`{-~]',
  ){
    my $str = $asc;
    my $sjs = replace($str, $re, 'ｶ', 'g');
    $str =~ s/$re/ｶ/g;
    $ng++ if $sjs ne $str;
  }
  print !$ng ? "ok" : "not ok", " 8\n";
}

{
  my $str = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789+-=";
  my $zen = "ＡＢＣＤＥＦＧＨＩＪａｂｃｄｅｆｇｈｉｊ０１２３４";
  my $jpn = "あいうえおかきくけこアイウエオカキクケコ０１２３４";
  my $perl = "ｐｅｒｌＰＥＲＬperlPERLぱあるパアル";

 print 1
   && "**CDEFGHIJKLMNO****TUVWXY***cdefghijklmno****tuvwxy*123456789+-="
       eq replace($str, '[abp-sz]', '*', 'ig')
   && "***DEFGHIJKLMNOPQRSTUVWXYZ***defghijklmnopqrstuvwxyz123456789+-="
       eq replace($str, '[abc]', '*', 'ig')
   && "**CDEFGHIJKLMNOPQRSTUVW*****cdefghijklmnopqrstuvw***123456789+-="
       eq replace($str, '[a-a_b-bx-z]', '*', 'ig')
   && "ABCDEFGHI*KLMNOPQRSTUVWXYZabcdefghi*klmnopqrstuvwxyz123456789+-="
       eq replace($str, '\c*', '*', 'ig')
    ? "ok" : "not ok", " 9\n";

 print 1
   && "*BCDEFGHIJKLMNOPQRSTUVWXYZ*bcdefghijklmnopqrstuvwxyz*********+-*"
       eq replace($str, '[0-A]', '*', 'ig')
   && "*************************************************************+-*"
       eq replace($str, '[0-a]', '*', 'ig')
   && "****E******L***P*R************e******l***p*r********************"
       eq replace($str, '[^perl]', '*', 'ig')
   && "あえおきくけこアエオキクケコ０１２３４"
       eq replace($jpn, '[うかい]', '', 'jg')
   && "＃ｅｒ＃＃ＥＲ＃p＃rlP＃RLぱ＃るパ＃ル"
       eq replace($perl, '[ｐeあＬ]', '＃', 'iIjg')
   && "＃ｅｒｌＰＥＲ＃p＃rlP＃RLぱ＃るパ＃ル"
       eq replace($perl, '[ｐeあＬ]', '＃', 'ijg')
    ? "ok" : "not ok", " 10\n";
}

print 1
  && '##りび-#ﾙ#ﾓ-#ン#ルー' eq
    replace('かがりび-ｶﾙｶﾞﾓ-カンガルー', '[[=か=]]', '#', 'g')
  &&  match('日本', '[[=日=]][[=本=]]')
  &&  match('PｅrＬ', '^[[=p=]][[=Ｅ=]][[=ｒ=]][[=L=]]$')
  &&  match('[a]', '^[[=[=]][[=\x41=]][[=]=]]$')
  &&  match('-［Ａ］', '.[[=[=]][[=\x61=]][[=]=]]$')
   ? "ok" : "not ok", " 11\n";

if ($] < 5.005) {
   print "ok 12\n";
   print "ok 13\n";
   print "ok 14\n";
} else {
   print 'ZアイウエZアZアイウZア泣A'
        eq replace('アイウエアアイウア泣A', '(?=ア)', 'Z', 'gz')
      ? "ok" : "not ok", " 12\n";
   print 'Z1Z2Z3Z1Z2Z3Z'
        eq replace('0123000123', '0*', 'Z', 'g')
   ? "ok" : "not ok", " 13\n";
   print "#\n#\n#a\n#bb\n#\n#cc\n#dd"
        eq replace("\n\na\nbb\n\ncc\ndd", '^', '#', 'mg')
      ? "ok" : "not ok", " 14\n";
}

print match('あい０１２３', '\A\pH{2}\pD*\z')
   && match('あい０１２３', '\A\ph{2}\pd*\z')
   && match('あい０１２３', '\A\p{hiragana}{2}\p{digit}{4}\z')
   && match('あい０１２３', '\A\p{IsHiragana}{2}\p{IsDigit}{4}\z')
   && match('あい０１２３', '\A\p{InHiragana}{2}\p{InDigit}{4}\z')
   ? "ok" : "not ok", " 15\n";

