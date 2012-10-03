package TestApp::Controller::Auth;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Mojo::ByteStream 'b';
use Mojo::Util qw/b64_encode b64_decode decode encode md5_sum/;

use Data::Dumper;

__PACKAGE__->attr(conf => sub { do 'conf/text_massages.conf' });
# authenfication user
# check user session
sub authenfication {
    my $self = shift;

    my $user;

    if ($self->session('user_id')) {

        $user = TestApp::Model::Users->select(
            '*', 
            'u_user_session=\'' . $self->session('user_id') . '\''
        )->hash;

        if ($user && $user->{u_mode} eq '-1') {
            $self->stash('USER' => '');
            $self->stash('USER_LOCK' => $user);
        } elsif ($user && $user->{u_mode} >= 0) {
            $self->stash('USER' => $user);
        } else {
            $self->stash('USER' => '');
        }
    } else {
        $self->stash('USER' => '');
    }

    return 1;
}

# sign in for user
# create user session
sub sign_in {
    my $self = shift;

    my (%var, $where);

    my $host = $self->req->content->headers->host;
    my $referrer = $self->req->content->headers->referrer;

    my $redirect = '/';
    if ($referrer =~ /$host/) {
        $redirect = $referrer;
    }
    
    # Since the MD5 algorithm is only defined for strings of bytes,
    # it can not be used on strings that contains chars with ordinal number above 255
    my $user_pass = md5_sum ( encode 'UTF-8', $self->param('u_password') );

    # TODO SQL injection protect
    my $user = TestApp::Model::Users->select(
            '*', 
            q`u_login='` . $self->param('u_login') . q`' AND u_password='` . $user_pass . q`'`
        )->hash;

    if ($user) {
        # set unique id for session
        my $ses_id = time . $self->app->secret;
        b64_encode $ses_id;
        $ses_id =~ s/\n+$//;

        $self->session('user_id' => $ses_id);

        my $where = {
            'u_login' => $self->param('u_login'),
            'u_password' => $user_pass,
        };
        my $fieldvals = {
            'u_user_session' => $ses_id,
        };

        TestApp::Model::Users->update( $fieldvals, $where);

        $self->session('user_id' => $ses_id);
        
        if ($self->{u_mode} eq '-1') {
            $self->stash('USER_LOCK' => $user);
            $self->stash('USER' => '');
        } else {
            $self->stash('USER' => $user);
        }
    } else {
        $self->stash('USER' => '');
    }

    $self->redirect_to($redirect);
    return 1;
}

# sign out for user
# destroy user session
sub sign_out {
    my $self = shift;

    my $host = $self->req->content->headers->host;
    my $referrer = $self->req->content->headers->referrer;

    my $redirect = '/';
    if ($referrer =~ /$host/) {
        $redirect = $referrer;
    }
    
    if ($self->session('user_id')) {
        my $where = {
            'u_user_session' => $self->session('user_id'),
            'u_id' => $self->stash('USER')->{'u_id'},
        };
        my $fieldvals = {
            'u_user_session' => '',
        };
        TestApp::Model::Users->update( $fieldvals, $where);
        $self->session('user_id' => '');
    }

    $self->stash('USER' => '');

    $self->redirect_to($redirect);
}

#show registration form
sub show_form {
    my $self = shift;

    $self->stash('CFG' => '');
    $self->render(err => '', user => '');
}

# user registration
sub regist {
    my $self = shift;
    # load config
    my $cfg = $self->conf;
    # decode config
    foreach (keys %$cfg){
        $cfg->{$_} = b($cfg->{$_})->decode('utf-8');
    }
    # set config
    $self->stash('CFG' => $cfg);

    my (@err, %var, $db, $login, $email, $check_email);
    
    my @cols = TestApp::Model::Users->select()->columns;
    
    # преобразуем параметры в хеш структуру 'ключ' => 'значение'
    foreach (@cols) {
        $var{$_} = $self->param($_) || '';
    }

    $check_email = $self->param('u_password_check') || '';

    $login = TestApp::Model::Users->select('u_login', 'u_login=\''.quotemeta($var{'u_login'}).'\'', '')->list;
    if ($login && $login ne q``) {
        push @err, 'exist_login';
    }

    $email = TestApp::Model::Users->select('u_email', 'u_email=\''.quotemeta($var{'u_email'}).'\'', '')->list;
    if ($email && $email ne q``) {
        push @err, 'exist_email';
    }
    # проверяем обязательные поля для регистрации нового пользователя
    push @err, 'user_login'   unless $var{'u_login'};
    push @err, 'user_name'    unless $var{'u_name'};
    push @err, 'empty_email'  unless $var{'u_email'};
    push @err, 'wrong_email'  unless ($var{'u_email'} =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i || $var{'u_email'} eq '');
    push @err, 'empty_pass'   unless $var{'u_password'};
    push @err, 'empty_pass_2' unless $check_email;
    push @err, 'dif_pass'
        if $var{'u_password'} && $check_email && ($var{'u_password'} ne $check_email);
    
    if (@err) {
        # если есть ошибки, указываем их и повторяем регистрацию
        # повторять можно долго и нудно :)
        $self->render(template => 'auth/show_form',
                      err => \@err, 
                      var => \%var,
                      user => '');
    } else {
        # вносим юзверя в нашу БД
        
        # Since the MD5 algorithm is only defined for strings of bytes,
        # it can not be used on strings that contains chars with ordinal number above 255
        $var{'u_password'} = md5_sum ( encode 'UTF-8', $self->param('u_password') );
        
        # my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
        $var{'u_create'} = time; #sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year+1900, $mon+1, $mday, $hour, $min, $sec);
        $var{'u_mode'} = 0;
        $var{'u_id'} = undef;
        $var{'u_absolute'} = 0;

        $self->stash('var' => \%var);

        my $row_id = TestApp::Model::Users->insert(\%var);

        $self->render(template => 'auth/regist',
                      message => 'Регистрация пользователя',
                      err => '',
                      user => '', 
                      var => \%var);
    }
}

1;
