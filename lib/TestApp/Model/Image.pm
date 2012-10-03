package TestApp::Model::Image;

use strict;
use warnings;

use base qw/Mojo::Base/;
use Image::Magick;
use Data::Dumper;
use Carp;
#### Class Methods ####

sub scale {
    my ($class, $value, $filename) = @_;

    my ($nx, $ox, $oy, $w, $h, $nw, $nh, $err, $fix);
    $fix = $value + 5;

    my $img = Image::Magick->new;

    $err = $img->Read( filename => $ENV{PATH_TO_ORIG} . $filename );

    ($w, $h) = $img->Get('base-columns', 'base-rows');

    if ($h > $w) {
        $img->Resize(geometry => $fix.'x');
    } elsif ($w > $h) {
        $img->Resize(geometry => 'x'.$fix);
    } else {
        $img->Resize(width => $fix, height => $fix);
    }

    $img->Set('quality' => 92, 'dither' => 'True');
    $img = $img->Transform(crop=>$value.'x'.$value.'+0+0', gravity=>'Center');
    $img->Write($ENV{PATH_TO_SCALE} . $filename);

    # delete
    @$img = ();
    undef $img;

    return 1;
}

sub optimize {
    my ($class, $filename, $ext) = @_;

    my ($h, $w, $nw, $nh, $err);
    my $max_size = 1024;

    my $img = Image::Magick->new;

    $err = $img->Read( filename => $ENV{PATH_TO_TEMP} . $filename . ".$ext");
    croak "Optimize image - can't open image" if $err;

    ($w, $h) = $img->Get('base-columns', 'base-rows');

    if ($w > $max_size) {
        $err = $img->Resize('geometry' => $max_size);
    }

    $img->Strip;
    $img->Set('quality' => 92, 'dither' => 'True');
    $img->Quantize(color => '24'); # for PNG

    $err = $img->Write(filename => $ENV{PATH_TO_ORIG} . $filename . '.png', compression=>'JPEG');
    # {None, BZip, Fax, Group4, JPEG, JPEG2000, LosslessJPEG, LZW, RLE, Zip}
    warn $err if $err;

    # delete
    @$img = ();
    undef $img;

    return 1;
}

sub ava_scale {
    my ($class, $filename) = @_;

    my ($height, $width) = (150, 150);
    my ($nx, $ox, $oy, $err);

    # my $img = TestApp::Model->image;
    my $img = Image::Magick->new;

    my $w = $img->Read( filename => $ENV{AVATAR_IMG} . 'tmp-' . $filename);

    return -1 if $w;

    ($ox, $oy) = $img->Get('base-columns', 'base-rows');
    
    if ($ox > '150' || $oy > '150') {
        $err = $img->Resize(height => int($height), width => int($width));
    }

    $err = $img->Write($ENV{AVATAR_IMG} . $filename);
    # delete
    @$img = ();
    undef $img;

    return 1;
}

1;
__END__
