# Copyright 2016, 2018 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

unit module Unicode::GCB:auth<github:cygx>:ver<0.3.0>;
use nqp;

sub gcb_propcode(str $name) {
    nqp::unipvalcode((BEGIN nqp::unipropcode('GCB')), $name);
}

sub gcb_value(int $cp) {
    nqp::getuniprop_int($cp, (BEGIN nqp::unipropcode('GCB')));
}

sub is_pictographic(int $cp) {
    nqp::getuniprop_bool($cp, (BEGIN nqp::unipropcode('Extended_Pictographic')));
}

enum Property (BEGIN {
    my @props =
        Other                 => gcb_propcode('Other'),
        Control               => gcb_propcode('Control'),
        CR                    => gcb_propcode('CR'),
        LF                    => gcb_propcode('LF'),
        L                     => gcb_propcode('L'),
        V                     => gcb_propcode('V'),
        T                     => gcb_propcode('T'),
        LV                    => gcb_propcode('LV'),
        LVT                   => gcb_propcode('LVT'),
        Prepend               => gcb_propcode('Prepend'),
        Extend                => gcb_propcode('Extend'),
        SpacingMark           => gcb_propcode('SpacingMark'),
        ZWJ                   => gcb_propcode('ZWJ'),
        Regional_Indicator    => gcb_propcode('Regional_Indicator'),

        # Unicode 9, obsolete
        Glue_After_Zwj        => my $ = gcb_propcode('Glue_After_Zwj') || -1,
        E_Base                => my $ = gcb_propcode('E_Base')         || -1,
        E_Base_GAZ            => my $ = gcb_propcode('E_Base_GAZ')     || -1,
        E_Modifier            => my $ = gcb_propcode('E_Modifier')     || -1,

        # Unicode 11, not a GCB property value
        Extended_Pictographic => my $ = -1;

    my $i = @props>>.value.max;
    $_ = ++$i if $_ < 0
        for @props>>.value;

    @props;
});

my constant $N = Property::.elems;

sub idx($a, $b) { $a * $N + $b }

sub typeof(int $cp) {
    my constant @MAP = [];
    BEGIN @MAP[$_] = $_ for Property::.values;

    @MAP[gcb_value($cp) || is_pictographic($cp) && Extended_Pictographic];
}

my constant @ALWAYS = (for ^$N -> $a {
    slip (for ^$N -> $b {
        given \($a, $b) {
            when :($ where CR,
                   $ where LF) { False }

            when :($ where Control|CR|LF,
                   $) { True }

            when :($,
                   $ where Control|CR|LF) { True }

            when :($ where L,
                   $ where L|V|LV|LVT) { False }

            when :($ where LV|V,
                   $ where V|T) { False }

            when :($ where LVT|T,
                   $ where T) { False }

            when :($,
                   $ where Extend|ZWJ) { False }

            when :($,
                   $ where SpacingMark) { False }

            when :($ where Prepend,
                   $) { False }

            when :($ where Regional_Indicator,
                   $ where Regional_Indicator) { False }

            # Unicode 9.0

            when :($ where E_Base|E_Base_GAZ|Extend,
                   $ where E_Modifier) { False }

            when :($ where ZWJ,
                   $ where Glue_After_Zwj|E_Base_GAZ) { False }

            # Unicode 11.0

            when :($ where ZWJ,
                   $ where Extended_Pictographic) { False }

            default { True }
        }
    });
});

my constant @MAYBE = [@ALWAYS];
BEGIN given @MAYBE {
    .[idx Regional_Indicator, Regional_Indicator] = True;
    .[idx Extend, E_Modifier] = True;         # Unicode 9.0
    .[idx ZWJ, Extended_Pictographic] = True; # Unicode 11.0
}

my class GCB is export {
    method always(uint32 $a, uint32 $b) {
        @ALWAYS[idx typeof($a), typeof($b)];
    }

    method maybe(uint32 $a, uint32 $b) {
        @MAYBE[idx typeof($a), typeof($b)];
    }

    proto method clusters(|) {*}

    multi method clusters(Uni \uni, :$chars!) {
        self.clusters(uni)>>.map: *.chr;
    }

    multi method clusters(Uni \uni, :$codes!) {
        self.clusters(uni)>>.map: *.Int;
    }

    multi method clusters(Uni \uni, :$props!) {
        self.clusters(uni)>>.map: &typeof;
    }

    multi method clusters(Uni \uni, :$strings!) {
        self.clusters(uni)>>.Str;
    }

    multi method clusters(Uni \uni, :$pairs!) {
        self.clusters(uni).map: {
            .Str => .map(&typeof);
        }
    }

    multi method clusters(Uni \uni where uni.elems < 2) { uni }

    multi method clusters(Uni \uni) {
        my $emoji = False;
        my $regio = False;
        my int $i = 0;
        my int $j = 0;
        gather {
            while ($j = $j + 1) < uni.elems {
                my int $pa = typeof uni[$j-1];
                my int $pb = typeof uni[$j];
                if @ALWAYS[idx $pa, $pb]
                        || (!$emoji && $pa == Extend && $pb == E_Modifier)
                        || (!$emoji && $pa == ZWJ && $pb == Extended_Pictographic)
                        || ( $regio && $pa == $pb == Regional_Indicator) {
                    take Uni.new(uni[$i..^$j]);
                    $i = $j;
                    $emoji = False;
                    $regio = False;
                }
                else {
                    $emoji = True if $pa == E_Base|E_Base_GAZ|Extended_Pictographic;
                    $regio = True if $pa == $pb == Regional_Indicator;
                }
            }
            take Uni.new(uni[$i..^$j]);
        }
    }
}
