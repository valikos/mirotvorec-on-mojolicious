package TestApp::Controller::Admin;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Mojo::ByteStream 'b';
use Mojo::Util qw/b64_decode b64_encode decode encode md5_sum/;

use Data::Dumper;

# create admin session
sub login {
    my $self = shift;
    
    # encode admin pass
    # 
    # Since the MD5 algorithm is only defined for strings of bytes,
    # it can not be used on strings that contains chars with ordinal number above 255
    my $admin_pass = md5_sum ( encode 'UTF-8', $self->param('a_password') );

    my $admin = TestApp::Model::Users->select(
            '*', 
            q`u_login='` . $self->param('a_login') . q`' and u_password='` . $admin_pass . q`'`
        )->hash;

    if ($admin) {
        # set unique id for session
        my $ses_id = time . $self->app->secret;
        b64_encode $ses_id;
        $ses_id =~ s/\n+$//;

        $self->session('admin_id' => $ses_id);

        my $where = {
            'u_login' => $self->param('a_login'),
            'u_password' => $admin_pass,
        };
        my $fieldvals = {
            'u_admin_session' => $ses_id,
        };

        TestApp::Model::Users->update( $fieldvals, $where);
    } else {
      $self->flash('login_error' => 1);
      $self->session('admin_id' => q``);
    }

    $self->redirect_to('/admin');
    return 1;
}

# admin logout
sub sign_out {
    my $self = shift;

    if ($self->session('admin_id')) {
        my $where = {
            'u_admin_session' => $self->session('admin_id'),
            'u_id' => $self->stash('ADMIN')->{'u_id'},
        };
        my $fieldvals = {
            'u_admin_session' => '',
        };
        TestApp::Model::Users->update( $fieldvals, $where);
        $self->session('admin_id' => '');
    }

    $self->stash('ADMIN' => '');

    $self->redirect_to('/admin/');
}

sub admin_check {
    #bridge
    my $self = shift;

    if ($self->session('admin_id')) {

        my $cc = TestApp::Model::Users->select(
                'count(u_id)', 
                q`u_admin_session='` . $self->session('admin_id') . q`'`, q``
            )->list;

        if ($cc > 0) {

            # select admin info
            my $admin = TestApp::Model::Users->select(
                '*', 
                q`u_admin_session='` . $self->session('admin_id') . q`'`, q``
            )->hash;        
            # set global admin hash
            $self->stash('ADMIN' => $admin);
            return 1;
        } 
    }
    
    $self->session('admin_id' => q``);
    $self->flash('login_error' => 1);
    $self->render(template => 'admin/login_form');
    return 1;
}

sub bbcode_preview {
    my $self = shift;

    my $data = $self->param('data') || '';

    TestApp::Model->init_bbcode();

    my $parsed_data = TestApp::Model::BBCode->pars_html($data);

    $self->render(text => $parsed_data);
}

sub index_page {
    my $self = shift;

    $self->stash('page_id' => 'main');

    if ($self->session('admin_id')) {
        my $session_id = TestApp::Model::Users->select(
            'u_admin_session', 
            q`u_admin_session='` . $self->session('admin_id') . q`'`
        )->list;
    }

    $self->render();
}

sub rules {
    my $self = shift;
    
    $self->render('template' => 'admin/rules', 'page_id' => '');
}

1;