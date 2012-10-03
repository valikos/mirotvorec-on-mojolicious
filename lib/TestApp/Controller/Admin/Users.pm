package TestApp::Controller::Admin::Users;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use Mojo::Util qw`decode encode`;

use Data::Dumper;

__PACKAGE__->attr(conf => sub { do 'conf/text_massages.conf' });
# обработка пользователей
sub users {
    my $self = shift;
    # load config
    my $cfg = $self->conf;
    # decode config
    foreach (keys %$cfg){
        $cfg->{$_} = b($cfg->{$_})->decode('utf-8');
    }
    # set config
    $self->stash('CFG' => $cfg);

    my $page = $self->param('page') || '1';
    my $ac = $self->param('ac') || 'view';
    my @err;

    $self->stash('ac'   => $ac);
    $self->stash('page' => $page);
    $self->stash('page_id' => 'users');

    if ($ac eq 'view') {
        my $cc = TestApp::Model::Users->select('count(u_id)')->list;

        my ($users, $err, %limit);
        $users = undef;
        
        $limit{'beg'} = ($page - 1) * $ENV{ITEMS_ON_PAGE};
        $limit{'end'} = $ENV{ITEMS_ON_PAGE};
        $limit{'str'} = 'LIMIT ' . $limit{'beg'} . ', ' . $limit{'end'};

        if ($cc > 0) {

            if ( ($cc / $ENV{ITEMS_ON_PAGE}) <= 1) {
                $self->stash('pages' => 0);
            } else {
               $self->stash('pages' => int($cc / $ENV{ITEMS_ON_PAGE}) + 1);
            }

            $users = TestApp::Model::Users->select('', '', ['u_id DESC ' . $limit{'str'}])->hashes;
        }

        $self->render(template => 'admin/users/preview',
                          'var' => $users,
                          'err' => undef,
                         );
        return 1;
    }

    if ($ac eq 'edit') {
        my $u_id = $self->param('u_id') || '';
        my $user;
        my $cc = TestApp::Model::Users->select('count(u_id)', 'u_id="'.$u_id.'"')->list;
        if ($cc > 0) {
            $user = TestApp::Model::Users->select('', 'u_id="'.$u_id.'"')->hash;

        } else {
            $user = undef;
        }

        $self->render(template => 'admin/users/edit', var => $user, err => '');
    }
    # update user information
    if ($ac eq 'change') {

        my ($info, %param);

        $info = TestApp::Model::Users->select('*', 'u_id=\'' . $self->param('u_id') . '\'')->hash;

        # my @cols = TestApp::Model::Users->select()->columns;

        # update user data
        if ( $self->param('u_id') == $self->stash('ADMIN')->{u_id} ) {
            # update self information
            $param{u_email} = $self->param('u_email') || '';
            $param{u_about} = $self->param('u_about') || '';
            $param{u_name}  = $self->param('u_name')  || '';
            $param{u_sname} = $self->param('u_sname') || '';
            $param{u_fname} = $self->param('u_fname') || '';
            $param{u_tel}   = $self->param('u_tel')   || '';
            $param{u_icq}   = $self->param('u_icq')   || '';
            $param{u_skype} = $self->param('u_skype') || '';

            # check errors
            push @err, 'user_name'    unless $param{'u_name'};
            push @err, 'empty_email'  unless $param{'u_email'};
            push @err, 'wrong_email'  unless ($param{'u_email'} =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i || $param{'u_email'} eq '');

        } elsif ( ($self->stash('ADMIN')->{u_mode} eq 2) && ($info->{u_absolute} eq 0) && ($self->param('u_mode') =~ m/-1|0|1|2/) ) {
            # change user mode for other
            $param{u_mode} = $self->param('u_mode');
        } elsif ( ($self->stash('ADMIN')->{u_mode} eq 1) && ($info->{u_absolute} eq 0) && ($self->param('u_mode') =~ m/-1|0|1/) ) {
            $param{u_mode} = $self->param('u_mode');
        } else {
            push @err, 'user_admin_error'    unless $param{'u_name'};
        }

        if (@err) {
            $self->render(template => 'admin/users/edit', var => $info, err => \@err);
            return 1;
        }

        if (%param) {
            # update info data
            my $update = TestApp::Model::Users->update(\%param, {'u_id' => $self->param('u_id')});
            $self->redirect_to('/admin/users');
        }

    }
}

1;