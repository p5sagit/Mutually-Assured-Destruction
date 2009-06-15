use strict;
use warnings;
use Test::More;
use Scalar::Util qw(weaken);

my %real;
my %weak;

@weak{qw(one two)} = @real{qw(one two)} = ({}, {});

weaken($_) for values %weak;

delete @real{keys %real};

cmp_ok(
  (scalar grep defined, values %weak), '==', 0,
  'All objects destroyed now'
);

done_testing;
