package Game;
no warnings 'recursion';

use strict;

use List::Util qw/
    max
    min
    shuffle
    sum
/;


use Scalar::Util qw/
    looks_like_number
/;

use Carp;
use Lingua::EN::Inflect qw/
    PL
    AN
    PART_PRES
    def_noun
    classical
/;

use JSON qw/
    to_json
    from_json
/;

$JSON::UTF8 = 1;

use POSIX qw/ INT_MAX /;
use Cwd qw/ realpath /;
use File::Basename qw/ basename dirname /;

srand;
binmode STDOUT, ':utf8';

our %Vars = (
    Player => $ENV{USER},
);
our %Local_vars;

our $Boss_monster_threshold = 200;
our $quiet_mode = 0;
our $perl_lib_base;

our $Dictionary_path;
our %Dictionaries;

classical 'herd';

def_noun 'huggle' => 'hugglz';
def_noun 'mudkip' => 'mudkipz';
def_noun 'cosmo' => 'cosmos';
def_noun 'LOL(.*)' => 'LOL$1z';
def_noun 'LOLrus' => 'LOLri';
def_noun "chapul\x{ed}n" => "chapulines";
def_noun "tamal" => "tamales";
def_noun "arroz" => "arroces";
def_noun 'TARDIS' => 'TARDES';
def_noun 'VHS' => 'VHSes';
def_noun $_ => $_ for qw/
    lakitu cas skub snus
    love bo asari elcor
    vorcha rachni krogan volus
    geth drell hanar voorta
    jem-hadar ferengi borg duros
/;

# Dictionaries are stored by default in Dictionaries/*.pl .
#
# <Foo> => random singular element from @Foo
# <Foo>(bar) => random singular element from @Foo, with argument text bar
# <-Foo> => random singular element from @Foo, hyphenated
# <^Foo> => random singular element from @Foo, capitalized
# <&Foo> => random singular element from @Foo with the first word capitalized
# </Foo> => random singular element from @Foo, lowercased
# <.Foo> => random singular element from @Foo, with the first word lowercased
# <!Foo> => random singular element from @Foo, ALLCAPS
# <*Foo> => random singular element from @Foo with articles stripped
# <,Foo> => random singular element from @Foo with spaces replaced with underscores
# <+Foo> => random singular element from @Foo with spaces replaced with plusses
# <~Foo> => random singular element from @Foo with spaces removed
# <#Foo> => random singular element from @Foo with 'fucking' inserted before some word
# <N-M> => random integer between N and M
# <$_> => argument passed to expansion (see <Foo>(bar))
# <$N> => reprise Nth substitution as singular (zero-based)
# <N [+-*/] M> => simple arithmetic
# <$Var {<|>|==|=~|!=|!~} M> => simple logic (true => 'yes', false => '')
# <NdM> => roll N dice of M size (standard sizes in <Die_size>)
# <$Foo> => variable
#   Some of the available variables:
#       $Player: the hero
#       $Player.experience: the hero's experience
#       $Player.hp: the hero's HP
#       $Player.gold: the hero's gold
#       $Player.class: the hero's class
#       $Player.status: the hero's status ailment, if any
#       $Player.location: the hero's current location
#       $Player_level: the hero's rank
#       $Player_sign: the hero's zodiacal sign
#       $Player_occupation: the hero's current occupation
#       $Opponent: the antagonist
#       $Loot: the loot being described/contested
#
#       Variables named $Player.* are persisted.
#
# <*>s    => Inflect as plural
# <*>'s   => Inflect as possessive
# <*>ing  => Inflect as gerund
# <*>e    => Inflect as ye Olde English
# word^   => When inflecting this string, inflect the word just before the caret.
#            By default, only the last word is inflected.
#            Can be used multiple times to inflect multiple words.
# <*>^H   => introduce a "typographical" error.
# a^, an^ => (special case) Nuke indefinite article when pluralizing
# ^       => (at beginning of string) Don't inflect at all
#
# [Variable?aaa:bbb] => emit aaa if Variable is set and non-empty string, bbb otherwise
# [<Expr>?aaa:bbb] => emit aaa if <Expr> expands to non-empty string, bbb otherwise
# [$Variable=aaa] => expand aaa and assign it to Variable forEVAR
# [Variable=aaa] => expand aaa and assign it to Variable for the scope of the current expansion
# <$$aaa> => expand the contents of the variable aaa, as if it were in <>
#
# Exercise 20.1: Rewrite engine in <Hipster_language>

our @Zodiac = (
    [ '2002-03-21', '2002-04-20', "\x{2648} Aries"       ],
    [ '2002-04-20', '2002-05-20', "\x{2649} Taurus"      ],
    [ '2002-05-21', '2002-06-20', "\x{264a} Gemini"      ],
    [ '2002-06-21', '2002-07-22', "\x{264b} Cancer"      ],
    [ '2002-07-23', '2002-08-22', "\x{264c} Leo"         ],
    [ '2002-08-23', '2002-09-22', "\x{264d} Virgo"       ],
    [ '2002-09-23', '2002-10-22', "\x{264e} Libra"       ],
    [ '2002-10-23', '2002-11-21', "\x{264f} Scorpio"     ],
    [ '2002-11-22', '2002-12-21', "\x{2650} Sagittarius" ],
    [ '2002-12-22', '2003-01-19', "\x{2651} Capricorn"   ],
    [ '2001-12-22', '2002-01-19', "\x{2651} Capricorn"   ],
    [ '2002-01-20', '2002-02-18', "\x{2652} Aquarius"    ],
    [ '2002-02-19', '2002-03-20', "\x{2653} Pisces"      ],
);

sub zodiacal_sign
{
    my ($date) = @_;
    (my $zdate = $date) =~ s{\A\d+}{2002};

    for my $sign (@Zodiac) {
        if ($sign->[0] le $zdate && $zdate le $sign->[1]) {
            return $sign->[2];
        }
    }
    return "\x{2639} unknown";
}

sub _load_dictionary
{
    my ($category) = @_;
    $Dictionary_path ||= dirname(__FILE__) . "/Dictionaries";
    my $category_file = "$Dictionary_path/$category.pl";

    return do $category_file;
}

sub dictionary
{
    my ($category) = @_;
    return $Dictionaries{$category} ||= _load_dictionary($category);
}

sub one_of
{
    my ($category, $arg) = @_;
    my $list = ref $category ? $category : dictionary($category);
    my @list =
          UNIVERSAL::isa($list, 'HASH')  ? keys %$list
        : UNIVERSAL::isa($list, 'ARRAY') ? @$list
        :                                  maybe_croak("Dictionary $category ain' no dictionary I air seen");

    return _one_of(\@list, $arg);
}

sub _one_of
{
    my ($list, $arg) = @_;
    my @list = @$list;
    my $thing = $list[int(rand() * @list)];
    return expand($thing, $arg);
}

sub maybe_croak
{
    my ($message) = @_;
    croak $message unless $quiet_mode;
    exit 1;
}

sub n_of
{
    my ($n, $category) = @_;
    my @things;
    my @category = @{ ref $category ? $category : dictionary($category) };

    for (1..$n) {
        push @things, expand(splice(@category, int(rand() * @category), 1));
    }
    return @things;
}

sub grammarize
{
    my ($string) = @_;
    $string =~ s/\b(the)\s+the\b/$1/gi;
    $string =~ s/\b(an?)\s+([tT])([hH][eE])\b/@{[lc($2)]}$3/g;
    $string =~ s/\b(An?)\s+([tT])([hH][eE])\b/@{[uc($2)]}$3/g;
    $string =~ s/\b(a)(\s+[aeiou])/$1n$2/gi;
    return $string;
}

sub want_inflection { my ($string) = @_; $string !~ /^\^/ }
sub custom_inflection { my ($string) = @_; $string =~ /\^(\s|$)/ }

sub singular
{
    my ($string) = @_;
    return inflect($string, '', sub { shift() });
}

sub plural
{
    my ($string) = @_;
    return inflect($string, 's', sub {my $word = shift();
        if ($word eq 'a' || $word eq 'an') {
            return '';
        } else {
            return PL($word);
        }
    });
}

sub gerund
{
    my ($string) = @_;
    return inflect($string, 'ing', \&PART_PRES);
}

sub olde_tyme
{
    my ($string) = @_;
    return inflect($string, 'e', sub {my $word = shift();
        $word =~ s/i/y/g;
        $word =~ s/Th/\x{de}/g;
        $word =~ s/th/\x{fe}/g;
        $word =~ s/s\B/\x{17f}/g;
        $word =~ s/e\B/ae/g;
        $word =~ s/e?$/e/;
        $word =~ tr/uv/vu/;
        return $word;
    });
}

sub past_tense
{
    my ($string) = @_;
    return inflect($string, 'd', sub {my $word = shift();
        my %special_cases = (
            bring => 'brought',
            bend  => 'bent',
            breed => 'bred',
            come  => 'came',
            do    => 'did',
            eat   => 'ate',
            feel  => 'felt',
            go    => 'went',
            grind => 'ground',
            hear  => 'heard',
            hold  => 'held',
            keep  => 'kept',
            leave => 'left',
            make  => 'made',
            put   => 'put',
            say   => 'said',
            sell  => 'sold',
            see   => 'saw',
            set   => 'set',
            sit   => 'sat',
            spit  => 'spat',
            run   => 'ran',
            take  => 'took',
            tell  => 'told',
            throw => 'threw',
            wear  => 'wore',
        );

        return $special_cases{$word} if exists $special_cases{$word};
        return "${1}ied" if $word =~ /(\w+[^aeiou])y$/;
        return "${1}ed" if $word =~ /(\w+)e$/;
        return "${1}${2}${2}ed" if $word =~ /(\w+[aeiou])([ptgd])$/;
        return "${word}ed";
    });
}

sub comparator
{
    my ($string) = @_;
    return inflect($string, 'r', sub {my $word = shift();
        return "${1}ier" if $word =~ /(\w+[^aeiou])y$/;
        return "${1}er" if $word =~ /(\w+)e$/;
        return "${1}${2}${2}er" if $word =~ /(\w+[aeiou])([ptgld])$/;
        return "${word}er";
    });
}

sub mostest
{
    my ($string) = @_;
    return inflect($string, 'st', sub {my $word = shift();
        return "${1}iest" if $word =~ /(\w+[^aeiou])y$/;
        return "${1}est" if $word =~ /(\w+)e$/;
        return "${1}${2}${2}est" if $word =~ /(\w+[aeiou])([ptgldc])$/;
        return "${word}est";
    });
}

sub possessive
{
    my ($string) = @_;
    return inflect($string, '\'s', sub {my $word = shift();
        return "${1}'" if $word =~ /(\w*)[szx]$/;
        return "${word}'s";
    });
}

sub inflect
{
    my ($string, $suffix, $inflector) = @_;
    if (want_inflection($string)) {
        if (custom_inflection($string)) {
            $string =~ s/([\w']+)\^(\s|$)/$inflector->($1) . $2/ge;
            $string =~ s/>\^(\s|$)/>$suffix$1/g;
        } else {
            $string =~ s/>$/>$suffix/g;
            $string =~ s/([\w']+)$/$inflector->($1)/ge;
        }
    } else {
        $string =~ s/^\^//;
    }
    return $string;
}

sub uc_every_first
{
    my ($string) = @_;
    $string =~ s/(^|[^\w'])(\w)/$1\u$2/g;
    return $string;
}

sub uc_the_first
{
    my ($string) = @_;
    $string =~ s/(^|[^\w'])(\w)/$1\u$2/;
    return $string;
}

sub lc_the_first
{
    my ($string) = @_;
    $string =~ s/(^|[^\w'])(\w)/$1\l$2/;
    return $string;
}

sub hyphenate
{
    my ($string) = @_;
    $string =~ s/\s+/-/g;
    return $string;
}

sub underscoreize
{
    my ($string) = @_;
    $string =~ s/\s+/_/g;
    return $string;
}

sub plus_ize
{
    my ($string) = @_;
    $string =~ s/\s+/+/g;
    return $string;
}

sub remove_spaces
{
    my ($string) = @_;
    $string =~ s/\s+//g;
    return $string;
}

sub in_bed_ize
{
    my ($string) = @_;
    if ($string =~ m{[.!?]\s*$}) {
        $string =~ s/([.!?])\s*$/ In bed$1/
    } else {
        $string =~ s/(\s*)$/ in bed/;
    }
    return $string;
}

sub add_insult
{
    my ($string) = @_;
    my $insult = _expand('<Insult>');
    $string =~ s/([\.\?!]*)$/, $insult$1/;
    return $string;
}

sub profanitize
{
    my ($string) = @_;
    my @words = split /\s/, $string;
    my $index = _rand(0, $#words);
    my $profanity = 'fucking';
    if ( $index == 0 ) {
        @words = ($profanity, @words);
    } else {
        @words = (@words[ 0 .. ($index - 1)], $profanity, @words[$index .. $#words]);
    }
    return join " ", @words;
}

sub typo
{
    my ($string) = @_;
    my $effect = _rand(0,4);
    my @effects = (
        # Transpose two characters
        sub { my $str = shift();
            my $offset = _rand(1, length($string) - 1);
            my $chr = substr($str, $offset, 1);
            my $previous_chr = substr($str, $offset - 1, 1, $chr);
            substr($str, $offset - 1, 2, $chr . $previous_chr);
            return $str;
        },
        # Drop a character
        sub { my $str = shift();
            my $offset = _rand(1, length($string) - 1);
            substr($str, $offset, 1, '');
            return $str;
        },
        # Repeat a character
        sub { my $str = shift();
            my $offset = _rand(0, length($string) - 1);
            substr($str, $offset, 0, substr($str, $offset, 1));
            return $str;
        },
        # Replace a character with a different character close to it on the keyboard
        #megalint complained, so I removed this. Fit if you care to.
        #sub { my $str = shift();
        #    my $offset = _rand(0, length($str) - 1);
        #    my $chr = substr($str, $offset, 1);
        #    my @layout = ('1234567890-=+_)(*&^%$#@!',
        #                  'qwertyuiop[]\\|}{POIUYTREWQ',
        #                  'asdfghjkl;\'":LKJHGFDSA',
        #                  'zxcvbnm,./?><MNBVCXZ',);
        #
        #    my $y;
        #    for my $x (0 .. (@layout - 1)) {
        #        if (-1 != ($y = index($layout[$x], $chr))) {
        #            my $v_offset = _rand(
        #                $x == 0 ? 0 : -1,
        #                $x == 3 ? 0 : 1
        #            );
        #            my $h_offset = _rand(
        #                $y == 0 ? 0 : -1,
        #                $y == length($layout[$x + $v_offset]) - 1 ? 0 : 1
        #            );
        #            my $replacement = substr($layout[$x + $v_offset], $y + $h_offset, 1);
        #            substr($str, $offset, 1, $replacement);
        #        }
        #    }
        #    return $str;
        #},
    );

    my $orig_string = $string;
    # A typo is guaranteed
    while ($orig_string eq $string) {
        $string = ($effects[_rand(0,$#effects)])->($string);
    }
    my $count = 1;
    while (_rand(0,20) < _rand(0,length($string)) && $count < length($string)/3) {
        $string = ($effects[_rand(0,$#effects)])->($string);
        $count++;
    }
    return $string;
}

sub roll_dice
{
    my ($count, $size, $plus) = @_;
    my $total = 0;
    if ($count > 1000 || $size > 1000)
    {
        return one_of('Amusing_dice_roller_response');
    }
    $total += _rand(1,$size) for (1..$count);
    return $total + ($plus || 0);
}

sub pick_one_from_comma_set_and_do_repetition
{
    my ($list) = @_;
    my $item = _one_of([trim(split(/,/, $list))]);
    if (my ($internal_item) = $item =~ /(.*)\+$/) {
        $item = $internal_item;
        $item .= $internal_item while rand(10) > 1;
    }

    return $item;
}

sub _backreference { my ($name, $backreferences) = @_; $name =~ /^\$(\d+)$/ && $backreferences->[$1] }

sub __variable {
    my ($v) = @_;
      exists $Local_vars{$v} ? $Local_vars{$v}
    : exists $Vars{$v}       ? $Vars{$v}
    : '';
}

sub _variable {
    my ($name, $arg) = @_;
    if ($name =~ /^\$([\w.]+)$/) {
        return __variable($1);
    } elsif ($name =~ /^\$\$([\w.]+)$/) {
        my $val = __variable($1);
        return $val ? expand('<' . singular($val) . '>', $arg) : '';
    }
    return undef;
}

sub _rand { my ($min, $max) = @_; int(rand() * ($max - $min + 1)) + $min }

sub _bool { my ($v) = @_; $v ? 'yes' : '' }

our $Recursion_level;
sub _expand
{
    my ($string) = @_;
    my @backreferences;
    my $save = sub { my ($inflection, $s) = @_;
        $inflection ||= '';
        my $x = expand($s);
        push @backreferences, $x;
        my %transforms = (
            s     => \&plural,
            '\'s' => \&possessive,
            ing   => \&gerund,
            e     => \&olde_tyme,
            '^H'  => \&typo,
            'd'   => \&past_tense,
            r     => \&comparator,
            st    => \&mostest,
        );
        defined $x ? (
            exists $transforms{$inflection}
                ? $transforms{$inflection}->($x)
                : singular($x)
        )
        : '';
    };

    return '' unless $string;

    $string =~ s(
        \[ (<)? ([^\]>?]+) (>)? \? ([^:]*) : ([^\]]*) \]                           # branch
        | \[ (\$)? ([\w.]+) = ([^\]]*) \]                                          # assignment
        | < ([\^\*\-!@.&,~\+\/#=}]*) ([^<>]+) > (?: [(]([^\)]*)[)] )? (st|s|ing|e|r|d|\^H)? # expansion
        | \[\?(.*?)?\]                                                             # choose one from inline list
    )(
        if ( $Recursion_level++ < 20 ) {
            my (
                $bracket1, $cond, $bracket2, $then, $else,
                $globalp, $var, $value,
                $mods, $name, $arg, $inflection, $list
            ) = ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13);

            my $result = "";
            if (defined $cond) {
                #warn "--- COND $bracket1$cond$bracket2|$then|$else";
                my $test_value = $bracket1 ? expand("<$cond>") : __variable($cond);

                $result = $save->('', defined $test_value && length singular($test_value) ? $then : $else);
            } elsif (defined $var) {
                #warn "--- ASSIGN $globalp|$var|$value";
                my $v = expand($value);
                $globalp
                    ? $Vars{$var} = $v
                    : $Local_vars{$var} = $v;
            } elsif (defined $list) {
                #warn "--- LIST $list ";
                $result = $save->('', pick_one_from_comma_set_and_do_repetition($list));
            } elsif ($name =~ /^(\d+)-(\d+)$/) {
                #warn "--- RANGE $1 $2";
                $result = _rand($1, $2);
            } elsif ($name =~ /^(\d+)d(\d+)$/) {
                #warn "--- DICE $1 $2";
                $result = roll_dice($1, $2);
            } elsif ($name =~ /^(\d+)d(\d+)\+(\d+)$/) {
                #warn "--- DICE $1 $2 $3";
                $result = roll_dice($1, $2, $3);
            } elsif ($name =~ /^([\d.]+) \+ ([\d.]+)$/) {
                #warn "--- ADD $1 $2";
                $result = $1 + $2;
            } elsif ($name =~ /^([\d.]+) \- ([\d.]+)$/) {
                #warn "--- SUB $1 $2";
                $result = $1 - $2;
            } elsif ($name =~ /^([\d.]+) \* ([\d.]+)$/) {
                #warn "--- MUL $1 $2";
                $result = $1 * $2;
            } elsif ($name =~ /^([\d.]+) \/ ([\d.]+)$/) {
                #warn "--- DIV $1 $2";
                $result = $2 != 0 ? ($1 / $2) : 0 ;
            } elsif ($name =~ /^\$([^>]+) < ([^>]+)$/) {
                #warn "--- LT $1 $2";
                $result = _bool(looks_like_number(__variable($1)) ? __variable($1) < $2 : __variable($1) lt $2);
            } elsif ($name =~ /^\$([^>]+) > ([^>]+)$/) {
                #warn "--- GT $1 $2";
                $result = _bool(looks_like_number(__variable($1)) ? __variable($1) > $2 : __variable($1) gt $2);
            } elsif ($name =~ /^\$([^>]+) <= ([^>]+)$/) {
                #warn "--- LTE $1 $2";
                $result = _bool(looks_like_number(__variable($1)) ? __variable($1) <= $2 : __variable($1) le $2);
            } elsif ($name =~ /^\$([^>]+) >= ([^>]+)$/) {
                #warn "--- GTE $1 $2";
                $result = _bool(looks_like_number(__variable($1)) ? __variable($1) >= $2 : __variable($1) ge $2);
            } elsif ($name =~ /^\$([^>]+) == ([^>]+)$/) {
                #warn "--- EQ $1 $2";
                $result = _bool(looks_like_number(__variable($1)) ? __variable($1) == $2 : __variable($1) eq $2);
            } elsif ($name =~ /^\$([^>]+) != ([^>]+)$/) {
                #warn "--- NE $1 $2";
                $result = _bool(looks_like_number(__variable($1)) ? __variable($1) != $2 : __variable($1) ne $2);
            } elsif ($name =~ /^\$([^>]+) =~ ([^>]+)$/) {
                #warn "--- LIKE $1 $2";
                $result = _bool(__variable($1) =~ m{$2});
            } elsif ($name =~ /^\$([^>]+) !~ ([^>]+)$/) {
                #warn "--- UNLIKE $1 $2";
                $result = _bool(__variable($1) !~ m{$2});
            } else {
                #warn "--- SUBST $name|$arg|$inflection";
                $arg = $Local_vars{_} if defined $arg && $arg eq '<$_>';
                my $item =
                      $name =~ /^\$\d+$/ ? _backreference($name, \@backreferences)
                    : $name =~ /^\$/     ? _variable($name, $arg)
                    :                      one_of($name, $arg);
                $result = $save->($inflection, $item);

                    $result = add_insult($result) if $mods =~ /@/;
                    $result = in_bed_ize($result) if $mods =~ /=/;
                    $result = profanitize($result) while $mods =~ s/#//;
                    $result = unthe($result) if $mods =~ /\*/;
                    $result = uc_every_first($result) if $mods =~ /\^/;
                    $result = uc_the_first($result) if $mods =~ /\&/;
                    $result = lc_the_first($result) if $mods =~ /\./;
                    $result = uc($result) if $mods =~ /!/;
                    $result = lc($result) if $mods =~ m{/};
                    $result = hyphenate($result) if $mods =~ /-/;
                    $result = underscoreize($result) if $mods =~ /,/;
                    $result = plus_ize($result) if $mods =~ /\+/;
                    $result = remove_spaces($result) if $mods =~ /~/;
            }

            $result;
        } else {
            '...';
        }
    )xge;

    $Recursion_level--;
    if ($Recursion_level < 0) { $Recursion_level = 0; }
    return grammarize($string);
}

sub trim
{
    my (@strings) = @_;
    return map {
        $_ = defined $_ ? $_ : '';
        $_ =~ s/\s*$//;
        $_ =~ s/^\s*//;
        $_;
    } @strings;
}

sub expand
{
    my ($thing, $arg) = @_;
    local %Local_vars = %Local_vars;
    $Local_vars{_} = $arg;

    return _expand(ref($thing) eq 'CODE' ? $thing->($arg) : $thing);
}

sub unthe
{
    my ($string) = @_;
    $string =~ s/\b(the\s)//i;
    return wantarray ? ($string, $1) : $string;
}

sub the
{
    my ($string) = @_;
    ($string, my $the) = unthe($string);
    $string = "$the$string" if $the;
    return $string;
}

sub new { $_[0] }

sub init
{
    my ($self, $dp, $qm) = @_;
    $self->_set_perl_lib_base();
    $quiet_mode = $qm if $qm;
    $Dictionary_path = $dp if $dp;

    return $self;
}

sub mood_string
{
    my ($self) = @_;
    return dictionary('Mood')->[$Vars{'Player.mood'}];
}

sub sign
{
    my ($self) = @_;
    return zodiacal_sign($Vars{'Player.dob'});
}

sub play
{
    my ($self, $was_successful, $tests_run) = @_;
    my $output = $self->initialize($was_successful, $tests_run);
    return $self->expand_string($output);
}

sub initialize
{
    my ($self, $was_successful, $tests_run) = @_;
    $Vars{'Player.name'} = $ENV{USER};
    $Vars{'Player.experience'} = 0;
    $Vars{'Player.class'} = 'programmer';
    $Vars{'Player.dob'} = '1970-01-01';
    $Vars{'Player.dob_format_should_remain'} = 'YYYY-MM-DD';
    $Vars{'Player.location'} = 'Initech HQ';
    $Vars{'Player.status'} = '';
    $Vars{'Player.hp'} = 100;
    $Vars{'Player.mood'} = 3;
    $Vars{'Player.gold'} = 0;
    $Vars{'Player.race'} = 'Human';

    $self->_load_state();

    $Vars{Player_level}  = $self->level();
    $Vars{Player_sign} = $self->sign();
    $Vars{Player_blood_type} = $self->_blood_type();
    $Vars{Player_alignment} = $self->_alignment();
    $Vars{Player_occupation} = $self->occupation();
    $Vars{Player_credit_score} = 400;
    $Vars{Player_is_mazed} = $self->is_mazed();

    $tests_run ||= 0;

    $Vars{Opponent_is_boss} = $tests_run >= $Boss_monster_threshold ? 'yes' : '';

    $Vars{Was_successful} = $was_successful ? 'yes' : '';

    if ($Vars{'Player.status'} eq 'Elmer Fudd syndrome') {
        $Vars{Opponent} = "that rascally rabbit";
    } else {
        $Vars{Opponent} =
              $tests_run < $Boss_monster_threshold ? "the " . one_of('Monster')
            : $was_successful                      ? one_of('Boss_monster')
            :                                        one_of('Dangerous_boss_monster');
    }

    $Vars{Tests_run} = $tests_run;

    my $output;
    if ($was_successful) {
        $Vars{'Player.mood'} = min($Vars{'Player.mood'} + 1, $#{ dictionary('Mood') });
        $output .= $self->_give_experience_and_loot($tests_run);
    } else {
        $Vars{'Player.mood'} = max($Vars{'Player.mood'} - 1, 0);
        $output .= $self->_miss($tests_run);
    }

    $Vars{Player_mood} = $self->mood_string();

    if ($Vars{'Player.hp'} < 15) {
        $output .= $self->_heal();
    }

    $output = $self->_check_for_achievements($output);

    if ($Vars{'Player.status'} eq 'Elmer Fudd syndrome') {
      $output = elmer_fudd_ize($output);
    }

    $output .= $self->_status();

    $self->_save_state();

    return $output;
}

sub expand_string
{
    my ($self, $output) = @_;
    return singular(expand($output));
}

sub test_string
{
    my ($self, $test_string) = @_;
    $self->_clear_dictionaries();
    $Vars{'Player'} = $ENV{USER};
    $Vars{'Player.experience'} = 0;
    $Vars{'Player.class'} = 'programmer';
    $Vars{'Player.dob'} = '1970-01-01';
    $Vars{'Player.location'} = one_of('Location');
    $Vars{'Player.status'} = '';
    $Vars{'Player.hp'} = 100;
    $Vars{'Player.mood'} = 3;
    $Vars{'Player.gold'} = 0;
    $Vars{'Player.bottle_caps'} = 1;
    $Vars{'Player.name'} = $ENV{USER};
    $Vars{Player_level}  = __PACKAGE__->level();
    $Vars{Player_sign} = __PACKAGE__->sign();
    $Vars{Player_blood_type} = __PACKAGE__->_blood_type();
    $Vars{Player_alignment} = __PACKAGE__->_alignment();
    $Vars{Player_occupation} = __PACKAGE__->occupation();
    $Vars{Loot} = one_of('Loot');

    $Vars{Was_successful} = _rand(0,1);
    $Vars{Opponent} = one_of('Boss_monster');

    return $self->expand_string($test_string);
}

sub _clear_dictionaries
{
    my ($self) = @_;
    %Dictionaries = ();
}

sub _heal
{
    my ($self) = @_;
    return singular(one_of('Healing')) . "\n";
}

sub _user_doesnt_get_it
{
    my ($self) = @_;
    ($ENV{'USER_CHILDHOOD'} || '') eq 'spent_outdoors';
}

sub level
{
    my ($self) = @_;
    for my $level (@{ dictionary('Class')->{$Vars{'Player.class'}} }) {
        my ($xp, $level_name) = @$level;
        return $level_name if ($Vars{'Player.experience'} < $xp);
    }
    return dictionary('Class')->{$Vars{'Player.class'}}[-1][1];
}

sub _experience_file { my ($self) = @_; "$ENV{HOME}/.experience" }

sub _load_state
{
    my ($self) = @_;
    my $state;
    eval { $state = from_json(read_file_contents($self->_experience_file())) };
    return unless $state;

    $state->{class} = 'programmer' unless exists dictionary('Class')->{ $state->{class}||'' };

    $Vars{"Player.$_"} = $state->{$_} for keys %$state;
}

sub _save_state
{
    my ($self) = @_;
    my %state = map { $_ =~ /^Player\.(.*)$/ ? ($1 => singular(__variable($_))) : () }
        (keys %Vars, keys %Local_vars);
    $state{comment} = "Don't steal experience points.";

    eval { write_file_contents($self->_experience_file(), to_json(\%state, {pretty => 2})) };
}

sub write_file_contents
{
    my ($path, $content) = @_;
    open(my $fh, '>:utf8', $path) or die $!;
    print $fh $content;
    close($fh) or die $!;
}
sub read_file_contents
{
    my ($path) = @_;
    open(my $fh, '<:encoding(utf8)', $path) or die $!;
    my $content = do { local $/; <$fh> };
    close($fh) or die $!;
    return $content;
}


sub _miss
{
    my ($self, $tests_run) = @_;
    $Vars{Loot} = one_of('Loot');
    return singular(one_of('FAIL'));
}

our @Achievements = (
    { name => 'Page Turner', badge => "\x{205e}", description => "Get more than 50 lines of output from a single game.pl run.", action => sub { my $output = shift();
        my @lines = split /\n/m, $output;

        return @lines > 50;
    } },

    { name => 'Winning Streak', badge => "\x{2654}", description => "Win five boss battles in a row without any boss defeats.", action => sub { my $output = shift();
        if ($Vars{Opponent_is_boss}) {
            if ($Vars{Was_successful}) {
                $Vars{'Player.boss_winning_streak'} = ($Vars{'Player.boss_winning_streak'} || 0)+1;
                return $Vars{'Player.boss_winning_streak'} >= 5;
            }
        } else {
            $Vars{'Player.boss_winning_streak'} = 0;
            return '';
        }
    } },

    { name => 'Epic Fail', badge => "\x{2639}", description => "Lose 20 battles in a row.", action => sub { my $output = shift();
        unless ($Vars{Was_successful}) {
            $Vars{'Player.losing_streak'} = ($Vars{'Player.losing_streak'} || 0)+1;
            return $Vars{'Player.losing_streak'} >= 20;
        }
        else {
            $Vars{'Player.losing_streak'} = 0;
            return '';
        }
    } },

    { name => 'Head of the Class', badge => "\x{fdf2}", description => "Achieve the highest rank for your player class.", action => sub { my $output = shift();
        return $Vars{'Player_level'} eq dictionary('Class')->{$Vars{'Player.class'}}[-1][1];
    } },

    { name => 'Self-Made Man', badge => "\x{2692}", description => "Defeat ten opponents without consulting PROTIPs.", action => sub { my $output = shift();
        if ($Vars{Was_successful}) {
            $Vars{'Player.protip_free_winning_streak'} = ($Vars{'Player.protip_free_winning_streak'} || 0)+1;
        }

        $Vars{'Player.protip_free_winning_streak'} = 0 if $output =~ '^PROTIP:';

        return ($Vars{'Player.protip_free_winning_streak'} || 0) >= 10;
    } },

    { name => 'Undead', badge => "\x{26b1}", description => "Obtain zero or negative hit points.", action => sub { my $output = shift();
        return $Vars{'Player.hp'} <= 0;
    } },

    { name => 'Babby\'s First Kill', badge => "\x{25ce}", description => "Defeat a monster.", action => sub { my $output = shift();
        return $Vars{'Was_successful'};
    } },

    { name => 'On Disability', badge => "\x{267f}", description => "Spend 10 consecutive turns with a status affliction.", action => sub { my $output = shift();
        if ($Vars{'Player.status'}) {
            $Vars{'Player.status_streak'} = ($Vars{'Player.status_streak'} || 0)+1;
        } else {
            $Vars{'Player.status_streak'} = 0;
        }

        return $Vars{'Player.status_streak'} >= 10;

    } },

    { name => 'Big Game Hunter', badge => "\x{2620}", description => "Defeat a boss monster.", action => sub { my $output = shift();
        return $Vars{'Was_successful'} && $Vars{'Opponent_is_boss'};
    } },

    { name => 'Ascend', badge => "@", description => "Bring the Amulet of Yendor to Heaven.", action => sub { my $output = shift();
        if ($Vars{Loot} eq 'Amulet of Yendor') {
            $Vars{'Player.has_amulet'}++;
        }
        return $Vars{'Player.has_amulet'} && $Vars{'Player.location'} eq 'Heaven';
    } },

    { name => 'Traveling with Ingrid', badge => 'R', description => 'Encounter Ingrid Initech in five different locations.', action => sub { my $output = shift();
        if ($Vars{Opponent} =~ /^Ingrid Initech/) {
            $Vars{'Player.travels_with_ingrid'}{$Vars{'Player.location'}} = 1;
        }
        return (scalar keys %{ $Vars{'Player.travels_with_ingrid'} } >= 5);
    } },
);

sub _give_experience_and_loot
{
    my ($self, $tests_run) = @_;
    my $old_level = $self->level();

    my $experience_gain = int(rand() * $tests_run / 4) + 10;
    my $gold_gain = int(rand() * 10 * $tests_run / 4) + 100;

    $Vars{'Player_level'} = $self->level();
    $Vars{'Player_level_changed'} = 'yes' if ($Vars{'Player_level'} ne $old_level);

    $Vars{'Player.experience'} += ($Vars{Player_experience_gain} = $experience_gain);
    $Vars{'Player.gold'} += ($Vars{Player_gold_gain} = $gold_gain);

    my $output = "\n";

    $output .= singular(one_of('WIN'));

    $self->_earn_loot($tests_run, \$output);

    $output .= $self->_roll_for_sidekick();
    $output .= $self->_roll_for_nemesis();

    return $output;
}

sub _earn_loot
{
    my ($self, $tests_run, $output) = @_;
    my $day_of_christmas = $self->_get_day_of_christmas();
    my @earned_loot = $day_of_christmas
        ? n_of($day_of_christmas, 'Loot')
        : n_of(int(rand()*3)+2, 'Loot');

    my $and = $day_of_christmas > 1 ? "And a" : "A";

    for my $loot (@earned_loot) {
        my $loot_count = $day_of_christmas
            ? ( $day_of_christmas == 1 ? $and : $day_of_christmas )
            : int(rand() * 4) + 1;
        $$output .= "    $loot_count "
            . ($loot_count <= 1 ? singular($loot) : plural($loot))
            . ($day_of_christmas == 1 ? " in a ".one_of('Food')." tree" : "")
            . "\n";
        $day_of_christmas-- if $day_of_christmas;
    }
    my $loot_to_describe;
    if ($tests_run >= $Boss_monster_threshold) {
        my $epic_loot = one_of('Epic_loot');
        $$output .= "    !!! " . singular($epic_loot) . "\n";
        $loot_to_describe = $epic_loot;
    } else {
        $loot_to_describe = one_of(\@earned_loot);
    }
    $Vars{Loot} = $loot_to_describe;

    $$output .= $self->_describe_loot($loot_to_describe);
}

sub _get_day_of_christmas
{
    return {
        '11-25' =>  1,
        '11-26' =>  2,
        '11-27' =>  3,
        '11-28' =>  4,
        '11-29' =>  5,
        '11-30' =>  6,
        '11-31' =>  7,
         '0-1'  =>  8,
         '0-2'  =>  9,
         '0-3'  => 10,
         '0-4'  => 11,
         '0-5'  => 12,
    }->{join('-', (localtime())[4, 3])} || 0;
}

sub _roll_for_sidekick
{
    my ($self) = @_;
    if ($Vars{'Opponent_is_boss'} && rand() > 0.8 && !$Vars{'Player.sidekick'}) {
        $Vars{'Player.sidekick'} = singular(one_of('Sidekick'));
        return "\n" . singular(one_of('Sidekick_found')) . "\n";
    } else {
        return "";
    }
}

sub _roll_for_nemesis
{
    my ($self) = @_;
    if (
        $Vars{'Opponent_is_boss'}
        && ! $Vars{'Was_successful'}
        && ! $Vars{'Player.nemesis'}
        && rand() > 0.9
    ) {
        $Vars{'Player.nemesis'} = $Vars{'Opponent'};
        return "\n" . singular(one_of('Nemeis_found')) . "\n";
    } else {
        return "";
    }
}

sub _describe_loot
{
    my ($self, $loot) = @_;
    return "\n" . singular(one_of('Loot_description')) . "\n";
}

sub _check_for_achievements
{
    my ($self, $output) = @_;
    my %earned_achievements = map { chr($_) => 1 } unpack("U*", $Vars{'Player.achievements'} || '');

    for my $achievement (@Achievements) {
        next if ($earned_achievements{$achievement->{badge}});

        if ($achievement->{action}->($output)) {
            $output .= "\nACHIEVEMENT GET!! $achievement->{badge} $achievement->{name}\n\t$achievement->{description}\n\n";
            $Vars{"Player.achievements"} .= $achievement->{badge};
        }
    }

    return $output;
}
sub occupation
{
    my ($self) = @_;
    return singular(one_of('Occupation'));

}
sub _simple_hash
{
    my ($self) = @_;
    my ($year, $month, $day);
    ($year, $month, $day) = $Vars{'Player.dob'} =~ m{\A(\d{4})-(\d\d)-(\d\d)\z}
        ? ($1, $2, $3)
        : qw(1970 1 1)
        ;
    s{\A0+}{} for ($year, $month, $day);
    
    sum(map { $_ - ord('a') } unpack("c*", lc($Vars{'Player.name'} . $Vars{'Player.class'})))
        + ($day << 26)
        + ($month << 22)
        + (($year % 100) << 15);
}

sub _alignment
{
    my ($self) = @_;
    my @groups;

    if($self->_user_doesnt_get_it()) {
        @groups = (
            ["left","right","center"],
            ["justified"],
        );
    } else {
        @groups = (
            ["terse","neutral","verbose"],
            ["salty","neutral","peppered"],
        );
    }

    my @alignments =
        map { $_ eq "neutral-neutral" ? "true neutral" : $_ }
        map { $_ eq "center-justified" ? "centered" : $_ }
        map { join('-', @{$_}) }
        (cross_join(@groups));

    return $alignments[($self->_simple_hash()) % @alignments];
}

sub cross_join
{
    my ($i, $j) = @_;
    my @results = [];

    for ($j, $i) {
        @results = map { my $x = $_; map { [ $x, @$_ ] } @results } @$_;
    }

    return @results;
}

sub _blood_type
{
    my ($self) = @_;
    my @types = map { $_->[0] . $_->[1] } (cross_join(
        ['B','A','AB','O','C',"\x{3a9}"],
        ['-','+', '++', '\'', '!','#', '*'],
    ));
    return $types[$self->_simple_hash() % @types];
}

sub random_element
{
    my (@list) = @_;
    return((shuffle(@list))[0]);
}

sub _lucky_numbers
{
    my ($self) = @_;
    my @numbers = shuffle(1..30);
    return "\n\n * * * * YOUR LUCKY NUMBERS FOR TODAY * * * *\n\n " .
        join('  ', splice(@numbers, 0, 6)) . "\n\n";
}

sub _status
{
    my ($self) = @_;
    if (int(rand(100)) == ($self->_simple_hash() % 100)
            && $Vars{Was_successful}) {
        return $self->_lucky_numbers();
    }
    $Vars{Player_is_mazed} = $self->is_mazed();

    my $s;
    if ($Vars{Player_is_mazed}) {
        $s .= $self->crawl_maze()."\n";
    }
    $s .= singular(one_of('STATUS'));
    return $s;
}

sub Roman
{
    my ($arg) = @_;
    my %roman_digit = qw(1 IV 10 XL 100 CD 1000 MMMMMM);
    my @figure = reverse sort keys %roman_digit;
    $roman_digit{$_} = [split(//, $roman_digit{$_}, 2)] foreach @figure;

    0 < $arg and $arg < 4000 or return undef;
    my($x, $roman);
    foreach (@figure) {
        my($digit, $i, $v) = (int($arg / $_), @{$roman_digit{$_}});
        if (1 <= $digit and $digit <= 3) {
            $roman .= $i x $digit;
        } elsif ($digit == 4) {
            $roman .= "$i$v";
        } elsif ($digit == 5) {
            $roman .= $v;
        } elsif (6 <= $digit and $digit <= 8) {
            $roman .= $v . $i x ($digit - 5);
        } elsif ($digit == 9) {
            $roman .= "$i$x";
        }
        $arg -= $digit * $_;
        $x = $i;
    }
    $roman;
}

sub elmer_fudd_ize
{
    my ($s) = @_;
    $s =~ s/r\B/w/g;
    $s =~ s/R\B/W/g;
    $s =~ s/th\B/d/g;
    $s =~ s/T[hH]\B/D/g;
    return $s;
}

sub crawl_maze
{
    my ($self) = @_;
    return unless $Vars{Player_is_mazed};
    my $pkg = $Vars{'Player.location'};
    unless (-d $self->_get_dir_from_pkg($pkg)) {
       return one_of('Exit_maze');
    }
    my %exits = $self->_get_exits($pkg);
    unless (%exits) {
       return one_of('Exit_maze');
    }

    my $chosen_exit = random_element(keys %exits);
    $Vars{'Player.location'} = $chosen_exit;
    $Vars{Maze_direction} = $exits{$chosen_exit};
    return one_of('Crawl_maze');
}

sub is_mazed
{
    my ($self) = @_;
    return $Vars{'Player.location'} =~ m/^INT($|::)/;
}

sub _get_exits
{
    my ($self, $pkg) = @_;
    (map { ( $_ => "north" ) } $self->_get_north_packages($pkg)),
    (map { ( $_ => "south" ) } $self->_get_south_packages($pkg)),
    (map { ( $_ => "east" ) } $self->_get_east_packages($pkg)),
    (map { ( $_ => "west" ) } $self->_get_west_packages($pkg)),
}

sub _set_perl_lib_base
{
    my ($self) = @_;
    my $pkg = "List::Util";
    $pkg =~ s|::|/|g;
    $pkg .= ".pm";

    foreach my $i (@INC) {
        if (-f "$i/$pkg") {
            $perl_lib_base = realpath($i);
            return;
        }
    }
}

sub _get_pkg_from_file
{
    my ($self, $filename) = @_;
    my $pkg = $filename;
    my $base = $perl_lib_base;
    $pkg =~ s|^\Q$base/\E||;
    $pkg =~ s|/|::|g;
    $pkg =~ s|\.pm$||g;
    return $pkg;
}

sub _get_file_from_pkg
{
    my ($self, $pkg) = @_;
    my $filename = $pkg;
    $filename =~ s|::|/|g;
    return "$perl_lib_base/$filename.pm";
}

sub _get_dir_from_pkg
{
    my ($self, $pkg) = @_;
    return dirname($self->_get_file_from_pkg($pkg));
}

sub _get_north_packages
{
    my ($self, $pkg) = @_;
    my $dir = $self->_get_dir_from_pkg($pkg);
    while (length($dir) > length($perl_lib_base)) {
        $dir = dirname($dir);
        my @candidates = <$dir/*.pm>;
        return map { $self->_get_pkg_from_file($_) } @candidates if @candidates;
    }
    return ();
}

sub _get_south_packages
{
    my ($self, $pkg) = @_;
    my @south_paths = ($self->_get_dir_from_pkg($pkg));
    my $max_depth = 4;
    do {
        @south_paths = grep { -d $_ } ( map { <$_/*> } @south_paths );
        return () unless @south_paths;
        my @candidates = map { <$_/*.pm> } @south_paths;
        return map { $self->_get_pkg_from_file($_) } @candidates if @candidates;
        $max_depth--;
    } while $max_depth;
}

sub _get_east_packages
{
    my ($self, $pkg) = @_;
    my $dir = $self->_get_dir_from_pkg($pkg);
    my $pkg_base = basename($self->_get_file_from_pkg($pkg));
    my @east_files = grep { basename($_) lt $pkg_base } <$dir/*.pm>;
    return map { $self->_get_pkg_from_file($_) } @east_files;
}


sub _get_west_packages
{
    my ($self, $pkg) = @_;
    my $dir = $self->_get_dir_from_pkg($pkg);
    my $pkg_base = basename($self->_get_file_from_pkg($pkg));
    my @east_files = grep { basename($_) gt $pkg_base } <$dir/*.pm>;
    return map { $self->_get_pkg_from_file($_) } @east_files;
}


1;
