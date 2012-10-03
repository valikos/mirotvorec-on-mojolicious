package TestApp::Controller::Contact;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Mojo::ByteStream 'b';
use Mojo::Util qw`url_escape url_unescape decode`;

# This action will render a template
sub info {
    my $self = shift;
    
    my ($mes, $file);

#    $mes = 'О нас';
#    decode 'cp-1251', $mes;

#    $file = 'Статут_УСВА.doc';
#    url_escape $file;

    #$self->render(message => $mes, file => $file);
    $self->render();
}

1;