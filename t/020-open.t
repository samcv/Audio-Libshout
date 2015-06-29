#!perl6
use v6;
use Test;
use lib 'lib';
use CheckSocket;

use Audio::Libshout;

my $host = %*ENV<SHOUT_TEST_HOST> // 'localhost';
my $port = %*ENV<SHOUT_TEST_PORT> // 8000;
my $user = %*ENV<SHOUT_TEST_USER> // 'source';
my $pass = %*ENV<SHOUT_TEST_PASS> // 'hackme';
my $mount = %*ENV<SHOUT_TEST_MOUNT> // '/shout_test';

plan 5;

if not check-socket($port, $host) {
    diag "not performing live tests as no icecast server";
    skip-rest "no icecast server";
    exit;
}

my $obj;

lives-ok { $obj = Audio::Libshout.new }, "create an Audio::Libshout object";

lives-ok {
$obj.host = $host;
$obj.port = $port;
$obj.user = $user;
$obj.mount= $mount;
}, "set some mandatory parameters";

throws-like { $obj.open }, X::ShoutError, "open without password should fail";

$obj.password = 'S0me8oGusP455w0RD!%';

throws-like { $obj.open }, rx/"The server refused login, probably because authentication failed"/, "open with wrong password should fail";

$obj.password = $pass;

lives-ok { $obj.open }, "open with good password";

done;

# vim: expandtab shiftwidth=4 ft=perl6
