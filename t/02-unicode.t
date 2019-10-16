use v6.d;

use Test;
use Unicode::GCB;

my @unicode-version-lookup = (
    (v2019.10, ‘GraphemeBreakTest-12.1.0.txt’, 602),
    (      v0, ‘GraphemeBreakTest-11.0.0.txt’, 672),
);

my $test-file;
my $test-count;

for @unicode-version-lookup {
    if $*PERL.compiler.version ≥ .[0] {
        $test-file  = .[1];
        $test-count = .[2];
        last
    }
}

plan $test-count;

for $*PROGRAM.sibling($test-file).lines -> $_ is copy {
    next if /^ '#' /;

    s/ \h+ '#' .+ //;
    s/^ '÷' \h* //;
    s/ \h* '÷' $//;

    my $codes = Uni.new(.comb(/ <xdigit>+ /).map({ :16($_) }));
    is  $_,
        GCB.clusters($codes).map(*.map(*.fmt('%04X')).join(' × ')).join(' ÷ ');
}
