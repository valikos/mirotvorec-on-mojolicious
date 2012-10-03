package TestApp::Controller::Admin::Guestbook;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Mojo::ByteStream 'b';

use Data::Dumper;

# обработка статей
sub guestbook {
    my $self = shift;

    my $page = $self->stash('num') || $self->param('page') || '1';
    my $ac = $self->param('ac') || 'view';
    my $g_id = $self->param('g_id') || '0';

    $self->stash('ac'   => $ac);
    $self->stash('g_id' => $g_id);
    $self->stash('page' => $page);
    $self->stash('page_id' => 'guestbook');
    $self->stash('pages' => 0);

    # limit on select query
    my %limit;
    $limit{'beg'} = ($page - 1) * $ENV{ITEMS_ON_PAGE};
    $limit{'end'} = $ENV{ITEMS_ON_PAGE};
    $limit{'str'} = 'LIMIT ' . $limit{'beg'} . ', ' . $limit{'end'};

    if ($ac eq 'view') {

        my $cc = TestApp::Model::Guest->select('count(g_id)')->list;

        if ($cc > 0) {

            if ( ($cc / $ENV{ITEMS_ON_PAGE}) <= 1) {
                $self->stash('pages' => 0);
            } else {
                $self->stash('pages' => int($cc / $ENV{ITEMS_ON_PAGE}) + 1);
            }

            my $html = TestApp::Model::Base->select_join(
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

                $self->render(template => 'admin/guestbook/preview',
                              'var' => $html,
                              'err' => '',
                             );
                return 1;
            }

        }

        $self->render(template => 'admin/guestbook/preview',
                'var' => '',
            );
        return 1;
    }

    # answer to guest
    if ($ac eq 'edit') {
        my $guest;

        my $cc = TestApp::Model::Guest->select('count(g_id)', 'g_id=\''.$g_id.'\'', '')->list;

        if ($cc > 0) {

            $guest = TestApp::Model::Guest->select('', 'g_id=\''.$g_id.'\'', '')->hash;
            my ($second, $minute, $hour, $mday, $month, $year) = localtime($guest->{'g_create'});
            $guest->{'g_create'} = sprintf(
                '%02d.%02d.%04d %02d:%02d',
                $mday, $month+1, $year+1900, $hour, $minute
            );

            $self->render(template => 'admin/guestbook/edit',
                          'var' => $guest,
                          'err' => undef,
                         );
            return 1;
        }
            $self->render(template => 'admin/guestbook/edit',
                          'var' => undef,
                          'err' => undef,
                         );
            return 1;
    }

    if ($ac eq 'update') {

        my (%param, @err);

        if (@err) {

            my @cols = TestApp::Model::Guest->select()->columns;

            foreach (@cols) {
                $param{$_} = $self->param($_);
            }

            $self->render(template => 'admin/guestbook/edit',
                          'var' => \%param,
                          'err' => \@err,
                         );
            return 1;
        }

        if ($g_id > 0) { # update

            $param{'g_answer'} = $self->param('g_answer');
            $param{'g_admin_id'} = $self->stash('ADMIN')->{'u_id'};

            my $update = TestApp::Model::Guest->update(\%param, {'g_id' => $g_id});

        }

        $self->redirect_to('/admin/guestbook/p/'.$page);

        return 1;
    }

    if ($ac eq 'del') {

        my $del = TestApp::Model::Guest->delete(
                {'g_id' => $self->param('g_id')}
            );

        $self->redirect_to('/admin/guestbook');

    }
}

1;