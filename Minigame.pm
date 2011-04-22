package Minigame;

use strict;
use Game;

my @RULES = qw/
 rock  crushes   lizard   eats       paper    disproves
 Spock bends     scissors decapitate lizard   poisons
 Spock vaporizes rock     smashes    scissors cuts
 paper covers    rock
/;

sub draw
{
    my $l = scalar(@RULES);
    my $win_idx = int(rand(($l-1)/2)) * 2;
    return @RULES[$win_idx..($win_idx + 2)];
}

sub play
{
    my ($dictionary_path, $opponent, $tests_tried, $tests_failed) = @_;
    my $game = Game->new($dictionary_path);
    $game->_load_state();
    $Game::Vars{"Player.bottle_caps"} ||= 0;

    my ($win, $verb, $lose) = draw();
    my ($msg, $bottle_caps_won);

    if ($tests_tried == 0) {
        $msg = ucfirst($opponent)." and you shout: \'$win!\' at the same time!";
        $bottle_caps_won = 0;
    } else {
        if ($tests_failed > 0) {
            $msg = ucfirst($opponent)."'s $win $verb your $lose!";
            $bottle_caps_won = -$tests_failed;
        } else {
            $msg = "Your $win $verb ${opponent}'s $lose!";
            $bottle_caps_won = 1;
        }
    }

    my $s = abs($bottle_caps_won == 1) ? "" : "s";
    if ($bottle_caps_won > 0) {
        $msg .= "\nYou win $bottle_caps_won bottle cap$s.";
    } elsif ($bottle_caps_won < 0) {
        $msg .= "\nYou lose ".-$bottle_caps_won." bottle cap$s.";
    }

    $Game::Vars{"Player.bottle_caps"} += $bottle_caps_won;
    $game->_save_state();

    return $msg;
}
