package TestApp::Controller::Uploadify;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Mojo::Util qw/decode encode/;
use File::Path;

use Data::Dumper;
use Carp;

my $conf = { path => $ENV{TEMP_IMG}, ext => qr/\.(?i:jpg|png|jpeg|JPG|PNG)$/ };

sub commit {
    my $self = shift;
    my %param;
    
    my $upload = $self->req->upload('Filedata');

    return unless $upload;
    return $self->render_text( 'Invalid file type' ) unless $upload->filename =~ /$conf->{ext}/;
=head
    unless ($upload) {
        warn Dumper 'Empty file';
        $self->render(json => {status => -1, error => 'Empty file'});
        return;
    }
    unless ($upload->filename =~ /$conf->{ext}/) {
        warn Dumper 'Invalid file type';
        $self->render_text(json => {status => -2, error => ''});
        return;
    }
=cut
    # $self->param('g_id') - id of gallery :)

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    my $image_name = sprintf('image-%04s%02s%02s%02s%02s%02s-%05d', $year+1900, $mon+1, $mday, $hour, $min, $sec, int rand(10000));
    $upload->filename =~ m/\.(jpg|png|jpeg)$/io;
    my $ext = $1;
    # save original image
    $upload->move_to($ENV{MOJO_TMPDIR} . $image_name . ".$ext");
    unless (-f $ENV{ROOT_DIR} . $ENV{MOJO_TMPDIR} . $image_name . ".$ext") {
        # my $image_name = sprintf('image-%04s%02s%02s%02s%02s%02s-%06d', $year+1900, $mon+1, $mday, $hour, $min, $sec, int rand(100000));
        warn 'File dont exist!!!!';
    }
    # optimize
    # TestApp::Model->init_image();
    TestApp::Model::Image->optimize($image_name, $ext);
    TestApp::Model::Image->scale(140, $image_name . '.png');

    # unlink $ENV{MOJO_TMPDIR} . $image_name . ".$ext" if -f $ENV{MOJO_TMPDIR} . $image_name . ".$ext";

    $param{'p_id'}          = undef;
    $param{'g_id'}          = $self->param('g_id');
    $param{'p_name'}        = $image_name . ".png";
    $param{'p_description'} = $upload->filename;
    $param{'p_create'}      = time; #sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year+1900, $mon+1, $mday, $hour, $min, $sec);

    my $row_id = TestApp::Model::Photos->insert(\%param);

    # $self->render_text( $upload->filename );
    $self->render(json => {status => 1, photo => $image_name . ".png", p_id => $row_id});
}

1;
__END__