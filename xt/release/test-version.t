#!/usr/bin/perl
use 5.006;
use strict;
use warnings;
use Test::More;

use Test::Requires {
    'Test::Version' => 1,
    'version'       => 0.86,
};

my @imports = ( 'version_all_ok' );

my $params = {
    is_strict   => 0,
    has_version => 1,
};

push @imports, $params
    if version->parse( $Test::Version::VERSION ) >= version->parse('1.002');


Test::Version->import(@imports);

version_all_ok;
done_testing;
