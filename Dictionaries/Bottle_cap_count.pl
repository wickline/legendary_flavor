[
    sub {
        my $caps = $Vars{'Player.bottle_caps'} || "0";
        my $abs = abs($caps);
        my $s = $abs == 1 ? "" : "s";
        return $caps >= 0 ? "Bottle caps: $caps" : "You owe $abs bottle cap$s";
    }
];
