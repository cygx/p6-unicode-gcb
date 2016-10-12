# Unicode::GCB [![Build Status](https://travis-ci.org/cygx/p6-unicode-gcb.svg?branch=master)](https://travis-ci.org/cygx/p6-unicode-gcb)

An implementation of the Unicode Grapheme Cluster Boundary algorithm

# Synopsis

```
    use Unicode::GCB;

    say GCB.always(0x600, 0x30);
    say GCB.maybe(
        "\c[REGIONAL INDICATOR SYMBOL LETTER G]".ord,
        "\c[REGIONAL INDICATOR SYMBOL LETTER B]".ord);
    say GCB.clusters("äöü".NFD);
```

# Description

TODO


# Bugs and Development

Development happens at [GitHub](https://github.com/cygx/p6-unicode-gcb). If you
found a bug or have a feature request, use the
[issue tracker](https://github.com/cygx/p6-unicode-gcb/issues) over there.


# Copyright and License

Copyright (C) 2016 by <cygx@cpan.org>

Distributed under the
[Boost Software License, Version 1.0](http://www.boost.org/LICENSE_1_0.txt)
