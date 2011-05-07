[
    '<$Opponent> runs off with your <$Loot>!',
    '<_MOVE_>You meet <$Opponent> for a quiet drink. You order a <Cocktail>. The next thing you know, you\'re in <$Player.location> and your <$Loot> is missing!',
    '<_WOUND_><_MOVE_><$Opponent> saps you on the head with your <$Loot>. Everything goes dark and you black out. When you come to, you are in <$Player.location>.',
    '<_MOVE_><$Opponent> throws you in the back of <Its> <Vehicle> and takes you to <$Player.location> against your will!',
    '[$Player.sep_sidekick=<$Player.sidekick>][$Player.sidekick=]<_WOUND_><_MOVE_><$Opponent> clocks you over the head with your <$Loot> and takes you to <$Player.location> against your will![Player.sep_sidekick? You get separated from <$Player.sep_sidekick>!:]',
    '[$Player.sep_sidekick=<$Player.sidekick>][$Player.sidekick=]<&Failure>
Meanwhile, the City of Los Angeles buys out your <$Player.sep_sidekick> franchise, which will now be known as the L.A. <$Player.sep_sidekick>s.',
    '<_WOUND_><$Opponent> smacks you right in the <Body_part>!',
    '<$Opponent> "accidentally" strokes your <Body_part> with <Its> <Body_part>!',
    '<_WOUND_><$Opponent> insults your mother whilst kicking dirt in your eye.',
    '<_WOUND_><$Opponent> yells "<Zinger>" and kicks you in the <Body_part>.',
    #'<_WOUND_>[Dice=<2-4>d<Die_size>][Roll=<$$Dice>][Ac=<$Roll> - 1]<$Opponent> rolls <$Dice> against <$Player>\'s AC of <$$Ac> and gets <$Roll>.',
    'You feel guilty and give <$Opponent> back <Its> <$Loot>.',
    '<&Failure>

[<$Player.status == being a zombie>?<Zombie_atmosphere>:<Atmosphere>]',
    '<$Opponent> leaves an origami [Player.dream_monster?<$Player.dream_monster>:unicorn] outside your door just to mess with you.',
    '<&Failure> You haven\'t taken a beating like that since <Event>.',
];
