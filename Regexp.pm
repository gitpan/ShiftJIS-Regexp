package ShiftJIS::Regexp;

use strict;
use Carp;
use vars qw($VERSION $PACKAGE @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.20';
$PACKAGE = 'ShiftJIS::Regexp'; #__PACKAGE__

require Exporter;

use vars qw(%Eq);
use ShiftJIS::Regexp::Equiv qw(%Eq);

@ISA = qw(Exporter);

%EXPORT_TAGS = (
    're'    => [qw(re mkclass rechar)],
    'op'    => [qw(match replace)],
    'split' => [qw(jsplit splitchar splitspace)],
);
$EXPORT_TAGS{all} = [ map @$_, values %EXPORT_TAGS ];
@EXPORT_OK   = @{ $EXPORT_TAGS{all} };
@EXPORT      = ();

my $ErrCode = $PACKAGE.' Sequence (?{...}) not terminated or not {}-balanced';
my $ErrUndef    = $PACKAGE.' "%s" is not defined';
my $ErrUnTermin = $PACKAGE.' %s is not terminated ("%s" missing)';
my $ErrNotASCII = $PACKAGE.' "%s" is not followed by an ASCII, [\x21-\x7e]';
my $ErrNotAlnum = $PACKAGE.' "%s" is not followed by an Alnum, [0-9A-Za-z]';
my $ErrBackTips = $PACKAGE.' Trailing \ in regexp';
my $ErrOddTrail = $PACKAGE.' "\\x%02x" is not followed by trail byte';

my $ErrReverse  = $PACKAGE.' Invalid [] range (reverse) %d > %d';
my $ErrInvalRng = $PACKAGE.' Invalid [] range "%s"';
my $ErrInvalMch = $PACKAGE.' Invalid Metacharacter "%s"';
my $ErrInvalHex = $PACKAGE.' Invalid Hexadecimal %s following "\x"';
my $ErrInvalFlw = $PACKAGE.' Invalid byte "\\x%02x" following "%s" (only "%s" allowed)';



my $SBC   = '[\x00-\x7F\xA1-\xDF]';
my $Trail = '[\x40-\x7E\x80-\xFC]';
my $DBC   = '[\x81-\x9F\xE0-\xFC]'. $Trail;

my $Char = "(?:$SBC|$DBC)";

my $Apad  = '(?:\A|[\x00-\x80\xA0-\xDF])(?:[\x81-\x9F\xE0-\xFC]{2})*?';
my $Gpad  = '(?:\G|[\x00-\x80\xA0-\xDF])(?:[\x81-\x9F\xE0-\xFC]{2})*?';
my $GApad = '(?:\G\A|\G(?:[\x81-\x9F\xE0-\xFC]{2})+?'
          . '|[\x00-\x80\xA0-\xDF](?:[\x81-\x9F\xE0-\xFC]{2})*?)';

my $Open = 5.005 > $] ? '(?:' : '(?-i:';
my $Close = ')';

my %Re = (
  '\C' => '[\x00-\xFF]',
  '\j' => $Char,
  '\J' => "(?:(?!\\n)$Char)",
  '\d' => '[0-9]',
  '\D' => '(?:[\x00-\x2F\x3A-\x7F\xA1-\xDF]|' . $DBC . ')',
  '\w' => '[0-9A-Z_a-z]',
  '\W' => '(?:[\x00-\x2F\x3A-\x40\x5B-\x5E\x60\x7B-\x7F\xA1-\xDF]|'.$DBC.')',
  '\s' => '[\x09\x0A\x0C\x0D\x20]',
  '\S' => '(?:[\x00-\x08\x0B\x0E-\x1F\x21-\x7F\xA1-\xDF]|' . $DBC . ')',

  '\p{xdigit}' => '[0-9A-Fa-f]',
  '\P{xdigit}' => $Open.'[\x00-\x2F\x3A-\x40\x47-\x60\x67-\x7F\xA1-\xDF]|'
		. $DBC .$Close,

  '\p{digit}' => $Open.'[\x30-\x39]|\x82[\x4F-\x58]'.$Close,
  '\P{digit}' => $Open.'[\x00-\x2F\x3A-\x7F\xA1-\xDF]'
		. '|[\x81\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]'
		. '|\x82[\x40-\x4E\x59-\x7E\x80-\xFC]'
		. $Close,

  '\p{upper}' => $Open.'[\x41-\x5A]|\x82[\x60-\x79]'.$Close,
  '\P{upper}' => $Open.'[\x00-\x40\x5B-\x7F\xA1-\xDF]'
		. '|[\x81\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]'
		. '|\x82[\x40-\x5F\x7A-\x7E\x80-\xFC]'
		. $Close,

  '\p{lower}' => $Open.'[\x61-\x7A]|\x82[\x81-\x9A]'.$Close,
  '\P{lower}' => $Open.'[\x00-\x60\x7B-\x7F\xA1-\xDF]'
		. '|[\x81\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]'
		. '|\x82[\x40-\x7E\x80\x9B-\xFC]'. $Close,

  '\p{alpha}' => $Open.'[\x41-\x5A\x61-\x7A]|\x82[\x60-\x79\x81-\x9A]'.$Close,
  '\P{alpha}' => $Open.'[\x00-\x40\x5B-\x60\x7B-\x7F\xA1-\xDF]'
		. '|[\x81\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]'
		. '|\x82[\x40-\x5F\x7A-\x7E\x80\x9B-\xFC]'. $Close,

  '\p{alnum}' => $Open.'[0-9A-Za-z]|\x82[\x4F-\x58\x60-\x79\x81-\x9A]'.$Close,
  '\P{alnum}' => $Open.'[\x00-\x2F\x3A-\x40\x5B-\x60\x7B-\x7F\xA1-\xDF]'
		. '|[\x81\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]'
		. '|\x82[\x40-\x4E\x59-\x5F\x7A-\x7E\x80\x9B-\xFC]'. $Close,

  '\p{space}' => $Open.'[\x09\x0A\x0C\x0D\x20]|\x81\x40'.$Close,
  '\P{space}' => $Open.'[\x00-\x08\x0B\x0E-\x1F\x21-\x7F\xA1-\xDF]'
		. '|\x81[\x41-\x7E\x80-\xFC]'
		. '|[\x82-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]'. $Close,

  '\p{punct}' => $Open.'[\x21-\x2F\x3A-\x40\x5B-\x60\x7B-\x7E\xA1-\xA5]'
		. '|\x81[\x41-\x49\x4C-\x51\x5C-\x7E\x80-\xAC\xB8-\xBF'
		. '\xC8-\xCE\xDA-\xE8\xF0-\xF7\xFC]|\x84[\x9F-\xBE]'. $Close,
  '\P{punct}' => $Open.'[\x00-\x20\x30-\x39\x41-\x5A\x61-\x7A\x7F\xA6-\xDF]'
		. '|\x81[\x40\x4A\x4B\x52-\x5B\xAD-\xB7\xC0-\xC7\xCF-\xD9'
		. '\xE9-\xEF\xF8-\xFB]|\x84[\x40-\x7E\x80-\x9E\xBF-\xFC]'
		. '|[\x82\x83\x85-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]'. $Close,

  '\p{graph}' => $Open.'[\x21-\x7E\xA1-\xDF]|\x81[\x41-\x7E\x80-\xFC]'
		. '|[\x82-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]'.$Close,
  '\P{graph}' => $Open.'[\x00-\x20\x7F]|\x81\x40'.$Close,

  '\p{print}' => $Open.'[\x09\x0A\x0C\x0D\x20-\x7E\xA1-\xDF]|' .$DBC.$Close,
  '\P{print}' => '[\x00-\x08\x0B\x0E-\x1F\x7F]',

  '\p{cntrl}' => '[\x00-\x1F]',
  '\P{cntrl}' => $Open.'[\x20-\x7F\xA1-\xDF]|' .$DBC.$Close,

  '\p{ascii}' => '[\x00-\x7F]',
  '\P{ascii}' => $Open.'[\xA1-\xDF]|' .$DBC.$Close,

  '\p{roman}' => '[\x00-\x7F]',
  '\P{roman}' => $Open.'[\xA1-\xDF]|' .$DBC.$Close,

  '\p{word}'   => $Open.'[0-9A-Z_a-z\xA6-\xDF]|\x81[\x4A\x4B\x52-\x5B]|'
		. '\x82[\x4F-\x58\x60-\x79\x81-\x9A\x9F-\xF1]|'
		. '\x83[\x40-\x7E\x80-\x96\x9F-\xB6\xBF-\xD6]|'
		. '\x84[\x40-\x60\x70-\x7E\x80-\x91]|\x88[\x9F-\xFC]|'
		. '[\x89-\x97\x99-\x9F\xE0-\xE9][\x40-\x7E\x80-\xFC]|'
		. '\x98[\x40-\x72\x9F-\xFC]|\xEA[\x40-\x7E\x80-\xA4]'
		. $Close,

  '\P{word}' => $Open.'[\x00-\x2F\x3A-\x40\x5B-\x5E\x60\x7B-\x7F\xA1-\xA5]|'
		. '\x81[\x40-\x49\x4C-\x51\x5C-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x4E\x59-\x5F\x7A-\x7E\x80\x9B-\x9E\xF2-\xFC]|'
		. '\x83[\x97-\x9E\xB7-\xBE\xD7-\xFC]|'
		. '\x84[\x61-\x6F\x92-\xFC]|'
		. '[\x85-\x87\xEB-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x88[\x40-\x7E\x80-\x9E]|\x98[\x73-\x7E\x80-\x9E]|'
		. '\xEA[\xA5-\xFC]'.$Close,

  '\p{hankaku}' => '[\xA1-\xDF]',
  '\P{hankaku}' => $Open.'[\x00-\x7F]|' .$DBC.$Close,
  '\p{zenkaku}' => "$Open$DBC$Close",
  '\P{zenkaku}' => "$Open$SBC$Close",
  '\p{x0201}'   => "$Open$SBC$Close",
  '\P{x0201}'   => "$Open$DBC$Close",

  '\p{x0208}' => $Open.'\x81[\x40-\x7E'
		. '\x80-\xAC\xB8-\xBF\xC8-\xCE\xDA-\xE8\xF0-\xF7\xFC]|'
		. '\x82[\x4F-\x58\x60-\x79\x81-\x9A\x9F-\xF1]|'
		. '\x83[\x40-\x7E\x80-\x96\x9F-\xB6\xBF-\xD6]|'
		. '\x84[\x40-\x60\x70-\x7E\x80-\x91\x9F-\xBE]|'
		. '\x88[\x9F-\xFC]|\x98[\x40-\x72\x9F-\xFC]|'
		. '[\x89-\x97\x99-\x9F\xE0-\xE9][\x40-\x7E\x80-\xFC]|'
		. '\xEA[\x40-\x7E\x80-\xA4]'
		.$Close,

  '\P{x0208}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '\x81[\xAD-\xB7\xC0-\xC7\xCF-\xD9\xE9-\xEF\xF8-\xFB]|'
		. '\x82[\x40-\x4E\x59-\x5F\x7A-\x7E\x80\x9B-\x9E\xF2-\xFC]|'
		. '\x83[\x97-\x9E\xB7-\xBE\xD7-\xFC]|'
		. '\x84[\x61-\x6F\x92-\x9E\xBF-\xFC]|'
		. '[\x85-\x87\xEB-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x88[\x40-\x7E\x80-\x9E]|\x98[\x73-\x7E\x80-\x9E]|'
		. '\xEA[\xA5-\xFC]'.$Close,

  '\p{jis}'   => $Open.'[\x00-\x7F\xA1-\xDF]|\x81[\x40-\x7E'
		. '\x80-\xAC\xB8-\xBF\xC8-\xCE\xDA-\xE8\xF0-\xF7\xFC]|'
		. '\x82[\x4F-\x58\x60-\x79\x81-\x9A\x9F-\xF1]|'
		. '\x83[\x40-\x7E\x80-\x96\x9F-\xB6\xBF-\xD6]|'
		. '\x84[\x40-\x60\x70-\x7E\x80-\x91\x9F-\xBE]|'
		. '\x88[\x9F-\xFC]|\x98[\x40-\x72\x9F-\xFC]|'
		. '[\x89-\x97\x99-\x9F\xE0-\xE9][\x40-\x7E\x80-\xFC]|'
		. '\xEA[\x40-\x7E\x80-\xA4]'
		. $Close,

  '\P{jis}'   => $Open
		. '\x81[\xAD-\xB7\xC0-\xC7\xCF-\xD9\xE9-\xEF\xF8-\xFB]|'
		. '\x82[\x40-\x4E\x59-\x5F\x7A-\x7E\x80\x9B-\x9E\xF2-\xFC]|'
		. '\x83[\x97-\x9E\xB7-\xBE\xD7-\xFC]|'
		. '\x84[\x61-\x6F\x92-\x9E\xBF-\xFC]|'
		. '[\x85-\x87\xEB-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x88[\x40-\x7E\x80-\x9E]|\x98[\x73-\x7E\x80-\x9E]|'
		. '\xEA[\xA5-\xFC]'
		.$Close,

  '\p{latin}' => $Open.'[\x41-\x5A\x61-\x7A]'.$Close,
  '\P{latin}' => $Open.'[\x00-\x40\x5B-\x60\x7B-\x7F\xA1-\xDF]|'.$DBC.$Close,

  '\p{fulllatin}' => $Open.'\x82[\x60-\x79\x81-\x9A]'.$Close,
  '\P{fulllatin}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x81\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x5F\x7A-\x7E\x80\x9B-\xFC]'
		. $Close,

  '\p{greek}' => $Open.'\x83[\x9f-\xb6\xbf-\xd6]'.$Close,
  '\P{greek}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x81\x82\x84-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x83[\x40-\x7E\x80-\x9e\xb7-\xbe\xd7-\xFC]'
		. $Close,

  '\p{cyrillic}' => $Open.'\x84[\x40-\x60\x70-\x7E\x80-\x91]'.$Close,
  '\P{cyrillic}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x81-\x83\x85-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x84[\x61-\x6f\x92-\xFC]'
		. $Close,

  '\p{european}' => $Open.'[\x41-\x5A\x61-\x7A]|\x82[\x60-\x79\x81-\x9A]|'
		. '\x83[\x9f-\xb6\xbf-\xd6]|\x84[\x40-\x60\x70-\x7E\x80-\x91]'
		. $Close,

  '\P{european}' => $Open.'[\x00-\x40\x5B-\x60\x7B-\x7F\xA1-\xDF]|'
		. '[\x81\x85-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x5F\x7A-\x7E\x80\x9B-\xFC]|'
		. '\x83[\x40-\x7E\x80-\x9e\xb7-\xbe\xd7-\xFC]|'
		. '\x84[\x61-\x6f\x92-\xFC]'. $Close,

  '\p{halfkana}' => '[\xA6-\xDF]',
  '\P{halfkana}' => $Open.'[\x00-\x7F\xA1-\xA5]|' .$DBC.$Close,

  '\p{hiragana}' => $Open.'\x82[\x9F-\xF1]|\x81[\x4A\x4B\x54\x55]'.$Close,
  '\P{hiragana}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x7E\x80-\x9E\xF2-\xFC]|'
		. '\x81[\x40-\x49\x4C-\x53\x56-\x7E\x80-\xFC]'
		. $Close,

  '\p{katakana}' => $Open.'\x83[\x40-\x7E\x80-\x96]|\x81[\x52\x53\x5B]'.$Close,
  '\P{katakana}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x82\x84-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x83[\x97-\xFC]|'
		. '\x81[\x40-\x51\x54-\x5A\x5C-\x7E\x80-\xFC]'
		. $Close,

  '\p{fullkana}' => $Open.'\x82[\x9F-\xF1]|\x83[\x40-\x7E\x80-\x96]|'
		    . '\x81[\x4A\x4B\x5B\x52-\x55]'.$Close,
  '\P{fullkana}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x84-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x7E\x80-\x9E\xF2-\xFC]|\x83[\x97-\xFC]|'
		. '\x81[\x40-\x49\x4C-\x51\x56-\x5A\x5C-\x7E\x80-\xFC]'
		. $Close,

  '\p{kana}' => $Open.'[\xA6-\xDF]|\x82[\x9F-\xF1]|\x83[\x40-\x7E\x80-\x96]|'
		    . '\x81[\x4A\x4B\x5B\x52-\x55]'.$Close,
  '\P{kana}' => $Open.'[\x00-\x7F\xA1-\xA5]|'
		. '[\x84-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x7E\x80-\x9E\xF2-\xFC]|\x83[\x97-\xFC]|'
		. '\x81[\x40-\x49\x4C-\x51\x56-\x5A\x5C-\x7E\x80-\xFC]'
		. $Close,

  '\p{kanji0}'  => $Open.'\x81[\x56-\x5A]'.$Close,
  '\P{kanji0}'  => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '\x81[\x40-\x55\x5b-\x7E\x80-\xFC]|'
		. '[\x82-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]'
		. $Close,

  '\p{kanji1}'  => $Open.'\x88[\x9F-\xFC]|\x98[\x40-\x72]|'
		. '[\x89-\x97][\x40-\x7E\x80-\xFC]'.$Close,
  '\P{kanji1}'  => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '\x88[\x40-\x7E\x80-\x9E]|\x98[\x73-\x7E\x80-\xFC]|'
		. '[\x81-\x87\x99-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]'
		. $Close,

  '\p{kanji2}'  => $Open.'\x98[\x9F-\xFC]|[\x99-\x9F\xE0-\xE9]'
		. '[\x40-\x7E\x80-\xFC]|\xEA[\x40-\x7E\x80-\xA4]'
		. $Close,
  '\P{kanji2}'  => $Open.'[\x00-\x7F\xA1-\xDF]|\x98[\x40-\x7E\x80-\x9E]|'
		. '[\x81-\x97\xEB-\xFC][\x40-\x7E\x80-\xFC]|\xEA[\xA5-\xFC]'
		. $Close,

  '\p{kanji}'   => $Open.'\x81[\x56-\x5A]|\x88[\x9F-\xFC]|'
		. '[\x89-\x97\x99-\x9F\xE0-\xE9][\x40-\x7E\x80-\xFC]|'
		. '\x98[\x40-\x72\x9F-\xFC]|\xEA[\x40-\x7E\x80-\xA4]'
		. $Close,
  '\P{kanji}'   => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '\x81[\x40-\x55\x5b-\x7E\x80-\xFC]|'
		. '\x88[\x40-\x7E\x80-\x9E]|\x98[\x73-\x7E\x80-\x9E]|'
		. '[\x82-\x87\xEB-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\xEA[\xA5-\xFC]'
		. $Close,

  '\p{boxdrawing}' => $Open.'\x84[\x9F-\xBE]'.$Close,
  '\P{boxdrawing}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x81-\x83\x85-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x84[\x40-\x7E\x80-\x9E\xBF-\xFC]'
		. $Close,

  '\p{nec}' => $Open. '\x87[\x40-\x5d\x5f-\x75\x7e\x80-\x9c]|'
		. '\xed[\x40-\x7e\x80-\xfc]|\xee[\x40-\x7e\x80-\xec\xef-\xfc]'
		. $Close,

  '\p{ibm}' => $Open.'[\xfa-\xfb][\x40-\x7e\x80-\xfc]|\xfc[\x40-\x4b]'.$Close,

  '\p{vendor}' => $Open. '\x87[\x40-\x5d\x5f-\x75\x7e\x80-\x9c]|'
		. '[\xed\xfa-\xfb][\x40-\x7e\x80-\xfc]|'
		. '\xee[\x40-\x7e\x80-\xec\xef-\xfc]|\xfc[\x40-\x4b]'
		. $Close,

  '\p{mswin}' => $Open.'[\x00-\x7f\xa1-\xdf]|'
	. '\x81[\x40-\x7e\x80-\xac\xb8-\xbf\xc8-\xce\xda-\xe8\xf0-\xf7\xfc]|'
	. '\x82[\x4f-\x58\x60-\x79\x81-\x9a\x9f-\xf1]|'
	. '\x83[\x40-\x7e\x80-\x96\x9f-\xb6\xbf-\xd6]|'
	. '\x84[\x40-\x60\x70-\x7e\x80-\x91\x9f-\xbe]|'
	. '\x88[\x9f-\xfc]|\x98[\x40-\x72\x9f-\xfc]|\xea[\x40-\x7e\x80-\xa4]|'
	. '[\x89-\x97\x99-\x9f\xe0-\xe9][\x40-\x7e\x80-\xfc]|'
	. '\x87[\x40-\x5d\x5f-\x75\x7e\x80-\x9c]|'
	. '\xed[\x40-\x7e\x80-\xfc]|\xee[\x40-\x7e\x80-\xec\xef-\xfc]|'
	. '[\xfa\xfb][\x40-\x7e\x80-\xfc]|\xfc[\x40-\x4b]'
	. $Close,
);


for (qw/ nec ibm mswin vendor /) {
    $Re{"\\P{$_}"} = $Open.'(?!'. $Re{ "\\p{$_}" } .')'. $Char.$Close;
}

my %AbbrevProp = qw(
  X  xdigit
  D  digit
  U  upper
  L  lower
  A  alpha
  W  word
  P  punct
  G  graph
  S  space
  C  cntrl
  R  roman
  Z  zenkaku
  J  jis
  N  nec
  I  ibm
  V  vendor
  M  mswin
  E  european
  H  hiragana
  K  katakana
  0  kanji0
  1  kanji1
  2  kanji2
  B  boxdrawing
);

#
# _parse_prop('p' or 'P', ref to string)
# returning '\p{digit}' etc.
#
sub _parse_prop {
  my($key, $rev);
  my $p = shift;
  for(${ $_[0] }) {
    if(s/^\{//) {
      $rev = s/^\^// ? '^' : '';
      s/^I[sn]//; # XXX, deprecated
      if(s/^([0-9A-Za-z]+)\}//){
        $key = lc $1;
      } elsif(s/^([0-9A-Za-z]*(?![0-9A-Za-z])$Char)//o){
        croak sprintf($ErrNotAlnum, "\\$p\{$rev$1");
      } else {
        croak sprintf($ErrUnTermin, "\\$p\{$_}", '}');
      }
    } else {
      $rev = s/^\^// ? '^' : '';
      if(s/^([\x21-\x7e])//){
        $key = $AbbrevProp{uc $1} || $1;
      } elsif(s/^($Char)//o){
        croak sprintf($ErrNotASCII, "\\$p$rev$1");
      } else {
        croak sprintf($ErrUnTermin, "\\$p^", '');
      }
    }
  }
  if($rev) { $p = $p eq 'p' ? 'P' : 'p' }
  return "\\$p\{$key\}";
}

#
# _parse_posix(ref to string)
#   called after "[:" in a character class.
#   returning '\p{digit}' etc.
#
sub _parse_posix {
  my($key, $rev);

  for(${ $_[0] }) {
    $rev = s/^\^// ? '^' : '';
    if(s/^([0-9A-Za-z]+)\:\]//){
      $key = lc $1;
    } elsif(s/^([0-9A-Za-z]*(?![:])$Char)//o){
      croak sprintf($ErrNotAlnum, "[:$rev$1");
    } else {
      croak sprintf($ErrUnTermin, "[:$rev$_", ":]");
    }
  }
  return $rev ? "\\P\{$key\}" : "\\p\{$key\}";
}

#
# _parse_literal(string)
#   returning a literal.
#
sub _parse_literal {
  my $str = shift;
  my $ret = '';
  while(length $str){
    $ret .= _parse_char(\$str);
  }
  $ret;
}


#
# _parse_char(ref to string)
#   returning a single- or double-byte char.
#
sub _parse_char {
  for(${ $_[0] }) {
    if($_ eq '\\') {
      croak sprintf($ErrBackTips);
    }
    if(s/^\\([0-7][0-7][0-7])//) {
      return chr(oct $1);
    }
    if(s/^\\x//) {
      if(s/^([0-9A-Fa-f][0-9A-Fa-f])//) {
        return chr(hex $1);
      }
      if(s/^\{([0-9A-Fa-f][0-9A-Fa-f])([0-9A-Fa-f][0-9A-Fa-f])\}//){
        return chr(hex $1) . chr(hex $2);
      }
      if(length) {
        croak sprintf($ErrInvalHex, $_);
      } else {
        croak sprintf($ErrUnTermin, '\x{$_', '}');
      }
    }
    if(s/^\\c//) {
      if(s/([\x00-\x7F])//) {
        return chr( ord(uc $1) ^ 64 );
      }
      if(length) {
        croak sprintf($ErrInvalFlw, ord, '\c', '[\x00-\x7F]');
      } else {
        croak sprintf($ErrUnTermin, '\c');
      }
    }
    if(s/^\\a//) { return "\a" }
    if(s/^\\b//) { return "\b" }
    if(s/^\\e//) { return "\e" }
    if(s/^\\f//) { return "\f" }
    if(s/^\\n//) { return "\n" }
    if(s/^\\r//) { return "\r" }
    if(s/^\\t//) { return "\t" }
    if(s/^\\0//) { return "\0" }
    if(s/^\\([0-9A-Za-z])//){
      croak sprintf($ErrInvalMch, "\\$1");
    }
    if(s/^\\?($Char)//o) { return $1 }
    croak sprintf($ErrOddTrail, ord);
  }
}



#
# _parse_class(ref to string, mode)
#   called after "[" at the beginning of a character class.
#   returning a byte-oriented regexp.
#
sub _parse_class {
  my(@re, $subclass);
  my $mod = $_[1] || '';
  my $state = 0; # enum: initial, char, range, subclass, last;

  for(${ $_[0] }) {
    while(length) {
      if(s/^\]//) {
        if(@re) {
          if($state == 1) {
            push @re, rechar(pop(@re), $mod);
          } elsif($state == 2) {
            push @re, rechar(pop(@re), $mod);
            push @re, rechar('-', $mod);
          }
        } else {
          push(@re, ']');
          $state = 1;
          next;
        }
        $state = 4;
        last;
      }

      if(s/^\-//) {
        if($state == 0) {
          push @re, '-';
          $state = 1;
        } elsif($state == 1) {
          $state = 2;
        } elsif($state == 2) {
          push @re, __expand(__ord(pop(@re)), __ord('-'), $mod);
          $state = 0;
        } else {
          croak sprintf($ErrInvalRng, "-$_");
        }
        next;
      }

      $subclass = undef;
      if(s/^\[\://) {
        my $key = _parse_posix(\$_);
        $subclass = defined $Re{$key} ? $Re{$key}
           :croak sprintf($ErrUndef, $key);
      }
      elsif(s/^\\([pP])//) { # prop
        my $key = _parse_prop($1, \$_);
        $subclass = defined $Re{$key} ? $Re{$key}
           :croak sprintf($ErrUndef, $key);
      }
      elsif(s/^(\\[dwsDWS])//) {
        $subclass = $Re{ $1 };
      }
      elsif(s/^\[=\\?([\\=])=\]//) {
        $subclass = defined $Eq{$1} ? $Eq{$1} : rechar($1,$mod);
      }
      elsif(s/^\[=([^=]+)=\]//) {
        my $lit = _parse_literal($1);
        $subclass = defined $Eq{$lit} ? $Eq{$lit} : rechar($lit,$mod);
      }

      if(defined $subclass) {
        if($state == 1) {
          push @re, rechar(pop(@re), $mod);
        } elsif($state == 2) {
          croak sprintf($ErrInvalRng, "-$_");
        }
        push @re, $subclass;
        $state = 3;
        next;
      }

      my $char = _parse_char(\$_);
      if($state == 1) {
        push @re, rechar(pop(@re), $mod);
        push @re, $char;
        $state = 1;
      } elsif($state == 2) {
        push @re, __expand(__ord(pop(@re)), __ord($char), $mod);
        $state = 0;
      } else {
        push @re, $char;
        $state = 1;
      }
    }
  }

  if($state != 4) {
    croak sprintf($ErrUnTermin, "character class", ']');
  }

  return '(?:' . join('|', @re) . ')';
}


my(%Cache);

sub re
{
  my($flag);
  my $pat = shift;
  my $mod = shift || '';
  if($pat =~ s/^ (\^|\\[AG]|) \(\? ([a-zA-Z]+) \) /$1/x){
    $mod .= $2;
  }
  my $s = $mod =~ /s/;
  my $m = $mod =~ /m/;
  my $x = $mod =~ /x/;
  my $h = $mod =~ /h/;
  if($mod =~ /o/ && defined $Cache{$pat}{$mod}){
    return $Cache{$pat}{$mod};
  }
  my $res = $m && $s ? '(?ms)' : $m ? '(?m)' : $s ? '(?s)' : '';
  my $tmppat = $pat;
  for($tmppat){
    while(length){
      if(s/^(\(\?[p?]?{)//){
        $res .= $1;
        my $count = 1;
        while($count && length){
          if(s/^(\x5C[\x00-\xFC])//){
             $res .= $1;
             next;
          }
          if(s/^([^{}\\]+)//){
             $res .= $1;
             next;
          }
          if(s/^{//){
             ++$count;
             $res .= '{';
             next;
          }
          if(s/^}//){
             --$count;
             $res .= '}';
             next;
          }
          croak $ErrCode;
        }
        if(s/^\)//){
          $res .= ')';
          next;
        }
        croak $ErrCode;
      }
      if(s/^\x5B(\^?)//)
      {
        my $not = $1;
        my $class = _parse_class(\$_, $mod);
        $res .= $not ? "(?:(?!$class)$Char)" : $class;
        next;
      }

      if(s/^\\([.*+?^$|\\()\[\]{}])//){ # backslashed meta chars
        $res .= '\\'.$1;
        next;
      }
      if(s|^\\?(['"/])||){ # <'>, <">, </> should be backslashed.
        $res .= '\\'.$1;
        next;
      }
      if($x && s/^\s+//){ # skip whitespace
        next;
      }
      if(s/^\.//){ # dot
        $res .= $s ? $Re{'\j'} : $Re{'\J'};
        next;
      }
      if(s/^\^//){ # begin
        $res .= '(?:^)';
        next;
      }
      if(s/^\$//){ # end
        $res .= '(?:$)';
        next;
      }
      if(s/^\\z//){ # \z
        $res .= '(?!\n)\Z';
        next;
      }
      if(s/^\\([dDwWsSCjJ])//){ # class
        $res .= $Re{ "\\$1" };
        next;
      }
      if(s/^\\([pP])//) { # prop
        my $key = _parse_prop($1, \$_);
        if(defined $Re{$key}) {
          $res .= $Re{$key};
        } else {
          croak sprintf($ErrUndef, $key);
        }
        next;
      }
      if(s/^\\([0-7][0-7][0-7]?)//){
        $res .= rechar(chr oct $1, $mod);
        next;
      }
      if(s/^\\0//){
        $res .='\\x00';
        next;
      }
      if(s/^\\c([\x00-\x7F])//){
        $res .= rechar(chr(ord(uc $1) ^ 64), $mod);
        next;
      }
      if(s/^\\x([0-9A-Fa-f][0-9A-Fa-f])//){
        $res .= rechar(chr hex $1, $mod);
        next;
      }
      if(s/^\\x\{([0-9A-Fa-f][0-9A-Fa-f])([0-9A-Fa-f][0-9A-Fa-f])\}//){
        $res .= rechar(chr(hex $1).chr(hex $2), $mod);
        next;
      }
      if(s/^\\([A-Za-z])//){
        $res .= '\\'. $1;
        next;
      }
      if(s/^(\(\?[a-z\-\s]+)//){
        $res .= $1;
        next;
      }
      if(s/^\\([1-9])//){
        $res .= $h ? '\\'. ($1+1) : '\\'. $1;
        next;
      }
      if(s/^([\x21-\x40\x5B\x5D-\x60\x7B-\x7E])//){
        $res .= $1;
        next;
      }
      if($_ eq '\\'){
        croak $ErrBackTips;
        next;
      }
      if(s/^\\?($Char)//o){
        $res .= rechar($1, $mod);
        next;
      }
      croak sprintf($ErrOddTrail, ord);
    }
  }
  return $mod =~ /o/ ? ($Cache{$pat}{$mod} = $res) : $res;
}


sub rechar
{
  my $c   = shift;
  my $mod = shift || '';
  if(1 == length $c){
    return $c =~ /^[A-Za-z]$/ && $mod =~ /i/
	? "[\U$c\L$c]"
	: sprintf('\\x%02x', ord $c);
  }
  my ($d) = ord substr($c,1,1); # the trail byte
  my $rechar =
	   $c =~ /^\x82([\x60-\x79])$/ && $mod =~ /I/
	? sprintf('\x82[\x%02x\x%02x]', $d, $d+33)
	:  $c =~ /^\x82([\x81-\x9A])$/ && $mod =~ /I/
	? sprintf('\x82[\x%02x\x%02x]', $d, $d-33)
	:  $c =~ /^\x83([\x9F-\xB6])$/ && $mod =~ /I/
	? sprintf('\x83[\x%02x\x%02x]', $d, $d+32)
	:  $c =~ /^\x83([\xBF-\xD6])$/ && $mod =~ /I/
	? sprintf('\x83[\x%02x\x%02x]', $d, $d-32)
	:  $c =~ /^\x84([\x40-\x4E])$/ && $mod =~ /I/
	? sprintf('\x84[\x%02x\x%02x]', $d, $d+48)
	:  $c =~ /^\x84([\x4F-\x60])$/ && $mod =~ /I/
	? sprintf('\x84[\x%02x\x%02x]', $d, $d+49)
	:  $c =~ /^\x84([\x70-\x7E])$/ && $mod =~ /I/
	? sprintf('\x84[\x%02x\x%02x]', $d, $d-48)
	:  $c =~ /^\x84([\x80-\x91])$/ && $mod =~ /I/
	? sprintf('\x84[\x%02x\x%02x]', $d, $d-49)
        :  $c =~ /^\x82([\x9F-\xDD])$/ && $mod =~ /j/
	? sprintf('\x82\x%02x|\x83\x%02x', $d, $d-0x5F)
	:  $c =~ /^\x82([\xDE-\xF1])$/ && $mod =~ /j/
	? sprintf('\x82\x%02x|\x83\x%02x', $d, $d-0x5E)
	:  $c =~ /^\x83([\x40-\x7E])$/ && $mod =~ /j/
	? sprintf('\x83\x%02x|\x82\x%02x', $d, $d+0x5F)
	:  $c =~ /^\x83([\x80-\x93])$/ && $mod =~ /j/
	? sprintf('\x83\x%02x|\x82\x%02x', $d, $d+0x5E)
	:  $c =~ /^\x81([\x52-\x53])$/ && $mod =~ /j/
	? sprintf('\x81[\x%02x\x%02x]', $d, $d+2)
	:  $c =~ /^\x81([\x54-\x55])$/ && $mod =~ /j/
	? sprintf('\x81[\x%02x\x%02x]', $d, $d-2)
	: sprintf('\x%02x\x%02x', unpack 'C2', $c);
    return "$Open$rechar$Close";
}


sub dst
{
  my $res = '';
  my $dst = shift;
  for($dst){
    while(length){
      if(s/^\\\\//){
        $res .= '\\\\';
        next;
      }
      if(s/^\\?\///){
        $res .= '\\/';
        next;
      }
      if(s/^\$([1-8])//){
        $res .= '${' . ($1 + 1) . '}';
        next;
      }
      if(s/^\${([1-8])}//){
        $res .= '${' . ($1 + 1) . '}';
        next;
      }
      if(s/^\\([0-7][0-7][0-7])//){
        $res .= "\\$1";
        next;
      }
      if(s/^\\([0-7][0-7])//){
        $res .= "\\0$1";
        next;
      }
      if(s/^\\x([0-9A-Fa-f][0-9A-Fa-f])//){
        $res .= "\\x$1";
        next;
      }
      if(s/^\\x\{([0-9A-Fa-f][0-9A-Fa-f])([0-9A-Fa-f][0-9A-Fa-f])\}//){
        $res .= '\\x' . $1 . '\\x' . $2;
        next;
      }
      if(s/^\\([0A-Za-z])//){
        $res .= '\\'. $1;
        next;
      }
      if(s/^\\?([\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])//){
        $res .= quotemeta($1);
        next;
      }
      if(s/^\\?([\x00-\x7F\xA1-\xDF])//){
        $res .= $1;
        next;
      }
      croak sprintf($ErrOddTrail, ord);
    }
  }
  return $res;
}

sub match
{
  my $str = $_[0];
  my $mod = $_[2] || '';
  my $pat = re($_[1], $mod);
  if($mod =~ /g/){
    my $fore = $mod =~ /z/ || '' =~ /$pat/ ? $GApad : $Gpad;
    $str =~ /$fore(?:$pat)/g;
  } else {
    $str =~ /$Apad(?:$pat)/;
  }
}


sub replace
{
  my $str = $_[0];
  my $dst = dst($_[2]);
  my $mod = $_[3] || '';
  my $pat = re($_[1], 'h'.$mod);
  if($mod =~ /g/){
    my $fore = $mod =~ /z/ || '' =~ /$pat/ ? $GApad : $Gpad;
    if(ref $str){
      eval "\$\$str =~ s/($fore)(?:$pat)/\${1}$dst/g";
    } else {
      eval   "\$str =~ s/($fore)(?:$pat)/\${1}$dst/g";
      $str;
    }
  } else {
    if(ref $str){
      eval "\$\$str =~ s/($Apad)(?:$pat)/\${1}$dst/";
    } else {
      eval   "\$str =~ s/($Apad)(?:$pat)/\${1}$dst/";
      $str;
    }
  }
}


sub __ord  { length($_[0]) > 1 ? unpack('n', $_[0]) : ord($_[0]) }

sub __ord2 { 0xFF < $_[0] ? unpack('C*', pack 'n', $_[0]) : chr($_[0]) }

sub __expand
{
  my($fr, $to, $mod) = @_;
  $mod ||= '';
  my($ini, $fin, $i, $ch, @retv, @retd, $add);
  my($ini_f, $fin_f, $ini_t, $fin_t, $ini_c, $fin_c);

  if($fr > $to){ croak sprintf($ErrReverse, $fr, $to) }
  if($fr <= 0x7F){
    $ini = $fr < 0x00 ? 0x00 : $fr;
    $fin = $to > 0x7F ? 0x7F : $to;
    if($ini == $fin){
      push @retv, rechar(chr($ini),$mod);
    }
    elsif($ini < $fin){
      if($mod =~ /i/){
         for($i=$ini;$i<=$fin;$i++){
            $add .= lc(chr $i) if 0x41 <= $i && $i <= 0x5A;
            $add .= uc(chr $i) if 0x61 <= $i && $i <= 0x7A;
         }
      } else {$add = ''}
      push @retv, sprintf "[\\x%02x-\\x%02x$add]", $ini, $fin;
    }
  }
  if($fr <= 0xDF){
    $ini = $fr < 0xA1 ? 0xA1 : $fr;
    $fin = $to > 0xDF ? 0xDF : $to;
    if($ini == $fin){
      push @retd, sprintf('\\x%2x', $ini);
    }
    elsif($ini < $fin){
      push @retd, sprintf('[\\x%2x-\\x%2x]', $ini, $fin);
    }
  }
  $ini = $fr < 0x8140 ? 0x8140 : $fr;
  $fin = $to > 0xFCFC ? 0xFCFC : $to;
  if($ini <= $fin){
    ($ini_f,$ini_t) = __ord2($ini);
    ($fin_f,$fin_t) = __ord2($fin);

    if($ini_f == $fin_f){
      push @retd,
	$ini_t == $fin_t ?
	  sprintf('\x%2x\x%2x', $ini_f, $ini_t) :
	$fin_t <= 0x7E || 0x80 <= $ini_t ?
	  sprintf('\x%2x[\x%2x-\x%2x]', $ini_f, $ini_t, $fin_t) :
	$ini_t == 0x7E && $fin_t == 0x80 ?
	  sprintf('\x%2x[\x7e\x80]', $ini_f) :
	$ini_t == 0x7E ?
	  sprintf('\x%2x[\x7e\x80-\x%2x]', $ini_f, $fin_t) :
	$fin_t == 0x80 ?
	  sprintf('\x%2x[\x%2x-\x7e\x80]', $ini_f, $ini_t) :
	sprintf('\x%2x[\x%2x-\x7e\x80-\x%2x]',$ini_f, $ini_t, $fin_t);
    }
    else {
      $ini_c = $ini_t == 0x40 ? $ini_f : $ini_f == 0x9F ? 0xE0 : $ini_f+1;
      $fin_c = $fin_t == 0xFC ? $fin_f : $fin_f == 0xE0 ? 0x9F : $fin_f-1;

      if($ini_t != 0x40){
        push @retd,
	  $ini_t == 0xFC ?
	    sprintf('\x%2x\xfc', $ini_f) :
	  0x80 <= $ini_t ?
	    sprintf('\x%2x[\x%2x-\xfc]', $ini_f, $ini_t) :
	  $ini_t == 0x7E ?
	    sprintf('\x%2x[\x7e\x80-\xfc]', $ini_f) :
	    sprintf('\x%2x[\x%2x-\x7e\x80-\xfc]', $ini_f, $ini_t);
      }
      if($ini_c > $fin_c) { 1 }
      else {
        my $lead = 
	  $ini_c == $fin_c
	    ?  sprintf('\x%2x', $ini_c) :
	  $fin_c <= 0x9F || 0xE0 <= $ini_c
	    ? sprintf('[\x%2x-\x%2x]', $ini_c, $fin_c) :
	  $ini_c == 0x9F && $fin_c == 0xE0
	    ? '[\x9f\xe0]' :
	  $ini_c == 0x9F
	    ? sprintf('[\x9f\xe0-\x%2x]', $fin_c) :
	  $fin_c == 0xE0
	    ? sprintf('[\x%2x-\x9f\xe0]', $ini_c)
	    : sprintf('[\x%2x-\x9f\xe0-\x%2x]', $ini_c, $fin_c);

        push @retd, $lead.$Trail;
      }
      if($fin_t != 0xFC){
        push @retd,
	  $fin_t == 0x40 ?
	    sprintf('\x%2x\x40', $fin_f) :
	  $fin_t <= 0x7E ?
	    sprintf('\x%2x[\x40-\x%2x]', $fin_f, $fin_t) :
	  $fin_t == 0x80 ?
	    sprintf('\x%2x[\x40-\x7e\x80]', $fin_f) :
	  sprintf('\x%2x[\x40-\x7e\x80-\x%2x]', $fin_f, $fin_t);
      }
    }
  }
  if($mod =~ /I/){
    for(
      [0x8260, 0x8279, +33], # Full A to Z
      [0x8281, 0x829A, -33], # Full a to z
      [0x839F, 0x83B6, +32], # Greek Alpha to Omega
      [0x83BF, 0x83D6, -32], # Greek alpha to omega
      [0x8440, 0x844E, +48], # Cyrillic A to N
      [0x8470, 0x847E, -48], # Cyrillic a to n
      [0x844F, 0x8460, +49], # Cyrillic O to Ya
      [0x8480, 0x8491, -49], # Cyrillic o to ya
    ){
      if($fr <= $_->[1] && $_->[0] <= $to){
        ($ini_f,$ini_t) = __ord2($fr <= $_->[0] ? $_->[0] : $fr);
        ($fin_f,$fin_t) = __ord2($_->[1] <= $to ? $_->[1] : $to);
        push @retd, sprintf('\x%02x[\x%02x-\x%02x]',
		$ini_f, $ini_t + $_->[2], $fin_t + $_->[2]);
      }
    }
  }
  if($mod =~ /j/){
    for(
      [0x829F, 0x82DD, -0x5F, 0x83], # Hiragana Small A to Mi
      [0x82DE, 0x82F1, -0x5E, 0x83], # Hiragana Mu to N
      [0x8340, 0x837E, +0x5F, 0x82], # Katakana Small A to Mi
      [0x8380, 0x8393, +0x5E, 0x82], # Katakana Mu to N
      [0x8152, 0x8153, +2,    0x81], # Katakana Iteration Marks
      [0x8154, 0x8155, -2,    0x81], # Hiragana Iteration Marks
    ){
      if($fr <= $_->[1] && $_->[0] <= $to){
        ($ini_f,$ini_t) = __ord2($fr <= $_->[0] ? $_->[0] : $fr);
        ($fin_f,$fin_t) = __ord2($_->[1] <= $to ? $_->[1] : $to);
        push @retd, sprintf('\x%02x[\x%02x-\x%02x]',
		$_->[3], $ini_t + $_->[2], $fin_t + $_->[2]);
      }
    }
  }
  return(@retv, @retd ? $Open.join('|',@retd).$Close : ());
}


#
# splitchar(STRING; LIMIT)
# 
sub splitchar
{
  my($str, $lim, @ret);
  ($str, $lim) = @_;
  $lim = 0 if ! defined $lim;
  if($str eq ''){
    return wantarray ? () : 0;
  } elsif($lim == 1){
    return wantarray ? ($str) : 1;
  } elsif($lim > 1) {
    while($str =~ s/($Char)//o){
      push @ret, $1;
      last if @ret >= $lim - 1;
    }
    push @ret, $str;
  } else {
    @ret = _splitchar($str);
    push @ret, '' if $lim < 0;
  }
  @ret;
}

sub _splitchar { $_[0] =~ /$Char/go }


#
# jsplit(PATTERN, STRING; LIMIT)
#
sub jsplit
{
  my($thing, $pat, $str, $lim, $cnt, @mat, @ret);
  $thing = shift;
  $pat = 'ARRAY' eq ref $thing ? re(@$thing) : re($thing);
  $str = shift;
  $lim = shift || 0;

  return wantarray ? () : 0 if $str eq '';
  return splitchar($str, $lim) if $pat eq '';
  return wantarray ? ($str) : 1 if $lim == 1;

  $cnt = 0;
  while(@mat = $str =~ /^($Char*?)($pat)/){
    if($mat[0] eq '' && $mat[1] eq ''){
      @mat = $str =~ /^($Char)($pat)/;
      $str =~ s/^$Char$pat//;
    } else {
      $str =~ s/^$Char*?$pat//;
    }
    if(@mat){
      push @ret, shift @mat;
      shift @mat; # $mat[1] eq $2 is to be removed.
      push @ret, @mat;
    }
    $cnt++;
    last if ! CORE::length $str;
    last if $lim > 1 && $cnt >= $lim - 1;
  }
  push @ret, $str if $str ne '' || $lim < 0 || $cnt < $lim;
  if($lim == 0){pop @ret while defined $ret[-1] && $ret[-1] eq ''}
  @ret;
}

sub splitspace
{
  my($str, $lim) = @_;
  return wantarray ? () : 0 if $str eq '';

  defined $lim && 0 < $lim 
    ? do{
        (ref $str ? $$str : $str) =~ s/^(?:[ \n\r\t\f]|\x81\x40)+//;
        jsplit('(?o)[ \n\r\t\f\x{8140}]+', $str, $lim)
      }
    : split(' ', spaceZ2H($str), $lim);
}

sub spaceZ2H
{
  my $str = shift;
  my $len = CORE::length(ref $str ? $$str : $str);
  (ref $str ? $$str : $str) =~
     s/\G($Char*?)\x81\x40/$1 /go;
  ref $str ? abs($len - CORE::length $$str) : $str;
};

sub spaceH2Z
{
  my $str = shift;
  my $len = CORE::length(ref $str ? $$str : $str);
  (ref $str ? $$str : $str) =~ s/ /\x81\x40/g;
  ref $str ? abs($len - CORE::length $$str) : $str;
};

1;
__END__

=head1 NAME

ShiftJIS::Regexp - Shift_JIS-oriented regexps on the byte-oriented perl

=head1 SYNOPSIS

  use ShiftJIS::Regexp qw(:all);

  match('Ç†Ç®ÇPÇQ', '\p{Hiragana}{2}\p{Digit}{2}');
# that is equivalant to this:
  match('Ç†Ç®ÇPÇQ', '\pH{2}\pD{2}');

  match('Ç†Ç¢Ç¢Ç§Ç§Ç§', '^Ç†Ç¢+Ç§{3}$');

  replace($str, 'A', 'Ç`', 'g');

=head1 DESCRIPTION

This module provides some functions to use Shift_JIS-oriented regexps
on the byte-oriented perl.

The legal Shift_JIS character in this module must match the following regexp:

    [\x00-\x7F\xA1-\xDF]|[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]

=head2 Functions

=over 4

=item C<re(PATTERN)>

=item C<re(PATTERN, MODIFIER)>

Returns regexp parsable by the byte-oriented perl.

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

emulation of C<m//> operator for the Shift_JIS encoding.

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

emulation of C<s///> operator for the Shift_JIS encoding.

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

But C<' '> as C<PATTERN> has no special meaning;
when you want to split the string on whitespace,
you can use C<splitspace()> function.

    jsplit('Å^', 'Ç†Ç¢Ç§Å^Ç¶Ç®ÉÅ^');

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

This function emulates C<CORE::split ' ', STRING>
and returns the array given by split on whitespace including IDEOGRAPHIC SPACE.
Leading whitespace characters do not produce any field.

=item C<splitchar(STRING)>

=item C<splitchar(STRING, LIMIT)>

This function emulates C<CORE::split //, STRING>
and returns the array given by split of the specified string into characters.

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
   \p{Alnum}     [\pA\pD]    [[:alnum:]]       [0-9A-Za-zÇO-ÇXÇ`-ÇyÇÅ-Çö]

   \p{Word}       \pW        [[:word:]]        [_\p{Digit}\p{European}\p{Kana}\p{Kanji}]

   \p{Punct}      \pP        [[:punct:]]       [!-/:-@[-`{-~°-•ÅA-ÅIÅL-ÅQÅ\-Å¨Å∏-ÅøÅ»-ÅŒÅ⁄-ÅËÅ-Å˜Å¸Ñü-Ñæ]

   \p{Space}      \pS        [[:space:]]       [\t\n\r\f\x20\x{8140}]
   \p{Graph}      \pG        [[:graph:]]       [^\0-\x20\x7F\x{8140}]
   \p{Print}     [\pS\pG]    [[:print:]]       [^\0-\x08\x0B\x0E-\x1F\x7F]
   \p{Cntrl}      \pC        [[:cntrl:]]       [\x00-\x1F]

   \p{Roman}      \pR        [[:roman:]]       [\x00-\x7F]
   \p{ASCII}                 [[:ascii:]]       [\p{Roman}]
   \p{Hankaku}               [[:hankaku:]]     [\xA1-\xDF]
   \p{Zenkaku}    \pZ        [[:zenkaku:]]     [\x{8140}-\x{FCFC}]

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
   \p{BoxDrawing} \pB        [[:boxdrawing:]]  [Ñü-Ñæ]

=over 4

=item *

=over 4

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

=back

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
Using of C<Is> and C<In> is deplicated since they may conflict
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

C<[[=Ç©=]]> matches C<'Ç©'>, C<'ÉJ'>, C<'∂'>, C<'Ç™'>, C<'ÉK'>, C<'∂ﬁ'>, C<'Éï'> (C<'∂ﬁ'> is a two-character string, but one collation element, 
C<HALFWIDTH FORM FOR KATAKANA LETTER GA>.

C<[[===]]> matches C<EQUALS SIGN> or 
C<FULLWIDTH EQUALS SIGN>;
C<[[=[=]]> matches C<LEFT SQUARE BRACKET> or 
C<FULLWIDTH LEFT SQUARE BRACKET>;
C<[[=]=]]> matches C<RIGHT SQUARE BRACKET> or 
C<FULLWIDTH RIGHT SQUARE BRACKET>;
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
one of regexps C<^>, C<\A>, or C<\G> at the beginning of the 'regexp'
is allowed to contain C<I>, C<j>, C<o> modifiers.

  e.g. (?sm)pattern  ^(?i)pattern  \G(?j)pattern  \A(?ijo)pattern

And C<match('ÉG', '(?i)Ég')> returns false (Good result)
even on Perl below 5.005,
since it works like C<match('ÉG', 'Ég', 'i')>.

=head1 CAVEATS

A legal Shift_JIS character in this module
must match the following regexp:

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

The regexps of the word boundary, C<\b> and C<\B>, don't work correctly.

Never pass any regexp containing C<'(?i)'> on perl below 5.005.
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
e.g. C<match("ÉAÉCÉE", '(?<=[A-Z])(\p{InKana})')> returns C<('ÉC')>.

Use of not greedy regexp, which can match empty string, 
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
