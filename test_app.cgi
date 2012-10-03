#!/usr/bin/perl

use strict;
use warnings;

use FindBin;

use File::Basename 'dirname';
use File::Spec;

BEGIN {
  $ENV{ITEMS_ON_PAGE} = '10';
  $ENV{SCRIPT_DIR} = "$FindBin::Bin";
  $ENV{ROOT_DIR} = '/hsphere/local/home/olegiii-3571/mirotvorec.zp.ua/';
  $ENV{LIB_DIR} = $ENV{SCRIPT_DIR} . '/lib/';
  $ENV{PUBLIC_DIR} = $ENV{ROOT_DIR} . 'public/';
  $ENV{ORIG_IMG} = 'public/images/original/';
  $ENV{SCALE_IMG} = 'public/images/scaled/';
  $ENV{THUMB_IMG} = 'public/images/thumbs/';
  $ENV{AVATAR_IMG} = $ENV{ROOT_DIR} . 'public/images/avatar/';
  $ENV{TEMP_IMG} = $ENV{ROOT_DIR} . 'public/images/temp/';
  # $ENV{MOJO_MODE} ||= 1;
  $ENV{MOJO_MAX_MESSAGE_SIZE} = 50 * 1024 * 1024;
  $ENV{MOJO_TMPDIR} = $ENV{ROOT_DIR} . 'tmp/upload/';
}

use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";

# use lib join '/', File::Spec->splitdir(dirname(__FILE__)), 'lib';
# use lib join '/', File::Spec->splitdir(dirname(__FILE__)), '..', 'lib';

# Check if Mojo is installed
eval 'use Mojolicious::Commands';
die <<EOF if $@;
It looks like you don't have the Mojolicious Framework installed.
Please visit http://mojolicious.org for detailed installation instructions.

EOF

# Application
$ENV{MOJO_APP} ||= 'TestApp';

# Start commands
Mojolicious::Commands->start;
