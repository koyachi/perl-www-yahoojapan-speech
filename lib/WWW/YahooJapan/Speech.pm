package WWW::YahooJapan::Speech;
use strict;
use warnings;
use Carp;
use LWP::UserAgent;
use File::Basename;
use File::Path;
use File::Spec;
use base qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors(qw/savedir/);

our $VERSION = '0.01';

=head1 NAME

WWW::YahooJapan::Speech - text to speach engine powered by Yahoo!Japan.

=head1 SYNOPSIS

  use WWW::YahooJapan::Speech;
  my $tts = WWW::YahooJapan::Speech->new;
  $tts->save("this is a pen");

=head1 DESCRIPTION

Text to speach engine powered by Yahoo!Japan.
http://stepup.yahoo.co.jp/english/listening/

=head1 METHODS

=head2 new

=over 4

=item Arguments: none

=item Return Value: none

=back

constructor.

=cut

sub new {
    my($class) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->agent('Mozilla');
    bless {
        ua => $ua,
    }, $class;
}

=head2 get

=over 4

=item Arguments: $word

=item Return Value: mp3 data

=back

get mp3 data from yahoo, and return mp3 bindary data.

=cut

sub get {
    my($self, $word) = @_;

    my $url = "http://tts.eng.stepup.yahoo.co.jp/tts/tts4.php?spell%3D$word";
    my $response = $self->{ua}->get($url);
    unless ($response->is_success) {
        croak "can't get $url"
    }

    my $mp3url = $response->content;
    $mp3url =~ s/.*?<fname>(.*?)<\/fname>.*/$1/s;
    $response = $self->{ua}->get($mp3url);
    unless ($response->is_success) {
        croak "can't get $mp3url"
    }
    $response->content
}

=head2 save

=over 4

=item Arguments: $word

=item Return Value: none

=back

save mp3 data.

=cut

sub save {
    my($self, $word) = @_;
    my $sound = $self->get($word);
    $word =~ s/ /-/g;
    my $path = File::Spec->catfile($self->savedir ||  './', "$word.mp3");
    my $dir = File::Basename::dirname($path);
    unless (-e $dir) {
        File::Path::mkpath($dir, 1, 0777);
    }
    open(FH, ">", $path);
    print FH $sound;
    close(FH);
    $path;
}


=head1 AUTHOR

Tsutomu KOYACHI <rtk2106@gmail.com>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
