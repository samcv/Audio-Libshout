use v6;
use NativeCall;
use AccessorFacade;

class Audio::Libshout {

    enum Error ( Success => 0 , Insane => -1 , Noconnect => -2 , Nologin => -3 , Socket => -4 , Malloc => -5, Meta => -6, Connected => -7, Unconnected => -8, Unsupported => -9, Busy => -10 );
    enum Format ( Ogg => 0, MP3 => 1 );
    enum Protocol ( HTTP => 0, XAUDIOCAST => 1, ICY => 2);

    class Metadata is repr('CPointer') {
        sub shout_metadata_add(Metadata, Str, Str ) returns int32 is native('libshout') { * }
    }

    class Shout is repr('CPointer') {

        sub shout_open(Shout) returns int32 is native('libshout') { * }

        method open() returns Int {
            shout_open(self);
        }

        sub shout_close(Shout) returns int32 is native('libshout') { * }

        method close() returns Int {
            shout_close(self);
        }
        
        sub shout_send(Shout, CArray[uint8], int32) returns int32 is native('libshout') { * }

        multi method send(CArray[uint8] $buf) returns int32 {
            shout_send(self, $buf, $buf.elems);
        }

        multi method send(Buf $buf) returns Int {
            my $carray = CArray[uint8].new;
            $carray[$_] = $buf[$_] for ^$buf.elems;
            self.send($carray);
        }

        sub shout_sync(Shout) returns int32 is native('libshout') { * }

        method sync() {
            shout_sync(self);
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

        # Directory parameters
        sub shout_get_public(Shout) returns int32 is native('libshout') { * }
        sub shout_set_public(Shout, int32) returns int32 is native('libshout') { * }

        method public returns Int is rw is accessor_facade(&shout_get_public, &shout_set_public, Code, &check) { }

        sub shout_get_name(Shout) returns Str is native('libshout') { * }
        sub shout_set_name(Shout, Str) returns int32 is native('libshout') { * }

        method name() returns Str is rw is accessor_facade(&shout_get_name, &shout_set_name, &manage, &check) { }

        sub shout_get_url(Shout) returns Str is native('libshout') { * }
        sub shout_set_url(Shout, Str) returns int32 is native('libshout') { * }

        method url() returns Str is rw is accessor_facade(&shout_get_url, &shout_set_url, &manage, &check) { }

        sub shout_get_genre(Shout) returns Str is native('libshout') { * }
        sub shout_set_genre(Shout, Str) returns int32 is native('libshout') { * }

        method genre() returns Str is rw is accessor_facade(&shout_get_genre, &shout_set_genre, &manage, &check) { }

        sub shout_get_description(Shout) returns Str is native('libshout') { * }
        sub shout_set_description(Shout, Str) returns int32 is native('libshout') { * }

        method description() returns Str is rw is accessor_facade(&shout_get_description, &shout_set_description, &manage, &check) { }

        # Not making a method for these quite yet.
        sub shout_get_audio_info(Shout, Str) returns Str is native('libshout') { * }
        sub shout_set_audio_info(Shout, Str, Str) returns Str is native('libshout') { * }

        # Set the metadata on this instance.

        sub shout_set_metadata(Shout, Metadata) returns int32 is native('libshout') { * }

        method set_metadata(Metadata $meta) {
            my $rc = shout_set_metadata(self, $meta);
        }
    }

    sub shout_init() is native('libshout') { * }

    sub shout_shutdown() is native('libshout') { * }

    sub shout_new() returns Shout is native('libshout') { * }
    sub shout_free(Shout) returns int32 is native('libshout') { * }

    has Shout $!shout handles <host>;

    sub shout_metadata_new() returns Metadata is native('libshout') { * }
    sub shout_metadata_free(Metadata) is native('libshout') { * }

    sub shout_version(int32, int32, int32) returns Str is native('libshout') { * }
    method libshout-version() returns Version {
        my $v = shout_version(int32, int32, int32);
        Version.new($v);
    }
    multi submethod BUILD() {
        shout_init();
        $!shout = shout_new();
    }

}

# vim: expandtab shiftwidth=4 ft=perl6
