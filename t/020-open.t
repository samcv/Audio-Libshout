#!perl6
use v6;
use Test;
use lib 'lib';
use CheckSocket;

my $host = %*ENV<SHOUT_TEST_HOST> // 'localhost';
my $port = %*ENV<SHOUT_TEST_PORT> // 8000;
my $user = %*ENV<SHOUT_TEST_USER> // 'source';
my $pass = %*ENV<SHOUT_TEST_PASS> // 'hackme';
my $mount = %*ENV<SHOUT_TEST_MOUNT> // '/shout_test';

plan 1;

if not check-socket($port, $host) {
    diag "not performing live tests as no icecast server";
    skip-rest "no icecast server";
    exit;
}

done;
# vim: expandtab shiftwidth=4 ft=perl6
