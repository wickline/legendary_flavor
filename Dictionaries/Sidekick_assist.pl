[
    sub {
        $Vars{Opponent_action} = dictionary('Sidekick_assists')->{singular($Vars{'Player.sidekick'})}
            ? dictionary('Sidekick_assists')->{singular($Vars{'Player.sidekick'})}($Vars{Tests_run})
            : singular(one_of('Sidekick_generic_assists'));
        return '<&$Opponent_action>';
    }
];
