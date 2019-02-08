use v6.d;

use Test;
use Unicode::GCB;

plan 672;

for $*PROGRAM.sibling('GraphemeBreakTest-11.0.0.txt').lines -> $_ is copy {
    next if /^ '#' /;

    s/ \h+ '#' .+ //;
    s/^ '÷' \h* //;
    s/ \h* '÷' $//;

    my $codes = Uni.new(.comb(/ <xdigit>+ /).map({ :16($_) }));
    is  $_,
        GCB.clusters($codes).map(*.map(*.fmt('%04X')).join(' × ')).join(' ÷ ');
}
