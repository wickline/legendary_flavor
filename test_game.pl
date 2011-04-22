#!perl -w

BEGIN{
    use File::Basename qw/ dirname /;
    push @INC, dirname(__FILE__);
}

use strict;
use Cwd;

use Game;

sub get_results
{
    my ($test_string) = @_;
    return Game->new(dirname(__FILE__) . "/Dictionaries")->test_string($test_string);
}
sub assert_game
{
    my ($test_string, $expected_results) = @_;
    my $actual_results = get_results($test_string);
    die <<HERE unless $actual_results eq $expected_results;
Results don't match.  Expected:
$expected_results
Got:
$actual_results
HERE
}

assert_game('foo', 'foo');
assert_game('<Static>',  'print CUMCAT IS DONE to stderr twice');
assert_game('<-Static>', 'print-CUMCAT-IS-DONE-to-stderr-twice');
assert_game('<^Static>',  'Print CUMCAT IS DONE To Stderr Twice');
assert_game('<&Static>',  'Print CUMCAT IS DONE to stderr twice');
assert_game('<.Static>',  'print CUMCAT IS DONE to stderr twice');
assert_game('<!Static>',  'PRINT CUMCAT IS DONE TO STDERR TWICE');
assert_game('<*Static>',  'print CUMCAT IS DONE to stderr twice');
assert_game('<,Static>',  'print_CUMCAT_IS_DONE_to_stderr_twice');
assert_game('<+Static>',  'print+CUMCAT+IS+DONE+to+stderr+twice');
assert_game('<~Static>', 'printCUMCATISDONEtostderrtwice');
assert_game('<=Static>', 'print CUMCAT IS DONE to stderr twice in bed');


print get_results(" scp it <Preposition> your desktop ");

print "all tests pass!\n";
