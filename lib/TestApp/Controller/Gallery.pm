package TestApp::Controller::Gallery;

use strict;
use warnings;

use base 'Mojolicious::Controller';
use Mojo::ByteStream 'b';
use Mojo::Util qw`decode encode html_unescape`;

use Data::Dumper;

# get all gallery
sub show {
    my $self = shift;

    my ($db, %var, $page, %limit, $html);

    $page = $self->stash('num');
    $self->stash('page' => $page);

    $limit{'beg'} = ($page - 1) * $ENV{ITEMS_ON_PAGE};
    $limit{'end'} = $ENV{ITEMS_ON_PAGE};
    $limit{'str'} = 'LIMIT ' . $limit{'beg'} . ', ' . $limit{'end'};

    my $cc = TestApp::Model::Gallery->select('count(g_id)', "g_publish='1'")->list;

    if ($cc > 0) {

        if ( ($cc / $ENV{ITEMS_ON_PAGE}) <= 1) {
            $self->stash('pages' => 0);
        } else {
            $self->stash('pages' => int($cc / $ENV{ITEMS_ON_PAGE}) + 1);
        }

        # $html = TestApp::Model::Gallery->select('*', '', ['g_id DESC ' . $limit{'str'}])->hashes;
        $html = TestApp::Model::Base->select_join(
                        'gallery as g join users as u ON (g.g_author_id=u.u_id)',
                        'g.*, u.u_login', "g.g_publish='1'",
                        'g_id DESC ' . $limit{'str'}
                        )->hashes;

        if ($html) {

            foreach (@$html) {
                my ($second, $minute, $hour, $mday, $month, $year, $wday) = localtime($_->{'g_create'});
                $_->{'g_create'} = sprintf(
                    '%02d.%02d.%04d %02d:%02d',
                    $mday, $month+1, $year+1900, $hour, $minute
                );
            } 

        } else {
            $html = undef;
        }

    } else {
        $self->stash('pages' => 0);
        $html = undef;
    }

    $self->render(var => $html);
}

# show gallery detail
sub preview {
    my $self = shift;

    TestApp::Model->init_bbcode();
    my ($count, $gal, $photos, $g_id, $mes);

    $g_id = $self->stash('id');

    my $cc = TestApp::Model::Photos->select('count(p_id)', 'g_id=\''.$g_id.'\'', '')->list;

    if ($cc > 0) {
            # update previews count
            $photos = TestApp::Model::Photos->select('', 'g_id=\''.$g_id.'\'', '')->hashes;
            $gal = TestApp::Model::Gallery->select('', 'g_id=\''.$g_id.'\'', '')->hash;
            $mes = 'Альбом: ' . $gal->{'g_title'};
    } else {
        $photos = undef;
        $gal = TestApp::Model::Gallery->select('', 'g_id=\''.$g_id.'\'', '')->hash;
    }

    # comments
    my $comments;
    
    $cc = TestApp::Model::Comments->select('count(c_id)', 'c_g_id=\'' . $g_id . '\'', '')->list;
    
    if ($cc > 0) {
        $comments = TestApp::Model::Base->select_join(
            'comments as c, gallery as g, users as u',
            'c.*, u.u_login, u.u_avatar', 
            'c.c_u_id=u.u_id and c.c_g_id=g.g_id and c.c_g_id=\''.$g_id.'\'', 
            'c.c_id'
        )->hashes;

        foreach (@$comments) {
            $_->{'c_comment'} = TestApp::Model::BBCode->pars_html($_->{'c_comment'}) if $_->{'c_comment'};
            html_unescape $_->{'c_comment'} if $_->{'c_comment'};
            my ($second, $minute, $hour, $mday, $month, $year, $wday) = localtime($_->{'c_create'});
            $_->{'c_create'} = sprintf(
                    '%02d.%02d.%04d %02d:%02d',
                    $mday, $month+1, $year+1900, $hour, $minute
            );
        }

    } else {
        $comments = undef;
    }

    $self->render(
                'message' => $mes,
                'var' => $gal,
                'photos' => $photos,
                'comments' => $comments,
    );

    return 1;
}

sub add_comment {
    my $self = shift;

    my $g_id = $self->stash('id');
    my %var;

    my $cc = TestApp::Model::Gallery->select('count(g_id)', 'g_id=\''.$g_id.'\'', '')->list;

    if ($cc > 0) {
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
        $var{'c_id'}        = undef;
        $var{'c_comment'}   = $self->param('g_comment');
        $var{'c_a_id'}      = q``;
        $var{'c_g_id'}      = $g_id;
        $var{'c_u_id'}      = $self->stash('USER')->{'u_id'};
        $var{'c_create'}    = time; #sprintf('%04d-%02d-%02d %02d:%02d', $year+1900, $mon+1, $mday, $hour, $min);
        $var{'c_update'}    = q``;

        TestApp::Model::Comments->insert(\%var);

        $self->redirect_to('/gallery/preview/' . $g_id);
        return 1;
    }
    $self->redirect_to('/gallery');
}

1;
__END__