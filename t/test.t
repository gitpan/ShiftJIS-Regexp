
use strict;
use vars qw($loaded);

BEGIN { $| = 1; print "1..129\n"; }
END {print "not ok 1\n" unless $loaded;}
use ShiftJIS::Regexp qw(:all);
$loaded = 1;
print "ok 1\n";

#########

print !match("Perl", "perl")          ? "ok" : "not ok", " 2\n";
print  match("PERL", '^(?i)perl$')    ? "ok" : "not ok", " 3\n";
print  match("PErl", '^perl$', 'i')   ? "ok" : "not ok", " 4\n";
print  match("Perl�u�K", '^perl�u�K$', 'i')    ? "ok" : "not ok", " 5\n";
print !match("Perl�u�k", '^perl�u�K$', 'i')    ? "ok" : "not ok", " 6\n";
print !match('�G', '�g', 'i')        ? "ok" : "not ok", " 7\n";
print !match('�G', '(?i)�g')         ? "ok" : "not ok", " 8\n";
print  $] < 5.005 ||
     ( match("Perl�u�K", '^(?i:perl�u�K)$')
   && !match("Perl�u�k", '^(?i:perl�u�K)$'))
    ? "ok" : "not ok", " 9\n";

print  match("�^�]�Ƌ�", "�^�]")     ? "ok" : "not ok", " 10\n";
print !match("���J��", "�|�b�g")     ? "ok" : "not ok", " 11\n";
print !match("���J��", "��[��]��")   ? "ok" : "not ok", " 12\n";
print  match("���J��", "��[��]��", 'j')    ? "ok" : "not ok", " 13\n";
print  match('�炭���{', '������', 'j')    ? "ok" : "not ok", " 14\n";
print  match('�炭���{', '(?j)������')     ? "ok" : "not ok", " 15\n";
print  match('�炭���{', '^(?j)������')    ? "ok" : "not ok", " 16\n";
print  match('�炭���{', '\A(?j)������')   ? "ok" : "not ok", " 17\n";
print  match('�炭���{', '\G(?j)������')   ? "ok" : "not ok", " 18\n";
print  match("���U���", "�J�S", 'j')      ? "ok" : "not ok", " 19\n";
print  match("���U���", "(?j)�J�S")       ? "ok" : "not ok", " 20\n";
print  match("����͂o������", "��������", 'I')  ? "ok" : "not ok", " 21\n";
print  match("���Ã���", "�΃Ãσ�", 'I')  ? "ok" : "not ok", " 22\n";
print  match("���Ã���", "(?I)�΃Ãσ�", 'j')    ? "ok" : "not ok", " 23\n";
print  match('���W�\��', (qw/�\ /)[0] )    ? "ok" : "not ok", " 24\n";
print !match('Y���W', (qw/�\ /)[0])        ? "ok" : "not ok", " 25\n";
print !match('��@��@ ==@', '�@')           ? "ok" : "not ok", " 26\n";
print  match('��', '')                     ? "ok" : "not ok", " 27\n";

print join('', match("��\n��", '(^\j*)')) eq "��\n��"
    ? "ok" : "not ok", " 28\n";
print join('', match("��\n��", '(^\J*)')) eq "��"
    ? "ok" : "not ok", " 29\n";
print join('', match("��\n��", '(^\C\C{2})')) eq "��\n"
    ? "ok" : "not ok", " 30\n";
print join('', match("��ABCD", '(^\J\C)')) eq "��A"
    ? "ok" : "not ok", " 31\n";
print join('', match("\xff��\xe0", '(^\C\J)')) eq "\xff��"
    ? "ok" : "not ok", " 32\n";

print  match('Aa���A���', '^\j{6}$')        ? "ok" : "not ok", " 33\n";
print  match('Aa���A���', '^\j{6}$', 's')   ? "ok" : "not ok", " 34\n";
print  match('Aa���A���', '^\j{6}$', 'm')   ? "ok" : "not ok", " 35\n";
print  match('Aa���A���'."\n", '^\j{6}$')   ? "ok" : "not ok", " 36\n";
print  match('Aa���A���'."\n", '^\j{6}$', 's')   ? "ok" : "not ok", " 37\n";
print  match('Aa���A���'."\n", '^\j{6}$', 'm')   ? "ok" : "not ok", " 38\n";
print  match('�\��', <<'HERE', 'x')         ? "ok" : "not ok", " 39\n";
^�\ .$
HERE

print  match('\�@', '�@$')            ? "ok" : "not ok", " 40\n";
print !match('\�@', '^�@$')           ? "ok" : "not ok", " 41\n";
print  match('�@', '^\�@$')           ? "ok" : "not ok", " 42\n";
print  match('�@', '^\x{8140}$')      ? "ok" : "not ok", " 43\n";
print  match('��', '^\x{82A0}$')      ? "ok" : "not ok", " 44\n";
print  match('��', '^[\x{81fc}-\x{8340}]$')      ? "ok" : "not ok", " 45\n";
print  match(' ',  '^\x20$')          ? "ok" : "not ok", " 46\n";
print  match('  ',  '^ \040	\ $	 ','x')  ? "ok" : "not ok", " 47\n";
print !match("a b",  'a b', 'x')      ? "ok" : "not ok", " 48\n";
print  match("ab",  'a b', 'x')       ? "ok" : "not ok", " 49\n";
print  match("ab",  '(?iIjx)  a  b  ')     ? "ok" : "not ok", " 50\n";
print  match("a b",  'a\ b', 'x')     ? "ok" : "not ok", " 51\n";
print  match("a b",  'a[ ]b', 'x')    ? "ok" : "not ok", " 52\n";
print  match("\0",  '^\0$')           ? "ok" : "not ok", " 53\n";

print  match('--\\--', '\\\\')        ? "ok" : "not ok", " 54\n";
print  match('����������', '^..��{3}$')       ? "ok" : "not ok", " 55\n";
print  match('����������', '^������{3}$')     ? "ok" : "not ok", " 56\n";
print  match('������������', '^����+��{3}$')  ? "ok" : "not ok", " 57\n";
print  match('�A�C�E�E�E', '^�A�C�E{3}$')     ? "ok" : "not ok", " 58\n";
print  match('�A�C�E�E�E', '^�A�C�E{3}$', 'i')    ? "ok" : "not ok", " 59\n";
print !match('�A�CC�E�E�E', '^�A�Cc�E{3}$')   ? "ok" : "not ok", " 60\n";
print !match('', '^�A�Cc�E{3}$')              ? "ok" : "not ok", " 61\n";
print  match("aaa\x1Caaa", '[\c\]')           ? "ok" : "not ok", " 62\n";
print  match('�A�CC�E�E�E', '^�A�Cc�E{3}$', 'i')  ? "ok" : "not ok", " 63\n";
print  match("������09", '^\pH{3}\pD{2}$')    ? "ok" : "not ok", " 64\n";
print  $] < 5.005 || match("�����P�Q", '(?<=\pH{2})\pD{2}')
    ? "ok" : "not ok", " 65\n";

use vars qw($aiu);
$aiu = "!����--������00";
print "!����--������00" eq replace($aiu, '[\pH]', '\x{8194}', 'g')
    ? "ok" : "not ok", " 66\n";
print "!����--������00" eq replace($aiu, '[\p{Hiragana}]', '\x{8194}', 'g')
    ? "ok" : "not ok", " 67\n";
print "!����--������00" eq replace($aiu, '\p{Hiragana}', '��')
    ? "ok" : "not ok", " 68\n";
print "!��������--������������00" eq replace($aiu, '(\pH+)', '${1}${1}', 'g')
    ? "ok" : "not ok", " 69\n";
print "!��������--������00" eq replace($aiu, '(\pH+)', '${1}${1}')
    ? "ok" : "not ok", " 70\n";


print "��\\0��\\0����" eq replace("��\0��\0����",'\0', '\\\\0', 'g')
    ? "ok" : "not ok", " 71\n";
print "=�}�~=" eq replace('{�}�~}', '\{|\}', '=', 'g')
    ? "ok" : "not ok", " 72\n";
print "��\n��\n����" eq replace("��\0��\0����",'\0', '\n', 'g')
    ? "ok" : "not ok", " 73\n";
print '��' eq (match("�o������",   '(\J)\Z'))[0]
    ? "ok" : "not ok", " 74\n";
print '��' eq (match("�o������\n", '(\J)\Z'))[0]
    ? "ok" : "not ok", " 75\n";
print "\n" eq (match("�o������\n", '(\j)\z'))[0]
    ? "ok" : "not ok", " 76\n";
print '��' eq (match("�o������",   '(\j)\z'))[0]
    ? "ok" : "not ok", " 77\n";
print '�`' eq (match("�}�b�`",   '(\j)\z'))[0]
    ? "ok" : "not ok", " 78\n";
print '����' eq (match('�������@�����낤', '(\PS+)\pS*\1'))[0]
    ? "ok" : "not ok", " 79\n";
print '��������E��������E' eq replace('��������E��������E', '�E', 'E', 'g')
    ? "ok" : "not ok", " 80\n";
print "a bDC123" eq replace("a b\n123", '$ \j', "DC", 'mx')
    ? "ok" : "not ok", " 81\n";
print "a bDC123" eq replace("a b\n123", '$\j', "DC", 'm')
    ? "ok" : "not ok", " 82\n";

print '��:����:������^' eq join(':', jsplit('�^', '���^�����^������^'))
    ? "ok" : "not ok", " 83\n";
print '��:������@:�����@��^' eq
      join(':', jsplit('\pS+', '��  ������@�@�����@��^', 3))
    ? "ok" : "not ok", " 84\n";
print '���Ƀ|�}�[�h�G�L��-;-�|�|��-;--;-�� �A�|��' eq
      join('-;-', jsplit('\|', '���Ƀ|�}�[�h�G�L��|�|�|��||�� �A�|��'))
    ? "ok" : "not ok", " 85\n";
print '����-�}�[�h�G�L��|-���� �A�|��' eq
      join('-', jsplit('�|+', '���Ƀ|�}�[�h�G�L��|�|�|���� �A�|��', 3))
    ? "ok" : "not ok", " 86\n";
print 'Perl-:-�^-:-�v���O����-:-�^-:-�p�X���[�h' eq
      join('-:-', jsplit('(�^)', 'Perl�^�v���O�����^�p�X���[�h'))
    ? "ok" : "not ok", " 87\n";
print '-:-�܂�-:-���܂₠��-:-�܂�-:-���܂�-:-�܂�-:-���܂�' eq
      join('-:-', jsplit('(?j)(�}�c)', '�܂��܂₠���܂��܂�܂��܂�'))
    ? "ok" : "not ok", " 88\n";
print '-:-�A����-:-�݂�' eq
      join('-:-', jsplit('(?j)��+', '�����A������݂�'))
    ? "ok" : "not ok", " 89\n";


use vars qw($asc);
$asc = "\0\x01\a\e\n\r\t\f"
    . q( !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ)
    . q([\]^_`abcdefghijklmnopqrstuvwxyz{|}~)."\x7F";

sub replace_ka { my($str, $re) = @_; replace($str, $re, '�', 'g') }
sub core_ka    { my($str, $re) = @_; $str =~ s/$re/�/g; $str }
sub compare    { my $r = shift; replace_ka($asc, $r) eq core_ka($asc, $r) }

print compare('[\d]')         ? "ok" : "not ok", " 90\n";
print compare('[^\s]')        ? "ok" : "not ok", " 91\n";
print compare('[^!2]')        ? "ok" : "not ok", " 92\n";
print compare('[^#-&]')       ? "ok" : "not ok", " 93\n";
print compare('[^\/]')        ? "ok" : "not ok", " 94\n";
print compare('[[-\\\\]')     ? "ok" : "not ok", " 95\n";
print compare('[a-~]')        ? "ok" : "not ok", " 96\n";
print compare('[\a-\e]')      ? "ok" : "not ok", " 97\n";
print compare('[\a-\b]')      ? "ok" : "not ok", " 98\n";
print compare('[\a-v]')       ? "ok" : "not ok", " 99\n";
print compare('[!-@[-^`{-~]') ? "ok" : "not ok", " 100\n";

use vars qw($str $zen $jpn $perl);
$str  = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789+-=";
$zen  = "�`�a�b�c�d�e�f�g�h�i���������������������O�P�Q�R�S";
$jpn  = "���������������������A�C�E�G�I�J�L�N�P�R�O�P�Q�R�S";
$perl = "���������o�d�q�kperlPERL�ς���p�A��";

print "**CDEFGHIJKLMNO****TUVWXY***cdefghijklmno****tuvwxy*123456789+-="
       eq replace($str, '[abp-sz]', '*', 'ig')
    ? "ok" : "not ok", " 101\n";
print "***DEFGHIJKLMNOPQRSTUVWXYZ***defghijklmnopqrstuvwxyz123456789+-="
       eq replace($str, '[abc]', '*', 'ig')
    ? "ok" : "not ok", " 102\n";
print "**CDEFGHIJKLMNOPQRSTUVW*****cdefghijklmnopqrstuvw***123456789+-="
       eq replace($str, '[a-a_b-bx-z]', '*', 'ig')
    ? "ok" : "not ok", " 103\n";
print "ABCDEFGHI*KLMNOPQRSTUVWXYZabcdefghi*klmnopqrstuvwxyz123456789+-="
       eq replace($str, '\c*', '*', 'ig')
    ? "ok" : "not ok", " 104\n";

print "*BCDEFGHIJKLMNOPQRSTUVWXYZ*bcdefghijklmnopqrstuvwxyz*********+-*"
       eq replace($str, '[0-A]', '*', 'ig')
    ? "ok" : "not ok", " 105\n";
print "*************************************************************+-*"
       eq replace($str, '[0-a]', '*', 'ig')
    ? "ok" : "not ok", " 106\n";
print "****E******L***P*R************e******l***p*r********************"
       eq replace($str, '[^perl]', '*', 'ig')
    ? "ok" : "not ok", " 107\n";
print "���������������A�G�I�L�N�P�R�O�P�Q�R�S"
       eq replace($jpn, '[������]', '', 'jg')
    ? "ok" : "not ok", " 108\n";
print "�����������d�q��p��rlP��RL�ρ���p����"
       eq replace($perl, '[��e���k]', '��', 'iIjg')
    ? "ok" : "not ok", " 109\n";
print "���������o�d�q��p��rlP��RL�ρ���p����"
       eq replace($perl, '[��e���k]', '��', 'ijg')
    ? "ok" : "not ok", " 110\n";

print '##���-#�#�-#��#���[' eq
    replace('�������-�ٶ��-�J���K���[', '[[=��=]]', '#', 'g')
    ? "ok" : "not ok", " 111\n";

print match('���{', '[[=��=]][[=�{=]]')
    ? "ok" : "not ok", " 112\n";
print match('P��r�k', '^[[=p=]][[=�d=]][[=��=]][[=L=]]$')
    ? "ok" : "not ok", " 113\n";
print match('[a]', '^[[=[=]][[=\x41=]][[=]=]]$')
    ? "ok" : "not ok", " 114\n";
print match('-�m�`�n', '.[[=[=]][[=\x61=]][[=]=]]$')
    ? "ok" : "not ok", " 115\n";

print $] < 5.005 || 'Z�A�C�E�GZ�AZ�A�C�EZ�A��A'
      eq replace('�A�C�E�G�A�A�C�E�A��A', '(?=�A)', 'Z', 'gz')
    ? "ok" : "not ok", " 116\n";
print $] < 5.005|| 'Z1Z2Z3Z1Z2Z3Z'
      eq replace('0123000123', '0*', 'Z', 'g')
    ? "ok" : "not ok", " 117\n";
print $] < 5.005 || "#\n#\n#a\n#bb\n#\n#cc\n#dd"
      eq replace("\n\na\nbb\n\ncc\ndd", '^', '#', 'mg')
    ? "ok" : "not ok", " 118\n";

print match('�����O�P�Q�R', '\A\pH{2}\pD*\z')
    ? "ok" : "not ok", " 119\n";
print match('�����O�P�Q�R', '\A\ph{2}\pd*\z')
    ? "ok" : "not ok", " 120\n";
print match('�����O�P�Q�R', '\A\p{hiragana}{2}\p{digit}{4}\z')
    ? "ok" : "not ok", " 121\n";
print match('�����O�P�Q�R', '\A\p{IsHiragana}{2}\p{IsDigit}{4}\z')
    ? "ok" : "not ok", " 122\n";
print match('�����O�P�Q�R', '\A\p{InHiragana}{2}\p{InDigit}{4}\z')
    ? "ok" : "not ok", " 123\n";

# A range must not match an illegal char.
print  match("\x84\x7e", "[\x84\x70-\x85\x50]")  ? "ok" : "not ok", " 124\n";
print !match("\x84\x7f", "[\x84\x70-\x85\x50]")  ? "ok" : "not ok", " 125\n";
print  match("\x84\xfc", "[\x84\x70-\x85\x50]")  ? "ok" : "not ok", " 126\n";
print !match("\x84\xff", "[\x84\x70-\x85\x50]")  ? "ok" : "not ok", " 127\n";
print !match("\x85\x10", "[\x84\x70-\x85\x50]")  ? "ok" : "not ok", " 128\n";
print  match("\x85\x40", "[\x84\x70-\x85\x50]")  ? "ok" : "not ok", " 129\n";

