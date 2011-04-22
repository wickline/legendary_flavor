[
    sub {
        no warnings 'recursion';
        if ($Vars{Was_successful}) {
            $Vars{Opponent_action} = dictionary('Boss_actions')->{singular($Vars{Opponent})}{win}
                ? dictionary('Boss_actions')->{singular($Vars{Opponent})}{win}($Vars{Tests_run})
                : singular(one_of('Death_blow'));
        } else {
            $Vars{Opponent_action} = dictionary('Boss_actions')->{singular($Vars{Opponent})}{lose}
                ? dictionary('Boss_actions')->{singular($Vars{Opponent})}->{lose}->($Vars{Tests_run})
                : singular(one_of('Distraction'));
        }
        return '<&$Opponent_action>';
    }
];
