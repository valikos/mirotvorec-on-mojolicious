package TestApp::Controller::Delete;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Data::Dumper;

sub comment {
    my $self = shift;

    my $c_id = $self->stash('c_id');
    my $cc = TestApp::Model::Comments->select('count()','c_id=\''.$c_id.'\'')->list;
    my $com;

    if ($cc > 0) {
        
        $com = TestApp::Model::Comments->select('*','c_id=\''.$c_id.'\'')->hash;
        
        if (($com->{c_u_id} eq $self->stash('USER')->{'u_id'}) || ($self->stash('USER')->{'u_mode'} eq 2)) {
            my $del = TestApp::Model::Comments->delete(
                {'c_id' => $c_id}
            );
            $self->render_json(1);
            return 1;
        } else {
            $self->render_json(0);
            return 1;
        }
    } else {
        $self->render_json(0);
        return 1;
    }
}

1;