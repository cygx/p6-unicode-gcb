# Copyright 2016 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

unit module Unicode::GCB:ver<0.1.0>;
use nqp;

my constant CODE = nqp::unipropcode('gcb');
my sub prop(\name)  { nqp::unipvalcode(CODE, name)  }
my sub getprop(\cp) { nqp::getuniprop_int(cp, CODE) }

my enum _ (
    Other               => prop('Other'),
    Control             => prop('Control'),
    CR                  => prop('CR'),
    LF                  => prop('LF'),
    L                   => prop('L'),
    V                   => prop('V'),
    T                   => prop('T'),
    LV                  => prop('LV'),
    LVT                 => prop('LVT'),
    Prepend             => prop('Prepend'),
    Extend              => prop('Extend'),
    SpacingMark         => prop('SpacingMark'),
    ZWJ                 => prop('ZWJ'),
    Glue_After_Zwj      => prop('Glue_After_Zwj'),
    E_Base              => prop('E_Base'),
    E_Base_GAZ          => prop('E_Base_GAZ'),
    E_Modifier          => prop('E_Modifier'),
    Regional_Indicator  => prop('Regional_Indicator'),
);

my constant COUNT = +_::;
my constant RANGE = ^COUNT;
my \TABLE = my @[COUNT;COUNT] = (True xx COUNT) xx COUNT;
TABLE[CR;LF] = False;
TABLE[L;$_] = False for L, V, LV, LVT;
TABLE[$_;T] = False for V, T, LV, LVT;
TABLE[$_;V] = False for V, LV;
TABLE[$_;Extend] = False for RANGE;
TABLE[$_;ZWJ] = False for RANGE;
TABLE[$_;SpacingMark] = False for RANGE;
TABLE[Prepend;$_] = False for RANGE;
TABLE[$_;E_Modifier] = False for E_Base, E_Base_GAZ, Extend;
TABLE[ZWJ;$_] for Glue_After_Zwj, E_Base_GAZ;
TABLE[Regional_Indicator;Regional_Indicator] = False;

our sub is-break(uint32 \a, uint32 \b) {
    TABLE[getprop(a);getprop(b)];
}

our sub is-maybe-break(uint32 \a, uint32 \b) {
    my \pa = getprop(a);
    my \pb = getprop(b);
    TABLE[pa;pb] || (pa == Extend && pb == E_Modifier)
                 || (pa == pb == Regional_Indicator);
}

our sub clusters(Uni \uni) {
    return uni if uni.elems < 2;
    my $emoji = False;
    my $ri = False;
    my int $i = 0;
    my int $j = 0;
    gather {
        while ($j = $j + 1) < uni.elems {
            my \pa = getprop(uni[$j-1]);
            my \pb = getprop(uni[$j]);
            if TABLE[pa;pb]
                    || (!$emoji && (pa == Extend && pb == E_Modifier))
                    || ($ri && pa == pb == Regional_Indicator) {
                take Uni.new(uni[$i..^$j]);
                $i = $j;
                $emoji = False;
                $ri = False;
            }
            else {
                $emoji = True if pa == E_Base|E_Base_GAZ;
                $ri = True if pa == pb == Regional_Indicator;
            }
        }
        take Uni.new(uni[$i..^$j]);
    }
}
