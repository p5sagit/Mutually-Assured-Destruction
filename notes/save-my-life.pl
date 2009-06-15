#!/usr/bin/env perl

use strict;
use warnings;

my %objs;

BEGIN {
  package Foo;

  sub DESTROY { warn "DESTROY\n"; $objs{$_[0]} = $_[0]; }
}

{
  bless({}, 'Foo');
}

warn join(', ', %objs);
