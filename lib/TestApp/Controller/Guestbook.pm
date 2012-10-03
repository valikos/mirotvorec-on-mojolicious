package TestApp::Controller::Guestbook;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojolicious::Sessions;

use Mojo::ByteStream 'b';
use Mojo::Util qw/decode encode/;

use Data::Dumper;

__PACKAGE__->attr(conf => sub { do 'conf/text_massages.conf' });

sub show {
    my $self = shift;

    my $session_code = $self->session('code');
    $self->session('code'=>'');
    my @letter = (0..9, 'a'..'z');
    $self->session('code' => join '', @letter[ map { int rand @letter } 1..5 ]);

    my $cfg = $self->conf;
    $self->stash('CFG' => $cfg);
    # decode config
    foreach (keys %$cfg){
        $cfg->{$_} = b($cfg->{$_})->decode('utf-8');
    }

    my (%var, $page, %limit, $html, @err);

    $page = $self->stash('num');
    $self->stash('page' => $page);

    $limit{'beg'} = ($page - 1) * $ENV{ITEMS_ON_PAGE};
    $limit{'end'} = $ENV{ITEMS_ON_PAGE};
    $limit{'str'} = 'LIMIT ' . $limit{'beg'} . ', ' . $limit{'end'};

    $self->stash('pages' => 0);
    $html = '';

    # read guest comments
    my $cc = TestApp::Model::Guest->select('count(g_id)')->list;

    if ($cc > 0) {

        if ( ($cc / $ENV{ITEMS_ON_PAGE}) <= 1) {
            $self->stash('pages' => 0);
        } else {
            $self->stash('pages' => int($cc / $ENV{ITEMS_ON_PAGE}) + 1);
        }

        # $html = TestApp::Model::Guest->select('', '', ['g_id DESC ' . $limit{'str'}])->hashes;
        $html = TestApp::Model::Base->select_join(
            'guestbook as g left join users as u on (g.g_admin_id=u.u_id)',
            'g.*, u.u_login, u.u_mode',
            '',
            'g_id DESC ' . $limit{'str'}
        )->hashes;

        if ($html) {

            foreach (@$html) {
                my ($second, $minute, $hour, $mday, $month, $year) = localtime($_->{'g_create'});
                $_->{'g_create'} = sprintf(
                    '%02d.%02d.%04d %02d:%02d',
                    $mday, $month+1, $year+1900, $hour, $minute
                );
            }

        } else {
            $html = '';
        }
    }

    # add quest comment;
    if ($self->stash('add') && $self->stash('add') eq 'add') {

        my @columns = TestApp::Model::Guest->select()->columns;
        foreach (@columns) {
            $var{$_} = $self->param($_);
        }

        push @err, 'guest_name'   unless $var{'g_user'};
        push @err, 'guest_text'   unless $var{'g_mes'};
        push @err, 'guest_code'   if $self->param('g_code') ne $session_code;

        if (@err) {
            $self->stash('error' => \@err);
            $self->render(template => 'guestbook/show', var => $html, 'pages' => 0);
            return 1;
        } else {
            $var{'g_create'} = time();
            my $row_id = TestApp::Model::Guest->insert(\%var);
            $self->redirect_to('/guestbook');
        }
    }

    $self->render(var => $html, CFG=>'');
}

sub gen_cpt () {
    my $self = shift;
    $self->render('data' => $self->captcha( $self->session('code') ));
}

1;
