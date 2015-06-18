use v6;
use NativeCall;
use AccessorFacade;

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

        my sub manage(Shout $self, Str $value is copy) {
            explicitly-manage($value);
            $value;
        }

        my sub check(Shout $self, Int $rc ) {

        }

        # "attributes"
        #
        sub shout_set_host(Shout, Str) returns int32 is native('libshout') { * }
        sub shout_get_host(Shout) returns Str is native('libshout') { * }

        method host() returns Str is rw is accessor_facade(&shout_get_host, &shout_set_host, &manage, &check) { }

        sub shout_set_port(Shout, int32) returns int32 is native('libshout') { * }
        sub shout_get_port(Shout) returns int32 is native('libshout') { * }

        method port() returns Int is rw is accessor_facade(&shout_get_port, &shout_set_port, Code, &check) { }

        sub shout_set_user(Shout, Str) returns int32 is native('libshout') { * }
        sub shout_get_user(Shout) returns Str is native('libshout') { * }

        method user() returns Str is rw is accessor_facade(&shout_get_user, &shout_set_user, &manage, &check) { }

        sub shout_set_pass(Shout, Str) returns int32 is native('libshout') { * }
        sub shout_get_pass(Shout) returns Str is native('libshout') { * }

        method pass() returns Str is rw is accessor_facade(&shout_get_pass, &shout_set_pass, &manage, &check) { }

        sub shout_get_protocol(Shout) returns int32 is native('libshout') { * }
        sub shout_set_protocol(Shout, int32) returns int32 is native('libshout') { * }

        method protocol() returns Int is rw is accessor_facade(&shout_get_protocol, &shout_set_protocol, Code, &check) { }

        sub shout_get_format(Shout) returns int32 is native('libshout') { * }
        sub shout_set_format(Shout, int32) returns int32 is native('libshout') { * }

        method format() returns Int is rw is accessor_facade(&shout_get_format, &shout_set_format, Code, &check) { }

        sub shout_get_mount(Shout) returns int32 is native('libshout') { * }
        sub shout_set_mount(Shout, Str) returns int32 is native('libshout') { * }

        method mount() returns Str is rw is accessor_facade(&shout_get_mount, &shout_set_mount, &manage, &check) { }

        sub shout_get_dumpfile(Shout) returns Str is native('libshout') { * }
        sub shout_set_dumpfile(Shout, Str ) returns int32 is native('klibshout') { * }

        method dumpfile() returns Str is rw is accessor_facade(&shout_get_dumpfile, &shout_set_dumpfile, &manage, &check ) { }

        sub shout_get_agent(Shout) returns Str is native('libshout') { * }
        sub shout_set_agent(Shout, Str) returns int32 is native('libshout') { * }

        method agent() returns Str is rw is accessor_facade(&shout_get_agent, &shout_set_agent, &manage, &check) { }
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
