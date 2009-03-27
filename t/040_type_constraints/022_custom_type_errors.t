#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 10;
use Test::Exception;

{
    package Animal;
    use Moose;

    BEGIN {
        ::use_ok("Moose::Util::TypeConstraints");
    }

    subtype 'Natural' => as 'Int' => where { $_ > 0 } =>
        message {"This number ($_) is not a positive integer!"};

    subtype 'NaturalLessThanTen' => as 'Natural' => where { $_ < 10 } =>
        message {"This number ($_) is not less than ten!"};

    has leg_count => (
        is      => 'rw',
        isa     => 'NaturalLessThanTen',
        lazy    => 1,
        default => 0,
    );
}

lives_ok { my $goat = Animal->new( leg_count => 4 ) }
'... no errors thrown, value is good';
lives_ok { my $spider = Animal->new( leg_count => 8 ) }
'... no errors thrown, value is good';

throws_ok { my $fern = Animal->new( leg_count => 0 ) }
qr/This number \(0\) is not less than ten!/,
    "gave custom supertype error message on new";

throws_ok { my $centipede = Animal->new( leg_count => 30 ) }
qr/This number \(30\) is not less than ten!/,
    "gave custom subtype error message on new";

my $chimera;
lives_ok { $chimera = Animal->new( leg_count => 4 ) }
'... no errors thrown, value is good';

throws_ok { $chimera->leg_count(0) }
qr/This number \(0\) is not less than ten!/,
    "gave custom supertype error message on set_value";

throws_ok { $chimera->leg_count(16) }
qr/This number \(16\) is not less than ten!/,
    "gave custom subtype error message on set_value";

my $gimp;
lives_ok { my $gimp = Animal->new() } '... no errors thrown, value is good';
throws_ok { $gimp->leg_count }
qr/This number \(0\) is not less than ten!/,
    "gave custom supertype error message on set_value";

