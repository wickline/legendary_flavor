({
    'Tails' => sub {
        return singular(one_of([
            'Tails falls off the edge of the screen.',
            'Tails bumbles into some spikes.',
            'Tails bumbles into a <Monster>.',
            'Your little <Relationship> takes control of Tails and sends him bumbling into a <Monster>.',
        ]));
    },
    Smithers => sub {
        return singular(one_of([
            '"Smithers, <Policy_violation> for me," you demand.
"Excellent idea, sir!"',
            '"Smithers, <Verb> my <Body_part>," you demand.
"With pleasure, sir!"',
            'You ask, "Smithers, who was that <Animal>?"
"Sir, that was <$Opponent>, one of your <Loot>s from <Initech_affiliate>."',
        ]));
    },
    'John Freeman' => sub {
        return singular(one_of([
            'John Freeman ramped off the building and did a backflip and landed',
            'John Freeman said "<$Opponent>s leave this place"',
            'John freeman said "Thanks i could help bro" and you said "you should come here earlier next time" and you laughed',
        ]));
    },
    Filburt => sub {
        return 'Filburt moans, "' . singular(one_of([
            'Turn the page, wash your hands. Turn the page, wash your hands. And then you turn the page, and then you wash your hands.',
            "I'm nauseous, I'm nauseous, I'm nauseous...",
        ])) . '"';
    },
    Pokey => sub {
        return singular(one_of([
            'Pokey apologizes profusely!',
            'Pokey smiles insincerely!',
            'Pokey complains to you!',
            'Pokey pretends to cry!',
            'Pokey hides behind you!',
            'Pokey uses you as a shield!',
            'Pokey thinks to himself!',
        ]));
    },
    'Fozzie Bear' => sub {
        return singular(one_of([
            'Wokka wokka wokka!',
        ]));
    },
    Chewbacca => sub {
        return singular(one_of([
            'Chewie fires his bowcaster at <$Opponent>!',
            'Chewie grabs <$Opponent> and lifts <It> a foot off the ground!',
            'Chewie pulls <$Opponent>\'s arm out of <Its> socket!',
            'Chewie roars, "[?G+][?r+][?o+][?w+][?f+][?!+]"',
            'Chewie asks, "[?G+][?r+][?o+][?w+][?f+]?"',
            'Chewie puts his arms behind his head and chuckles.',
        ]));
    },
    'Artie, the Strongest Man in the World' => sub {
        return singular(one_of([
            'Artie laughs and proclaims, "I am Artie! *flex* The strongest man... *flex* in the world."',
            'Artie exclaims, "PIPE!"',
        ]));
    },
    'Sebastian' => sub {
        return 'Sebastian leads the ocean creatures in a rendition of "<Song>".';
    },
    'Danny Glover' => sub {
        return 'Danny Glover grumbles, "I\'m getting too old for this shit."',
    },
    'Robin' => sub {
        return 'Robin shouts, "Holy <Loot>s, <$Player>!"',
    },
});
