#!perl -w
no warnings 'recursion';

BEGIN{
    use File::Basename qw/ dirname /;
    unshift @INC, dirname(__FILE__);
}


use strict;

use Getopt::Long;
use File::Basename qw/dirname/;

use Game;
use Minigame;

sub _default_dictionary_path
{
    return dirname(__FILE__) . "/Dictionaries";
}

sub read_file_contents
{
    my ($path) = @_;
    open(my $fh, '<:encoding(utf8)', $path) or die $!;
    do { local $/; <$fh> };
}

use utf8;
utf8::decode($_) for @ARGV;

GetOptions({ argv => \@ARGV },
    'was_successful=s' => \my $was_successful,
    'total_num_tests_executed=s' => \my $total_num_tests_executed,
    'test-string=s' => \my $test_string,
    'dictionary-path=s' => \my $dictionary_path,
    'quiet' => \my $quiet_mode,
    'lint' => \my $lint,
    'megalint' => \my $megalint,
);

$dictionary_path ||= _default_dictionary_path();

our ($test_file) = @ARGV;

if ($test_file) {
    my $test_string = read_file_contents($test_file);
    $test_string =~ s/^#!.*\n//;
    chomp $test_string;
}

if ($lint) {
    opendir my $dh, $dictionary_path
        or die "Could not opendir $dictionary_path: $!";

    my @dicts = grep { /\.pl$/ } readdir($dh);
    my $tests_run = 0;
    my $errors = 0;

    eval { $tests_run++ ; do "$dictionary_path/$_" } or ($errors++, print "$dictionary_path/$_ didn't return a true value\n") for @dicts;

    closedir $dh;
    print "Dictionary in $dictionary_path OK\n" unless $errors;

    my $msg = Minigame::play($dictionary_path, "the lint bug", $tests_run, $errors);
    print $msg."\n";
}
elsif ($megalint) {
    opendir my $dh, $dictionary_path
        or die "Could not opendir $dictionary_path: $!";
    my @dicts = grep { /\.pl$/ } readdir($dh);
    my %bad_perl_dicts;
    my %bad_lines;
    my $tests_run = 0;

    for my $dict (@dicts) {
        # print "    $dict\n";
        my $dictionary;
        eval {
            $tests_run++;
            package Game;
            $dictionary = do "$dictionary_path/$dict";
        };
        if ($@ || ! $dictionary) {
            my $error = $@ ? $@ : "$dict did not return a true value";
            $bad_perl_dicts{$dict} = $error;
            next;
        }

        next unless ref $dictionary && ref $dictionary eq 'ARRAY';

        my $game = Game->new($dictionary_path, $quiet_mode);
        for my $item (@$dictionary) {
            # print "    $dict $item\n";
            $tests_run++;
            eval {
                $game->test_string($item);
            };
            if (my $error = $@) {
                $bad_lines{$dict} ||= {};
                $bad_lines{$dict}->{$item} = $error;
            }
        }
    }

    my $there_were_problems =0;
    for my $bad_perl_dict ( keys %bad_perl_dicts ) {
        $there_were_problems++;
        print "$bad_perl_dict had problems at compile-time:\n\t$bad_perl_dicts{$bad_perl_dict}\n";
    };
    for my $dict_with_problems ( keys %bad_lines ) {
        print "$dict_with_problems had problems:\n";
        for my $problem ( keys %{$bad_lines{$dict_with_problems}} ) {
            $there_were_problems++;
            print "\t$problem\t=>\t$bad_lines{$dict_with_problems}->{$problem}\n";
        }
    }

    print "No problems!\n" unless $there_were_problems;

    my $msg = Minigame::play($dictionary_path, "the megalint bug", $tests_run, $there_were_problems);
    print $msg."\n";
}
elsif ($test_string)
{
    my $game = Game->new($dictionary_path, $quiet_mode);
    print $game->test_string($test_string) . "\n";
}
else {
    my $output = Game->new($dictionary_path, $quiet_mode)->play($was_successful, $total_num_tests_executed);
    if ($ENV{'LANG'} =~ m/latin/i) {
        $output =~ s/u/v/g;
        $output =~ s/U/V/g;
        $output =~ s/(\d+)/${\(Roman($1))}/gi;
    }
    print $output;
}


1;
