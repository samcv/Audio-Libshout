use v6;
use NativeCall;
use AccessorFacade:ver<v0.0.2>;
use OO::Monitors;

=begin pod

=head1 NAME

Audio::Libshout - binding to the xiph.org libshout icecast source client

=head1 SYNOPSIS

=begin code

=end code

See also the files in the C<examples> directory

=head1 DESCRIPTION

This provides a source client to stream to an icecast server.  It can
stream Ogg/Vorbis or MP3 data but doesn't provide any transcoding so the
data will need to be provided from an appropriate source in the required
encoding. This has been developed against version 2.2.2 of libshout,
it is possible later versions may provide support for other encodings.

The API is somewhat simplified in comparison to libshout but provides
an asynchronous mechanism whereby data can be fed as quickly as it is
obtained to a worker thread via a channel so the client doesn't have
to worry about the timing and synchronisation issues, though the lower
level send and sync methods are available if your application requires
a different scheme.

In testing this proved quite capable of streaming a 320kb/s MP3 read from
a file to an icecast server on the local network, though of course network
conditions may limit the rate that will work well to remote servers.

The "examples" directory in the distribution contains a simple streaming
source client that will allow you to send an Ogg or MP3 file to an
icecast server.

If you're curious the first thing that I streamed using this library was

https://www.mixcloud.com/mikestern-awakening/mike-stern-guest-mix-for-technotic-eire-radio-show/

Mike's a great DJ, great DJs and producers make making software
worthwhile :)

=head1 METHODS



=end pod

class Audio::Libshout:ver<v0.0.1>:auth<github:jonathanstowe> {

    enum Error ( Success => 0 , Insane => -1 , Noconnect => -2 , Nologin => -3 , Socket => -4 , Malloc => -5, Meta => -6, Connected => -7, Unconnected => -8, Unsupported => -9, Busy => -10 );
    enum Format ( Ogg => 0, MP3 => 1 );
    enum Protocol ( HTTP => 0, XAUDIOCAST => 1, ICY => 2);

    class X::ShoutError is Exception {
        has Error $.error;
        has Str $.what = "unknown operation";

        method message() {
            my $message = do given $!error {
                                when Insane {
                                    "Not a valid Shout object or missing parameters";
                                }
                                when Noconnect {
                                    "A connection to the server could not be established."
                                }
                                when Nologin {
                                    "The server refused login, probably because authentication failed.";
                                }
                                when Socket {
                                    "An error occured while talking to the server.";
                                }
                                when Malloc {
                                    "There wasn't enough memory to complete the operation.";
                                }
                                when Meta {
                                    "The server returned an error while setting metadata.";
                                }
                                when Connected {
                                    "The connection has already been opened."
                                }
                                when Unconnected {
                                    "The Shout object is not currently connected";
                                }
                                when Unsupported {
                                    "The combination of parameters is not supported for this operation";
                                }
                                when Busy {
                                    "The connection is busy and could not perform the operation.";
                                }
                                default {
                                    "Unknown issue or not an error";
                                }

                            }
            $!what ~ ' : ' ~ $message;
        }
    }

    class Metadata is repr('CPointer') {
        sub shout_metadata_new() returns Metadata is native('libshout') { * }

        method new() {
            shout_metadata_new();
        }

        sub shout_metadata_free(Metadata) is native('libshout') { * }

        method DESTROY() {
            shout_metadata_free(self);
        }

        sub shout_metadata_add(Metadata, Str, Str ) returns int32 is native('libshout') { * }

        method add(Str $key is rw, Str $value is rw) returns Error {
            explicitly-manage($key);
            explicitly-manage($value);
            my $rc = shout_metadata_add(self, $key, $value);
            Error($rc);
        }

    }

    class Shout is repr('CPointer') {

        sub shout_new() returns Shout is native('libshout') { * }

        method new(Shout:U: *%attribs) returns Shout {
            my $shout = shout_new();

            for %attribs.kv -> $attrib, $value {
                if $shout.can($attrib) {
                    $shout."$attrib"() = $value;
                }
            }
            $shout;
        }

        sub shout_free(Shout) returns int32 is native('libshout') { * }

        submethod DESTROY() {
            shout_free(self);
        }

        sub shout_open(Shout) returns int32 is native('libshout') { * }

        method open() returns Error {
            my $rc = shout_open(self);
            Error($rc);
        }

        sub shout_close(Shout) returns int32 is native('libshout') { * }

        method close() returns Error {
            my $rc = shout_close(self);
            Error($rc);
        }
        
        sub shout_send(Shout, CArray[uint8], int32) returns int32 is native('libshout') { * }

        multi method send(CArray[uint8] $buf, Int $elems) returns Error {
            my $rc = shout_send(self, $buf, $elems);
            Error($rc);
        }

        multi method send(Buf $buf) returns Error {
            my $carray = CArray[uint8].new;
            $carray[$_] = $buf[$_] for ^($buf.elems);
            self.send($carray, $buf.elems);
        }

        sub shout_sync(Shout) is native('libshout') { * }

        method sync() {
            shout_sync(self);
        }

        my sub manage(Shout $self, Str $value is copy) {
            explicitly-manage($value);
            $value;
        }

        my sub check(Shout $self, Int $rc ) {
            given Error($rc) {
                when Success {
                }
                default {
                    X::ShoutError.new(error => $_, what => "Setting parameter").throw;
                }
            }

        }

        # "attributes"
        #
        sub shout_set_host(Shout, Str) returns int32 is native('libshout') { * }
        sub shout_get_host(Shout) returns Str is native('libshout') { * }

        method host() returns Str is rw is accessor-facade(&shout_get_host, &shout_set_host, &manage, &check) { }

        sub shout_set_port(Shout, int32) returns int32 is native('libshout') { * }
        sub shout_get_port(Shout) returns int32 is native('libshout') { * }

        method port() returns Int is rw is accessor-facade(&shout_get_port, &shout_set_port, Code, &check) { }

        sub shout_set_user(Shout, Str) returns int32 is native('libshout') { * }
        sub shout_get_user(Shout) returns Str is native('libshout') { * }

        method user() returns Str is rw is accessor-facade(&shout_get_user, &shout_set_user, &manage, &check) { }

        sub shout_set_password(Shout, Str) returns int32 is native('libshout') { * }
        sub shout_get_password(Shout) returns Str is native('libshout') { * }

        method password() returns Str is rw is accessor-facade(&shout_get_password, &shout_set_password, &manage, &check) { }

        sub shout_get_protocol(Shout) returns int32 is native('libshout') { * }
        sub shout_set_protocol(Shout, int32) returns int32 is native('libshout') { * }

        method protocol() returns Protocol is rw is accessor-facade(&shout_get_protocol, &shout_set_protocol, Code, &check) { }

        sub shout_get_format(Shout) returns int32 is native('libshout') { * }
        sub shout_set_format(Shout, int32) returns int32 is native('libshout') { * }

        method format() returns Format is rw is accessor-facade(&shout_get_format, &shout_set_format, Code, &check) { }

        sub shout_get_mount(Shout) returns Str is native('libshout') { * }
        sub shout_set_mount(Shout, Str) returns int32 is native('libshout') { * }

        method mount() returns Str is rw is accessor-facade(&shout_get_mount, &shout_set_mount, &manage, &check) { }

        sub shout_get_dumpfile(Shout) returns Str is native('libshout') { * }
        sub shout_set_dumpfile(Shout, Str ) returns int32 is native('libshout') { * }

        method dumpfile() returns Str is rw is accessor-facade(&shout_get_dumpfile, &shout_set_dumpfile, &manage, &check ) { }

        sub shout_get_agent(Shout) returns Str is native('libshout') { * }
        sub shout_set_agent(Shout, Str) returns int32 is native('libshout') { * }

        method agent() returns Str is rw is accessor-facade(&shout_get_agent, &shout_set_agent, &manage, &check) { }

        # Directory parameters
        sub shout_get_public(Shout) returns int32 is native('libshout') { * }
        sub shout_set_public(Shout, int32) returns int32 is native('libshout') { * }

        method public returns Bool is rw is accessor-facade(&shout_get_public, &shout_set_public, Code, &check) { }

        sub shout_get_name(Shout) returns Str is native('libshout') { * }
        sub shout_set_name(Shout, Str) returns int32 is native('libshout') { * }

        method name() returns Str is rw is accessor-facade(&shout_get_name, &shout_set_name, &manage, &check) { }

        sub shout_get_url(Shout) returns Str is native('libshout') { * }
        sub shout_set_url(Shout, Str) returns int32 is native('libshout') { * }

        method url() returns Str is rw is accessor-facade(&shout_get_url, &shout_set_url, &manage, &check) { }

        sub shout_get_genre(Shout) returns Str is native('libshout') { * }
        sub shout_set_genre(Shout, Str) returns int32 is native('libshout') { * }

        method genre() returns Str is rw is accessor-facade(&shout_get_genre, &shout_set_genre, &manage, &check) { }

        sub shout_get_description(Shout) returns Str is native('libshout') { * }
        sub shout_set_description(Shout, Str) returns int32 is native('libshout') { * }

        method description() returns Str is rw is accessor-facade(&shout_get_description, &shout_set_description, &manage, &check) { }

        # Not making a method for these quite yet.
        sub shout_get_audio_info(Shout, Str) returns Str is native('libshout') { * }
        sub shout_set_audio_info(Shout, Str, Str) returns Str is native('libshout') { * }

        # Set the metadata on this instance.

        sub shout_set_metadata(Shout, Metadata) returns int32 is native('libshout') { * }

        method set-metadata(Metadata $meta) returns Error {
            my $rc = shout_set_metadata(self, $meta);
            Error($rc);
        }

        sub shout_get_error(Shout) returns Str is native('libshout') { * };

        method last-error() returns Str {
            shout_get_error(self);
        }

        sub shout_get_errno(Shout) returns int32 is native('libshout') { * };

        method last-error-number() returns Error {
            my $rc = shout_get_errno(self);
            Error($rc);
        }
    }

    monitor Initialiser {
        has Int $!initialisers = 0;

        sub shout_init() is native('libshout') { * }

        method init() {
            if $!initialisers == 0 {
                shout_init();
            }
            ++$!initialisers;
        }

        sub shout_shutdown() is native('libshout') { * }

        method shutdown() {
            --$!initialisers;
            if $!initialisers == 0 {
                shout_shutdown();
            }
        }
    }


    my $initialiser = Initialiser.new;

    has Shout $!shout handles <host port user password protocol format mount dumpfile agent public name url genre description>;
    has Metadata $!metadata;

    has Bool $!opened = False;

    has Promise $!helper-promise;

    method open() {
        if not $!opened {
            my $rc = $!shout.open();
            if $rc !~~ Success {
                X::ShoutError.new(error => $rc, what => "opening stream").throw;
            }
            $!opened = True;
        }
    }

    method send(Buf $buff) {
        if not $!opened {
            self.open()
        }
        my $rc = $!shout.send($buff);
        if $rc !~~ Success {
            X::ShoutError.new(error => $rc, what => "sending data").throw;
        }
    }

    multi method send-channel(Audio::Libshout $self:) returns Channel {
        my $channel = Channel.new;
        $self.send-channel($channel);
    }


    multi method send-channel(Audio::Libshout $self: Channel $channel) returns Channel {
        $!helper-promise = start {
            for $channel.list -> $item {
                $self.send($item);
                $self.sync;
            }
        }
        $channel;
    }

    method sync() {
        if $!opened {
            $!shout.sync();
        }
    }

    method close() {
        if $!helper-promise.defined {
            await $!helper-promise;
        }
        if $!opened {
            my $rc = $!shout.close();
            if $rc !~~ Success {
                X::ShoutError.new(error => $rc, what => "closing stream").throw;
            }
            $!opened = False;
        }
    }

    multi method add-metadata(Str $key, Str $value) {
        my $rc = $!metadata.add($key, $value);
        if $rc !~~ Success {
            X::ShoutError.new(error => $rc, what => "adding metadata");
        }
    }

    multi method add-metadata(*%metas) {
        for %metas.kv -> $key, $value {
            self.add-metadata($key, $value);
        }
        self.set-metadata();
    }

    method set-metadata() {
        if self.format ~~ MP3 {
            my $rc = $!shout.set-metadata($!metadata);
            if $rc !~~ Success {
                X::ShoutError.new(error => $rc, what => "setting metadata");
            }
        }
    }


    sub shout_version(int32, int32, int32) returns Str is native('libshout') { * }
    method libshout-version() returns Version {
        my int32 $major;
        my int32 $minor;
        my int32 $patch;
        my $v = shout_version($major, $minor, $patch);
        Version.new($v);
    }

    multi submethod BUILD(*%attribs) {
        $initialiser.init();
        $!shout = Shout.new(|%attribs);
        $!metadata = Metadata.new;
    }

    submethod DESTROY() {
        $!shout = Shout;
        $!metadata = Metadata;
        $initialiser.shutdown();
    }

}

# vim: expandtab shiftwidth=4 ft=perl6
