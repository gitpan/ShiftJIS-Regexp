package ShiftJIS::Regexp;
use strict;
use Carp;

use vars qw($VERSION $PACKAGE @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.24';
$PACKAGE = 'ShiftJIS::Regexp'; #__PACKAGE__

use vars qw(%Err %Re $Char $PadA $PadG $PadGA);
use ShiftJIS::Regexp::Class;
use ShiftJIS::Regexp::Const qw(%Err %Re $Char $PadA $PadG $PadGA);

require Exporter;
@ISA = qw(Exporter);

%EXPORT_TAGS = (
    're'    => [qw(re mkclass rechar)],
    'op'    => [qw(match replace)],
    'split' => [qw(jsplit splitchar splitspace)],
);
$EXPORT_TAGS{all} = [ map @$_, values %EXPORT_TAGS ];
@EXPORT_OK   = @{ $EXPORT_TAGS{all} };
@EXPORT      = ();

my(%Cache);

sub getReCache { wantarray ? %Cache : \%Cache }

sub re ($;$) {
    my($flag);
    my $pat = shift;
    my $mod = shift || '';
    if ($pat =~ s/^ (\^|\\[AG]|) \(\? ([a-zA-Z]+) \) /$1/x) {
	$mod .= $2;
    }

    my $s = $mod =~ /s/;
    my $m = $mod =~ /m/;
    my $x = $mod =~ /x/;
    my $h = $mod =~ /h/;

    if ($mod =~ /o/ && defined $Cache{$pat}{$mod}) {
	return $Cache{$pat}{$mod};
    }

    my $res = $m && $s ? '(?ms)' : $m ? '(?m)' : $s ? '(?s)' : '';
    my $tmppat = $pat;

    for ($tmppat) {
	while (length) {
	    if (s/^(\(\?[p?]?{)//) {
		$res .= $1;
		my $count = 1;
		while ($count && length) {
		    if (s/^(\x5C[\x00-\xFC])//) {
			$res .= $1;
			next;
		    }
		    if (s/^([^{}\\]+)//) {
			$res .= $1;
			next;
		    }
		    if (s/^{//) {
			++$count;
			$res .= '{';
			next;
		    }
		    if (s/^}//) {
			--$count;
			$res .= '}';
			next;
		    }
		    croak $Err{Code};
		}
		if (s/^\)//) {
		    $res .= ')';
		    next;
		}
		croak $Err{Code};
	    }

	    if (s/^\x5B(\^?)//) {
		my $not = $1;
		my $class = parse_class(\$_, $mod);
		$res .= $not ? "(?:(?!$class)$Char)" : $class;
		next;
	    }

	    if (s/^\\([.*+?^$|\\()\[\]{}])//) { # backslashed meta chars
		$res .= '\\'.$1;
		next;
	    }
	    if (s|^\\?(['"/])||) { # <'>, <">, </> should be backslashed.
		$res .= '\\'.$1;
		next;
	    }
	    if ($x && s/^\s+//) { # skip whitespace
		next;
	    }
	    if (s/^\.//) { # dot
		$res .= $s ? $Re{'\j'} : $Re{'\J'};
		next;
	    }
	    if (s/^\^//) { # begin
		$res .= '(?:^)';
		next;
	    }
	    if (s/^\$//) { # end
		$res .= '(?:$)';
		next;
	    }
	    if (s/^\\z//) { # \z (Perl 5.003 doesn't have this)
		$res .= '(?!\n)\Z';
		next;
	    }
	    if (s/^\\([dDwWsSCjJ])//) { # class
		$res .= $Re{ "\\$1" };
		next;
	    }
	    if (s/^\\([pP])//) { # prop
	        my $key = parse_prop($1, \$_);
		if (defined $Re{$key}) {
		    $res .= $Re{$key};
		} else {
		    croak sprintf($Err{Undef}, $key);
		}
		next;
	    }
	    if (s/^\\([R])//) { # regex
	        my $key = parse_regex($1, \$_);
		if (defined $Re{$key}) {
		    $res .= $Re{$key};
		} else {
		    croak sprintf($Err{Undef}, $key);
		}
		next;
	    }
	    if (s/^\\([0-7][0-7][0-7]?)//) {
		$res .= rechar(chr oct $1, $mod);
		next;
	    }
	    if (s/^\\0//) {
		$res .='\\x00';
		next;
	    }
	    if (s/^\\c([\x00-\x7F])//) {
		$res .= rechar(chr(ord(uc $1) ^ 64), $mod);
		next;
	    }
	    if (s/^\\x([0-9A-Fa-f][0-9A-Fa-f])//) {
		$res .= rechar(chr hex $1, $mod);
		next;
	    }
	    if (s/^\\x\{([0-9A-Fa-f][0-9A-Fa-f])([0-9A-Fa-f][0-9A-Fa-f])\}//) {
		$res .= rechar(chr(hex $1).chr(hex $2), $mod);
		next;
	    }
	    if (s/^\\([A-Za-z])//) {
		$res .= '\\'. $1;
		next;
	    }
	    if (s/^(\(\?[a-z\-\s]+)//) {
		$res .= $1;
		next;
	    }
	    if (s/^\\([1-9])//) {
		$res .= $h ? '\\'. ($1+1) : '\\'. $1;
		next;
	    }
	    if (s/^([\x21-\x40\x5B\x5D-\x60\x7B-\x7E])//) {
		$res .= $1;
		next;
	    }
	    if ($_ eq '\\') {
		croak $Err{backtips};
	    }
	    if (s/^\\?($Char)//o) {
		$res .= rechar($1, $mod);
		next;
	    }
	    croak sprintf($Err{oddTrail}, ord);
	}
    }
    return $mod =~ /o/ ? ($Cache{$pat}{$mod} = $res) : $res;
}



sub dst ($) {
    my $str = shift;
    my $res = '';
    for ($str) {
	while (length) {
	    if (s/^\\\\//) {
		$res .= '\\\\';
		next;
	    }
	    if (s/^\\?\///) {
		$res .= '\\/';
		next;
	    }
	    if (s/^\$([1-8])//) {
		$res .= '${' . ($1 + 1) . '}';
		next;
	    }
	    if (s/^\${([1-8])}//) {
		$res .= '${' . ($1 + 1) . '}';
		next;
	    }
	    if (s/^\\([0-7][0-7][0-7])//) {
		$res .= "\\$1";
		next;
	    }
	    if (s/^\\([0-7][0-7])//) {
		$res .= "\\0$1";
		next;
	    }
	    if (s/^\\x([0-9A-Fa-f][0-9A-Fa-f])//) {
		$res .= "\\x$1";
		next;
	    }
	    if (s/^\\x\{([0-9A-Fa-f][0-9A-Fa-f])([0-9A-Fa-f][0-9A-Fa-f])\}//) {
		$res .= '\\x' . $1 . '\\x' . $2;
		next;
	    }
	    if (s/^\\0//) {
		$res .='\\x00';
		next;
	    }
	    if (s/^\\([A-Za-z])//) {
		$res .= '\\'. $1;
		next;
	    }
	    if (s/^\\?([\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])//) {
		$res .= quotemeta($1);
		next;
	    }
	    if (s/^\\?([\x00-\x7F\xA1-\xDF])//) {
		$res .= $1;
		next;
	    }
	    croak sprintf($Err{oddTrail}, ord);
	}
    }
    return $res;
}

sub match ($$;$) {
    my $str = $_[0];
    my $mod = $_[2] || '';
    my $pat = re($_[1], $mod);
    if ($mod =~ /g/) {
	my $fore = $mod =~ /z/ || '' =~ /$pat/ ? $PadGA : $PadG;
	$str =~ /$fore(?:$pat)/g;
    } else {
	$str =~ /$PadA(?:$pat)/;
    }
}


sub replace ($$$;$) {
    my $str = $_[0];
    my $dst = dst($_[2]);
    my $mod = $_[3] || '';
    my $pat = re($_[1], 'h'.$mod);
    if ($mod =~ /g/) {
	my $fore = $mod =~ /z/ || '' =~ /$pat/ ? $PadGA : $PadG;
	if (ref $str) {
	    eval "\$\$str =~ s/($fore)(?:$pat)/\${1}$dst/g";
	} else {
	    eval   "\$str =~ s/($fore)(?:$pat)/\${1}$dst/g";
	    $str;
	}
    } else {
	if (ref $str) {
	    eval "\$\$str =~ s/($PadA)(?:$pat)/\${1}$dst/";
	} else {
	    eval   "\$str =~ s/($PadA)(?:$pat)/\${1}$dst/";
	    $str;
	}
   }
}


#
# splitchar(STRING; LIMIT)
#
sub splitchar ($;$) {
    my $str = shift;
    my $lim = shift || 0;

    return wantarray ? () : 0 if $str eq '';
    return wantarray ? ($str) : 1 if $lim == 1;

    my(@ret);
    if ($lim > 1) {
	while ($str =~ s/($Char)//o) {
	    push @ret, $1;
	    last if @ret >= $lim - 1;
	}
	push @ret, $str;
    } else {
	@ret = $str =~ /$Char/go;
	push @ret, '' if $lim < 0;
    }
    return @ret;
}

#
# splitspace(STRING; LIMIT)
#
sub splitspace ($;$) {
    my $str = shift;
    my $lim = shift || 0;
    return wantarray ? () : 0 if $str eq '';

    my @ret;
    if (0 < $lim) {
	$str =~ s/^(?:[ \n\r\t\f]|\x81\x40)+//;
	@ret = jsplit('(?o)[ \n\r\t\f\x{8140}]+', $str, $lim)
    } else {
	$str =~ s/\G($Char*?)\x81\x40/$1 /go;
	@ret = split(' ', $str, $lim);
    }
    return @ret;
}

#
# jsplit(PATTERN, STRING; LIMIT)
#
sub jsplit ($$;$) {
    my $thing = shift;
    my $str = shift;
    my $lim = shift || 0;

    return splitspace($str, $lim) if !defined $thing;

    my $pat = 'ARRAY' eq ref $thing
	? re($$thing[0], $$thing[1])
	: re($thing);

    return splitchar($str, $lim) if $pat eq '';
    return wantarray ? () : 0 if $str eq '';
    return wantarray ? ($str) : 1 if $lim == 1;

    my $cnt = 0;
    my(@mat, @ret);
    while (@mat = $str =~ /^($Char*?)($pat)/) {
	if ($mat[0] eq '' && $mat[1] eq '') {
	    @mat = $str =~ /^($Char)($pat)/;
	    $str =~ s/^$Char$pat//;
	} else {
	    $str =~ s/^$Char*?$pat//;
	}
	if (@mat) {
	    push @ret, shift @mat;
	    shift @mat; # $mat[1] eq $2 is to be removed.
	    push @ret, @mat;
	}
	$cnt++;
	last if ! CORE::length $str;
	last if $lim > 1 && $cnt >= $lim - 1;
    }
    push @ret, $str if $str ne '' || $lim < 0 || $cnt < $lim;
    if ($lim == 0) {
	pop @ret while defined $ret[-1] && $ret[-1] eq '';
    }
    return @ret;
}

1;
__END__

=head1 NAME

ShiftJIS::Regexp - Shift_JIS-oriented regular expressions on byte-oriented perl

=head1 ABOUT THIS POD

This POD is written in Shift_JIS encoding.

Do you see 'C<Ç†>' as C<HIRAGANA LETTER A>?
or 'C<\>' as C<YEN SIGN>, not as C<REVERSE SOLIDUS>?
Otherwise you'd change your font to an appropriate one.
(or the POD might be badly converted.)

=head1 SYNOPSIS

  use ShiftJIS::Regexp qw(:all);

  match('Ç†Ç®ÇPÇQ', '\p{Hiragana}{2}\p{Digit}{2}');
# that is equivalant to this:
  match('Ç†Ç®ÇPÇQ', '\pH{2}\pD{2}');

  match('Ç†Ç¢Ç¢Ç§Ç§Ç§', '^Ç†Ç¢+Ç§{3}$');

  replace($str, 'A', 'Ç`', 'g');

=head1 DESCRIPTION

This module provides some functions to use Shift_JIS-oriented
regular expressions on the byte-oriented perl.

The legal Shift_JIS character in this module must
match the following regular expression:

    [\x00-\x7F\xA1-\xDF]|[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]

=head2 Functions

=over 4

=item C<re(PATTERN)>

=item C<re(PATTERN, MODIFIER)>

Returns a regular expression parsable by the byte-oriented perl.

C<PATTERN> is specified as a string.

C<MODIFIER> is specified as a string.

     i  case-insensitive pattern (only for ascii alphabets)
     I  case-insensitive pattern (greek, cyrillic, fullwidth latin)
     j  hiragana-katakana-insensitive pattern

     s  treat string as single line
     m  treat string as multiple lines
     x  ignore whitespace (i.e. [ \n\r\t\f], but not comments!)
        unless backslashed or inside a character class

     o  once parsed (not compiled!) and the result is cached internally.

C<re('^ÉRÉìÉsÉÖÅ[É^Å[?$')> matches C<'ÉRÉìÉsÉÖÅ[É^Å['> or C<'ÉRÉìÉsÉÖÅ[É^'>.

C<re('^ÇÁÇ≠Çæ$','j')> matches C<'ÇÁÇ≠Çæ'>, C<'ÉâÉNÉ_'>, C<'ÇÁÉNÇæ'>, etc.

B<C<o> modifier>

     while(<DATA>){
       print replace($_, '(perl)', '<strong>$1</strong>', 'igo');
     }
        is more efficient than

     while(<DATA>){
       print replace($_, '(perl)', '<strong>$1</strong>', 'ig');
     }

     because in the latter case the pattern is parsed every time
     whenever the function is called.

=item C<match(STRING, PATTERN)>

=item C<match(STRING, PATTERN, MODIFIER)>

An emulation of C<m//> operator for the Shift_JIS encoding.

C<PATTERN> is specified as a string.

C<MODIFIER> is specified as a string.

     i  case-insensitive pattern (only for ascii alphabets)
     I  case-insensitive pattern (greek, cyrillic, fullwidth latin)
     j  hiragana-katakana-insensitive pattern

     s  treat string as single line
     m  treat string as multiple lines
     x  ignore whitespace (i.e. [ \n\r\t\f], but not comments!)
        unless backslashed or inside a character class
     g  match globally
     z  tell the function the pattern matches zero-length substring
           (sorry, due to the poor auto-detection)

     o  once parsed (not compiled!) and the result is cached internally.

=item C<replace(STRING or SCALAR REF, PATTERN, REPLACEMENT)>

=item C<replace(STRING or SCALAR REF, PATTERN, REPLACEMENT, MODIFIER)>

An emulation of C<s///> operator for the Shift_JIS encoding.

If a reference of scalar variable is specified as the first argument,
returns the number of substitutions made.
If a string is specified as the first argument,
returns the substituted string and the specified string is unaffected.

    my $str = 'ã‡ÇPÇTÇRÇOÇOÇOÇOâ~';
    1 while replace(\$str, '(\pD)(\pD{3})(?!\pD)', '$1ÅC$2');
    print $str; # ã‡ÇPÅCÇTÇRÇOÅCÇOÇOÇOâ~

C<MODIFIER> is specified as a string.

     i  case-insensitive pattern (only for ascii alphabets)
     I  case-insensitive pattern (greek, cyrillic, fullwidth latin)
     j  hiragana-katakana-insensitive pattern

     s  treat string as single line  treat string as single line
     m  treat string as multiple lines
     x  ignore whitespace (i.e. [ \n\r\t\f], but not comments!)
        unless backslashed or inside a character class
     g  match globally
     z  tell the function the pattern matches zero-length substring
           (sorry, due to the poor auto-detection)

     o  once parsed (not compiled!) and the result is cached internally.

=item C<jsplit(PATTERN or ARRAY REF of [PATTERN, MODIFIER], STRING)>

=item C<jsplit(PATTERN or ARRAY REF of [PATTERN, MODIFIER], STRING, LIMIT)>

This function emulates C<CORE::split>.

If not in list context, these functions do only return the number of fields
found, but do not split into the C<@_> array.

C<PATTERN> is specified as a string.

    jsplit('Å^', 'Ç†Ç¢Ç§Å^Ç¶Ç®ÉÅ^');

But C<' '> as C<PATTERN> has no special meaning;
it splits the string on a single space similarly to C<CORE::split / />.

When you want to split the string on whitespace,
pass an undefined value as C<PATTERN>
or use the C<splitspace()> function.

    jsplit(undef, ' Å@ This  is Å@ perl.');
    splitspace(' Å@ This  is Å@ perl.');
    # ('This', 'is', 'perl.')

If you want to pass pattern with modifiers,
specify an arrayref of C<[PATTERN, MODIFIER]> as the first argument.

    jsplit([ 'Ç†', 'jo' ], '01234Ç†Ç¢Ç§Ç¶Ç®ÉAÉCÉEÉGÉI');

Or you can say (see L<Embedded Modifiers>):

    jsplit('(?jo)Ç†', '01234Ç†Ç¢Ç§Ç¶Ç®ÉAÉCÉEÉGÉI');

C<MODIFIER> is specified as a string.

     i  do case-insensitive pattern matching (only for ascii alphabets)
     I  do case-insensitive pattern matching
        (greek, cyrillic, fullwidth latin)
     j  do hiragana-katakana-insensitive pattern matching

     s  treat string as single line
     m  treat string as multiple lines
     x  ignore whitespace (i.e. [ \n\r\t\f], but not comments!)
        unless backslashed or inside a character class

     o  once parsed (not compiled!) and the result is cached internally.

=item C<splitspace(STRING)>

=item C<splitspace(STRING, LIMIT)>

This function emulates C<CORE::split ' ', STRING, LIMIT>
and returns the array given by split on whitespace including IDEOGRAPHIC SPACE.
Leading whitespace characters do not produce any field.

B<Note:> C<splitspace(STRING, LIMIT)> is equivalent
to C<jsplit(undef, STRING, LIMIT)>.

=item C<splitchar(STRING)>

=item C<splitchar(STRING, LIMIT)>

This function emulates C<CORE::split //, STRING, LIMIT>
and returns the array given by split of the specified string into characters.

B<Note:> C<splitchar(STRING, LIMIT)> is equivalent
to C<jsplit('', STRING, LIMIT)>.

=back

=head2 Basic Regular Expressions

   regexp          meaning

   ^               match the start of the string
                   match the start of any line with 'm' modifier

   $               match the end of the string, or before newline at the end
                   match the end of any line with 'm' modifier

   .               match any character except \n
                   match any character with 's' modifier

   \A              only at beginning of string
   \Z              at the end of the string, or before newline at the end
   \z              only at the end of the string (eq. '(?!\n)\Z')

   \C              match a single C char (octet), i.e. [\0-\xFF] in perl.
   \j              match any character, i.e. [\0-\x{FCFC}] in this module.
   \J              match any character except \n, i.e. [^\n] in this module.

     * \j and \J are extensions by this module. e.g.

        match($_, '(\j{5})\z') returns last five chars including \n at the end
        match($_, '(\J{5})\Z') returns last five chars excluding \n at the end

   \a              alarm      (BEL)
   \b              backspace  (BS) * within character classes *
   \e              escape     (ESC)
   \f              form feed  (FF)
   \n              newline    (LF, NL)
   \r              return     (CR)
   \t              tab        (HT, TAB)
   \0              null       (NUL)

   \ooo            octal single-byte character
   \xhh            hexadecimal single-byte character
   \x{hhhh}        hexadecimal double-byte character
   \c[             control character

      e.g. \012 \123 \x5c \x5C \x{824F} \x{9Fae} \cA \cZ \c^ \c?

=head2 Predefined Character Classes

   \d                        [\d]              [0-9]
   \D                        [\D]              [^0-9]
   \w                        [\w]              [0-9A-Z_a-z]
   \W                        [\W]              [^0-9A-Z_a-z]
   \s                        [\s]              [\t\n\r\f ]
   \S                        [\S]              [^\t\n\r\f ]

   \p{Xdigit}     \pX        [[:xdigit:]]      [0-9A-Fa-f]
   \p{Digit}      \pD        [[:digit:]]       [0-9ÇO-ÇX]
   \p{Upper}      \pU        [[:upper:]]       [A-ZÇ`-Çy]
   \p{Lower}      \pL        [[:lower:]]       [a-zÇÅ-Çö]
   \p{Alpha}      \pA        [[:alpha:]]       [A-Za-zÇ`-ÇyÇÅ-Çö]
   \p{Alnum}      \pQ        [[:alnum:]]       [0-9A-Za-zÇO-ÇXÇ`-ÇyÇÅ-Çö]

   \p{Word}       \pW        [[:word:]]        [_\p{Digit}\p{European}\p{Kana}\p{Kanji}]
   \p{Punct}      \pP        [[:punct:]]       [!-/:-@[-`{-~°-•ÅA-ÅIÅL-ÅQÅ\-Å¨Å∏-ÅøÅ»-ÅŒÅ⁄-ÅËÅ-Å˜Å¸Ñü-Ñæ]
   \p{Graph}      \pG        [[:graph:]]       [\p{Word}\p{Punct}]
   \p{Print}      \pT        [[:print:]]       [\x20\x{8140}\p{Graph}]
   \p{Space}      \pS        [[:space:]]       [\x20\x{8140}\x09-\x0D]
   \p{Blank}      \pB        [[:blank:]]       [\x20\x{8140}\t]
   \p{Cntrl}      \pC        [[:cntrl:]]       [\x00-\x1F\x7F]

   \p{Roman}      \pR        [[:roman:]]       [\x00-\x7F]
   \p{ASCII}                 [[:ascii:]]       [\p{Roman}]
   \p{Hankaku}    \pY        [[:hankaku:]]     [\xA1-\xDF]
   \p{Zenkaku}    \pZ        [[:zenkaku:]]     [\x{8140}-\x{FCFC}]
   \p{Halfwidth}             [[:halfwidth:]]   [!#$%&()*+,./0-9:;<=>?@A-Z\[\\\]^_`a-z{|}~]
   \p{Fullwidth}  \pF        [[:fullwidth:]]   [ÅIÅîÅêÅìÅïÅiÅjÅñÅ{ÅCÅDÅ^ÇO-ÇXÅFÅGÅÉÅÅÅÑÅHÅóÇ`-ÇyÅmÅèÅnÅOÅQÅMÇÅ-ÇöÅoÅbÅpÅP]

   \p{X0201}                 [[:x0201:]]       [\x00-\x7F\xA1-\xDF]
   \p{X0208}                 [[:x0208:]]       [\x{8140}-Å¨Å∏-ÅøÅ»-ÅŒÅ⁄-ÅËÅ-Å˜Å¸ÇO-ÇXÇ`-ÇyÇÅ-ÇöÇü-ÇÒÉ@-ÉñÉü-É∂Éø-É÷Ñ@-Ñ`Ñp-ÑëÑü-Ñæàü-òròü-Í§]
   \p{JIS}        \pJ        [[:jis:]]         [\p{X0201}\p{X0208}]
   \p{NEC}        \pN        [[:nec:]]         [\x{8740}-\x{875D}\x{875f}-\x{8775}\x{877E}-\x{879c}\x{ed40}-\x{eeec}\x{eeef}-\x{eefc}]
   \p{IBM}        \pI        [[:ibm:]]         [\x{fa40}-\x{fc4b}]
   \p{Vendor}     \pV        [[:vendor:]]      [\p{NEC}\p{IBM}]
   \p{MSWin}      \pM        [[:mswin:]]       [\p{JIS}\p{NEC}\p{IBM}]

   \p{Latin}                 [[:latin:]]       [A-Za-z]
   \p{FullLatin}             [[:fulllatin:]]   [Ç`-ÇyÇÅ-Çö]
   \p{Greek}                 [[:greek:]]       [Éü-É∂Éø-É÷]
   \p{Cyrillic}              [[:cyrillic:]]    [Ñ@-Ñ`Ñp-Ñë]
   \p{European}   \pE        [[:european:]]    [A-Za-zÇ`-ÇyÇÅ-ÇöÉü-É∂Éø-É÷Ñ@-Ñ`Ñp-Ñë]

   \p{HalfKana}              [[:halfkana:]]    [¶-ﬂ]
   \p{Hiragana}   \pH        [[:hiragana:]]    [Çü-ÇÒÅJÅKÅTÅU]
   \p{Katakana}   \pK        [[:katakana:]]    [É@-ÉñÅ[ÅRÅS]
   \p{FullKana}  [\pH\pK]    [[:fullkana:]]    [Çü-ÇÒÉ@-ÉñÅJÅKÅ[ÅTÅUÅRÅS]
   \p{Kana}                  [[:kana:]]        [¶-ﬂÇü-ÇÒÉ@-ÉñÅJÅKÅ[ÅTÅUÅRÅS]
   \p{Kanji0}     \p0        [[:kanji0:]]      [ÅV-ÅZ]
   \p{Kanji1}     \p1        [[:kanji1:]]      [àü-òr]
   \p{Kanji2}     \p2        [[:kanji2:]]      [òü-Í§]
   \p{Kanji}    [\p0\p1\p2]  [[:kanji:]]       [ÅV-ÅZàü-òròü-Í§]
   \p{BoxDrawing}            [[:boxdrawing:]]  [Ñü-Ñæ]

=over 4

=item *

C<\p{NEC}> matches an NEC special character 
or an NEC-selected IBM extended character.

C<\p{IBM}> matches an IBM extended character.

C<\p{Vendor}> matches a character of vendor-defined characters 
in Microsoft CP932, i.e. equivalent to C<[\p{NEC}\p{IBM}]>.

C<\p{MSWin}> matches a character of Microsoft CP932.

C<\p{Kanji0}> matches a kanji of the minimum kanji class of JIS X 4061;
C<\p{Kanji1}>, of the level 1 kanji of JIS X 0208;
C<\p{Kanji2}>, of the level 2 kanji of JIS X 0208;
C<\p{Kanji}>, of the basic kanji class of JIS X 4061.

=item *

C<\p{Prop}>, C<\P{^Prop}>, C<[\p{Prop}]>, etc. are equivalent to each other;
and their complements are C<\P{Prop}>, C<\p{^Prop}>, C<[\P{Prop}]>,
C<[^\p{Prop}]>, etc.

C<\pP>, C<\P^P>, C<[\pP]>, etc. are equivalent to each other;
and their complements are C<\PP>, C<\p^P>, C<[\PP]>, C<[^\pP]>, etc.

C<[[:class:]]>is equivalent to C<[^[:^class:]]>;
and their complements are C<[[:^class:]]> or C<[^[:class:]]>.

In C<\p{Prop}>, C<\P{Prop}>, C<[:class:]> expressions,
C<Prop> and C<class> are case-insensitive
(e.g. C<\p{digit}>, C<[:BoxDrawings:]>).

=item *

Prefixes C<Is> and C<In> for C<\p{Prop}> and C<\P{Prop}>
(e.g. C<\p{IsProp}>, C<\P{InProp}>, etc.) are optional.
But C<\p{isProp}>, C<\p{ISProp}>, etc. are not ok,
as C<Is> and C<In> are B<not> case-insensitive.
Using of C<Is> and C<In> is deprecated since they may conflict
with a property name beginning with C<'is'> or C<'in'> in future.

=back

=head2 Character Classes

Ranges in character class are supported. 

The order of Shift_JIS characters is:
  C<0x00 .. 0x7F, 0xA1 .. 0xDF, 0x8140 .. 0x9FFC, 0xE040 .. 0xFCFC>.

So C<[\0-\x{fcfc}]> matches any one Shift_JIS character.

In character classes, any character or byte sequence
that does not match any one Shift_JIS character,
e.g. C<re('[\xA0-\xFF]')>, is croaked.

Character classes that match non-Shift_JIS substring
are not supported (use C<\C> or alternation).

=head2 Character Equivalences

Since the version 0.13,
the POSIX character equivalent classes C<[=cc=]> are supported.
e.g. C<[[=Ç†=]]> is identical to C<[ÇüÉ@ßÇ†ÉA±]>;
C<[[=P=]]> to C<[pPÇêÇo]>; C<[[=4=]]> to C<[4ÇS]>.
They are used in a character class, like C<[[=cc=]]>,
C<[[=p=][=e=][=r=][=l=]]>.

As C<cc> in C<[=cc=]>, any character literal or meta chatacter
(C<\xhh>, C<\x{hhhh}>) that belongs to the character equivalents can be used.
e.g. C<[=Ç†=]>, C<[=ÉA=]>, C<[=\x{82A0}=]>, C<[=\xB1=]>, etc.
have identical meanings.

C<[[=Ç©=]]> matches C<'Ç©'>, C<'ÉJ'>, C<'∂'>, C<'Ç™'>, C<'ÉK'>, C<'∂ﬁ'>,
C<'Éï'> (C<'∂ﬁ'> is a two-character string, but one collation element,
C<HALFWIDTH FORM FOR KATAKANA LETTER GA>.

C<[[===]]> matches C<EQUALS SIGN>
or C<FULLWIDTH EQUALS SIGN>;
C<[[=[=]]> matches C<LEFT SQUARE BRACKET>
or C<FULLWIDTH LEFT SQUARE BRACKET>;
C<[[=]=]]> matches C<RIGHT SQUARE BRACKET>
or C<FULLWIDTH RIGHT SQUARE BRACKET>;
C<[[=\=]]> matches C<YEN SIGN> or C<FULLWIDTH YEN SIGN>.

=head2 Code Embedded in a Regular Expression (Perl 5.005 or later)

Parsing C<(?{ ... })> or C<(??{ ... })> assertions is carried out
without any special care of double-byte characters.

C<(?{ ... })> assertions are disallowed in C<match()> or C<replace()>
functions by perl due to security concerns.
Use them via C<re()> function inside your scope.

  use ShiftJIS::Regexp qw(:all);

  use re 'eval';

  $::res = 0;
  $_ = 'É|' x 8;

  my $regex = re(q/
       \j*?
       (?{ $cnt = 0 })
       (
         É| (?{ local $cnt = $cnt + 1; })
       )*  
       É|É|É|
       (?{ $::res = $cnt })
     /, 'x');

  /$regex/;
  print $::res; # 5

=head2 Embedded Modifiers

Since version 0.15, embedded modifiers are extended.

An embedded modifier, C<(?iIjsmxo)>,
that appears at the beginning of the 'regexp' or that follows
one of regular expressions C<^>, C<\A>, or C<\G>
at the beginning of the 'regexp' is allowed to
contain C<I>, C<j>, C<o> modifiers.

    e.g. (?sm)pattern  ^(?i)pattern  \G(?j)pattern  \A(?ijo)pattern

And C<match('ÉG', '(?i)Ég')> returns false (Good result)
even on Perl below 5.005,
since it works like C<match('ÉG', 'Ég', 'i')>.

=head2 Avoiding Mismatching

Using 'e' modifier in replacement or looping in a C<while>-clause
are not supported by this module.

They can be used only via a usual syntax (i.e. in C<m//> or C<s///> operators).

Use a regular expression C<'\A(\j*?)'> or C<'\G(\j*?)'>,
to avoid mismatching a single-byte character
on a trailing byte of a double-byte character,
or a double-byte character on two bytes
before and after a character boundary.

Don't forget C<$1> corresponds to C<'(\j*?)'>
and backreferences intended to use begin from C<$2>.

Ex.1

    use ShiftJIS::Regexp qw(re);

    $_ = 'Ç†Ç¢Ç§Ç¶Ç®ÉAÉCÉEÉGÉIäøéö ÉVÉtÉgÇiÇhÇr';
    my $regex = re('\G(\j*?)(\pK)');
    # or say: my $regex = re('(\R{padG})(\pK)');

    while (/$regex/go) {
        print "found a katakana: $2\n";
    }

Ex.2

    use ShiftJIS::Regexp qw(re);
    use ShiftJIS::String qw(strrev); # a Shift_JIS-oriented scalar reverse()

    my $regex = re('\G(\j*?)(\w+)');
    # or say: my $regex = re('(\R{padG})(\w+)');

    foreach ('s/Perl/Camel/g', '(ÉAÉCÉEÉGÉI)AIUEO-äøéö') {
        (my $str = $_) =~ s/$regex/$1.strrev($2)/geo; # <$1.> must be said.
        print "$str\n";
    }

B<Note:> If matching on a very long string,
a special regular expression C<\R{padG}> may be safer than C<\G(\j*?)>
as the former has a lower probability of
that the repeating count of C<*> would overflows a preset limit.

=head1 CAVEATS

A legal Shift_JIS character in this module
must match the following regular expression:

   [\x00-\x7F\xA1-\xDF]|[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]

Any string from external resource should be checked by C<issjis()>
function of C<ShiftJIS::String>, excepting you know
it is surely encoded in Shift_JIS.

Use of an illegal Shift_JIS string may lead to odd results.

Some Shift_JIS double-byte characters have one of C<[\x40-\x7E]>
as the trail byte.

   @ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~

The Perl lexer doesn't take any care to these characters,
so they sometimes make trouble.
e.g. the quoted literal C<"ï\"> causes fatal error,
since its trail byte C<0x5C> backslashes the closing quote.

Such a problem doesn't arise when the string is gotten from
any external resource. 
But writing the script containing Shift_JIS
double-byte characters needs the greatest care.

The use of single-quoted heredoc, C<E<lt>E<lt> ''>,
or C<\xhh> meta characters is recommended
in order to define a Shift_JIS string literal.

The safe ASCII-graphic characters, C<[\x21-\x3F]>, are:

   !"#$%&'()*+,-./0123456789:;<=>?

They are preferred as the delimiter of quote-like operators.

=head1 BUGS

The C<\U>, C<\L>, C<\Q>, C<\E>, and interpolation are not considered.
If necessary, use them in C<""> (or C<qq//>) operators in the argument list.

The regular expressions of the word boundary, C<\b> and C<\B>, don't work correctly.

Never pass any regular expression containing C<'(?i)'> on perl below 5.005.
Pass C<'i'> modifier as the second argument.
(On Perl 5.005 or later, C<'(?i)'> is allowed
because C<'(?-i:RE)'> prevents it from wrong matching)

e.g.

  match('ÉG', '(?i)Ég') returns true on Perl below 5.005 (Wrong).
  match('ÉG', '(?i)Ég') returns false on Perl 5.005 or later (Good).
  match('ÉG', 'Ég', 'i') returns false, ok.
  # The trail byte of 'ÉG' is 'G' and that of 'Ég' is 'g';

(see also L<Embedded Modifiers>)

The C<i>, C<I> and C<j> modifiers are invalid
 to C<\p{}>, C<\P{}>, and POSIX C<[: :]>.
 (e.g. C<\p{IsLower}>, C<[:lower:]>, etc).
So use C<re('\p{IsAlpha}')> instead of C<re('\p{IsLower}', 'iI')>.

The look-behind assertion like C<(?<=[A-Z])> is not prevented from matching
trail byte of the previous double byte character:
e.g. C<match("ÉAÉCÉE", '(?<=[A-Z])(\p{InKana})')> 
returns C<('ÉC')> (of course wrong).

Use of not greedy regular expressions, which can match empty string, 
such as C<.??> and C<\d*?>, as the PATTERN in C<jsplit()>, 
may cause failure to the emulation of C<CORE::split>.

=head1 AUTHOR

Tomoyuki SADAHIRO

  bqw10602@nifty.com
  http://homepage1.nifty.com/nomenclator/perl/
  This program is free software; you can redistribute it and/or 
  modify it under the same terms as Perl itself.

=head1 SEE ALSO

=over 4

=item L<ShiftJIS::String>

=item L<ShiftJIS::Collate>

=back

=cut
