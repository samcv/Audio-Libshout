use v6;
use NativeCall;

class Audio::Libshout {
    class Shout is repr('CPointer') {

        sub shout_open(Shout) returns int32 is native('libshout') { * }

        method open() returns Int {
            shout_open(self);
        }

        sub shout_close(Shout) returns int32 is native('libshout') { * }

        method close() returns Int {
            shout_close(self);
        }


        sub shout_set_host(Shout, Str) returns int32 is native('libshout') { * }
        sub shout_get_host(Shout) returns Str is native('libshout') { * }

        method host() is rw {
            Proxy.new(
                FETCH => sub ($) {
                    shout_get_host(self);
                },
                STORE   =>  sub ($, $host is copy ) {
                    explicitly-manage($host);
                    shout_set_host(self, $host);
                }
            );
        }

        sub shout_set_port(Shout, int32) returns int32 is native('libshout') { * }
        sub shout_get_port(Shout) returns int32 is native('libshout') { * }

        method port() returns Int is rw {
            Proxy.new(
                FETCH => sub ($) {
                    shout_get_port(self);
                },
                STORE   =>  sub ($, $port is copy ) {
                    shout_set_port(self, $port);
                }
            );
        }

        sub shout_set_user(Shout, Str) returns int32 is native('libshout') { * }
        sub shout_get_user(Shout) returns Str is native('libshout') { * }

        method user() returns Str is rw {
            Proxy.new(
                FETCH => sub ($) {
                    shout_get_user(self);
                },
                STORE   =>  sub ($, $user is copy ) {
                    explicitly-manage($user);
                    shout_set_user(self, $user);
                }
            );
        }
        sub shout_set_pass(Shout, Str) returns int32 is native('libshout') { * }
        sub shout_get_pass(Shout) returns Str is native('libshout') { * }

        method pass() returns Str is rw {
            Proxy.new(
                FETCH => sub ($) {
                    shout_get_pass(self);
                },
                STORE   =>  sub ($, $pass is copy ) {
                    explicitly-manage($pass);
                    shout_set_pass(self, $pass);
                }
            );
        }
    }

    sub shout_init() is native('libshout') { * }

    sub shout_shutdown() is native('libshout') { * }

    sub shout_new() returns Shout is native('libshout') { * }

    has Shout $!shout handles <host>;

    multi submethod BUILD() {
        shout_init();
        $!shout = shout_new();
    }

    sub shout_free(Shout) returns int32 is native('libshout') { * }
}

# vim: expandtab shiftwidth=4 ft=perl6
