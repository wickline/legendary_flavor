({
    'C-3PO' => sub {
        return 'C-3PO complains, "' . singular(one_of([
            'Sir! The chances of us surviving an encounter with <$Opponent> are <100-10000000> to one!',
            'I\'ve got a bad feeling about this.',
            'I believe what <$Opponent> is trying to say is, \'<Rant>\'',
        ])) . '"';
    },
    'R2-D2' => sub {
        return singular(one_of([
            'R2 says, "<R2_speech>."',
            'R2 exclaims, "<R2_speech>!"',
            'R2 interfaces with <$Opponent>\'s <Loot>.',
        ]));
    },
    'Dirk Calloway' => sub {
        return singular(one_of([
            '"Dirk, take dictation," you speak. "Potential members for <Club>: <Boss_monster>, <Sidekick>, <Legendary_warrior>, <$Opponent>. . ."',
            'You say, "<$Opponent>, this is Dirk Calloway, my chapel partner."',
            '"I know about you and the <Relationship>", Dirk tells <$Opponent>.
"Does <$Player> know?"
"No," Dirk answers, "and I don\'t want him to know. I just want it to stop."',
        ]));
    },
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
            'Turn the page, <Policy_compliance>. Turn the page, <$0>. And then you turn the page, and then you <$0>.',
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
        my $opponent = singular(one_of(['<*$Opponent>']));
        $opponent =~ s/^.*\s(\w+)$/$1/;
        if ($opponent =~ /r$/) {
            return qq{Fozzie quips, "$opponent? I don't even know 'er! Wokka wokka wokka!"};
        } elsif ($opponent =~ /m$/) {
            return qq{Fozzie quips, "$opponent? I don't even know 'em! Wokka wokka wokka!"};
        } elsif ($opponent =~ /[aeiouy]s$/) {
            return qq{Fozzie quips, "$opponent? I don't even know us! Wokka wokka wokka!"};
        } elsif ($opponent =~ /(oo|u)$/) {
            return qq{Fozzie quips, "$opponent? I don't even know you! Wokka wokka wokka!"};
        } elsif ($opponent =~ /(ee|[bcdfghjklmnpqrstvwxz]y|i)$/) {
            return qq{Fozzie quips, "$opponent? I don't even know ye! Wokka wokka wokka!"};
        } else {
            return qq{Fozzie quips, "Wokka wokka wokka!"};
        }
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
