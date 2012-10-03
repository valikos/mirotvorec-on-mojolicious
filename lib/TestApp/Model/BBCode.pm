package TestApp::Model::BBCode;

use strict;
use warnings;

use base qw/Mojo::Base/;
#### Class Methods ####

sub pars_bbcode {
    my $class = shift;

    return TestApp::Model->bbcode->parse(shift);
}

sub pars_html {
    my $class = shift;

    return TestApp::Model->bbcode->render(shift);
}

1;
__END__
