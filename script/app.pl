#!/usr/bin/env perl
use Mojo::Base -strict;

use File::Basename 'dirname';
use File::Spec::Functions qw/catdir splitdir/;

BEGIN {
    $ENV{MOJO_MODE}     = 'development';
    $ENV{MOJO_MAX_MESSAGE_SIZE} = 10 * 1024 * 1024;
    $ENV{ITEMS_ON_PAGE} = '10';
    $ENV{ROOT_DIR}      = '/home/valikos/projects/mojo/mirotvorec/'; # for debug
    # $ENV{ROOT_DIR} = '/hsphere/local/home/olegiii-3571/mirotvorec.zp.ua';
    # $ENV{SCRIPT_DIR}    = "$FindBin::Bin";
    # $ENV{LIB_DIR}       = $ENV{SCRIPT_DIR} . '/lib/';
    $ENV{ORIG_IMG}      = 'public/images/original/';
    $ENV{SCALE_IMG}     = 'public/images/scaled/';
    $ENV{PATH_TO_ORIG}  = $ENV{ROOT_DIR} . 'public/images/original/';
    $ENV{PATH_TO_SCALE} = $ENV{ROOT_DIR} . 'public/images/scaled/';
    $ENV{PATH_TO_TEMP}  = $ENV{ROOT_DIR} . 'tmp/upload/';
    $ENV{AVATAR_IMG}    = $ENV{ROOT_DIR} . '/public/images/avatar/';
    $ENV{TEMP_IMG}      = $ENV{ROOT_DIR} . '/public/images/temp/';
    $ENV{MOJO_TMPDIR}   = 'tmp/upload/';
}

# Source directory has precedence
my @base = (splitdir(dirname(__FILE__)), '..');
my $lib = join('/', @base, 'lib');
-e catdir(@base, 't') ? unshift(@INC, $lib) : push(@INC, $lib);

# Check if Mojolicious is installed;
die <<EOF unless eval 'use Mojolicious::Commands; 1';
It looks like you don't have the Mojolicious framework installed.
Please visit http://mojolicio.us for detailed installation instructions.

EOF

# Application
$ENV{MOJO_APP} ||= 'TestApp';

# Start commands
Mojolicious::Commands->start;