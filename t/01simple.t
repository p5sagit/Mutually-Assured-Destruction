use strict;
use warnings;
use Test::More;
use Scalar::Util qw(weaken);

my %real;
my %weak;

my @names = qw(one two);

my %next_name;

foreach my $idx (-1 .. $#names-1) {
  $next_name{$names[$idx+1]} = $names[$idx];
}

my %last_name = reverse %next_name;

# construct objects

foreach my $name (@names) {
  weaken($weak{$name} = $real{$name} = bless({}, 'Foo'));
}

# setup forward and back pointers

foreach my $name (@names) {
  $real{$name}->{forward} = $real{$next_name{$name}};
  weaken($real{$next_name{$name}->{back} = $real{$name});
}

# weaken last forward pointer

weaken($real{$names[-1]}->{forward});

# to test: undef each one in order
#          undef all but one
#          undef all and verify destruction



@weak{qw(one two)} = @real{qw(one two)} = ({}, {});

weaken($_) for values %weak;

$real{one}->{two} = $real{two};

$real{two}->{one} = $real{one};

delete @real{keys %real};

cmp_ok(
  (scalar grep defined, values %weak), '==', 0,
  'All objects destroyed now'
);

done_testing;
