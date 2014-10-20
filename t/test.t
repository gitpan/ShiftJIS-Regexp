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
   &&  match("Perl�u�K", '^perl�u�K$', 'i')
   && !match("Perl�u�k", '^perl�u�K$', 'i')
   && !match('�G', '�g', 'i')
   && !match('�G', '(?i)�g')
   &&
 ( $] < 5.005 || 
       match("Perl�u�K", '^(?i:perl�u�K)$')
   && !match("Perl�u�k", '^(?i:perl�u�K)$')
 )
   &&  match("�^�]�Ƌ�", "�^�]")
   && !match("���J��", "�|�b�g")
   && !match("���J��", "��[��]��")
   &&  match("���J��", "��[��]��", 'j')
   &&  match('�炭���{', '������', 'j')
   &&  match('�炭���{', '(?j)������')
   &&  match('�炭���{', '^(?j)������')
   &&  match('�炭���{', '\A(?j)������')
   &&  match('�炭���{', '\G(?j)������')
   &&  match("���U���", "�J�S", 'j')
   &&  match("���U���", "(?j)�J�S")
   &&  match("����͂o������", "��������", 'I')
   &&  match("���Ã���", "�΃Ãσ�", 'I')
   &&  match("���Ã���", "(?I)�΃Ãσ�", 'j')
   &&  match('���W�\��', (qw/�\ /)[0] )
   && !match('Y���W', (qw/�\ /)[0])
   && !match('��@��@ ==@', '�@')
   &&  match('��', '')
   &&  join('', match("��\n��", '(^\j*)')) eq "��\n��"
   &&  join('', match("��\n��", '(^\J*)')) eq "��"
   &&  join('', match("��\n��", '(^\C\C{2})')) eq "��\n"
   &&  join('', match("��ABCD", '(^\J\C)')) eq "��A"
   &&  join('', match("\xff��\xe0", '(^\C\J)')) eq "\xff��"
   &&  match('Aa���A���', '^\j{6}$')
   &&  match('Aa���A���', '^\j{6}$', 's')
   &&  match('Aa���A���', '^\j{6}$', 'm')
   &&  match('Aa���A���'."\n", '^\j{6}$')
   &&  match('Aa���A���'."\n", '^\j{6}$', 's')
   &&  match('Aa���A���'."\n", '^\j{6}$', 'm')
   &&  match('�\��', <<'HERE', 'x')
^�\ .$
HERE
    ? "ok" : "not ok", " 2\n";

print  match('\�@', '�@$')
   && !match('\�@', '^�@$')
   &&  match('�@', '^\�@$')
   &&  match('�@', '^\x{8140}$')
   &&  match('��', '^\x{82A0}$')
   &&  match('��', '^[\x{81fc}-\x{8340}]$')
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
   &&  match('����������', '^..��{3}$')
   &&  match('����������', '^������{3}$')
   &&  match('������������', '^����+��{3}$')
   &&  match('�A�C�E�E�E', '^�A�C�E{3}$')
   &&  match('�A�C�E�E�E', '^�A�C�E{3}$', 'i')
   && !match('�A�CC�E�E�E', '^�A�Cc�E{3}$')
   && !match('', '^�A�Cc�E{3}$')
   &&  match("aaa\x1Caaa", '[\c\]')
   &&  match('�A�CC�E�E�E', '^�A�Cc�E{3}$', 'i')
   &&  match("������09", '^\pH{3}\pD{2}$')
   &&
 ( $] < 5.005 || match "�����P�Q", '(?<=\pH{2})\pD{2}') 
    ? "ok" : "not ok", " 4\n";

{
    my $aiu = "!����--������00";
print 1
   && "!����--������00" eq replace($aiu, '[\pH]', '\x{8194}', 'g')
   && "!����--������00" eq replace($aiu, '[\p{Hiragana}]', '\x{8194}', 'g')
   && "!����--������00" eq replace($aiu, '\p{Hiragana}', '��')
   && "!��������--������������00" eq replace($aiu, '(\pH+)', '${1}${1}', 'g')
   && "!��������--������00" eq replace($aiu, '(\pH+)', '${1}${1}')
    ? "ok" : "not ok", " 5\n";
}

print 1
   && "��\\0��\\0����" eq replace("��\0��\0����",'\0', '\\\\0', 'g')
   && "=�}�~=" eq replace('{�}�~}', '\{|\}', '=', 'g')
   && "��\n��\n����" eq replace("��\0��\0����",'\0', '\n', 'g')
   && '��' eq (match("�o������",   '(\J)\Z'))[0]
   && '��' eq (match("�o������\n", '(\J)\Z'))[0]
   && "\n" eq (match("�o������\n", '(\j)\z'))[0]
   && '��' eq (match("�o������",   '(\j)\z'))[0]
   && '�`' eq (match("�}�b�`",   '(\j)\z'))[0]
   && '����' eq (match('�������@�����낤', '(\PS+)\pS*\1'))[0]
   && '��������E��������E' eq replace('��������E��������E', '�E', 'E', 'g')
   && "a bDC123" eq replace("a b\n123", '$ \j', "DC", 'mx')
   && "a bDC123" eq replace("a b\n123", '$\j', "DC", 'm')
    ? "ok" : "not ok", " 6\n";

print '��:����:������^' eq join(':', jsplit('�^', '���^�����^������^'))
   && '��:������@:�����@��^' 
	eq join(':', jsplit('\pS+', '��  ������@�@�����@��^', 3))
   && join('-;-', jsplit('\|', '���Ƀ|�}�[�h�G�L��|�|�|��||�� �A�|��'))
	eq '���Ƀ|�}�[�h�G�L��-;-�|�|��-;--;-�� �A�|��'
   && join('-', jsplit('�|+', '���Ƀ|�}�[�h�G�L��|�|�|���� �A�|��', 3))
	eq '����-�}�[�h�G�L��|-���� �A�|��'
   && join('-:-', jsplit('(�^)', 'Perl�^�v���O�����^�p�X���[�h'))
	eq 'Perl-:-�^-:-�v���O����-:-�^-:-�p�X���[�h'
   && join('-:-', jsplit('(?j)(�}�c)', '�܂��܂₠���܂��܂�܂��܂�'))
	eq '-:-�܂�-:-���܂₠��-:-�܂�-:-���܂�-:-�܂�-:-���܂�'
   && join('-:-', jsplit('(?j)��+', '�����A������݂�'))
	eq '-:-�A����-:-�݂�'
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
    my $sjs = replace($str, $re, '�', 'g');
    $str =~ s/$re/�/g;
    $ng++ if $sjs ne $str;
  }
  print !$ng ? "ok" : "not ok", " 8\n";
}

{
  my $str = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789+-=";
  my $zen = "�`�a�b�c�d�e�f�g�h�i���������������������O�P�Q�R�S";
  my $jpn = "���������������������A�C�E�G�I�J�L�N�P�R�O�P�Q�R�S";
  my $perl = "���������o�d�q�kperlPERL�ς���p�A��";

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
   && "���������������A�G�I�L�N�P�R�O�P�Q�R�S"
       eq replace($jpn, '[������]', '', 'jg')
   && "�����������d�q��p��rlP��RL�ρ���p����"
       eq replace($perl, '[��e���k]', '��', 'iIjg')
   && "���������o�d�q��p��rlP��RL�ρ���p����"
       eq replace($perl, '[��e���k]', '��', 'ijg')
    ? "ok" : "not ok", " 10\n";
}

print 1
  && '##���-#�#�-#��#���[' eq
    replace('�������-�ٶ��-�J���K���[', '[[=��=]]', '#', 'g')
  &&  match('���{', '[[=��=]][[=�{=]]')
  &&  match('P��r�k', '^[[=p=]][[=�d=]][[=��=]][[=L=]]$')
  &&  match('[a]', '^[[=[=]][[=\x41=]][[=]=]]$')
  &&  match('-�m�`�n', '.[[=[=]][[=\x61=]][[=]=]]$')
   ? "ok" : "not ok", " 11\n";

if ($] < 5.005) {
   print "ok 12\n";
   print "ok 13\n";
   print "ok 14\n";
} else {
   print 'Z�A�C�E�GZ�AZ�A�C�EZ�A��A'
        eq replace('�A�C�E�G�A�A�C�E�A��A', '(?=�A)', 'Z', 'gz')
      ? "ok" : "not ok", " 12\n";
   print 'Z1Z2Z3Z1Z2Z3Z'
        eq replace('0123000123', '0*', 'Z', 'g')
   ? "ok" : "not ok", " 13\n";
   print "#\n#\n#a\n#bb\n#\n#cc\n#dd"
        eq replace("\n\na\nbb\n\ncc\ndd", '^', '#', 'mg')
      ? "ok" : "not ok", " 14\n";
}

print match('�����O�P�Q�R', '\A\pH{2}\pD*\z')
   && match('�����O�P�Q�R', '\A\ph{2}\pd*\z')
   && match('�����O�P�Q�R', '\A\p{hiragana}{2}\p{digit}{4}\z')
   && match('�����O�P�Q�R', '\A\p{IsHiragana}{2}\p{IsDigit}{4}\z')
   && match('�����O�P�Q�R', '\A\p{InHiragana}{2}\p{InDigit}{4}\z')
   ? "ok" : "not ok", " 15\n";

