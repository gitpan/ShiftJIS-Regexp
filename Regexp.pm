package ShiftJIS::Regexp;

use strict;
use Carp;
use vars qw($VERSION $PACKAGE @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

require Exporter;

use vars qw(%Eq);
use ShiftJIS::Regexp::Equiv qw(%Eq);

$VERSION = '0.13';
$PACKAGE = 'ShiftJIS::Regexp'; #__PACKAGE__

@ISA = qw(Exporter);

my @Re    = qw(re  mkclass  rechar);
my @Split = qw(jsplit splitchar splitspace);
my @Op    = qw(match replace);

@EXPORT      = ();
@EXPORT_OK   = (@Re, @Op, @Split);
%EXPORT_TAGS = (
	re	=> \@Re,
	op	=> \@Op,
	split	=> \@Split,
	all	=> [@Re, @Op, @Split],
);

my $Msg_unm = $PACKAGE.' Unmatched [ character class';
my $Msg_ilb = $PACKAGE.' Illegal byte in class (following [)';
my $Msg_odd = $PACKAGE.' \\x%02x is not followed by trail byte';
my $Msg_und = $PACKAGE.' %s not defined';
my $Msg_rev = $PACKAGE.' Invalid [] range (reverse) %d > %d';
my $Msg_bsl = $PACKAGE.' Trailing \ in regexp';
my $Msg_cod = $PACKAGE.' Sequence (?{...}) not terminated or not {}-balanced';

my $SBC = '[\x00-\x7F\xA1-\xDF]';
my $DBC = '[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]';
my $Char = '(?:' . $SBC . '|' . $DBC . ')';

my $Open = 5.005 > $] ? '(?:' : '(?-i:';

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
  '\p{IsDigit}' => $Open.'[\x30-\x39]|\x82[\x4F-\x58])',
  '\P{IsDigit}' => $Open.'[\x00-\x2F\x3A-\x7F\xA1-\xDF]|'
		. '[\x81\x83-\x9F\xE0-\xFC]'
		. '[\x40-\x7E\x80-\xFC]|\x82[\x40-\x4E\x59-\x7E\x80-\xFC])',
  '\p{IsUpper}' => $Open.'[\x41-\x5A]|\x82[\x60-\x79])',
  '\P{IsUpper}' => $Open.'[\x00-\x40\x5B-\x7F\xA1-\xDF]|'
		. '[\x81\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x5F\x7A-\x7E\x80-\xFC])',
  '\p{IsLower}' => $Open.'[\x61-\x7A]|\x82[\x81-\x9A])',
  '\P{IsLower}' => $Open.'[\x00-\x60\x7B-\x7F\xA1-\xDF]|'
		. '[\x81\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x7E\x80\x9B-\xFC])',
  '\p{IsAlpha}' => $Open.'[\x41-\x5A\x61-\x7A]|\x82[\x60-\x79\x81-\x9A])',
  '\P{IsAlpha}' => $Open.'[\x00-\x40\x5B-\x60\x7B-\x7F\xA1-\xDF]|'
		. '[\x81\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x5F\x7A-\x7E\x80\x9B-\xFC])',
  '\p{IsAlnum}' => $Open.'[0-9A-Za-z]|\x82[\x4F-\x58\x60-\x79\x81-\x9A])',

  '\P{IsAlnum}' => $Open.'[\x00-\x2F\x3A-\x40\x5B-\x60\x7B-\x7F\xA1-\xDF]|'
		. '[\x81\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x4E\x59-\x5F\x7A-\x7E\x80\x9B-\xFC])',
  '\p{IsSpace}' => $Open.'[\x09\x0A\x0C\x0D\x20]|\x81\x40)',
  '\P{IsSpace}' => $Open.'[\x00-\x08\x0B\x0E-\x1F\x21-\x7F\xA1-\xDF]|'
		. '\x81[\x41-\x7E\x80-\xFC]|'
		. '[\x82-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])',
  '\p{IsPunct}' => $Open.'[\x21-\x2F\x3A-\x40\x5B-\x60\x7B-\x7E\xA1-\xA5]|'
		. '\x81[\x41-\x49\x4C-\x51\x5C-\x7E\x80-\xAC\xB8-\xBF'
		. '\xC8-\xCE\xDA-\xE8\xF0-\xF7\xFC]|\x84[\x9F-\xBE])',
  '\P{IsPunct}' => $Open.'[\x00-\x20\x30-\x39\x41-\x5A\x61-\x7A\x7F\xA6-\xDF]|'
		. '\x81[\x40\x4A\x4B\x52-\x5B\xAD-\xB7\xC0-\xC7\xCF-\xD9'
		. '\xE9-\xEF\xF8-\xFB]|\x84[\x40-\x7E\x80-\x9E\xBF-\xFC]|'
		. '[\x82\x83\x85-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])',
  '\p{IsGraph}' => $Open.'[\x21-\x7E\xA1-\xDF]|\x81[\x41-\x7E\x80-\xFC]|'
			. '[\x82-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])',
  '\P{IsGraph}' => $Open.'[\x00-\x20\x7F]|\x81\x40)',
  '\p{IsPrint}' => $Open.'[\x09\x0A\x0C\x0D\x20-\x7E\xA1-\xDF]|' . $DBC . ')',
  '\P{IsPrint}' => '[\x00-\x08\x0B\x0E-\x1F\x7F]',
  '\p{IsCntrl}' => '[\x00-\x1F]',
  '\P{IsCntrl}' => $Open.'[\x20-\x7F\xA1-\xDF]|' . $DBC . ')',
  '\p{IsAscii}' => '[\x00-\x7F]',
  '\P{IsAscii}' => $Open.'[\xA1-\xDF]|' . $DBC . ')',

  '\p{IsWord}'   => $Open.'[0-9A-Z_a-z\xA6-\xDF]|\x81[\x4A\x4B\x52-\x5B]|'
		. '\x82[\x4F-\x58\x60-\x79\x81-\x9A\x9F-\xF1]|'
		. '\x83[\x40-\x7E\x80-\x96\x9F-\xB6\xBF-\xD6]|'
		. '\x84[\x40-\x60\x70-\x7E\x80-\x91]|\x88[\x9F-\xFC]|'
		. '[\x89-\x97\x99-\x9F\xE0-\xE9][\x40-\x7E\x80-\xFC]|'
		. '\x98[\x40-\x72\x9F-\xFC]|\xEA[\x40-\x7E\x80-\xA4])',

  '\P{IsWord}' => $Open.'[\x00-\x2F\x3A-\x40\x5B-\x5E\x60\x7B-\x7F\xA1-\xA5]|'
		. '\x81[\x40-\x49\x4C-\x51\x5C-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x4E\x59-\x5F\x7A-\x7E\x80\x9B-\x9E\xF2-\xFC]|'
		. '\x83[\x97-\x9E\xB7-\xBE\xD7-\xFC]|'
		. '\x84[\x61-\x6F\x92-\xFC]|'
		. '[\x85-\x87\xEB-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x88[\x40-\x7E\x80-\x9E]|\x98[\x73-\x7E\x80-\x9E]|'
		. '\xEA[\xA5-\xFC])',

  '\p{IsHankaku}' => '[\xA1-\xDF]',
  '\P{IsHankaku}' => $Open.'[\x00-\x7F]|' . $DBC . ')',
  '\p{IsZenkaku}' => $Open. $DBC . ')',
  '\P{IsZenkaku}' => $Open. $SBC . ')',
  '\p{IsX0201}' => $Open. $SBC . ')',
  '\P{IsX0201}' => $Open. $DBC . ')',

  '\p{IsX0208}' => $Open.'\x81[\x40-\x7E'
		. '\x80-\xAC\xB8-\xBF\xC8-\xCE\xDA-\xE8\xF0-\xF7\xFC]|'
		. '\x82[\x4F-\x58\x60-\x79\x81-\x9A\x9F-\xF1]|'
		. '\x83[\x40-\x7E\x80-\x96\x9F-\xB6\xBF-\xD6]|'
		. '\x84[\x40-\x60\x70-\x7E\x80-\x91\x9F-\xBE]|'
		. '\x88[\x9F-\xFC]|\x98[\x40-\x72\x9F-\xFC]|'
		. '[\x89-\x97\x99-\x9F\xE0-\xE9][\x40-\x7E\x80-\xFC]|'
		. '\xEA[\x40-\x7E\x80-\xA4])',

  '\P{IsX0208}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '\x81[\xAD-\xB7\xC0-\xC7\xCF-\xD9\xE9-\xEF\xF8-\xFB]|'
		. '\x82[\x40-\x4E\x59-\x5F\x7A-\x7E\x80\x9B-\x9E\xF2-\xFC]|'
		. '\x83[\x97-\x9E\xB7-\xBE\xD7-\xFC]|'
		. '\x84[\x61-\x6F\x92-\x9E\xBF-\xFC]|'
		. '[\x85-\x87\xEB-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x88[\x40-\x7E\x80-\x9E]|\x98[\x73-\x7E\x80-\x9E]|'
		. '\xEA[\xA5-\xFC])',

  '\p{InLatin}' => $Open.'[\x41-\x5A\x61-\x7A])',
  '\P{InLatin}' => $Open.'[\x00-\x40\x5B-\x60\x7B-\x7F\xA1-\xDF]|'.$DBC.')',
  '\p{InFullLatin}' => $Open.'\x82[\x60-\x79\x81-\x9A])',
  '\P{InFullLatin}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x81\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x5F\x7A-\x7E\x80\x9B-\xFC])',
  '\p{InGreek}' => $Open.'\x83[\x9f-\xb6\xbf-\xd6])',
  '\P{InGreek}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x81\x82\x84-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x83[\x40-\x7E\x80-\x9e\xb7-\xbe\xd7-\xFC])',
  '\p{InCyrillic}' => $Open.'\x84[\x40-\x60\x70-\x7E\x80-\x91])',
  '\P{InCyrillic}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x81-\x83\x85-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x84[\x61-\x6f\x92-\xFC])',
  '\p{InHalfKana}' => '[\xA6-\xDF]',
  '\P{InHalfKana}' => $Open.'[\x00-\x7F\xA1-\xA5]|' . $DBC . ')',
  '\p{InHiragana}' => $Open.'\x82[\x9F-\xF1]|\x81[\x4A\x4B\x54\x55])',
  '\P{InHiragana}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x83-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x7E\x80-\x9E\xF2-\xFC]|'
		. '\x81[\x40-\x49\x4C-\x53\x56-\x7E\x80-\xFC])',
  '\p{InKatakana}' => $Open.'\x83[\x40-\x7E\x80-\x96]|\x81[\x52\x53\x5B])',
  '\P{InKatakana}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x82\x84-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x83[\x97-\xFC]|'
		. '\x81[\x40-\x51\x54-\x5A\x5C-\x7E\x80-\xFC])',
  '\p{InFullKana}' => $Open.'\x82[\x9F-\xF1]|\x83[\x40-\x7E\x80-\x96]|'
		    . '\x81[\x4A\x4B\x5B\x52-\x55])',
  '\P{InFullKana}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x84-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x7E\x80-\x9E\xF2-\xFC]|\x83[\x97-\xFC]|'
		. '\x81[\x40-\x49\x4C-\x51\x56-\x5A\x5C-\x7E\x80-\xFC])',
  '\p{InKana}' => $Open.'[\xA6-\xDF]|\x82[\x9F-\xF1]|\x83[\x40-\x7E\x80-\x96]|'
		    . '\x81[\x4A\x4B\x5B\x52-\x55])',
  '\P{InKana}' => $Open.'[\x00-\x7F\xA1-\xA5]|'
		. '[\x84-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x82[\x40-\x7E\x80-\x9E\xF2-\xFC]|\x83[\x97-\xFC]|'
		. '\x81[\x40-\x49\x4C-\x51\x56-\x5A\x5C-\x7E\x80-\xFC])',
  '\p{InKanji1}'  => $Open.'\x88[\x9F-\xFC]|\x98[\x40-\x72]|'
		. '[\x89-\x97][\x40-\x7E\x80-\xFC])',
  '\P{InKanji1}'  => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '\x88[\x40-\x7E\x80-\x9E]|\x98[\x73-\x7E\x80-\xFC]|'
		. '[\x81-\x87\x99-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])',
  '\p{InKanji2}'  => $Open.'\x98[\x9F-\xFC]|[\x99-\x9F\xE0-\xE9]'
		. '[\x40-\x7E\x80-\xFC]|\xEA[\x40-\x7E\x80-\xA4])',
  '\P{InKanji2}'  => $Open.'[\x00-\x7F\xA1-\xDF]|\x98[\x40-\x7E\x80-\x9E]|'
		. '[\x81-\x97\xEB-\xFC][\x40-\x7E\x80-\xFC]|\xEA[\xA5-\xFC])',
  '\p{InKanji}'   => $Open.'\x81[\x56-\x5A]|\x88[\x9F-\xFC]|'
		. '[\x89-\x97\x99-\x9F\xE0-\xE9][\x40-\x7E\x80-\xFC]|'
		. '\x98[\x40-\x72\x9F-\xFC]|\xEA[\x40-\x7E\x80-\xA4])',
  '\P{InKanji}'   => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '\x81[\x40-\x55\x5b-\x7E\x80-\xFC]|'
		. '\x88[\x40-\x7E\x80-\x9E]|\x98[\x73-\x7E\x80-\x9E]|'
		. '[\x82-\x87\xEB-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\xEA[\xA5-\xFC])',
  '\p{InBoxDrawing}' => $Open.'\x84[\x9F-\xBE])',
  '\P{InBoxDrawing}' => $Open.'[\x00-\x7F\xA1-\xDF]|'
		. '[\x81-\x83\x85-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]|'
		. '\x84[\x40-\x7E\x80-\x9E\xBF-\xFC])',
);

my %Class = (
  digit => 'IsDigit',
  upper => 'IsUpper',
  lower => 'IsLower',
  alpha => 'IsAlpha',
  alnum => 'IsAlnum',
  punct => 'IsPunct',
  space => 'IsSpace',
  graph => 'IsGraph',
  print => 'IsPrint',
  cntrl => 'IsCntrl',
  ascii => 'IsAscii',
  word  => 'IsWord',
 boxdrawing => 'InBoxDrawing',
  latin     => 'InLatin',
  fulllatin => 'InFullLatin',
  greek     => 'InGreek',
  cyrillic  => 'InCyrillic',
  hankaku   => 'IsHankaku',
  zenkaku   => 'IsZenkaku',
  x0201     => 'IsX0201',
  x0208     => 'IsX0208',
  kanji     => 'InKanji',
  kanji1    => 'InKanji1',
  kanji2    => 'InKanji2',
  halfkana  => 'InHalfKana',
  hiragana  => 'InHiragana',
  katakana  => 'InKatakana',
  fullkana  => 'InFullKana',
  kana      => 'InKana',
);

my(%Cache);

sub re {
  my($flag);
  my $pat = shift;
  my $mod = shift || '';
  my $s = $mod =~ /s/;
  my $m = $mod =~ /m/;
  my $x = $mod =~ /x/;
  my $h = $mod =~ /h/;

  return $pat if $mod =~ /n/;
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
          croak $Msg_cod;
        }
        if(s/^\)//){
          $res .= ')';
          next;
        }
        croak $Msg_cod;
      }
      if(s/^\x5B(\^?)(\x5D?
        (?:\[\:\x5e?[0-9A-Z_a-z]+\:\]|\[=[^=]+=\]|\[=\\?==\]
        |\x5Cc?[\x5C\x5D]|\x5C?(?![\x5C\x5D])$Char
        )*
      )\x5D//ox)
      {
        my($not,$cls) = ($1,$2);
        if($2 eq ''){ croak $Msg_unm }
        my $class = mkclass($cls,$mod);
        $res .= $not ? "(?:(?!$class)$Char)" : $class;
        next;
      } elsif (s/^\[//){ croak $Msg_ilb }

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
        $res .= $Re{'\\'. $1};
        next;
      }
      if(s/^\\([pP])\{([0-9A-Z_a-z]+)\}//){ # prop
        my($p, $key) = ($1,$2);
        if(defined $Re{ "\\$p\{$key\}"}){
          $res .= $Re{ "\\$p\{$key\}" }
        } elsif(defined $Re{ "\\$p\{Is$key\}"}){
          $res .= $Re{ "\\$p\{Is$key\}" }
        } elsif(defined $Re{ "\\$p\{In$key\}"}){
          $res .= $Re{ "\\$p\{In$key\}" }
        } else {
          croak sprintf $Msg_und, "\\$p\{$key\}";
        }
        next;
      }
      if(s/^\\([0-7][0-7][0-7])//){
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
        croak $Msg_bsl;
        next;
      }
      if(s/^\\?($Char)//){
        $res .= rechar($1, $mod);
        next;
      }
      croak sprintf $Msg_odd, ord;
    }
  }
  return $mod =~ /o/ ? ($Cache{$pat}{$mod} = $res) : $res;
}

sub rechar {
  my $c   = shift;
  my $mod = shift || '';
  if(1 == length $c){
    return $c =~ /^[A-Za-z]$/ && $mod =~ /i/
	? "[\U$c\L$c]"
	: sprintf('\\x%02x', ord $c);
  }
  my ($d) = ord substr($c,1,1); # the trail byte
  return
	   $c =~ /^\x82([\x60-\x79])$/ && $mod =~ /I/
	? sprintf($Open.'\x82[\x%02x\x%02x])', $d, $d+33)
	:  $c =~ /^\x82([\x81-\x9A])$/ && $mod =~ /I/
	? sprintf($Open.'\x82[\x%02x\x%02x])', $d, $d-33)
	:  $c =~ /^\x83([\x9F-\xB6])$/ && $mod =~ /I/
	? sprintf($Open.'\x83[\x%02x\x%02x])', $d, $d+32)
	:  $c =~ /^\x83([\xBF-\xD6])$/ && $mod =~ /I/
	? sprintf($Open.'\x83[\x%02x\x%02x])', $d, $d-32)
	:  $c =~ /^\x84([\x40-\x4E])$/ && $mod =~ /I/
	? sprintf($Open.'\x84[\x%02x\x%02x])', $d, $d+48)
	:  $c =~ /^\x84([\x4F-\x60])$/ && $mod =~ /I/
	? sprintf($Open.'\x84[\x%02x\x%02x])', $d, $d+49)
	:  $c =~ /^\x84([\x70-\x7E])$/ && $mod =~ /I/
	? sprintf($Open.'\x84[\x%02x\x%02x])', $d, $d-48)
	:  $c =~ /^\x84([\x80-\x91])$/ && $mod =~ /I/
	? sprintf($Open.'\x84[\x%02x\x%02x])', $d, $d-49)
        :  $c =~ /^\x82([\x9F-\xDD])$/ && $mod =~ /j/
	? sprintf($Open.'\x82\x%02x|\x83\x%02x)', $d, $d-0x5F)
	:  $c =~ /^\x82([\xDE-\xF1])$/ && $mod =~ /j/
	? sprintf($Open.'\x82\x%02x|\x83\x%02x)', $d, $d-0x5E)
	:  $c =~ /^\x83([\x40-\x7E])$/ && $mod =~ /j/
	? sprintf($Open.'\x83\x%02x|\x82\x%02x)', $d, $d+0x5F)
	:  $c =~ /^\x83([\x80-\x93])$/ && $mod =~ /j/
	? sprintf($Open.'\x83\x%02x|\x82\x%02x)', $d, $d+0x5E)
	:  $c =~ /^\x81([\x52-\x53])$/ && $mod =~ /j/
	? sprintf($Open.'\x81[\x%02x\x%02x])', $d, $d+2)
	:  $c =~ /^\x81([\x54-\x55])$/ && $mod =~ /j/
	? sprintf($Open.'\x81[\x%02x\x%02x])', $d, $d-2)
	: sprintf($Open.'\x%02x\x%02x)', unpack 'C2', $c)
}

sub dst {
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
      croak sprintf $Msg_odd, ord;
    }
  }
  return $res;
}

sub match {
  my $str = $_[0];
  my $mod = $_[2] || '';
  my $pat = re($_[1], $mod);
  if($mod =~ /g/){
    my $for = $mod =~ /z/ || '' =~ /$pat/ ? "(?:\\A|$Char+?)" : "$Char*?";
    $str =~ /\G$for(?:$pat)/g;
  } else {
    $str =~ /^$Char*?(?:$pat)/;
  }
}

sub replace {
  my $str = $_[0];
  my $dst = dst($_[2]);
  my $mod = $_[3] || '';
  my $pat = re($_[1], 'h'.$mod);
  if($mod =~ /g/){
    my $for = $mod =~ /z/ || '' =~ /$pat/ ? "(?:\\A|$Char+?)" : "$Char*?";
    if(ref $str){
      eval "\$\$str =~ s/\\G($for)(?:$pat)/\${1}$dst/g";
    } else {
      eval "\$str =~ s/\\G($for)(?:$pat)/\${1}$dst/g";
      $str;
    }
  } else {
    if(ref $str){
      eval "\$\$str =~ s/^($Char*?)(?:$pat)/\${1}$dst/";
    } else {
      eval "\$str =~ s/^($Char*?)(?:$pat)/\${1}$dst/";
      $str;
    }
  }
}

sub mkclass {
  my($tmp,@res);
  my $pat = shift;
  my $mod = shift || '';
  for($pat){
    while(length){
      if(s/^(\[\:\x5e?[0-9A-Z_a-z]+\:\])//){
        $tmp .= $1;
        next;
      }
      if(s/^(\[=\\?[=\x2D\x5B\x5C]=\])//){
        $tmp .= $1;
        next;
      }
      if(s/^(\[\=)(?=[^=]+\=\])//){
        $tmp .= $1;
        next;
      }
      if(s/^\\?\[// || s/^\\133// || s/^\\x5[bB]//){
        $tmp .= '\\['; # prevent from confusion with [: :], [= =].
        next;
      }
      if(s/^\\\\//  || s/^\\134// || s/^\\x5[cC]//){
        $tmp .= '\\\\';
        next;
      }
      if(s/^\\-//   || s/^\\055// || s/^\\x2[dD]//){
        $tmp .= '\\-';
        next;
      }
      if(s/^\\([0-7][0-7][0-7])//){
        $tmp .= chr(oct $1);
        next;
      }
      if(s/^\\x([0-9A-Fa-f][0-9A-Fa-f])//){
        $tmp .= chr(hex $1);
        next;
      }
      if(s/^\\x\{([0-9A-Fa-f][0-9A-Fa-f])([0-9A-Fa-f][0-9A-Fa-f])\}//){
        $tmp .= chr(hex $1) . chr(hex $2);
        next;
      }
      if(s/^\\0//){ $tmp .= "\0"; next }
      if(s/^\\a//){ $tmp .= "\a"; next }
      if(s/^\\b//){ $tmp .= "\b"; next }
      if(s/^\\e//){ $tmp .= "\e"; next }
      if(s/^\\f//){ $tmp .= "\f"; next }
      if(s/^\\n//){ $tmp .= "\n"; next }
      if(s/^\\r//){ $tmp .= "\r"; next }
      if(s/^\\t//){ $tmp .= "\t"; next }
      if(s/^\\c([\x00-\x7F])//){
        $tmp .= chr( ord(uc $1) ^ 64 );
        next;
      }
      if(s/^(\\[dwsDWS])//){
        $tmp .= $1;
        next;
      }
      if(s/^\\?([\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])//){
        $tmp .= $1;
        next;
      }
      if(s/^\\?([\x00-\x7F\xA1-\xDF])//){
        $tmp .= $1;
        next;
      }
      croak sprintf $Msg_odd, ord;
    }
  }
  for($tmp){
    while(length){
      if(s/^\[\:(\x5E?)([0-9A-Z_a-z]+)\:\]//){
        my $class = '\\' . ($1 ? 'P' : 'p') .'{' . $Class{$2} .'}';
        if(!defined $Re{$class}){croak sprintf $Msg_und, "[:$1$2:]"}
        push @res, $Re{$class};
        next;
      }
      if(s/^\[=\\([=\x2D\x5B\x5C])=\]//){
        push @res, defined $Eq{$1} ? $Eq{$1} : rechar($1,$mod);
        next;
      }
      if(s/^\[=([^=]+|=)=\]//){
        push @res, defined $Eq{$1} ? $Eq{$1} : rechar($1,$mod);
        next;
      }
      if(s/^(\\[dwsDWSjJ])//){
        push @res, $Re{ $1 };
        next;
      }
      if(s/^
	(\x5C[\x2D\x5B\x5C]|(?![\x5B\x5C])$Char)
	\-
	(\x5C[\x2D\x5B\x5C]|(?![\x5B\x5C])$Char)
      //xo)
      {
        my($le,$tr) = (__ord($1), __ord($2)); # lead trail
        push @res, __expand($le,$tr,$mod);
        next;
      }
      if(s/\x5C([\x2D\x5B\x5C])//){
        push @res, rechar($1,$mod);
        next;
      }
      if(s/^($Char)//o){
        push @res, rechar($1,$mod);
        next;
      }
      croak sprintf $Msg_odd, ord;
    }
  }
  return '(?:' . join('|', @res) . ')';
}

sub __ord {
  my $c = shift;
  $c =~ s/^\x5C//;
  length($c) > 1 ? unpack('n', $c) : ord($c);
}

sub __ord2{
  my $c = shift;
  0xFF < $c ? unpack('C*', pack 'n', $c) : chr($c);
}

sub __expand {
  my($fr, $to, $mod) = @_;
  $mod ||= '';
  my($ini, $fin, $i, $ch, @retv, @retd, $add);
  my($ini_f, $fin_f, $ini_t, $fin_t, $ini_c, $fin_c);
  my $trail = '[\x40-\x7e\x80-\xfc]';

  if($fr > $to){ croak sprintf $Msg_rev, $fr, $to }
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
      }else{$add = ''}
      push @retv, sprintf "[\\x%02x-\\x%02x$add]", $ini, $fin;
    }
  }
  if($fr <= 0xDF){
    $ini = $fr < 0xA1 ? 0xA1 : $fr;
    $fin = $to > 0xDF ? 0xDF : $to;
    if($ini == $fin){
      push @retv, sprintf('\\x%2x', $ini);
    }
    elsif($ini < $fin){
      push @retv, sprintf('[\\x%2x-\\x%2x]', $ini, $fin);
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
        push @retd,
	  $ini_c == $fin_c ?
	    sprintf('\x%2x'.$trail, $ini_c) :
	  $fin_c <= 0x9F || 0xE0 <= $ini_c ?
	    sprintf('[\x%2x-\x%2x]'.$trail, $ini_c, $fin_c) :
	  $ini_c == 0x9F && $fin_c == 0xE0 ?
	    '[\x9f\xe0]'.$trail :
	  $ini_c == 0x9F ?
	    sprintf('[\x9f\xe0-\x%2x]'.$trail, $fin_c) :
	  $fin_c == 0xE0 ?
	    sprintf('[\x%2x-\x9f\xe0]'.$trail, $ini_c) :
	  sprintf('[\x%2x-\x9f\xe0-\x%2x]'.$trail, $ini_c, $fin_c);
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
  return(@retv, @retd ? $Open.join('|',@retd).')' : ());
}

############################################################################
#
# splitchar(STRING; LIMIT)
# 
############################################################################
sub splitchar{
  my($str, $lim, @ret);
  ($str, $lim) = @_;
  $lim = 0 if ! defined $lim;
  if($lim == 1){
    @ret = ($str);
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

sub _splitchar{ $_[0] =~ /$Char/go }


############################################################################
#
# jsplit(PATTERN, STRING; LIMIT)
# 
############################################################################
sub jsplit{
  my($thing, $pat, $str, $lim, $cnt, @mat, @ret);
  $thing = shift;
  $pat = 'ARRAY' eq ref $thing ? re(@$thing) : re($thing);
  $str = shift;
  $lim = shift || 0;
  return splitchar($str, $lim) if '' eq $pat;
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

sub splitspace{
  my($str, $lim) = @_;
  defined $lim && 0 < $lim 
    ? do{
        (ref $str ? $$str : $str) =~ s/^(?:[\ \n\r\t\f]|\x81\x40)+//;
        jsplit('(?:[\ \n\r\t\f]|\x81\x40)+', $str, $lim)
      }
    : split(' ', spaceZ2H($str), $lim);
}

sub spaceZ2H {
  my $str = shift;
  my $len = CORE::length(ref $str ? $$str : $str);
  (ref $str ? $$str : $str) =~
     s/\G($Char*?)\x81\x40/$1 /go;
  ref $str ? abs($len - CORE::length $$str) : $str;
};

sub spaceH2Z {
  my $str = shift;
  my $len = CORE::length(ref $str ? $$str : $str);
  (ref $str ? $$str : $str) =~ s/ /\x81\x40/g;
  ref $str ? abs($len - CORE::length $$str) : $str;
};

1;
__END__

=head1 NAME

ShiftJIS::Regexp - Perl module to use Shift_JIS-oriented regexps in the byte-oriented perl

=head1 SYNOPSIS

  use ShiftJIS::Regexp qw(:all);

  match('Ç†Ç®ÇPÇQ', '\p{InHiragana}{2}\p{IsDigit}{2}');
  match('Ç†Ç¢Ç¢Ç§Ç§Ç§', '^Ç†Ç¢+Ç§{3}$');
  replace($str, 'A', 'Ç`', 'g');

=head1 DESCRIPTION

This module provides some functions to use Shift_JIS-oriented regexps
in the byte-oriented perl.

The legal Shift_JIS character in this module must match the following regexp:

    [\x00-\x7F\xA1-\xDF]|[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]

=head2 FUNCTIONS

=over 4

=item C<re(PATTERN)>

=item C<re(PATTERN, MODIFIER)>

Returns regexp parsable by the byte-oriented perl.

C<PATTERN> is specified as a string.

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

     i  do case-insensitive pattern matching (only for ascii alphabets)
     I  do case-insensitive pattern matching
        (greek, cyrillic, fullwidth latin)
     j  do hiragana-katakana-insensitive pattern matching

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

    my $d = '\p{IsDigit}';
    my $str = 'ã‡ÇPÇTÇRÇOÇOÇOÇOâ~';
    1 while replace(\$str, "($d)($d$d$d)(?!$d)", '$1ÅC$2');
    print $str; # ã‡ÇPÅCÇTÇRÇOÅCÇOÇOÇOâ~

C<MODIFIER> is specified as a string.

     i  do case-insensitive pattern matching (only for ascii alphabets)
     I  do case-insensitive pattern matching
        (greek, cyrillic, fullwidth latin)
     j  do hiragana-katakana-insensitive pattern matching

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

=head2 REGEXPS

   regexp          meaning

   ^               match the start of the string
                   match the start of any line with 'm' modifier

   $               match the end of the string
                   match the end of any line with 'm' modifier

   .               match any character except \n
                   match any character with 's' modifier

   \A              only at beginning of string
   \Z              at end of string, or before newline at the end
   \z              only at end of string (eq. '(?!\n)\Z')

   \C              match a single C char (octet), i.e. [\0-\xFF] in perl.
   \j              match any character, i.e. [\0-\x{FCFC}] in this module.
   \J              match any character except \n, i.e. [^\n] in this module.

     * \j and \J are extensions by this module. e.g.

        match($_, '(\j{5})\z') returns last five chars including \n at the end
        match($_, '(\J{5})\Z') returns last five chars excluding \n at the end

   \a              alarm      (BEL)
   \b              backspace  (BS) * within character classes *
   \t              tab        (HT, TAB)
   \n              newline    (LF, NL)
   \f              form feed  (FF)
   \r              return     (CR)
   \e              escape     (ESC)

   \0              null       (NUL)

   \ooo            octal single-byte character
   \xhh            hexadecimal single-byte character
   \x{hhhh}        hexadecimal double-byte character
   \c[             control character

      e.g. \012 \123 \x5c \x5C \x{824F} \x{9Fae} \cA \cZ \c^ \c?

   regexp           equivalent character class

   \d               [\d]              [0-9]
 ! \D               [\D]              [^0-9]
   \w               [\w]              [0-9A-Z_a-z]
 ! \W               [\W]              [^0-9A-Z_a-z]
   \s               [\s]              [\t\n\r\f ]
 ! \S               [\S]              [^\t\n\r\f ]

   \p{IsDigit}      [[:digit:]]       [0-9ÇO-ÇX]
 ! \P{IsDigit}      [[:^digit:]]      [^0-9ÇO-ÇX]
   \p{IsUpper}      [[:upper:]]       [A-ZÇ`-Çy]
 ! \P{IsUpper}      [[:^upper:]]      [^A-ZÇ`-Çy]
   \p{IsLower}      [[:lower:]]       [a-zÇÅ-Çö]
 ! \P{IsLower}      [[:^lower:]]      [^a-zÇÅ-Çö]
   \p{IsAlpha}      [[:alpha:]]       [A-Za-zÇ`-ÇyÇÅ-Çö]
 ! \P{IsAlpha}      [[:^alpha:]]      [^A-Za-zÇ`-ÇyÇÅ-Çö]
   \p{IsAlnum}      [[:alnum:]]       [0-9A-Za-zÇO-ÇXÇ`-ÇyÇÅ-Çö]
 ! \P{IsAlnum}      [[:^alnum:]]      [^0-9A-Za-zÇO-ÇXÇ`-ÇyÇÅ-Çö]

   \p{IsWord}       [[:word:]]
          [0-9A-Z_a-zÇO-ÇXÇ`-ÇyÇÅ-ÇöÉü-É∂Éø-É÷Ñ@-Ñ`Ñp-Ñë¶-ﬂÇü-ÇÒÉ@-ÉñÅJÅKÅR-Å[àü-òròü-Í§]
 ! \P{IsWord}       [[:^word:]]
          [^0-9A-Z_a-zÇO-ÇXÇ`-ÇyÇÅ-ÇöÉü-É∂Éø-É÷Ñ@-Ñ`Ñp-Ñë¶-ﬂÇü-ÇÒÉ@-ÉñÅJÅKÅR-Å[àü-òròü-Í§]

   \p{IsPunct}      [[:punct:]]
                [!-/:-@[-`{-~°-•ÅA-ÅIÅL-ÅQÅ\-Å¨Å∏-ÅøÅ»-ÅŒÅ⁄-ÅËÅ-Å˜Å¸Ñü-Ñæ]
 ! \P{IsPunct}      [[:^punct:]]
                [^!-/:-@[-`{-~°-•ÅA-ÅIÅL-ÅQÅ\-Å¨Å∏-ÅøÅ»-ÅŒÅ⁄-ÅËÅ-Å˜Å¸Ñü-Ñæ]
   \p{IsSpace}      [[:space:]]       [\t\n\r\f \x{8140}]
 ! \P{IsSpace}      [[:^space:]]      [^\t\n\r\f \x{8140}]
 ! \p{IsGraph}      [[:graph:]]       [^\0- \x7F\x{8140}]
   \P{IsGraph}      [[:^graph:]]      [\0- \x7F\x{8140}]
 ! \p{IsPrint}      [[:print:]]       [^\0- \x0B\x0E-\x1F\x7F]
   \P{IsPrint}      [[:^print:]]      [\x00-\x08\x0B\x0E-\x1F\x7F]
   \p{IsCntrl}      [[:cntrl:]]       [\x00-\x1F]
 ! \P{IsCntrl}      [[:^cntrl:]]      [^\x00-\x1F]

   \p{IsAscii}      [[:ascii:]]       [\x00-\x7F]
 ! \P{IsAscii}      [[:^ascii:]]      [^\x00-\x7F]
   \p{IsHankaku}    [[:hankaku:]]     [\xA1-\xDF]
 ! \P{IsHankaku}    [[:^hankaku:]]    [^\xA1-\xDF]
 ! \p{IsZenkaku}    [[:zenkaku:]]     [\x{8140}-\x{FCFC}]
   \P{IsZenkaku}    [[:^zenkaku:]]    [^\x{8140}-\x{FCFC}]

   \p{IsX0201}      [[:x0201:]]       [\x00-\x7F\xA1-\xDF]
 ! \P{IsX0201}      [[:^x0201:]]      [^\x00-\x7F\xA1-\xDF]
   \p{IsX0208}      [[:x0208:]]
          [\x{8140}-Å¨Å∏-ÅøÅ»-ÅŒÅ⁄-ÅËÅ-Å˜Å¸ÇO-ÇXÇ`-ÇyÇÅ-ÇöÇü-ÇÒÉ@-ÉñÉü-É∂Éø-É÷Ñ@-Ñ`Ñp-ÑëÑü-Ñæàü-òròü-Í§]

 ! \P{IsX0208}      [[:^x0208:]]
          [^\x{8140}-Å¨Å∏-ÅøÅ»-ÅŒÅ⁄-ÅËÅ-Å˜Å¸ÇO-ÇXÇ`-ÇyÇÅ-ÇöÇü-ÇÒÉ@-ÉñÉü-É∂Éø-É÷Ñ@-Ñ`Ñp-ÑëÑü-Ñæàü-òròü-Í§]

   \p{InLatin}      [[:latin:]]       [A-Za-z]
 ! \P{InLatin}      [[:^latin:]]      [^A-Za-z]
   \p{InFullLatin}  [[:fulllatin:]]   [Ç`-ÇyÇÅ-Çö]
 ! \P{InFullLatin}  [[:^fulllatin:]]  [^Ç`-ÇyÇÅ-Çö]
   \p{InGreek}      [[:greek:]]       [Éü-É∂Éø-É÷]
 ! \P{InGreek}      [[:^greek:]]      [^Éü-É∂Éø-É÷]
   \p{InCyrillic}   [[:cyrillic:]]    [Ñ@-Ñ`Ñp-Ñë]
 ! \P{InCyrillic}   [[:^cyrillic:]]   [^Ñ@-Ñ`Ñp-Ñë]
   \p{InHalfKana}   [[:halfkana:]]    [¶-ﬂ]
 ! \P{InHalfKana}   [[:^halfkana:]]   [^¶-ﬂ]
   \p{InHiragana}   [[:hiragana:]]    [Çü-ÇÒÅJÅKÅTÅU]
 ! \P{InHiragana}   [[:^hiragana:]]   [^Çü-ÇÒÅJÅKÅTÅU]
   \p{InKatakana}   [[:katakana:]]    [É@-ÉñÅ[ÅRÅS]
 ! \P{InKatakana}   [[:^katakana:]]   [^É@-ÉñÅ[ÅRÅS]
   \p{InFullKana}   [[:fullkana:]]    [Çü-ÇÒÉ@-ÉñÅJÅKÅ[ÅTÅUÅRÅS]
 ! \P{InFullKana}   [[:^fullkana:]]   [^Çü-ÇÒÉ@-ÉñÅJÅKÅ[ÅTÅUÅRÅS]
   \p{InKana}       [[:kana:]]        [¶-ﬂÇü-ÇÒÉ@-ÉñÅJÅKÅ[ÅTÅUÅRÅS]
 ! \P{InKana}       [[:^kana:]]       [^¶-ﬂÇü-ÇÒÉ@-ÉñÅJÅKÅ[ÅTÅUÅRÅS]
   \p{InKanji1}     [[:kanji1:]]      [àü-òr]
 ! \P{InKanji1}     [[:^kanji1:]]     [^àü-òr]
   \p{InKanji2}     [[:kanji2:]]      [òü-Í§]
 ! \P{InKanji2}     [[:^kanji2:]]     [^òü-Í§]
   \p{InKanji}      [[:kanji:]]       [ÅV-ÅZàü-òròü-Í§]
 ! \P{InKanji}      [[:^kanji:]]      [^ÅV-ÅZàü-òròü-Í§]
   \p{InBoxDrawing} [[:boxdrawing:]]  [Ñü-Ñæ]
 ! \P{InBoxDrawing} [[:^boxdrawing:]] [^Ñü-Ñæ]

   * On \p{Prop} or \P{Prop} expressions, 'Is' or 'In' can be omitted
     like \p{Digit} or \P{Kanji}.
    (the omission of 'In' is an extension by this module)

   * Character classes marked with <!> contain undefined codepoints
     in JIS (JIS X 0201 or JIS X 0208).

=over 4

=item Character class

Ranges in character class are supported. 

The order of Shift_JIS characters is:
  C<0x00 .. 0x7F, 0xA1 .. 0xDF, 0x8140 .. 0x9FFC, 0xE040 .. 0xFCFC>.

So C<[\0-\x{fcfc}]> matches any one Shift_JIS character.

In character classes, any character or byte sequence
that does not match any one Shift_JIS character,
e.g. C<re('[\xA0-\xFF]')>, is croaked.

Character classes that match non-Shift_JIS substring
are not supported (use C<\C> or alternation).

=item Character Equivalents

Since the version 0.13,
the POSIX character equivalent classes C<[=cc=]> are supported.
e.g. C<[[=Ç†=]]> is identical to C<[ÇüÉ@ßÇ†ÉA±]>;
C<[[=P=]]> to C<[pPÇêÇo]>; C<[[=4=]]> to C<[4ÇS]>.

As C<cc> in C<[=cc=]>, any character literal or meta chatacter
(C<\xhh>, C<\x{hhhh}>) that belongs to the character equivalents can be used.
e.g. C<[=Ç†=]>, C<[=ÉA=]>, C<[=\x{82A0}=]>, C<[=\xB1=]>, etc.
have identical meanings.

C<[[=Ç©=]]> matches C<'Ç©'>, C<'ÉJ'>, C<'∂'>, C<'Ç™'>, C<'ÉK'>, C<'∂ﬁ'>, C<'Éï'> (C<'∂ﬁ'> is a two-character string, but one collation element, 
C<HALFWIDTH FORM FOR KATAKANA LETTER GA>.

C<[[===]]> matches C<EQUALS SIGN> or C<FULLWIDTH EQUALS SIGN>;
C<[[=[=]]> matches C<LEFT SQUARE BRACKET> or C<FULLWIDTH LEFT SQUARE BRACKET>;
C<[[=\=]]> matches C<YEN SIGN> or C<FULLWIDTH YEN SIGN>.

=item Code embedded in regexp (Perl 5.005 or later)

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

=back

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

perl(1), ShiftJIS::String

=cut
