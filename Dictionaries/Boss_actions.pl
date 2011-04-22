{
    'The Forgetful Functor' => { lose =>sub {
        my ($self,$num_tests)=@_;
        if ($num_tests < 2*$Boss_monster_threshold) {
            $Vars{'Player.gold'} = 0;
            return qq{\nThe Forgetful Functor detonates a Logic Bomb! In the confusion, you think, "<Paradox>"
You also forget where you put your pouch of gold.};

        } else {
            return qq{\nThe Forgetful Functor forgot your birthday, AGAIN. Don't take it personally.};
        };
    }},
    'The King of All Cosmos' => { lose => sub {
        return 'The King of All Cosmos scratches, "' . singular(one_of([
            'My, Earth really is full of things!',
            'My, Unicode really is full of things!',
            "This sky is not pretty at all. It's rough and masculine. Possibly sweaty.",
            "We broke it. Yes, we were naughty. Completely naughty. So, so very sorry. But just between you and us, it felt quite good.",
            "Dzien' dobry! Have you been to Poland? We go there often.",
        ])) . '"';
    }},
    'Pit-Pat' => { lose => sub {
        return 'Pit-Pat floats in from the side of the screen and sings, "Take it from me--I love you!"';
    }},
    'Michael Scott' => { lose => sub {
        return singular(one_of([
            'Michael Scott distracts you with an anecdote about his admiration for <Monster> culture.',
            'Michael Scott makes an inappropriate offhand remark about your <Appearance>.',
            'Michael Scott makes a politically incorrect generalization about <Monster>s.',
            'Michael Scott attempts to mimic a suave hand gesture he saw in "<Movie>".',
            'Michael Scott distracts you with a bad impression of <Comedian>.',
            'Michael Scott emphasizes his point with a bad impression of <Bond>.',
            'Michael Scott inadvertently reveals an uncomfortable detail about his private life.',
            'Michael Scott flashes a grin at the camera.',
            'Michael Scott mentions the time he burned his <Body_part> on his <Epic_loot>.',
            'Michael Scott interjects, "That\'s what SHE said!"',
        ]));
    }},
    'Grandpa' => {
        lose => sub {return singular(one_of([
            '<Fable>',
            "<Fable>\n<Fable>\n<Fable>",
        ]))},
    },
    'Paul McCartney' => {
        win => sub {
            return singular(one_of([
                'You dip your copy of Abbey Road in water and the apple turns red!',
                'John Lennon sings, "I buried Paul"!',
            ]));
        },
    },
    'The Kwisatz Haderach' => {
        lose => sub {
            return singular(one_of([
                "You shout into the weirding module!\nThe Kwisatz Haderach does not consider the movie canon!",
            ]));
        },
    },
    'Dean Wormer' => {
        lose => sub {
            return singular(one_of([
                'Dean Wormer muses, "The time has come for someone to put his <Body_part> down. And that <$0> is me."',
                '[$Player.status=double-secret <Status>]Dean Wormer places you on <$Player.status>!',
            ]));
        },
        win => sub {
            return singular(one_of([
                'You seduce Dean Wormer\'s wife!',
                'You leave a dead horse in Dean Wormer\'s office!',
            ]));
        }
    },
    'SQLBuilder' => { lose => sub {
        return singular(one_of([
            "None of the requested fields were found in my source tables. I don't know where to start my plan:",
        ]));
    }},
    'George Lucas' => {
        lose => sub {
            return singular(one_of([
                'George Lucas diverts your attention by showing you his new Special Edition of <Movie> with digitally-inserted <Monster>s.',
                'George Lucas diverts your attention by showing you his new Special Edition of <Movie> in which <Boss_monster> shoots first.',
                'George Lucas diverts your attention by showing you his new Special Edition of <Movie> with all the <Loot>s digitally replaced with walkie-talkies.',
                'George Lucas rambles about his desire to return to making experimental films.',
                'George Lucas vetoes your motion to filibuster the Galactic Senate using an arcane parlimentary tactic.',
                'You watch the Star Wars Holiday Special!',
            ]));
        },
    },
    'Pavel Goberman' => {
        lose => sub {
            return singular(one_of([
                'Pavel Goberman hands you an incomprehensible campaign flyer!',
                'You vote for Pavel Goberman on purpose!',
                'You inadvertently vote for Pavel Goberman!',
            ]));
        },
    },
    'Keyboard Cat' => {
        lose => sub {
            return singular(one_of([
                'Keyboard Cat plays you off!',
            ]));
        },
    },
    'Chicken Little' => {
        lose => sub {
            'The sky falls on you!',
        },
        win => sub {
            'Chicken Little screams, "The sky is falling!" and runs away!',
        },
    },
    'WOPR' => {
        win => sub {
            return singular(one_of([
                'An interesting game. The only winning move is not to play.',
            ]));
        },
        lose => sub {
            return 'WOPR asks if you would like to play a game of chess instead.';
        },
    },
    'Nelson' => { lose => sub {
        return 'Nelson points and says, "Ha-haw!"';
    }},
    'Gustavo' => { lose => sub {
        return 'COOKIE!';
    }},
    'Cookie Monster' => { lose => sub {
        return 'OM NOM NOM NOM';
    }},
    'Tony Wonder' => {
        lose => sub {
            return singular(one_of([
                'Tony Wonder distracts you by pulling a piece of <Food> out of his <Body_part>.',
                'All of a sudden, Tony Wonder appears out of nowhere! Right in front of the dumb waiter!',
                'Tony Wonder erupts from the giant loaf of bread!',
            ]));
        },
        win => sub {
            return singular(one_of([
                'You make the cover of POOF!',
            ]));
        },
    },
    'Shredder' => {
        lose => sub {
            return singular(one_of([
                qq{"Hey!" you shout.  "<&Monster>s have the right of way!"
Shredder throws open the door of the <.Vehicle> and yells, "<&\$0>s yes.  <&Monster>s no!"}
            ]));
        },
    },
    'Cluny the Scourge' => {
        win => sub {
            return singular(one_of([
                'A bell falls on Cluny the Scourge!',
            ]));
        }
    },
    'Duffman' => { lose => sub {
        return 'Duffman is thrusting in the direction of your <Loot>!',
    }},
    'Ceiling Cat' => { lose => sub {
        return singular(one_of([
            'Ceiling Cat is watching you <Policy_violation>.',
        ]));
    }},
    'McBain' => { lose => sub {
        return singular(one_of([
            'McBain says, "You know how men alway leave ze toilet seat up vhen vomen vant it to go down? ... Zat is ze joke."',
            'McBain says, "Zat is some outfit, <$Player>. It makes you look like a <Monster>."',
            'McBain says, "Up and at zem!"',
            'McBain says, "I am under attack by Commie Nazis."',
        ]));
    }},
    Q => {
        lose => sub {
            return singular(one_of([
                'Q transforms your bridge crew into a mariachi band!',
                'Q brings the <$Player.race> race to the attention of the <Alien_race>s!',
            ]));
        },
        win => sub {
            return singular(one_of([
                "You tell Q, 'What Hamlet said with irony I say with conviction. 'What a piece of work is man! How noble in reason! How infinite in faculty. In form, in moving, how express and admirable. In action, how like an angel. In apprehension, how like a god!'",
            ]));
        }
    },
    'The DEVASTATOR' => { lose => sub {
        return singular(one_of([
            'The DEVASTATOR shatters your soul!',
        ]));
    }},
    'Abe Froman' => {
        lose => sub {
            return singular(one_of([
                'Abe Froman makes you into a sausage!',
            ]));
        }, win => sub {
            return singular(one_of([
                'You impersonate Abe Froman and steal his lunch reservation!',
            ]));
        }
    },
    'The PA System' => {
        lose => sub {
            return singular(one_of([
                'The PA System broadcasts, "May I have your attention please, may I have your attention please. <Announcement>"',
            ]));
        },
        win => sub {
            return singular(one_of([
                'The speaker nearest your desk shorts out!',
                'A kind soul accidentally the speaker nearest your desk.',
            ]));
        },
    },
    'Doc Brown' => {
        lose => sub {
            return singular(one_of([
                'Doc Brown yells "Great Scott!!"',
                'Doc Brown says "You\'re not thinking fourth dimensionally, <$Player>!',
                '[$Cue_roger_daltrey=yes]Doc Brown puts on his sunglasses and says "Roads? Where we\'re going, we don\'t need roads."',
                'Doc Brown explains how the space-time continuum works using a chalk board and some colorful technobabble.',
                'Doc Brown roots through your garbage, finds a <Loot>, and tosses it into the time machine\'s fusion reactor.',
            ]));
        },
        win => sub {
            return singular(one_of([
                'It\'s the Libyans!',
            ]));
        },
    },
    'Biff Tannen' => {
        lose => sub {
            return singular(one_of([
                'Biff Tannen yells, "<Zinger>!"',
                'Biff Tannen calls you a chicken!',
                'Biff Tannen steals your <$Loot> and uses it to win <100000-1000000> gold pieces at the track.',
            ]));
        },
        win => sub {
            return singular(one_of([
                'You maneuver Biff Tannen into crashing into a manure truck!',
            ]));
        },
    },
    Zolan => {
        lose => sub {
            return singular(one_of([
                'Zolan unnerves you with a comment he makes in IRC!',
                'Zolan invites you to stroke his kangaroo scrotum!',
            ]));
        },
        win => sub {
            return singular(one_of([
                'You sneak up on Zolan while he is caught up in maintaining <OS>!',
                'You convince Amir to transfer Zolan back to sysadmin duty!',
            ]));
        },
    },
    'Candlejack' => { lose => sub {
        return singular(one_of([
            "You shout, \"Hands off my candle, Jack!\" as you swing yo\n",
            "\"We're going to need more rope!\" Candlejack muses as h\n",
            "<&Death_blow>\nCandlejack is ki\n",
        ]));
    }},
    'The Scoutmaster' => { lose => sub {
        return singular(one_of([
            'The Scoutmaster shouts, "Go get \'em, scouts!"',
            'The Scoutmaster shouts, "Don\'t be afraid to use your nails, boys!"',
        ]));
    }},
    'Earl Grey' => { lose => sub {
        return singular(one_of([
            'Earl Grey dries and roasts your leaves!',
            'Earl Grey soaks you in bergamot oil!',
        ]));
    }},
    'The Oracle' => { lose => sub {
        return singular(one_of([
            'The Oracle peers into your future and declares, "<Eight_ball>".',
        ]));
    }},
    'Lumpawarrump' => {
        lose => sub {
            return singular(one_of([
                'Lumpy annoys you with his toy X-Wing!',
            ]));
        },
        win => sub {
            return singular(one_of([
                'You push Lumpy off the edge of the tree house!',
                'You rip the head off of Lumpy\'s toy bantha!',
            ]));
        }
    },
    'Attichitcuk' => {
        lose => sub {
            return singular(one_of([
                'Itchy takes your <$Loot> and pushes you off of the tree house.',
                'Itchy sits in his projection chair and watches your WOW.',
            ]));
        },
    },
    'The A.C.K.' => {
        lose => sub {
            return singular(one_of([
                'The A.C.K. asks you to set up a new <Feature> feature for <Essentials>.',
            ]));
        },
    },
    'The Owl Really' => {
        lose => sub {
            return singular(one_of([
                "[target=<Legendary_warrior>]You try to distract <\$Opponent> with a false rumor:\n  <Rumor>(\$target)\n<\$Opponent> hoots: O RLY? Unfortunately, you are unable to think of a witty comeback.",
            ]));
        },
        win => sub {
            return singular(one_of([
                "You distract <\$Opponent> with a story:\n<Fable>\n<\$Opponent> hoots: \"O RLY?\" Unabashed, you retort: \"YA RLY.\" <\$Opponent> is flabbergasted.",
            ]));
        },
    },
};

