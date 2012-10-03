package TestApp::Controller::Event;

use strict;
use warnings;

use base 'Mojolicious::Controller';

# This action will render a template
sub show {
    my $self = shift;
    $self->render(message => 'События');
};

1;